import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/prayer/domain/hijri_calendar_month.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/prayer_notification_policy.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

void main() {
  test(
    'builds reminders for the remaining prayers of the day and tomorrow fajr with unique ids',
    () {
      final schedules = PrayerNotificationPolicy.buildRemainderOfDay(
        snapshot: _sampleSnapshot(
          nextPrayer: PrayerType.asr,
          nextPrayerTime: DateTime(2026, 3, 30, 15, 29),
        ),
        now: DateTime(2026, 3, 30, 12, 5),
        offset: PrayerReminderOffset.tenMinBefore,
        labelResolver: (type) => type.name,
      );

      expect(schedules, hasLength(4));
      expect(
        schedules.map((schedule) => schedule.id),
        <int>[41022, 41023, 41024, 41030],
      );
      expect(
        schedules.map((schedule) => schedule.scheduledAt),
        <DateTime>[
          DateTime(2026, 3, 30, 15, 19),
          DateTime(2026, 3, 30, 17, 59),
          DateTime(2026, 3, 30, 19, 17),
          DateTime(2026, 3, 31, 4, 16),
        ],
      );
      expect(
        schedules.every(
          (schedule) =>
              schedule.launchTarget ==
              const NotificationLaunchTarget.prayerDetails(),
        ),
        isTrue,
      );
    },
  );

  test(
    'does not add tomorrow fajr while today fajr is still pending to avoid id collisions',
    () {
      final schedules = PrayerNotificationPolicy.buildRemainderOfDay(
        snapshot: _sampleSnapshot(
          nextPrayer: PrayerType.fajr,
          nextPrayerTime: DateTime(2026, 3, 30, 4, 26),
        ),
        now: DateTime(2026, 3, 30, 4),
        offset: PrayerReminderOffset.tenMinBefore,
        labelResolver: (type) => type.name,
      );

      // 5 today prayers + 1 tomorrow fajr = 6
      expect(schedules, hasLength(6));
      // Today's Fajr uses prayerReminder ID (41020)
      expect(
        schedules.where((schedule) => schedule.id == 41020),
        hasLength(1),
      );
      // Tomorrow's Fajr uses adhanAlert ID (41030)
      expect(
        schedules.where((schedule) => schedule.id == 41030),
        hasLength(1),
      );
    },
  );

  test('builds the next prayer reminder from the current prayer snapshot', () {
    final reminder = PrayerNotificationPolicy.buildNextReminder(
      snapshot: _sampleSnapshot(
        nextPrayer: PrayerType.maghrib,
        nextPrayerTime: DateTime(2026, 3, 30, 18, 9),
      ),
      now: DateTime(2026, 3, 30, 17, 30),
      offset: PrayerReminderOffset.tenMinBefore,
    );

    expect(reminder, isNotNull);
    expect(reminder!.reminderType, NotificationReminderType.prayer);
    expect(
      reminder.id,
      ScheduledNotificationIdPolicy.prayerReminder(PrayerType.maghrib),
    );
    expect(
        reminder.launchTarget, const NotificationLaunchTarget.prayerDetails());
    expect(reminder.scheduledAt, DateTime(2026, 3, 30, 17, 59));
  });

  test(
      'clamps the reminder into a safe immediate window when lead time has already passed',
      () {
    final reminder = PrayerNotificationPolicy.buildNextReminder(
      snapshot: _sampleSnapshot(
        nextPrayer: PrayerType.maghrib,
        nextPrayerTime: DateTime(2026, 3, 30, 18, 9),
      ),
      now: DateTime(2026, 3, 30, 18, 5),
      offset: PrayerReminderOffset.tenMinBefore,
    );

    expect(reminder, isNotNull);
    expect(reminder!.scheduledAt, DateTime(2026, 3, 30, 18, 6));
  });

  test('returns null when no prayer snapshot is available', () {
    final reminder = PrayerNotificationPolicy.buildNextReminder(
      snapshot: null,
      now: DateTime(2026, 3, 30, 17, 30),
      offset: PrayerReminderOffset.tenMinBefore,
    );

    expect(reminder, isNull);
  });

  test('returns an empty schedule when no prayer snapshot is available', () {
    final schedules = PrayerNotificationPolicy.buildRemainderOfDay(
      snapshot: null,
      now: DateTime(2026, 3, 30, 17, 30),
      offset: PrayerReminderOffset.tenMinBefore,
      labelResolver: (type) => type.name,
    );

    expect(schedules, isEmpty);
  });
}

HomePrayerSnapshot _sampleSnapshot({
  required PrayerType nextPrayer,
  required DateTime nextPrayerTime,
}) {
  return HomePrayerSnapshot(
    locationLabel: 'Cairo',
    gregorianDate: DateTime(2026, 3, 30),
    hijriDay: 12,
    hijriYear: 1447,
    weekdayLabel: 'Monday',
    hijriLabel: '12 Shawwal 1447 AH',
    nextPrayer: nextPrayer,
    nextPrayerTime: nextPrayerTime,
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
