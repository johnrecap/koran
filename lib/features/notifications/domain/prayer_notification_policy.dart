import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/notification_schedule_window_policy.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

abstract final class PrayerNotificationPolicy {
  static ScheduledNotificationDescriptor? buildNextReminder({
    required HomePrayerSnapshot? snapshot,
    required DateTime now,
    required PrayerReminderOffset offset,
    String title = '',
    String body = '',
  }) {
    if (snapshot == null) {
      return null;
    }

    final candidate = snapshot.nextPrayerTime.subtract(offset.leadTime);
    final scheduledAt = NotificationScheduleWindowPolicy.clampIntoSafeFuture(
      candidate: candidate,
      now: now,
    );
    if (!NotificationScheduleWindowPolicy.isWithinRollingWindow(
      scheduledAt: scheduledAt,
      now: now,
    )) {
      return null;
    }

    return ScheduledNotificationDescriptor(
      id: ScheduledNotificationIdPolicy.family(NotificationReminderType.prayer),
      reminderType: NotificationReminderType.prayer,
      scheduledAt: scheduledAt,
      cadence: ScheduledNotificationCadence.once,
      launchTarget: const NotificationLaunchTarget.prayerDetails(),
      title: title,
      body: body,
    );
  }
}
