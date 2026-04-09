import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/more/presentation/widgets/prayer_adherence_summary.dart';

void main() {
  testWidgets('PrayerAdherenceSummary renders the completion fraction',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const PrayerAdherenceSummary(
          summary: DailyAdherenceSummary(
            completed: 3,
            total: 5,
            streakDays: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('prayer-adherence-title')), findsOneWidget);
    expect(find.byKey(const Key('prayer-adherence-value')), findsOneWidget);
    expect(find.byKey(const Key('prayer-adherence-streak')), findsNothing);
  });

  testWidgets('PrayerAdherenceSummary shows the streak badge when streak >= 2',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const PrayerAdherenceSummary(
          summary: DailyAdherenceSummary(
            completed: 5,
            total: 5,
            streakDays: 4,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('prayer-adherence-value')), findsOneWidget);
    expect(find.byKey(const Key('prayer-adherence-streak')), findsOneWidget);
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
