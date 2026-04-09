import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/recurring_notification_policy.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

void main() {
  test('builds the next daily reminder at the configured local time', () {
    final schedule = RecurringNotificationPolicy.nextDaily(
      reminderType: NotificationReminderType.dailyWird,
      localTime: const TimeOfDay(hour: 8, minute: 30),
      now: DateTime(2026, 3, 30, 7, 0),
      launchTarget: const NotificationLaunchTarget.dailyWirdReader(),
    );

    expect(schedule.reminderType, NotificationReminderType.dailyWird);
    expect(
      schedule.id,
      ScheduledNotificationIdPolicy.family(NotificationReminderType.dailyWird),
    );
    expect(schedule.cadence, ScheduledNotificationCadence.daily);
    expect(schedule.scheduledAt, DateTime(2026, 3, 30, 8, 30));
    expect(schedule.launchTarget,
        const NotificationLaunchTarget.dailyWirdReader());
  });

  test('rolls the weekly reminder to the next matching weekday', () {
    final schedule = RecurringNotificationPolicy.nextWeekly(
      reminderType: NotificationReminderType.fridayKahf,
      weekday: DateTime.friday,
      localTime: const TimeOfDay(hour: 9, minute: 15),
      now: DateTime(2026, 3, 30, 10, 0),
      launchTarget: const NotificationLaunchTarget.fridayKahfReader(),
    );

    expect(schedule.reminderType, NotificationReminderType.fridayKahf);
    expect(
      schedule.id,
      ScheduledNotificationIdPolicy.family(
        NotificationReminderType.fridayKahf,
      ),
    );
    expect(schedule.cadence, ScheduledNotificationCadence.weekly);
    expect(schedule.scheduledAt, DateTime(2026, 4, 3, 9, 15));
  });
}
