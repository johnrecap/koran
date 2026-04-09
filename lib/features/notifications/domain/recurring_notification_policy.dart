import 'package:flutter/material.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

abstract final class RecurringNotificationPolicy {
  static ScheduledNotificationDescriptor nextDaily({
    required NotificationReminderType reminderType,
    required TimeOfDay localTime,
    required DateTime now,
    required NotificationLaunchTarget launchTarget,
    String title = '',
    String body = '',
  }) {
    final today = DateTime(
      now.year,
      now.month,
      now.day,
      localTime.hour,
      localTime.minute,
    );
    final scheduledAt =
        today.isAfter(now) ? today : today.add(const Duration(days: 1));

    return ScheduledNotificationDescriptor(
      id: ScheduledNotificationIdPolicy.family(reminderType),
      reminderType: reminderType,
      scheduledAt: scheduledAt,
      cadence: ScheduledNotificationCadence.daily,
      launchTarget: launchTarget,
      title: title,
      body: body,
    );
  }

  static ScheduledNotificationDescriptor nextWeekly({
    required NotificationReminderType reminderType,
    required int weekday,
    required TimeOfDay localTime,
    required DateTime now,
    required NotificationLaunchTarget launchTarget,
    String title = '',
    String body = '',
  }) {
    var scheduledAt = DateTime(
      now.year,
      now.month,
      now.day,
      localTime.hour,
      localTime.minute,
    );
    while (scheduledAt.weekday != weekday || !scheduledAt.isAfter(now)) {
      scheduledAt = scheduledAt.add(const Duration(days: 1));
    }

    return ScheduledNotificationDescriptor(
      id: ScheduledNotificationIdPolicy.family(reminderType),
      reminderType: reminderType,
      scheduledAt: scheduledAt,
      cadence: ScheduledNotificationCadence.weekly,
      launchTarget: launchTarget,
      title: title,
      body: body,
    );
  }
}
