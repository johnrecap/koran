import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/notification_schedule_window_policy.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

abstract final class ReviewNotificationPolicy {
  static ScheduledNotificationDescriptor? buildNextReminder({
    required List<SpacedReviewItem> items,
    required DateTime now,
    String title = '',
    String body = '',
  }) {
    if (items.isEmpty) {
      return null;
    }

    final sortedItems = [...items]..sort(
        (first, second) => first.nextReviewAt.compareTo(second.nextReviewAt));
    final nextItem = sortedItems.first;
    final scheduledAt = NotificationScheduleWindowPolicy.clampIntoSafeFuture(
      candidate: nextItem.nextReviewAt,
      now: now,
    );
    if (!NotificationScheduleWindowPolicy.isWithinRollingWindow(
      scheduledAt: scheduledAt,
      now: now,
    )) {
      return null;
    }

    return ScheduledNotificationDescriptor(
      id: ScheduledNotificationIdPolicy.family(
        NotificationReminderType.spacedReview,
      ),
      reminderType: NotificationReminderType.spacedReview,
      scheduledAt: scheduledAt,
      cadence: ScheduledNotificationCadence.once,
      launchTarget: const NotificationLaunchTarget.reviewQueue(),
      title: title,
      body: body,
    );
  }
}
