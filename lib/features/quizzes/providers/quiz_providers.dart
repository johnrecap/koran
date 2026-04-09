import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_history_repository.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_mistake_repository.dart';
import 'package:quran_kareem/features/quizzes/data/verse_completion_generator.dart';
import 'package:quran_kareem/features/quizzes/data/verse_topic_generator.dart';
import 'package:quran_kareem/features/quizzes/data/word_meaning_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/adaptive_difficulty_engine.dart';
import 'package:quran_kareem/features/quizzes/domain/question_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_mistake_models.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

final quizNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final quizHistoryRepositoryProvider = Provider<QuizHistoryRepository>(
  (ref) => QuizHistoryRepository(),
);

final quizMistakeRepositoryProvider = Provider<QuizMistakeRepository>(
  (ref) => QuizMistakeRepository(),
);

final verseCompletionGeneratorProvider = Provider<QuestionGenerator>(
  (ref) => VerseCompletionGenerator(),
);

final wordMeaningGeneratorProvider = Provider<QuestionGenerator>(
  (ref) => WordMeaningGenerator(),
);

final verseTopicGeneratorProvider = Provider<QuestionGenerator>(
  (ref) => VerseTopicGenerator(),
);

final quizQuestionGeneratorProvider = Provider.family<QuestionGenerator, QuizType>(
  (ref, quizType) {
    return switch (quizType) {
      QuizType.verseCompletion => ref.watch(verseCompletionGeneratorProvider),
      QuizType.wordMeaning => ref.watch(wordMeaningGeneratorProvider),
      QuizType.verseTopic => ref.watch(verseTopicGeneratorProvider),
    };
  },
);

final quizTypeAvailabilityProvider = FutureProvider<Map<QuizType, bool>>((
  ref,
) async {
  final results = await Future.wait(
    QuizType.values.map((quizType) async {
      final generator = ref.read(quizQuestionGeneratorProvider(quizType));
      return MapEntry(quizType, await generator.isAvailable());
    }),
  );

  return <QuizType, bool>{
    for (final result in results) result.key: result.value,
  };
});

final quizHistoryProvider =
    FutureProvider.family<List<QuizHistoryEntry>, QuizType>((ref, quizType) {
  final repository = ref.read(quizHistoryRepositoryProvider);
  return repository.getHistory(quizType);
});

final quizMistakesProvider =
    FutureProvider.family<List<QuizMistakeEntry>, QuizType>((ref, quizType) {
  final repository = ref.read(quizMistakeRepositoryProvider);
  return repository.getMistakes(quizType);
});

final quizMistakeCountsProvider = FutureProvider<Map<QuizType, int>>((ref) async {
  final repository = ref.read(quizMistakeRepositoryProvider);
  final results = await Future.wait(
    QuizType.values.map((quizType) async {
      return MapEntry(quizType, await repository.getMistakeCount(quizType));
    }),
  );

  return <QuizType, int>{
    for (final result in results) result.key: result.value,
  };
});

final quizResultProvider = StateProvider<QuizResult?>((ref) => null);

final quizSessionProvider =
    StateNotifierProvider<QuizSessionNotifier, QuizSessionState?>((ref) {
  return QuizSessionNotifier(ref);
});

class QuizSessionState {
  const QuizSessionState({
    required this.config,
    required this.currentQuestionIndex,
    required this.currentQuestion,
    required this.answers,
    required this.isComplete,
    required this.currentDifficulty,
    this.isCurrentQuestionAnswered = false,
  });

  final QuizSessionConfig config;
  final int currentQuestionIndex;
  final QuizQuestion? currentQuestion;
  final List<QuizAnswer> answers;
  final bool isComplete;
  final QuizDifficulty currentDifficulty;
  final bool isCurrentQuestionAnswered;

  QuizSessionState copyWith({
    QuizSessionConfig? config,
    int? currentQuestionIndex,
    QuizQuestion? currentQuestion,
    bool clearCurrentQuestion = false,
    List<QuizAnswer>? answers,
    bool? isComplete,
    QuizDifficulty? currentDifficulty,
    bool? isCurrentQuestionAnswered,
  }) {
    return QuizSessionState(
      config: config ?? this.config,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentQuestion: clearCurrentQuestion
          ? null
          : (currentQuestion ?? this.currentQuestion),
      answers: answers ?? this.answers,
      isComplete: isComplete ?? this.isComplete,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      isCurrentQuestionAnswered:
          isCurrentQuestionAnswered ?? this.isCurrentQuestionAnswered,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState?> {
  QuizSessionNotifier(this.ref) : super(null);

  final Ref ref;

  AdaptiveDifficultyEngine? _difficultyEngine;
  QuestionGenerator? _generator;
  QuizQuestion? _queuedQuestion;
  final List<QuizQuestion> _askedQuestions = <QuizQuestion>[];
  final Set<String> _seenQuestionKeys = <String>{};
  List<QuizMistakeEntry> _pendingMistakeEntries = const <QuizMistakeEntry>[];
  Set<int> _mistakeQuestionIndexes = const <int>{};

  Future<void> startSession(QuizSessionConfig config) async {
    ref.read(quizResultProvider.notifier).state = null;

    _difficultyEngine = AdaptiveDifficultyEngine(config.difficulty);
    _generator = ref.read(quizQuestionGeneratorProvider(config.quizType));
    _queuedQuestion = null;
    _askedQuestions.clear();
    _seenQuestionKeys.clear();

    final mistakeRepository = ref.read(quizMistakeRepositoryProvider);
    final persistedMistakes = await mistakeRepository.getMistakes(config.quizType);
    _pendingMistakeEntries = _filterMistakesForConfig(
      persistedMistakes,
      surahFilter: config.surahFilter,
    );
    _mistakeQuestionIndexes = _buildMistakeQuestionIndexes(
      totalQuestions: config.questionCount,
      availableMistakes: _pendingMistakeEntries.length,
    );

    final firstQuestion = await _loadQuestionForIndex(
      questionIndex: 0,
      config: config,
      difficulty: config.difficulty,
    );

    if (firstQuestion == null) {
      state = null;
      return;
    }

    _registerDisplayedQuestion(firstQuestion);
    state = QuizSessionState(
      config: config,
      currentQuestionIndex: 0,
      currentQuestion: firstQuestion,
      answers: const <QuizAnswer>[],
      isComplete: false,
      currentDifficulty: config.difficulty,
    );
  }

  Future<void> submitAnswer(int selectedIndex) async {
    final currentState = state;
    final currentQuestion = currentState?.currentQuestion;
    if (currentState == null ||
        currentQuestion == null ||
        currentState.isComplete ||
        currentState.isCurrentQuestionAnswered) {
      return;
    }

    final isCorrect = selectedIndex == currentQuestion.correctIndex;
    final nextDifficulty = _recordDifficultyAfterAnswer(
      currentState: currentState,
      isCorrect: isCorrect,
    );
    final updatedAnswers = <QuizAnswer>[
      ...currentState.answers,
      QuizAnswer(
        questionIndex: currentState.currentQuestionIndex,
        selectedIndex: selectedIndex,
        isCorrect: isCorrect,
        difficulty: currentQuestion.difficulty,
      ),
    ];

    if (updatedAnswers.length >= currentState.config.questionCount) {
      await completeSession(
        answersOverride: updatedAnswers,
        difficultyOverride: nextDifficulty,
      );
      return;
    }

    _queuedQuestion = await _loadQuestionForIndex(
      questionIndex: currentState.currentQuestionIndex + 1,
      config: currentState.config,
      difficulty: nextDifficulty,
    );

    if (_queuedQuestion == null) {
      await completeSession(
        answersOverride: updatedAnswers,
        difficultyOverride: nextDifficulty,
      );
      return;
    }

    state = currentState.copyWith(
      answers: updatedAnswers,
      currentDifficulty: nextDifficulty,
      isCurrentQuestionAnswered: true,
    );
  }

  Future<void> moveToNextQuestion() async {
    final currentState = state;
    final queuedQuestion = _queuedQuestion;
    if (currentState == null ||
        currentState.isComplete ||
        !currentState.isCurrentQuestionAnswered ||
        queuedQuestion == null) {
      return;
    }

    _registerDisplayedQuestion(queuedQuestion);
    _queuedQuestion = null;

    state = currentState.copyWith(
      currentQuestionIndex: currentState.currentQuestionIndex + 1,
      currentQuestion: queuedQuestion,
      isCurrentQuestionAnswered: false,
    );
  }

  Future<QuizResult?> completeSession({
    List<QuizAnswer>? answersOverride,
    QuizDifficulty? difficultyOverride,
  }) async {
    final currentState = state;
    if (currentState == null) {
      return null;
    }

    final result = QuizResult(
      config: currentState.config,
      questions: List<QuizQuestion>.unmodifiable(_askedQuestions),
      answers: List<QuizAnswer>.unmodifiable(
        answersOverride ?? currentState.answers,
      ),
      completedAt: ref.read(quizNowProvider)(),
    );

    ref.read(quizResultProvider.notifier).state = result;
    _queuedQuestion = null;
    state = currentState.copyWith(
      answers: answersOverride ?? currentState.answers,
      currentDifficulty: difficultyOverride ?? currentState.currentDifficulty,
      isComplete: true,
      isCurrentQuestionAnswered: false,
      clearCurrentQuestion: true,
    );

    return result;
  }

  void discardSession() {
    _difficultyEngine = null;
    _generator = null;
    _queuedQuestion = null;
    _askedQuestions.clear();
    _seenQuestionKeys.clear();
    _pendingMistakeEntries = const <QuizMistakeEntry>[];
    _mistakeQuestionIndexes = const <int>{};
    ref.read(quizResultProvider.notifier).state = null;
    state = null;
  }

  QuizDifficulty _recordDifficultyAfterAnswer({
    required QuizSessionState currentState,
    required bool isCorrect,
  }) {
    if (!currentState.config.adaptiveDifficulty || _difficultyEngine == null) {
      return currentState.currentDifficulty;
    }

    _difficultyEngine!.recordAnswer(isCorrect);
    return _difficultyEngine!.currentDifficulty;
  }

  Future<QuizQuestion?> _loadQuestionForIndex({
    required int questionIndex,
    required QuizSessionConfig config,
    required QuizDifficulty difficulty,
  }) async {
    if (_mistakeQuestionIndexes.contains(questionIndex)) {
      final mistakeQuestion = _takeNextMistakeQuestion(
        difficultyOverride: difficulty,
      );
      if (mistakeQuestion != null) {
        return mistakeQuestion;
      }
    }

    final generatedQuestion = await _generateUnseenQuestion(
      config: config,
      difficulty: difficulty,
    );
    if (generatedQuestion != null) {
      return generatedQuestion;
    }

    return _takeNextMistakeQuestion(
      difficultyOverride: difficulty,
    );
  }

  Future<QuizQuestion?> _generateUnseenQuestion({
    required QuizSessionConfig config,
    required QuizDifficulty difficulty,
  }) async {
    final generator = _generator;
    if (generator == null) {
      return null;
    }

    final generatedQuestions = await generator.generate(
      count: config.questionCount * 3,
      difficulty: difficulty,
      surahFilter: config.surahFilter,
    );

    for (final question in generatedQuestions) {
      if (_seenQuestionKeys.contains(quizQuestionKeyFor(question))) {
        continue;
      }
      return question;
    }

    return null;
  }

  QuizQuestion? _takeNextMistakeQuestion({
    required QuizDifficulty difficultyOverride,
  }) {
    while (_pendingMistakeEntries.isNotEmpty) {
      final entry = _pendingMistakeEntries.first;
      _pendingMistakeEntries = _pendingMistakeEntries.sublist(1);

      final question = rebuildQuizQuestionFromMistake(
        entry,
        difficultyOverride: difficultyOverride,
      );
      if (question == null) {
        continue;
      }
      if (_seenQuestionKeys.contains(quizQuestionKeyFor(question))) {
        continue;
      }
      return question;
    }

    return null;
  }

  List<QuizMistakeEntry> _filterMistakesForConfig(
    List<QuizMistakeEntry> entries, {
    int? surahFilter,
  }) {
    if (surahFilter == null) {
      return List<QuizMistakeEntry>.from(entries);
    }

    return entries.where((entry) {
      final surahNumber = _readInt(entry.questionMetadata['surahNumber']);
      return surahNumber == surahFilter;
    }).toList(growable: false);
  }

  Set<int> _buildMistakeQuestionIndexes({
    required int totalQuestions,
    required int availableMistakes,
  }) {
    final maxMistakeQuestions = (totalQuestions * 3) ~/ 10;
    final mistakeQuestionCount = availableMistakes < maxMistakeQuestions
        ? availableMistakes
        : maxMistakeQuestions;

    if (mistakeQuestionCount <= 0) {
      return const <int>{};
    }

    final indexes = <int>{};
    for (var index = 0; index < mistakeQuestionCount; index += 1) {
      indexes.add((index * totalQuestions) ~/ mistakeQuestionCount);
    }
    return indexes;
  }

  void _registerDisplayedQuestion(QuizQuestion question) {
    _askedQuestions.add(question);
    _seenQuestionKeys.add(quizQuestionKeyFor(question));
  }
}

String quizQuestionKeyFor(QuizQuestion question) {
  return switch (question) {
    VerseCompletionQuestion() =>
      'vc:${question.surahNumber}:${question.ayahNumber}',
    WordMeaningQuestion() =>
      'wm:${question.surahNumber}:${question.ayahNumber}:${question.word}',
    VerseTopicQuestion() =>
      'vt:${question.surahNumber}:${question.ayahNumber}:${question.topicId}',
  };
}

QuizMistakeEntry buildQuizMistakeEntry({
  required QuizType quizType,
  required QuizQuestion question,
  int correctStreak = 0,
  DateTime? attemptedAt,
}) {
  return QuizMistakeEntry(
    questionKey: quizQuestionKeyFor(question),
    quizType: quizType,
    questionMetadata: _questionMetadataFromQuestion(question),
    correctStreak: correctStreak,
    lastAttemptedAt: attemptedAt ?? DateTime.now(),
  );
}

QuizQuestion? rebuildQuizQuestionFromMistake(
  QuizMistakeEntry entry, {
  QuizDifficulty? difficultyOverride,
}) {
  final metadata = entry.questionMetadata;
  final prompt = metadata['prompt'] as String?;
  final correctIndex = _readInt(metadata['correctIndex']);
  final surahNumber = _readInt(metadata['surahNumber']);
  final ayahNumber = _readInt(metadata['ayahNumber']);
  final choices = _readChoices(metadata['choices']);
  final difficultyName = metadata['difficulty'] as String?;
  final difficulty = difficultyOverride ??
      _difficultyFromName(difficultyName) ??
      QuizDifficulty.medium;
  final questionKind = metadata['questionKind'] as String?;

  if (prompt == null ||
      correctIndex == null ||
      surahNumber == null ||
      ayahNumber == null ||
      choices == null ||
      correctIndex < 0 ||
      correctIndex >= choices.length) {
    return null;
  }

  return switch (questionKind) {
    'verseCompletion' => VerseCompletionQuestion(
        prompt: prompt,
        choices: choices,
        correctIndex: correctIndex,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        difficulty: difficulty,
        fullVerse: metadata['fullVerse'] as String? ?? '',
      ),
    'wordMeaning' => WordMeaningQuestion(
        prompt: prompt,
        choices: choices,
        correctIndex: correctIndex,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        difficulty: difficulty,
        word: metadata['word'] as String? ?? prompt,
      ),
    'verseTopic' => VerseTopicQuestion(
        prompt: prompt,
        choices: choices,
        correctIndex: correctIndex,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        difficulty: difficulty,
        topicId: metadata['topicId'] as String? ?? '',
      ),
    _ => null,
  };
}

Map<String, dynamic> _questionMetadataFromQuestion(QuizQuestion question) {
  final base = <String, dynamic>{
    'prompt': question.prompt,
    'choices': question.choices,
    'correctIndex': question.correctIndex,
    'surahNumber': question.surahNumber,
    'ayahNumber': question.ayahNumber,
    'difficulty': question.difficulty.name,
  };

  return switch (question) {
    VerseCompletionQuestion() => <String, dynamic>{
        ...base,
        'questionKind': 'verseCompletion',
        'fullVerse': question.fullVerse,
      },
    WordMeaningQuestion() => <String, dynamic>{
        ...base,
        'questionKind': 'wordMeaning',
        'word': question.word,
      },
    VerseTopicQuestion() => <String, dynamic>{
        ...base,
        'questionKind': 'verseTopic',
        'topicId': question.topicId,
      },
  };
}

List<String>? _readChoices(Object? value) {
  if (value is! List) {
    return null;
  }

  return value.map((item) => item.toString()).toList(growable: false);
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

QuizDifficulty? _difficultyFromName(String? value) {
  for (final difficulty in QuizDifficulty.values) {
    if (difficulty.name == value) {
      return difficulty;
    }
  }

  return null;
}
