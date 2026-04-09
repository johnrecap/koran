import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_history_repository.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_mistake_repository.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_mistake_models.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/screens/quiz_result_screen.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';
import 'package:quran_kareem/features/quizzes/utils/quiz_card_image_exporter.dart';

void main() {
  testWidgets('shows the score summary, review list, and result actions',
      (tester) async {
    final historyRepository = _FakeHistoryRepository();
    final mistakeRepository = _FakeMistakeRepository();
    final container = ProviderContainer(
      overrides: [
        quizHistoryRepositoryProvider.overrideWithValue(historyRepository),
        quizMistakeRepositoryProvider.overrideWithValue(mistakeRepository),
      ],
    );
    addTearDown(container.dispose);

    final result = _buildResult(
      config: const QuizSessionConfig(
        quizType: QuizType.verseCompletion,
        questionCount: 4,
        difficulty: QuizDifficulty.hard,
      ),
      questions: <QuizQuestion>[
        _verseQuestion(
          questionId: 'one',
          surahNumber: 2,
          ayahNumber: 1,
          difficulty: QuizDifficulty.medium,
        ),
        _verseQuestion(
          questionId: 'two',
          surahNumber: 2,
          ayahNumber: 2,
          difficulty: QuizDifficulty.hard,
        ),
        _verseQuestion(
          questionId: 'three',
          surahNumber: 2,
          ayahNumber: 3,
          difficulty: QuizDifficulty.hard,
        ),
        _verseQuestion(
          questionId: 'four',
          surahNumber: 2,
          ayahNumber: 4,
          difficulty: QuizDifficulty.hard,
        ),
      ],
      answers: const <QuizAnswer>[
        QuizAnswer(
          questionIndex: 0,
          selectedIndex: 0,
          isCorrect: true,
          difficulty: QuizDifficulty.medium,
        ),
        QuizAnswer(
          questionIndex: 1,
          selectedIndex: 0,
          isCorrect: true,
          difficulty: QuizDifficulty.hard,
        ),
        QuizAnswer(
          questionIndex: 2,
          selectedIndex: 0,
          isCorrect: true,
          difficulty: QuizDifficulty.hard,
        ),
        QuizAnswer(
          questionIndex: 3,
          selectedIndex: 1,
          isCorrect: false,
          difficulty: QuizDifficulty.hard,
        ),
      ],
    );

    QuizSessionConfig? retriedConfig;
    var backToHubCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: QuizResultScreen(
          result: result,
          onTryAgain: (context, config) async {
            retriedConfig = config;
          },
          onBackToHub: () {
            backToHubCount += 1;
          },
        ),
      ),
    );
    await _pumpResultFrame(tester);

    expect(find.text('75%'), findsOneWidget);
    expect(find.text('3 / 4'), findsOneWidget);
    expect(find.text('Very good'), findsOneWidget);
    expect(find.byKey(const Key('quiz-difficulty-badge-hard')), findsOneWidget);
    expect(find.text('prompt-one'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('prompt-four'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await _pumpResultFrame(tester);

    expect(find.text('prompt-four'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await _pumpResultFrame(tester);

    expect(retriedConfig, isNotNull);
    expect(retriedConfig!.quizType, QuizType.verseCompletion);
    expect(retriedConfig!.questionCount, 4);
    expect(retriedConfig!.difficulty, QuizDifficulty.hard);

    await tester.tap(find.text('Back to hub'));
    await _pumpResultFrame(tester);

    expect(backToHubCount, 1);
  });

  testWidgets('renders all four performance tiers', (tester) async {
    final cases = <({int score, int total, String label})>[
      (score: 4, total: 4, label: 'Excellent'),
      (score: 3, total: 4, label: 'Very good'),
      (score: 2, total: 4, label: 'Good start'),
      (score: 1, total: 4, label: 'Keep practicing'),
    ];

    for (final testCase in cases) {
      final container = ProviderContainer(
        overrides: [
          quizHistoryRepositoryProvider.overrideWithValue(
            _FakeHistoryRepository(),
          ),
          quizMistakeRepositoryProvider.overrideWithValue(
            _FakeMistakeRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = _resultWithScore(
        score: testCase.score,
        total: testCase.total,
      );

      await tester.pumpWidget(
        _buildHarness(
          container: container,
          child: QuizResultScreen(result: result),
        ),
      );
      await _pumpResultFrame(tester);

      expect(find.text(testCase.label), findsOneWidget);
    }
  });

  testWidgets('saves history and updates the mistakes pool only once',
      (tester) async {
    final completedAt = DateTime(2026, 4, 6, 18, 45);
    final historyRepository = _FakeHistoryRepository();
    final mistakeRepository = _FakeMistakeRepository(
      mistakesByType: <QuizType, List<QuizMistakeEntry>>{
        QuizType.verseCompletion: <QuizMistakeEntry>[
          QuizMistakeEntry(
            questionKey: 'vc:67:2',
            quizType: QuizType.verseCompletion,
            questionMetadata: <String, dynamic>{
              'questionKind': 'verseCompletion',
              'prompt': 'prompt-known',
              'choices': <String>[
                'correct-known',
                'wrong-a-known',
                'wrong-b-known',
                'wrong-c-known',
              ],
              'correctIndex': 0,
              'surahNumber': 67,
              'ayahNumber': 2,
              'difficulty': QuizDifficulty.medium.name,
              'fullVerse': 'full-known',
            },
            correctStreak: 1,
            lastAttemptedAt: DateTime(2026, 4, 5, 10),
          ),
        ],
      },
    );

    final container = ProviderContainer(
      overrides: [
        quizHistoryRepositoryProvider.overrideWithValue(historyRepository),
        quizMistakeRepositoryProvider.overrideWithValue(mistakeRepository),
      ],
    );
    addTearDown(container.dispose);

    final result = QuizResult(
      config: const QuizSessionConfig(
        quizType: QuizType.verseCompletion,
        questionCount: 2,
        difficulty: QuizDifficulty.medium,
      ),
      questions: <QuizQuestion>[
        _verseQuestion(
          questionId: 'missed',
          surahNumber: 67,
          ayahNumber: 1,
          difficulty: QuizDifficulty.medium,
        ),
        _verseQuestion(
          questionId: 'known',
          surahNumber: 67,
          ayahNumber: 2,
          difficulty: QuizDifficulty.medium,
        ),
      ],
      answers: const <QuizAnswer>[
        QuizAnswer(
          questionIndex: 0,
          selectedIndex: 2,
          isCorrect: false,
          difficulty: QuizDifficulty.medium,
        ),
        QuizAnswer(
          questionIndex: 1,
          selectedIndex: 0,
          isCorrect: true,
          difficulty: QuizDifficulty.medium,
        ),
      ],
      completedAt: completedAt,
    );

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: QuizResultScreen(result: result),
      ),
    );
    await _pumpResultFrame(tester);

    expect(historyRepository.addedEntries, hasLength(1));
    expect(historyRepository.addedEntries.single.score, 1);
    expect(historyRepository.addedEntries.single.totalQuestions, 2);
    expect(historyRepository.addedEntries.single.completedAt, completedAt);

    expect(mistakeRepository.saveCallCount, 1);
    final savedEntries =
        mistakeRepository.savedEntriesByType[QuizType.verseCompletion]!;
    expect(savedEntries, hasLength(1));
    expect(savedEntries.single.questionKey, 'vc:67:1');
    expect(savedEntries.single.correctStreak, 0);
    expect(savedEntries.single.lastAttemptedAt, completedAt);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(historyRepository.addedEntries, hasLength(1));
    expect(mistakeRepository.saveCallCount, 1);
  });

  testWidgets('opens save/share options and saves the selected review card',
      (tester) async {
    final historyRepository = _FakeHistoryRepository();
    final mistakeRepository = _FakeMistakeRepository();
    final exporter = _FakeQuizCardImageExporter(
      saveOutcome: QuizCardImageSaveOutcome.success,
      shareResult: true,
    );
    final container = ProviderContainer(
      overrides: [
        quizHistoryRepositoryProvider.overrideWithValue(historyRepository),
        quizMistakeRepositoryProvider.overrideWithValue(mistakeRepository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: QuizResultScreen(
          result: _resultWithScore(score: 1, total: 1),
          imageExporter: exporter,
          surahNameResolver: _resolveSurahName,
        ),
      ),
    );
    await _pumpResultFrame(tester);

    await tester.tap(find.byKey(const Key('quiz-result-item-export-action')));
    await _pumpResultFrame(tester);

    expect(find.text('Save as image'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);

    await tester.tap(find.text('Save as image'));
    await _pumpResultFrame(tester);

    expect(exporter.captureCallCount, 1);
    expect(exporter.saveCallCount, 1);
    expect(exporter.shareCallCount, 0);
    expect(find.text('Image saved to your photos.'), findsOneWidget);
  });

  testWidgets('shares the selected review card from the result screen',
      (tester) async {
    final historyRepository = _FakeHistoryRepository();
    final mistakeRepository = _FakeMistakeRepository();
    final exporter = _FakeQuizCardImageExporter(
      saveOutcome: QuizCardImageSaveOutcome.success,
      shareResult: true,
    );
    final container = ProviderContainer(
      overrides: [
        quizHistoryRepositoryProvider.overrideWithValue(historyRepository),
        quizMistakeRepositoryProvider.overrideWithValue(mistakeRepository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: QuizResultScreen(
          result: _resultWithScore(score: 1, total: 1),
          imageExporter: exporter,
          surahNameResolver: _resolveSurahName,
        ),
      ),
    );
    await _pumpResultFrame(tester);

    await tester.tap(find.byKey(const Key('quiz-result-item-export-action')));
    await _pumpResultFrame(tester);
    await tester.tap(find.text('Share'));
    await _pumpResultFrame(tester);

    expect(exporter.captureCallCount, 1);
    expect(exporter.saveCallCount, 0);
    expect(exporter.shareCallCount, 1);
  });
}

Widget _buildHarness({
  required ProviderContainer container,
  required Widget child,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

Future<void> _pumpResultFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

QuizResult _buildResult({
  required QuizSessionConfig config,
  required List<QuizQuestion> questions,
  required List<QuizAnswer> answers,
}) {
  return QuizResult(
    config: config,
    questions: questions,
    answers: answers,
    completedAt: DateTime(2026, 4, 6, 17),
  );
}

QuizResult _resultWithScore({
  required int score,
  required int total,
}) {
  final questions = List<QuizQuestion>.generate(
    total,
    (index) => _verseQuestion(
      questionId: 'tier-$index',
      surahNumber: 1,
      ayahNumber: index + 1,
      difficulty: QuizDifficulty.medium,
    ),
  );

  final answers = List<QuizAnswer>.generate(
    total,
    (index) => QuizAnswer(
      questionIndex: index,
      selectedIndex: index < score ? 0 : 1,
      isCorrect: index < score,
      difficulty: QuizDifficulty.medium,
    ),
  );

  return QuizResult(
    config: const QuizSessionConfig(
      quizType: QuizType.verseCompletion,
      questionCount: 4,
    ),
    questions: questions,
    answers: answers,
    completedAt: DateTime(2026, 4, 6, 17),
  );
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

class _FakeHistoryRepository extends QuizHistoryRepository {
  final List<QuizHistoryEntry> addedEntries = <QuizHistoryEntry>[];

  @override
  Future<void> addEntry(QuizHistoryEntry entry) async {
    addedEntries.add(entry);
  }
}

class _FakeMistakeRepository extends QuizMistakeRepository {
  _FakeMistakeRepository({
    Map<QuizType, List<QuizMistakeEntry>>? mistakesByType,
  }) : savedEntriesByType = {
          for (final entry
              in (mistakesByType ?? <QuizType, List<QuizMistakeEntry>>{}).entries)
            entry.key: List<QuizMistakeEntry>.from(entry.value),
        };

  final Map<QuizType, List<QuizMistakeEntry>> savedEntriesByType;
  int saveCallCount = 0;

  @override
  Future<List<QuizMistakeEntry>> getMistakes(QuizType type) async {
    return List<QuizMistakeEntry>.from(
      savedEntriesByType[type] ?? const <QuizMistakeEntry>[],
    );
  }

  @override
  Future<void> saveMistakes(
    QuizType type,
    List<QuizMistakeEntry> entries,
  ) async {
    saveCallCount += 1;
    savedEntriesByType[type] = List<QuizMistakeEntry>.from(entries);
  }
}

class _FakeQuizCardImageExporter extends QuizCardImageExporter {
  _FakeQuizCardImageExporter({
    required this.saveOutcome,
    required this.shareResult,
  });

  final QuizCardImageSaveOutcome saveOutcome;
  final bool shareResult;
  int captureCallCount = 0;
  int saveCallCount = 0;
  int shareCallCount = 0;

  @override
  Future<Uint8List?> captureCard(GlobalKey repaintBoundaryKey) async {
    captureCallCount += 1;
    return Uint8List.fromList(<int>[137, 80, 78, 71, 13, 10, 26, 10, 1, 2]);
  }

  @override
  Future<QuizCardImageSaveOutcome> saveToGallery(
    Uint8List pngBytes,
    String fileName,
  ) async {
    saveCallCount += 1;
    return saveOutcome;
  }

  @override
  Future<bool> shareImage(Uint8List pngBytes, String fileName) async {
    shareCallCount += 1;
    return shareResult;
  }
}

Future<String> _resolveSurahName(int surahNumber) async {
  if (surahNumber == 1) {
    return 'Al-Fatihah';
  }

  return surahNumber.toString();
}
