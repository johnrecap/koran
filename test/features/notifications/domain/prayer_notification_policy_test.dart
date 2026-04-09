import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/more/domain/hijri_calendar_month.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/prayer_notification_policy.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

void main() {
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
      ScheduledNotificationIdPolicy.family(NotificationReminderType.prayer),
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
