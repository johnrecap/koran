import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/more/domain/hijri_calendar_month.dart';
import 'package:quran_kareem/features/more/domain/prayer_day_tracking.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/more/domain/prayer_times_policies.dart';

void main() {
  test('nextPrayer selects the first prayer after the current time', () {
    final nextPrayer = PrayerTimesPolicies.nextPrayer(
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
      date: DateTime(2026, 3, 25),
      now: DateTime(2026, 3, 25, 17),
    );

    expect(nextPrayer.type, PrayerType.maghrib);
    expect(nextPrayer.dateTime, DateTime(2026, 3, 25, 18, 9));
  });

  test('nextPrayer uses the supplied next-day timings after isha', () {
    final nextPrayer = PrayerTimesPolicies.nextPrayer(
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
      date: DateTime(2026, 3, 25),
      now: DateTime(2026, 3, 25, 23),
      nextDay: PrayerTimesDay(
        gregorianDate: DateTime(2026, 3, 26),
        hijriDay: 7,
        hijriYear: 1447,
        hijriMonthReference: const HijriMonthReference(
          year: 1447,
          month: 10,
          monthNameArabic: 'ط´ظˆط§ظ„',
          monthNameEnglish: 'Shawwal',
        ),
        prayers: const [
          PrayerTimeEntry(
            type: PrayerType.fajr,
            label: 'Fajr',
            timeOfDay: TimeOfDay(hour: 4, minute: 24),
          ),
          PrayerTimeEntry(
            type: PrayerType.dhuhr,
            label: 'Dhuhr',
            timeOfDay: TimeOfDay(hour: 12, minute: 2),
          ),
        ],
      ),
    );

    expect(nextPrayer.type, PrayerType.fajr);
    expect(nextPrayer.dateTime, DateTime(2026, 3, 26, 4, 24));
  });

  test('formatCountdown keeps leading zeros in hh:mm:ss form', () {
    expect(
      PrayerTimesPolicies.formatCountdown(
        const Duration(hours: 1, minutes: 5, seconds: 9),
      ),
      '01:05:09',
    );
  });

  test('resolveDayVisualState marks past incomplete days and today distinctly',
      () {
    expect(
      PrayerTimesPolicies.resolveDayVisualState(
        dayDate: DateTime(2026, 3, 24),
        today: DateTime(2026, 3, 25),
        tracking: const PrayerDayTracking(
          dateKey: '2026-03-24',
          completedPrayers: {PrayerType.fajr},
        ),
      ),
      PrayerCalendarDayVisualState.pastIncomplete,
    );

    expect(
      PrayerTimesPolicies.resolveDayVisualState(
        dayDate: DateTime(2026, 3, 25),
        today: DateTime(2026, 3, 25),
        tracking: const PrayerDayTracking(
          dateKey: '2026-03-25',
          completedPrayers: {},
        ),
      ),
      PrayerCalendarDayVisualState.today,
    );

    expect(
      PrayerTimesPolicies.resolveDayVisualState(
        dayDate: DateTime(2026, 3, 26),
        today: DateTime(2026, 3, 25),
        tracking: const PrayerDayTracking(
          dateKey: '2026-03-26',
          completedPrayers: {},
        ),
      ),
      PrayerCalendarDayVisualState.normal,
    );
  });

  test('localizes weekday and Hijri labels from locale-aware policies', () {
    expect(
      PrayerTimesPolicies.localizedWeekdayLabel(
        date: DateTime(2026, 3, 25),
        languageCode: 'ar',
      ),
      'الأربعاء',
    );
    expect(
      PrayerTimesPolicies.localizedHijriLabel(
        dayOfMonth: 6,
        year: 1447,
        reference: const HijriMonthReference(
          year: 1447,
          month: 10,
          monthNameArabic: 'شوال',
          monthNameEnglish: 'Shawwal',
        ),
        languageCode: 'ar',
      ),
      '6 شوال 1447 هـ',
    );
  });
  test('marks visible snapshots for refresh when next prayer is stale', () {
    final shouldRefresh = PrayerTimesPolicies.shouldRefreshHomeSnapshot(
      snapshot: HomePrayerSnapshot(
        locationLabel: 'Cairo, Egypt',
        gregorianDate: DateTime(2026, 3, 25),
        hijriDay: 6,
        hijriYear: 1447,
        weekdayLabel: 'Wednesday',
        hijriLabel: '6 Shawwal 1447 AH',
        nextPrayer: PrayerType.fajr,
        nextPrayerTime: DateTime(2026, 3, 25, 4, 28),
        hijriMonthReference: const HijriMonthReference(
          year: 1447,
          month: 10,
          monthNameArabic: 'ط´ظˆط§ظ„',
          monthNameEnglish: 'Shawwal',
        ),
        isUsingCachedData: true,
        cachedFetchedAt: DateTime(2026, 3, 24, 23, 37),
        prayers: const [
          PrayerTimeEntry(
            type: PrayerType.fajr,
            label: 'Fajr',
            timeOfDay: TimeOfDay(hour: 4, minute: 28),
          ),
        ],
      ),
      now: DateTime(2026, 3, 25, 10, 4),
    );

    expect(shouldRefresh, isTrue);
  });
}
