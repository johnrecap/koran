import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/review_notification_policy.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

void main() {
  test('chooses the nearest due review item for the queue reminder', () {
    final reminder = ReviewNotificationPolicy.buildNextReminder(
      items: <SpacedReviewItem>[
        _item(id: 'review-2', nextReviewAt: DateTime(2026, 3, 31, 9)),
        _item(id: 'review-1', nextReviewAt: DateTime(2026, 3, 30, 11)),
      ],
      now: DateTime(2026, 3, 30, 10),
    );

    expect(reminder, isNotNull);
    expect(reminder!.reminderType, NotificationReminderType.spacedReview);
    expect(
      reminder.id,
      ScheduledNotificationIdPolicy.family(
        NotificationReminderType.spacedReview,
      ),
    );
    expect(reminder.launchTarget, const NotificationLaunchTarget.reviewQueue());
    expect(reminder.scheduledAt, DateTime(2026, 3, 30, 11));
  });

  test('clamps overdue review reminders into a safe immediate window', () {
    final reminder = ReviewNotificationPolicy.buildNextReminder(
      items: <SpacedReviewItem>[
        _item(id: 'review-1', nextReviewAt: DateTime(2026, 3, 30, 8)),
      ],
      now: DateTime(2026, 3, 30, 10),
    );

    expect(reminder, isNotNull);
    expect(reminder!.scheduledAt, DateTime(2026, 3, 30, 10, 1));
  });

  test('returns null when there are no review items to schedule', () {
    final reminder = ReviewNotificationPolicy.buildNextReminder(
      items: const <SpacedReviewItem>[],
      now: DateTime(2026, 3, 30, 10),
    );

    expect(reminder, isNull);
  });
}

SpacedReviewItem _item({
  required String id,
  required DateTime nextReviewAt,
}) {
  return SpacedReviewItem(
    id: id,
    khatmaId: 'khatma-1',
    khatmaTitle: 'Weekly Khatma',
    startPage: 1,
    endPage: 20,
    createdAt: DateTime(2026, 3, 20),
    nextReviewAt: nextReviewAt,
    repetitionCount: 0,
    intervalDays: 1,
    easeFactor: 2.3,
  );
}
