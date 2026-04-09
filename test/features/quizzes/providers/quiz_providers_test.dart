import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_history_repository.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_mistake_repository.dart';
import 'package:quran_kareem/features/quizzes/domain/question_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_mistake_models.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';

void main() {
  group('QuizSessionNotifier', () {
    test('startSession initializes state and generates the first question', () async {
      final generator = _FakeQuestionGenerator(
        questionsByDifficulty: <QuizDifficulty, List<QuizQuestion>>{
          QuizDifficulty.medium: <QuizQuestion>[
            _verseQuestion(
              questionId: 'm1',
              surahNumber: 2,
              ayahNumber: 1,
              difficulty: QuizDifficulty.medium,
            ),
          ],
        },
      );

      final container = ProviderContainer(
        overrides: [
          verseCompletionGeneratorProvider.overrideWithValue(generator),
          wordMeaningGeneratorProvider.overrideWithValue(generator),
          verseTopicGeneratorProvider.overrideWithValue(generator),
          quizMistakeRepositoryProvider.overrideWithValue(_FakeMistakeRepository()),
        ],
      );
      addTearDown(container.dispose);

      const config = QuizSessionConfig(
        quizType: QuizType.verseCompletion,
        questionCount: 1,
      );

      await container.read(quizSessionProvider.notifier).startSession(config);
      final state = container.read(quizSessionProvider);

      expect(state, isNotNull);
      expect(state!.config.quizType, QuizType.verseCompletion);
      expect(state.currentQuestionIndex, 0);
      expect(state.currentQuestion?.prompt, 'prompt-m1');
      expect(state.answers, isEmpty);
      expect(state.currentDifficulty, QuizDifficulty.medium);
      expect(container.read(quizResultProvider), isNull);
    });

    test(
        'submitAnswer records answers, adapts difficulty, and prepares the next question at the new difficulty',
        () async {
      final generator = _FakeQuestionGenerator(
        questionsByDifficulty: <QuizDifficulty, List<QuizQuestion>>{
          QuizDifficulty.medium: <QuizQuestion>[
            _verseQuestion(
              questionId: 'm1',
              surahNumber: 2,
              ayahNumber: 1,
              difficulty: QuizDifficulty.medium,
            ),
            _verseQuestion(
              questionId: 'm2',
              surahNumber: 2,
              ayahNumber: 2,
              difficulty: QuizDifficulty.medium,
            ),
            _verseQuestion(
              questionId: 'm3',
              surahNumber: 2,
              ayahNumber: 3,
              difficulty: QuizDifficulty.medium,
            ),
          ],
          QuizDifficulty.hard: <QuizQuestion>[
            _verseQuestion(
              questionId: 'h1',
              surahNumber: 2,
              ayahNumber: 4,
              difficulty: QuizDifficulty.hard,
            ),
          ],
        },
      );

      final container = ProviderContainer(
        overrides: [
          verseCompletionGeneratorProvider.overrideWithValue(generator),
          wordMeaningGeneratorProvider.overrideWithValue(generator),
          verseTopicGeneratorProvider.overrideWithValue(generator),
          quizMistakeRepositoryProvider.overrideWithValue(_FakeMistakeRepository()),
        ],
      );
      addTearDown(container.dispose);

      const config = QuizSessionConfig(
        quizType: QuizType.verseCompletion,
        questionCount: 4,
      );

      final notifier = container.read(quizSessionProvider.notifier);
      await notifier.startSession(config);

      await notifier.submitAnswer(0);
      await notifier.moveToNextQuestion();
      await notifier.submitAnswer(0);
      await notifier.moveToNextQuestion();
      await notifier.submitAnswer(0);

      final stateAfterThirdAnswer = container.read(quizSessionProvider)!;

      expect(stateAfterThirdAnswer.answers, hasLength(3));
      expect(stateAfterThirdAnswer.currentDifficulty, QuizDifficulty.hard);
      expect(stateAfterThirdAnswer.isCurrentQuestionAnswered, isTrue);
      expect(generator.requestedDifficulties, contains(QuizDifficulty.hard));

      await notifier.moveToNextQuestion();

      final advancedState = container.read(quizSessionProvider)!;

      expect(advancedState.currentQuestionIndex, 3);
      expect(advancedState.currentQuestion?.difficulty, QuizDifficulty.hard);
      expect(advancedState.currentQuestion?.prompt, 'prompt-h1');
      expect(advancedState.isCurrentQuestionAnswered, isFalse);
    });

    test('mixes mistake-pool questions up to thirty percent of the session', () async {
      final generator = _FakeQuestionGenerator(
        questionsByDifficulty: <QuizDifficulty, List<QuizQuestion>>{
          QuizDifficulty.medium: List<QuizQuestion>.generate(
            10,
            (index) => _verseQuestion(
              questionId: 'g$index',
              surahNumber: 2,
              ayahNumber: 100 + index,
              difficulty: QuizDifficulty.medium,
            ),
          ),
        },
      );
      final mistakeRepository = _FakeMistakeRepository(
        mistakesByType: <QuizType, List<QuizMistakeEntry>>{
          QuizType.verseCompletion: List<QuizMistakeEntry>.generate(
            5,
            (index) => _verseMistake(
              questionId: 'mistake$index',
              surahNumber: 2,
              ayahNumber: 200 + index,
            ),
          ),
        },
      );

      final container = ProviderContainer(
        overrides: [
          verseCompletionGeneratorProvider.overrideWithValue(generator),
          wordMeaningGeneratorProvider.overrideWithValue(generator),
          verseTopicGeneratorProvider.overrideWithValue(generator),
          quizMistakeRepositoryProvider.overrideWithValue(mistakeRepository),
        ],
      );
      addTearDown(container.dispose);

      const config = QuizSessionConfig(
        quizType: QuizType.verseCompletion,
        questionCount: 10,
        adaptiveDifficulty: false,
      );

      final notifier = container.read(quizSessionProvider.notifier);
      await notifier.startSession(config);

      final seenKeys = <String>[];
      while (true) {
        final state = container.read(quizSessionProvider);
        if (state == null || state.currentQuestion == null) {
          break;
        }

        seenKeys.add(_questionKey(state.currentQuestion!));
        await notifier.submitAnswer(state.currentQuestion!.correctIndex);

        final nextState = container.read(quizSessionProvider);
        if (nextState == null || nextState.isComplete) {
          break;
        }

        await notifier.moveToNextQuestion();
      }

      final mistakeKeys = {
        for (var index = 0; index < 5; index += 1) 'vc:2:${200 + index}'
      };
      final mistakeQuestionsSeen =
          seenKeys.where(mistakeKeys.contains).length;

      expect(seenKeys, hasLength(10));
      expect(mistakeQuestionsSeen, 3);
    });

    test('completeSession produces QuizResult and blocks further answers', () async {
      final generator = _FakeQuestionGenerator(
        questionsByDifficulty: <QuizDifficulty, List<QuizQuestion>>{
          QuizDifficulty.medium: <QuizQuestion>[
            _verseQuestion(
              questionId: 'm1',
              surahNumber: 2,
              ayahNumber: 1,
              difficulty: QuizDifficulty.medium,
            ),
            _verseQuestion(
              questionId: 'm2',
              surahNumber: 2,
              ayahNumber: 2,
              difficulty: QuizDifficulty.medium,
            ),
          ],
        },
      );

      final container = ProviderContainer(
        overrides: [
          verseCompletionGeneratorProvider.overrideWithValue(generator),
          wordMeaningGeneratorProvider.overrideWithValue(generator),
          verseTopicGeneratorProvider.overrideWithValue(generator),
          quizMistakeRepositoryProvider.overrideWithValue(_FakeMistakeRepository()),
          quizNowProvider.overrideWith((ref) => () => DateTime(2026, 4, 6, 12)),
        ],
      );
      addTearDown(container.dispose);

      const config = QuizSessionConfig(
        quizType: QuizType.verseCompletion,
        questionCount: 2,
      );

      final notifier = container.read(quizSessionProvider.notifier);
      await notifier.startSession(config);
      await notifier.submitAnswer(1);
      await notifier.moveToNextQuestion();
      await notifier.submitAnswer(0);

      final state = container.read(quizSessionProvider)!;
      final result = container.read(quizResultProvider);

      expect(state.isComplete, isTrue);
      expect(state.currentQuestion, isNull);
      expect(result, isNotNull);
      expect(result!.score, 1);
      expect(result.totalQuestions, 2);
      expect(result.completedAt, DateTime(2026, 4, 6, 12));

      await notifier.submitAnswer(0);

      expect(container.read(quizSessionProvider)!.answers, hasLength(2));
      expect(container.read(quizResultProvider)!.score, 1);
    });
  });

  group('quiz providers', () {
    test('availability, history, and mistake count providers read the backing sources',
        () async {
      final availableGenerator = _FakeQuestionGenerator(
        questionsByDifficulty: <QuizDifficulty, List<QuizQuestion>>{
          QuizDifficulty.medium: <QuizQuestion>[
            _verseQuestion(
              questionId: 'available',
              surahNumber: 1,
              ayahNumber: 1,
              difficulty: QuizDifficulty.medium,
            ),
          ],
        },
        isAvailableResult: true,
      );
      final unavailableGenerator = _FakeQuestionGenerator(
        questionsByDifficulty: const <QuizDifficulty, List<QuizQuestion>>{},
        isAvailableResult: false,
      );
      final historyRepository = _FakeHistoryRepository(
        historyByType: <QuizType, List<QuizHistoryEntry>>{
          QuizType.wordMeaning: <QuizHistoryEntry>[
            QuizHistoryEntry(
              quizType: QuizType.wordMeaning,
              score: 7,
              totalQuestions: 10,
              difficulty: QuizDifficulty.medium,
              surahFilter: null,
              completedAt: DateTime(2026, 4, 6, 9),
            ),
          ],
        },
      );
      final mistakeRepository = _FakeMistakeRepository(
        mistakesByType: <QuizType, List<QuizMistakeEntry>>{
          QuizType.verseCompletion: <QuizMistakeEntry>[
            _verseMistake(
              questionId: 'mistake',
              surahNumber: 2,
              ayahNumber: 255,
            ),
          ],
        },
      );

      final container = ProviderContainer(
        overrides: [
          verseCompletionGeneratorProvider.overrideWithValue(availableGenerator),
          wordMeaningGeneratorProvider.overrideWithValue(unavailableGenerator),
          verseTopicGeneratorProvider.overrideWithValue(unavailableGenerator),
          quizHistoryRepositoryProvider.overrideWithValue(historyRepository),
          quizMistakeRepositoryProvider.overrideWithValue(mistakeRepository),
        ],
      );
      addTearDown(container.dispose);

      final availability =
          await container.read(quizTypeAvailabilityProvider.future);
      final history = await container.read(
        quizHistoryProvider(QuizType.wordMeaning).future,
      );
      final mistakeCounts =
          await container.read(quizMistakeCountsProvider.future);

      expect(availability[QuizType.verseCompletion], isTrue);
      expect(availability[QuizType.wordMeaning], isFalse);
      expect(history, hasLength(1));
      expect(history.single.score, 7);
      expect(mistakeCounts[QuizType.verseCompletion], 1);
      expect(mistakeCounts[QuizType.wordMeaning], 0);
    });
  });
}

VerseCompletionQuestion _verseQuestion({
  required String questionId,
  required int surahNumber,
  required int ayahNumber,
  required QuizDifficulty difficulty,
}) {
  return VerseCompletionQuestion(
    prompt: 'prompt-$questionId',
    choices: <String>[
      'correct-$questionId',
      'wrong-a-$questionId',
      'wrong-b-$questionId',
      'wrong-c-$questionId',
    ],
    correctIndex: 0,
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    difficulty: difficulty,
    fullVerse: 'full-$questionId',
  );
}

QuizMistakeEntry _verseMistake({
  required String questionId,
  required int surahNumber,
  required int ayahNumber,
}) {
  return QuizMistakeEntry(
    questionKey: 'vc:$surahNumber:$ayahNumber',
    quizType: QuizType.verseCompletion,
    questionMetadata: <String, dynamic>{
      'questionKind': 'verseCompletion',
      'prompt': 'prompt-$questionId',
      'choices': <String>[
        'correct-$questionId',
        'wrong-a-$questionId',
        'wrong-b-$questionId',
        'wrong-c-$questionId',
      ],
      'correctIndex': 0,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'difficulty': QuizDifficulty.medium.name,
      'fullVerse': 'full-$questionId',
    },
    lastAttemptedAt: DateTime(2026, 4, 6, 10),
  );
}

String _questionKey(QuizQuestion question) {
  return switch (question) {
    VerseCompletionQuestion() =>
      'vc:${question.surahNumber}:${question.ayahNumber}',
    WordMeaningQuestion() =>
      'wm:${question.surahNumber}:${question.ayahNumber}:${question.word}',
    VerseTopicQuestion() =>
      'vt:${question.surahNumber}:${question.ayahNumber}:${question.topicId}',
  };
}

class _FakeQuestionGenerator implements QuestionGenerator {
  _FakeQuestionGenerator({
    required this.questionsByDifficulty,
    this.isAvailableResult = true,
  });

  final Map<QuizDifficulty, List<QuizQuestion>> questionsByDifficulty;
  final bool isAvailableResult;
  final List<QuizDifficulty> requestedDifficulties = <QuizDifficulty>[];

  @override
  Future<List<QuizQuestion>> generate({
    required int count,
    required QuizDifficulty difficulty,
    int? surahFilter,
  }) async {
    requestedDifficulties.add(difficulty);

    final pool = questionsByDifficulty[difficulty] ?? const <QuizQuestion>[];
    final filtered = surahFilter == null
        ? pool
        : pool
            .where((question) => question.surahNumber == surahFilter)
            .toList(growable: false);

    return filtered.take(count).toList(growable: false);
  }

  @override
  Future<bool> isAvailable({int? surahFilter}) async => isAvailableResult;
}

class _FakeHistoryRepository extends QuizHistoryRepository {
  _FakeHistoryRepository({
    Map<QuizType, List<QuizHistoryEntry>>? historyByType,
  }) : _historyByType = historyByType ?? <QuizType, List<QuizHistoryEntry>>{};

  final Map<QuizType, List<QuizHistoryEntry>> _historyByType;

  @override
  Future<List<QuizHistoryEntry>> getHistory(QuizType type) async {
    return List<QuizHistoryEntry>.from(_historyByType[type] ?? const []);
  }
}

class _FakeMistakeRepository extends QuizMistakeRepository {
  _FakeMistakeRepository({
    Map<QuizType, List<QuizMistakeEntry>>? mistakesByType,
  }) : _mistakesByType =
            mistakesByType ?? <QuizType, List<QuizMistakeEntry>>{};

  final Map<QuizType, List<QuizMistakeEntry>> _mistakesByType;

  @override
  Future<List<QuizMistakeEntry>> getMistakes(QuizType type) async {
    return List<QuizMistakeEntry>.from(_mistakesByType[type] ?? const []);
  }

  @override
  Future<int> getMistakeCount(QuizType type) async {
    return (_mistakesByType[type] ?? const []).length;
  }
}
