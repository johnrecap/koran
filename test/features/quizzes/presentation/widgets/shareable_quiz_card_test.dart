import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/shareable_quiz_card.dart';

void main() {
  testWidgets(
      'renders prompt, color-coded choices, verse reference, branding, and a solid background',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: ShareableQuizCard(
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
            difficulty: QuizDifficulty.medium,
            fullVerse: 'وَالضُّحَى وَاللَّيْلِ إِذَا سَجَى',
          ),
          answer: const QuizAnswer(
            questionIndex: 0,
            selectedIndex: 2,
            isCorrect: false,
            difficulty: QuizDifficulty.medium,
          ),
          surahName: 'Ad-Duhaa',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quiz-shareable-card-branding')), findsOneWidget);
    expect(find.text('Quran Kareem'), findsNWidgets(2));
    expect(find.text('وَالضُّحَى'), findsOneWidget);
    expect(find.text('وَاللَّيْلِ إِذَا سَجَى'), findsOneWidget);
    expect(find.text('مَا وَدَّعَكَ'), findsOneWidget);
    expect(find.text('وَلَلْآخِرَةُ خَيْرٌ لَّكَ'), findsOneWidget);
    expect(find.text('فَأَمَّا الْيَتِيمَ'), findsOneWidget);
    expect(find.text('Surah Ad-Duhaa • Ayah 1'), findsOneWidget);

    final surface = tester.widget<Container>(
      find.byKey(const Key('quiz-shareable-card-surface')),
    );
    expect(
      (surface.decoration as BoxDecoration).color,
      AppColors.surfaceLight,
    );

    final correctChoice = tester.widget<Container>(
      find.byKey(const Key('quiz-shareable-card-choice-0-panel')),
    );
    final selectedWrongChoice = tester.widget<Container>(
      find.byKey(const Key('quiz-shareable-card-choice-2-panel')),
    );

    expect(
      (correctChoice.decoration as BoxDecoration).color,
      AppColors.success.withValues(alpha: 0.12),
    );
    expect(
      (selectedWrongChoice.decoration as BoxDecoration).color,
      AppColors.error.withValues(alpha: 0.12),
    );
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
      body: Center(
        child: SizedBox(
          width: 380,
          child: child,
        ),
      ),
    ),
  );
}
