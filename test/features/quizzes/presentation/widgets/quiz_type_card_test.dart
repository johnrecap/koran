import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_type_card.dart';

void main() {
  testWidgets('renders localized copy and the mistake review badge',
      (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        child: QuizTypeCard(
          quizType: QuizType.verseCompletion,
          isAvailable: true,
          mistakeCount: 3,
          onPressed: () {
            tapCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verse completion'), findsOneWidget);
    expect(
      find.text('Complete the missing continuation of an ayah.'),
      findsOneWidget,
    );
    expect(find.text('3 to review'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('quiz-type-card-button-verseCompletion')),
    );
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('disables the action when the quiz type is unavailable',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const QuizTypeCard(
          quizType: QuizType.wordMeaning,
          isAvailable: false,
          mistakeCount: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Word meaning'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('quiz-type-card-button-wordMeaning')),
    );
    expect(button.onPressed, isNull);
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
          width: 360,
          child: child,
        ),
      ),
    ),
  );
}
