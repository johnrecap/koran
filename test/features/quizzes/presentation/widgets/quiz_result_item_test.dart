import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_result_item.dart';

void main() {
  testWidgets(
      'shows incorrect review state with the revealed correct answer, difficulty badge, and full verse toggle',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: QuizResultItem(
          question: VerseCompletionQuestion(
            prompt: 'وَالضُّحَى',
            choices: const <String>[
              'وَاللَّيْلِ إِذَا سَجَى',
              'مَا وَدَّعَكَ',
              'وَلَلْآخِرَةُ خَيْرٌ لَّكَ',
              'فَأَمَّا الْيَتِيمَ',
            ],
            correctIndex: 0,
            surahNumber: 93,
            ayahNumber: 1,
            difficulty: QuizDifficulty.hard,
            fullVerse: 'وَالضُّحَى وَاللَّيْلِ إِذَا سَجَى',
          ),
          answer: const QuizAnswer(
            questionIndex: 0,
            selectedIndex: 2,
            isCorrect: false,
            difficulty: QuizDifficulty.hard,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quiz-difficulty-badge-hard')), findsOneWidget);
    expect(find.text('Your answer'), findsOneWidget);
    expect(find.text('Correct answer'), findsOneWidget);
    expect(find.text('وَلَلْآخِرَةُ خَيْرٌ لَّكَ'), findsOneWidget);
    expect(find.text('وَاللَّيْلِ إِذَا سَجَى'), findsOneWidget);

    final userAnswerPanel = tester.widget<Container>(
      find.byKey(const Key('quiz-result-item-user-answer-panel')),
    );
    final correctAnswerPanel = tester.widget<Container>(
      find.byKey(const Key('quiz-result-item-correct-answer-panel')),
    );

    expect(
      (userAnswerPanel.decoration as BoxDecoration).color,
      AppColors.error.withValues(alpha: 0.10),
    );
    expect(
      (correctAnswerPanel.decoration as BoxDecoration).color,
      AppColors.success.withValues(alpha: 0.10),
    );

    await tester.tap(find.byKey(const Key('quiz-question-view-full-verse-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('وَالضُّحَى وَاللَّيْلِ إِذَا سَجَى'), findsOneWidget);
  });

  testWidgets(
      'shows a single positive review panel when the selected answer is correct',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: QuizResultItem(
          question: WordMeaningQuestion(
            prompt: 'الصمد',
            choices: const <String>[
              'The Eternal Refuge',
              'The Dawn',
              'The Mercy',
              'The Book',
            ],
            correctIndex: 0,
            surahNumber: 112,
            ayahNumber: 2,
            difficulty: QuizDifficulty.easy,
            word: 'الصمد',
          ),
          answer: const QuizAnswer(
            questionIndex: 0,
            selectedIndex: 0,
            isCorrect: true,
            difficulty: QuizDifficulty.easy,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quiz-difficulty-badge-easy')), findsOneWidget);
    expect(find.text('Your answer'), findsOneWidget);
    expect(find.text('Correct answer'), findsNothing);

    final userAnswerPanel = tester.widget<Container>(
      find.byKey(const Key('quiz-result-item-user-answer-panel')),
    );

    expect(
      (userAnswerPanel.decoration as BoxDecoration).color,
      AppColors.success.withValues(alpha: 0.10),
    );
  });

  testWidgets('shows an export action and notifies when tapped', (tester) async {
    var exportTapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        child: QuizResultItem(
          question: WordMeaningQuestion(
            prompt: 'الصمد',
            choices: const <String>[
              'The Eternal Refuge',
              'The Dawn',
              'The Mercy',
              'The Book',
            ],
            correctIndex: 0,
            surahNumber: 112,
            ayahNumber: 2,
            difficulty: QuizDifficulty.easy,
            word: 'الصمد',
          ),
          answer: const QuizAnswer(
            questionIndex: 0,
            selectedIndex: 0,
            isCorrect: true,
            difficulty: QuizDifficulty.easy,
          ),
          onExportTap: () {
            exportTapCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quiz-result-item-export-action')), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-result-item-export-action')));
    await tester.pumpAndSettle();

    expect(exportTapCount, 1);
  });
}

Widget _buildHarness({
  required Widget child,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 380,
            child: child,
          ),
        ),
      ),
    ),
  );
}
