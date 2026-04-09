import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_question_view.dart';

void main() {
  testWidgets('renders verse completion prompts with Amiri typography and RTL',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: QuizQuestionView(
          question: _verseCompletionQuestion(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Complete the verse'), findsOneWidget);
    expect(find.text('وَالضُّحَىٰ'), findsOneWidget);

    final promptText = tester.widget<Text>(
      find.byKey(const Key('quiz-question-view-prompt')),
    );
    final promptDirectionality = tester.widget<Directionality>(
      find.byKey(const Key('quiz-question-view-prompt-directionality')),
    );

    expect(promptText.style?.fontFamily, 'Amiri');
    expect(promptDirectionality.textDirection, TextDirection.rtl);
  });

  testWidgets('renders word meaning prompts with the expected localized title',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: QuizQuestionView(
          question: _wordMeaningQuestion(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('What does this word mean?'), findsOneWidget);
    expect(find.text('الصَّمَدُ'), findsOneWidget);
  });

  testWidgets('renders verse topic prompts with the expected localized title',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: QuizQuestionView(
          question: _verseTopicQuestion(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Which topic matches this verse?'), findsOneWidget);
    expect(find.text('إِنَّ مَعَ الْعُسْرِ يُسْرًا'), findsOneWidget);
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

VerseCompletionQuestion _verseCompletionQuestion() {
  return VerseCompletionQuestion(
    prompt: 'وَالضُّحَىٰ',
    choices: <String>[
      'وَاللَّيْلِ إِذَا سَجَىٰ',
      'خَيْرٌ لَّكَ',
      'مَا وَدَّعَكَ',
      'فَأَمَّا الْيَتِيمَ',
    ],
    correctIndex: 0,
    surahNumber: 93,
    ayahNumber: 1,
    difficulty: QuizDifficulty.medium,
    fullVerse: 'وَالضُّحَىٰ وَاللَّيْلِ إِذَا سَجَىٰ',
  );
}

WordMeaningQuestion _wordMeaningQuestion() {
  return WordMeaningQuestion(
    prompt: 'الصَّمَدُ',
    choices: <String>[
      'The Eternal Refuge',
      'The Dawn',
      'The Book',
      'The Mercy',
    ],
    correctIndex: 0,
    surahNumber: 112,
    ayahNumber: 2,
    difficulty: QuizDifficulty.easy,
    word: 'الصَّمَدُ',
  );
}

VerseTopicQuestion _verseTopicQuestion() {
  return VerseTopicQuestion(
    prompt: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    choices: <String>[
      'Patience',
      'Inheritance',
      'Fasting',
      'Travel',
    ],
    correctIndex: 0,
    surahNumber: 94,
    ayahNumber: 6,
    difficulty: QuizDifficulty.medium,
    topicId: 'patience',
  );
}
