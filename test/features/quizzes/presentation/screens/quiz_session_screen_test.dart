import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_mistake_repository.dart';
import 'package:quran_kareem/features/quizzes/domain/question_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_mistake_models.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/screens/quiz_session_screen.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';

void main() {
  testWidgets(
      'shows progress, updates the difficulty badge, locks answers, and emits the completed result',
      (tester) async {
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

    await container.read(quizSessionProvider.notifier).startSession(
          const QuizSessionConfig(
            quizType: QuizType.verseCompletion,
            questionCount: 4,
          ),
        );

    QuizResult? completedResult;

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: QuizSessionScreen(
          onSessionComplete: (context, result) async {
            completedResult = result;
          },
        ),
      ),
    );
    await _pumpQuizFrame(tester);

    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.byKey(const Key('quiz-difficulty-badge-medium')), findsOneWidget);
    expect(find.text('prompt-m1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-answer-choice-0')));
    await _pumpQuizFrame(tester);

    expect(container.read(quizSessionProvider)!.answers, hasLength(1));
    expect(find.byKey(const Key('quiz-session-next-action')), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-answer-choice-1')));
    await _pumpQuizFrame(tester);

    expect(
      container.read(quizSessionProvider)!.answers.single.selectedIndex,
      0,
    );

    await tester.tap(find.byKey(const Key('quiz-session-next-action')));
    await _pumpQuizFrame(tester);

    expect(find.text('2 / 4'), findsOneWidget);
    expect(find.text('prompt-m2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-answer-choice-0')));
    await _pumpQuizFrame(tester);
    await tester.tap(find.byKey(const Key('quiz-session-next-action')));
    await _pumpQuizFrame(tester);

    expect(find.text('3 / 4'), findsOneWidget);
    expect(find.text('prompt-m3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-answer-choice-0')));
    await _pumpQuizFrame(tester);

    expect(find.byKey(const Key('quiz-difficulty-badge-hard')), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-session-next-action')));
    await _pumpQuizFrame(tester);

    expect(find.text('4 / 4'), findsOneWidget);
    expect(find.text('prompt-h1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-answer-choice-0')));
    await _pumpQuizFrame(tester);

    expect(completedResult, isNotNull);
    expect(completedResult!.score, 4);
    expect(completedResult!.totalQuestions, 4);
  });

  testWidgets('shows an exit confirmation dialog and discards the session',
      (tester) async {
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

    await container.read(quizSessionProvider.notifier).startSession(
          const QuizSessionConfig(
            quizType: QuizType.verseCompletion,
            questionCount: 1,
          ),
        );

    var exitCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: QuizSessionScreen(
          onExitConfirmed: () {
            exitCount += 1;
          },
        ),
      ),
    );
    await _pumpQuizFrame(tester);

    await tester.tap(find.byKey(const Key('quiz-session-exit-action')));
    await _pumpQuizFrame(tester);

    expect(find.text('Exit quiz?'), findsOneWidget);
    expect(find.text('This session will be discarded.'), findsOneWidget);

    await tester.tap(find.text('Stay'));
    await _pumpQuizFrame(tester);

    expect(container.read(quizSessionProvider), isNotNull);
    expect(exitCount, 0);

    await tester.tap(find.byKey(const Key('quiz-session-exit-action')));
    await _pumpQuizFrame(tester);
    await tester.tap(find.text('Exit'));
    await _pumpQuizFrame(tester);

    expect(container.read(quizSessionProvider), isNull);
    expect(exitCount, 1);
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

Future<void> _pumpQuizFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
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

class _FakeQuestionGenerator implements QuestionGenerator {
  _FakeQuestionGenerator({
    required this.questionsByDifficulty,
  });

  final Map<QuizDifficulty, List<QuizQuestion>> questionsByDifficulty;

  @override
  Future<List<QuizQuestion>> generate({
    required int count,
    required QuizDifficulty difficulty,
    int? surahFilter,
  }) async {
    final pool = questionsByDifficulty[difficulty] ?? const <QuizQuestion>[];
    final filtered = surahFilter == null
        ? pool
        : pool
            .where((question) => question.surahNumber == surahFilter)
            .toList(growable: false);
    return filtered.take(count).toList(growable: false);
  }

  @override
  Future<bool> isAvailable({int? surahFilter}) async => true;
}

class _FakeMistakeRepository extends QuizMistakeRepository {
  @override
  Future<List<QuizMistakeEntry>> getMistakes(QuizType type) async {
    return const <QuizMistakeEntry>[];
  }
}
