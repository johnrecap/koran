import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_answer_choice.dart';

void main() {
  testWidgets('invokes the tap callback once and ignores taps after locking',
      (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        child: QuizAnswerChoice(
          choiceIndex: 0,
          label: 'Choice A',
          state: QuizAnswerChoiceState.idle,
          isLocked: false,
          onTap: () {
            tapCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-answer-choice-0')));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);

    await tester.pumpWidget(
      _buildHarness(
        child: QuizAnswerChoice(
          choiceIndex: 0,
          label: 'Choice A',
          state: QuizAnswerChoiceState.idle,
          isLocked: true,
          onTap: () {
            tapCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-answer-choice-0')));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
  });

  testWidgets('renders the correct, incorrect, and revealed visual states',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const Column(
          children: [
            QuizAnswerChoice(
              choiceIndex: 0,
              label: 'Correct choice',
              state: QuizAnswerChoiceState.correct,
              isLocked: true,
            ),
            QuizAnswerChoice(
              choiceIndex: 1,
              label: 'Incorrect choice',
              state: QuizAnswerChoiceState.incorrect,
              isLocked: true,
            ),
            QuizAnswerChoice(
              choiceIndex: 2,
              label: 'Revealed choice',
              state: QuizAnswerChoiceState.revealed,
              isLocked: true,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Correct choice'), findsOneWidget);
    expect(find.text('Incorrect choice'), findsOneWidget);
    expect(find.text('Revealed choice'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
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
