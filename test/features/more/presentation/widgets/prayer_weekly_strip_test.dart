import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/more/presentation/widgets/prayer_weekly_strip.dart';

void main() {
  testWidgets('PrayerWeeklyStrip renders the 7 current-week cells',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: PrayerWeeklyStrip(
          week: List<WeeklyDaySnapshot>.generate(7, (index) {
            final date = DateTime(2026, 3, 21 + index);
            return WeeklyDaySnapshot(
              dateKey:
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              date: date,
              completedCount: index == 4 ? 3 : index == 6 ? 5 : 0,
              totalPrayers: 5,
              isToday: index == 4,
            );
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('prayer-weekly-title')), findsOneWidget);
    expect(find.byKey(const Key('prayer-weekly-cell-2026-03-21')),
        findsOneWidget);
    expect(find.byKey(const Key('prayer-weekly-cell-2026-03-27')),
        findsOneWidget);
    expect(find.byKey(const Key('prayer-weekly-cell-today')), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
    expect(find.text('5/5'), findsOneWidget);
  });
}

Widget _buildHarness({required Widget child}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}
