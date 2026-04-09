import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';

enum ScheduledNotificationCadence {
  once,
  daily,
  weekly,
}

abstract final class ScheduledNotificationIdPolicy {
  static int family(NotificationReminderType reminderType) {
    return switch (reminderType) {
      NotificationReminderType.dailyWird => 4101,
      NotificationReminderType.prayer => 4102,
      NotificationReminderType.fridayKahf => 4103,
      NotificationReminderType.spacedReview => 4104,
      NotificationReminderType.adhkar => 4105,
    };
  }
}

class ScheduledNotificationDescriptor {
  const ScheduledNotificationDescriptor({
    required this.id,
    required this.reminderType,
    required this.scheduledAt,
    required this.cadence,
    required this.launchTarget,
    this.title = '',
    this.body = '',
  });

  final int id;
  final NotificationReminderType reminderType;
  final DateTime scheduledAt;
  final ScheduledNotificationCadence cadence;
  final NotificationLaunchTarget launchTarget;
  final String title;
  final String body;
}
