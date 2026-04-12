import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/prayer/presentation/widgets/prayer_today_times_panel.dart';

void main() {
  testWidgets(
      'PrayerTodayTimesPanel renders 5 prayer rows with status labels and tracking indicator',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const PrayerTodayTimesPanel(
          rows: [
            PrayerTimeSlotView(
              entry: PrayerTimeEntry(
                type: PrayerType.fajr,
                label: 'Fajr',
                timeOfDay: TimeOfDay(hour: 4, minute: 26),
              ),
              status: PrayerTimeSlotStatus.past,
              isTracked: true,
              timeOfDay: TimeOfDay(hour: 4, minute: 26),
            ),
            PrayerTimeSlotView(
              entry: PrayerTimeEntry(
                type: PrayerType.dhuhr,
                label: 'Dhuhr',
                timeOfDay: TimeOfDay(hour: 12, minute: 1),
              ),
              status: PrayerTimeSlotStatus.past,
              isTracked: false,
              timeOfDay: TimeOfDay(hour: 12, minute: 1),
            ),
            PrayerTimeSlotView(
              entry: PrayerTimeEntry(
                type: PrayerType.asr,
                label: 'Asr',
                timeOfDay: TimeOfDay(hour: 15, minute: 29),
              ),
              status: PrayerTimeSlotStatus.current,
              isTracked: false,
              timeOfDay: TimeOfDay(hour: 15, minute: 29),
            ),
            PrayerTimeSlotView(
              entry: PrayerTimeEntry(
                type: PrayerType.maghrib,
                label: 'Maghrib',
                timeOfDay: TimeOfDay(hour: 18, minute: 9),
              ),
              status: PrayerTimeSlotStatus.upcoming,
              isTracked: false,
              timeOfDay: TimeOfDay(hour: 18, minute: 9),
            ),
            PrayerTimeSlotView(
              entry: PrayerTimeEntry(
                type: PrayerType.isha,
                label: 'Isha',
                timeOfDay: TimeOfDay(hour: 19, minute: 27),
              ),
              status: PrayerTimeSlotStatus.upcoming,
              isTracked: false,
              timeOfDay: TimeOfDay(hour: 19, minute: 27),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('prayer-today-title')), findsOneWidget);
    expect(find.byKey(const Key('prayer-today-row-fajr')), findsOneWidget);
    expect(find.byKey(const Key('prayer-today-row-isha')), findsOneWidget);
    expect(find.byKey(const Key('prayer-today-tracked-fajr')), findsOneWidget);
    expect(
      find.byKey(const Key('prayer-today-status-fajr-past')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('prayer-today-status-dhuhr-past')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('prayer-today-status-asr-current')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('prayer-today-status-maghrib-upcoming')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('prayer-today-status-isha-upcoming')),
      findsOneWidget,
    );
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
