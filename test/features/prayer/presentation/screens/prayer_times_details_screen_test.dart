import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/prayer/presentation/screens/prayer_times_details_screen.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

void main() {
  testWidgets('PrayerTimesDetailsScreen renders the new prayer sections',
      (tester) async {
    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('prayer-adherence-title')), findsOneWidget);
    expect(find.byKey(const Key('prayer-today-title')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('prayer-weekly-title')),
      200,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('prayer-weekly-title')), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(5));
  });

  testWidgets('PrayerTimesDetailsScreen renders the new prayer sections in RTL',
      (tester) async {
    await tester.pumpWidget(_buildHarness(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    final screenContext = tester.element(find.byType(PrayerTimesDetailsScreen));

    expect(Directionality.of(screenContext), TextDirection.rtl);
    expect(find.byKey(const Key('prayer-adherence-title')), findsOneWidget);
    expect(find.byKey(const Key('prayer-today-title')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('prayer-weekly-title')),
      200,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('prayer-weekly-title')), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(5));
  });
}

Widget _buildHarness({Locale locale = const Locale('en')}) {
  return ProviderScope(
    overrides: [
      appSettingsInitialStateProvider.overrideWithValue(
        const AppSettingsState.defaults(),
      ),
      homePrayerSnapshotProvider.overrideWith(
        (ref) => Stream<HomePrayerSnapshot>.value(_samplePrayerSnapshot()),
      ),
      hijriMonthCalendarViewProvider.overrideWith(
        (ref, _) async => _sampleMonthView(),
      ),
      prayerAdherenceSummaryProvider.overrideWith(
        (ref) async => const DailyAdherenceSummary(
          completed: 3,
          total: 5,
          streakDays: 2,
        ),
      ),
      todayPrayerTimesPanelProvider.overrideWith(
        (ref) async => const [
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
            isTracked: true,
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
      prayerWeeklyStripProvider.overrideWith(
        (ref) async => List<WeeklyDaySnapshot>.generate(7, (index) {
          final date = DateTime(2026, 3, 21 + index);
          return WeeklyDaySnapshot(
            dateKey:
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            date: date,
            completedCount: index == 4 ? 3 : 0,
            totalPrayers: 5,
            isToday: index == 4,
          );
        }),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const PrayerTimesDetailsScreen(),
    ),
  );
}

HomePrayerSnapshot _samplePrayerSnapshot() {
  return HomePrayerSnapshot(
    locationLabel: 'Cairo',
    gregorianDate: DateTime(2026, 3, 25),
    hijriDay: 6,
    hijriYear: 1447,
    weekdayLabel: 'Wednesday',
    hijriLabel: '6 Shawwal 1447 AH',
    nextPrayer: PrayerType.maghrib,
    nextPrayerTime: DateTime(2026, 3, 25, 18, 9),
    hijriMonthReference: const HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'شوال',
      monthNameEnglish: 'Shawwal',
    ),
    isUsingCachedData: false,
    cachedFetchedAt: null,
    prayers: const [
      PrayerTimeEntry(
        type: PrayerType.fajr,
        label: 'Fajr',
        timeOfDay: TimeOfDay(hour: 4, minute: 26),
      ),
      PrayerTimeEntry(
        type: PrayerType.dhuhr,
        label: 'Dhuhr',
        timeOfDay: TimeOfDay(hour: 12, minute: 1),
      ),
      PrayerTimeEntry(
        type: PrayerType.asr,
        label: 'Asr',
        timeOfDay: TimeOfDay(hour: 15, minute: 29),
      ),
      PrayerTimeEntry(
        type: PrayerType.maghrib,
        label: 'Maghrib',
        timeOfDay: TimeOfDay(hour: 18, minute: 9),
      ),
      PrayerTimeEntry(
        type: PrayerType.isha,
        label: 'Isha',
        timeOfDay: TimeOfDay(hour: 19, minute: 27),
      ),
    ],
  );
}

HijriCalendarMonthView _sampleMonthView() {
  return const HijriCalendarMonthView(
    reference: HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'شوال',
      monthNameEnglish: 'Shawwal',
    ),
    days: [
      HijriCalendarDayView(
        data: HijriCalendarDayData(
          dayOfMonth: 6,
          weekday: DateTime.wednesday,
          gregorianDate: '2026-03-25',
        ),
        tracking: PrayerDayTracking(
          dateKey: '2026-03-25',
          completedPrayers: {PrayerType.fajr, PrayerType.dhuhr},
        ),
        visualState: PrayerCalendarDayVisualState.today,
      ),
    ],
  );
}
