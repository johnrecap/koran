import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

enum ScheduledNotificationCadence {
  once,
  daily,
  weekly,
}

abstract final class ScheduledNotificationIdPolicy {
  /// Legacy family-level ID — used by non-prayer reminders.
  static int family(NotificationReminderType reminderType) {
    return switch (reminderType) {
      NotificationReminderType.dailyWird => 4101,
      NotificationReminderType.prayer => 4102,
      NotificationReminderType.fridayKahf => 4103,
      NotificationReminderType.spacedReview => 4104,
      NotificationReminderType.adhkar => 4105,
    };
  }

  /// Unique ID for each prayer's pre-adhan reminder notification.
  static int prayerReminder(PrayerType prayerType) {
    return switch (prayerType) {
      PrayerType.fajr => 41020,
      PrayerType.dhuhr => 41021,
      PrayerType.asr => 41022,
      PrayerType.maghrib => 41023,
      PrayerType.isha => 41024,
    };
  }

  /// Unique ID for each prayer's at-adhan-time notification.
  static int adhanAlert(PrayerType prayerType) {
    return switch (prayerType) {
      PrayerType.fajr => 41030,
      PrayerType.dhuhr => 41031,
      PrayerType.asr => 41032,
      PrayerType.maghrib => 41033,
      PrayerType.isha => 41034,
    };
  }

  /// All prayer-related notification IDs for bulk cancellation.
  static List<int> get allPrayerIds => [
        ...PrayerType.values.map(prayerReminder),
        ...PrayerType.values.map(adhanAlert),
      ];
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
    this.androidRawSoundName,
  });

  final int id;
  final NotificationReminderType reminderType;
  final DateTime scheduledAt;
  final ScheduledNotificationCadence cadence;
  final NotificationLaunchTarget launchTarget;
  final String title;
  final String body;

  /// Android raw resource name for custom notification sound (without extension).
  /// When non-null, the notification will use this sound instead of the default.
  final String? androidRawSoundName;
}
