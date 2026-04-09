import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/more/domain/prayer_day_tracking.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/more/domain/prayer_times_policies.dart';

void main() {
  test('PrayerReminderOffset.fromName restores known values and defaults safely',
      () {
    expect(
      PrayerReminderOffset.fromName('atAdhan'),
      PrayerReminderOffset.atAdhan,
    );
    expect(
      PrayerReminderOffset.fromName('missing'),
      PrayerReminderOffset.fifteenMinBefore,
    );
  });

  test('resolveTodayTimesPanel marks past current upcoming and tracked rows', () {
    final rows = PrayerTimesPolicies.resolveTodayTimesPanel(
      prayers: _samplePrayers(),
      now: DateTime(2026, 3, 25, 14),
      tracking: const PrayerDayTracking(
        dateKey: '2026-03-25',
        completedPrayers: {PrayerType.fajr, PrayerType.dhuhr},
      ),
    );

    expect(rows, hasLength(5));
    expect(rows[0].status, PrayerTimeSlotStatus.past);
    expect(rows[0].isTracked, isTrue);
    expect(rows[1].status, PrayerTimeSlotStatus.past);
    expect(rows[1].isTracked, isTrue);
    expect(rows[2].status, PrayerTimeSlotStatus.current);
    expect(rows[2].isTracked, isFalse);
    expect(rows[3].status, PrayerTimeSlotStatus.upcoming);
    expect(rows[4].status, PrayerTimeSlotStatus.upcoming);
  });

  test('buildDailyAdherence counts completed prayers out of the full day', () {
    final summary = PrayerTimesPolicies.buildDailyAdherence(
      tracking: const PrayerDayTracking(
        dateKey: '2026-03-25',
        completedPrayers: {
          PrayerType.fajr,
          PrayerType.dhuhr,
          PrayerType.asr,
        },
      ),
    );

    expect(summary.completed, 3);
    expect(summary.total, 5);
  });

  test('computeConsecutiveCompleteDays walks backward from yesterday', () {
    final streak = PrayerTimesPolicies.computeConsecutiveCompleteDays(
      trackings: const <String, PrayerDayTracking>{
        '2026-03-24': PrayerDayTracking(
          dateKey: '2026-03-24',
          completedPrayers: {
            PrayerType.fajr,
            PrayerType.dhuhr,
            PrayerType.asr,
            PrayerType.maghrib,
            PrayerType.isha,
          },
        ),
        '2026-03-23': PrayerDayTracking(
          dateKey: '2026-03-23',
          completedPrayers: {
            PrayerType.fajr,
            PrayerType.dhuhr,
            PrayerType.asr,
            PrayerType.maghrib,
            PrayerType.isha,
          },
        ),
        '2026-03-22': PrayerDayTracking(
          dateKey: '2026-03-22',
          completedPrayers: {PrayerType.fajr},
        ),
      },
      today: DateTime(2026, 3, 25),
    );

    expect(streak, 2);
  });

  test('buildWeeklyStrip returns the current Saturday to Friday window', () {
    final week = PrayerTimesPolicies.buildWeeklyStrip(
      today: DateTime(2026, 3, 25),
      weekTrackings: const <String, PrayerDayTracking>{
        '2026-03-21': PrayerDayTracking(
          dateKey: '2026-03-21',
          completedPrayers: {PrayerType.fajr},
        ),
        '2026-03-25': PrayerDayTracking(
          dateKey: '2026-03-25',
          completedPrayers: {
            PrayerType.fajr,
            PrayerType.dhuhr,
            PrayerType.asr,
          },
        ),
        '2026-03-27': PrayerDayTracking(
          dateKey: '2026-03-27',
          completedPrayers: {
            PrayerType.fajr,
            PrayerType.dhuhr,
            PrayerType.asr,
            PrayerType.maghrib,
            PrayerType.isha,
          },
        ),
      },
    );

    expect(week, hasLength(7));
    expect(week.first.dateKey, '2026-03-21');
    expect(week.last.dateKey, '2026-03-27');
    expect(week[4].dateKey, '2026-03-25');
    expect(week[4].isToday, isTrue);
    expect(week[4].completedCount, 3);
    expect(week[4].totalPrayers, 5);
    expect(week.last.completedCount, 5);
  });
}

List<PrayerTimeEntry> _samplePrayers() {
  return const [
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
  ];
}
