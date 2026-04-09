import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_progress_chart.dart';

void main() {
  testWidgets(
      'renders a touch-enabled line chart from the latest twenty history entries',
      (tester) async {
    final entries = List<QuizHistoryEntry>.generate(
      24,
      (index) => QuizHistoryEntry(
        quizType: QuizType.verseCompletion,
        score: index + 1,
        totalQuestions: 25,
        difficulty: QuizDifficulty.medium,
        surahFilter: 2,
        completedAt: DateTime(2026, 4, index + 1),
      ),
    );

    await tester.pumpWidget(
      _buildHarness(
        child: QuizProgressChart(entries: entries),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    final lineData = chart.data.lineBarsData.single;

    expect(chart.data.lineTouchData.enabled, isTrue);
    expect(chart.data.lineTouchData.handleBuiltInTouches, isTrue);
    expect(lineData.spots, hasLength(20));
    expect(lineData.spots.first.y, closeTo(20, 0.001));
    expect(lineData.spots.last.y, closeTo(96, 0.001));
  });

  testWidgets('shows the minimum-history empty state when fewer than 3 entries exist',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: QuizProgressChart(
          entries: <QuizHistoryEntry>[
            QuizHistoryEntry(
              quizType: QuizType.wordMeaning,
              score: 4,
              totalQuestions: 5,
              difficulty: QuizDifficulty.easy,
              surahFilter: 1,
              completedAt: DateTime(2026, 4, 1),
            ),
            QuizHistoryEntry(
              quizType: QuizType.wordMeaning,
              score: 5,
              totalQuestions: 5,
              difficulty: QuizDifficulty.easy,
              surahFilter: 1,
              completedAt: DateTime(2026, 4, 2),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsNothing);
    expect(
      find.text('Complete more quizzes to see your progress'),
      findsOneWidget,
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
          width: 360,
          child: child,
        ),
      ),
    ),
  );
}
