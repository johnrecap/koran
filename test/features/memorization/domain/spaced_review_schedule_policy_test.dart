import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_schedule_policy.dart';

void main() {
  test('creates a new review item with its first review scheduled for the next day',
      () {
    final item = SpacedReviewSchedulePolicy.createNewItem(
      khatmaId: 'khatma-1',
      khatmaTitle: 'Monthly Khatma',
      startPage: 1,
      endPage: 21,
      now: DateTime(2026, 3, 28, 14, 30),
    );

    expect(item.nextReviewAt, DateTime(2026, 3, 29));
    expect(item.repetitionCount, 0);
    expect(item.intervalDays, 1);
    expect(item.easeFactor, 2.3);
    expect(item.lastOutcome, isNull);
  });

  test('easy outcome grows the interval and repetition count', () {
    final updated = SpacedReviewSchedulePolicy.applyOutcome(
      item: _seedItem(),
      outcome: ReviewOutcome.easy,
      reviewedAt: DateTime(2026, 3, 29, 9),
    );

    expect(updated.nextReviewAt, DateTime(2026, 4, 1));
    expect(updated.intervalDays, 3);
    expect(updated.repetitionCount, 1);
    expect(updated.lastOutcome, ReviewOutcome.easy);
    expect(updated.easeFactor, greaterThan(2.3));
  });

  test('hard outcome resets the interval to one day and lowers ease', () {
    final reviewedItem = _seedItem(
      repetitionCount: 2,
      intervalDays: 7,
      easeFactor: 2.6,
      lastOutcome: ReviewOutcome.easy,
      lastReviewedAt: DateTime(2026, 3, 20),
    );

    final updated = SpacedReviewSchedulePolicy.applyOutcome(
      item: reviewedItem,
      outcome: ReviewOutcome.hard,
      reviewedAt: DateTime(2026, 3, 29, 9),
    );

    expect(updated.nextReviewAt, DateTime(2026, 3, 30));
    expect(updated.intervalDays, 1);
    expect(updated.repetitionCount, 0);
    expect(updated.lastOutcome, ReviewOutcome.hard);
    expect(updated.easeFactor, lessThan(2.6));
  });
}

SpacedReviewItem _seedItem({
  int repetitionCount = 0,
  int intervalDays = 1,
  double easeFactor = 2.3,
  ReviewOutcome? lastOutcome,
  DateTime? lastReviewedAt,
}) {
  return SpacedReviewItem(
    id: SpacedReviewItem.buildId(
      khatmaId: 'khatma-1',
      startPage: 1,
      endPage: 21,
    ),
    khatmaId: 'khatma-1',
    khatmaTitle: 'Monthly Khatma',
    startPage: 1,
    endPage: 21,
    createdAt: DateTime(2026, 3, 28),
    nextReviewAt: DateTime(2026, 3, 29),
    lastReviewedAt: lastReviewedAt,
    repetitionCount: repetitionCount,
    intervalDays: intervalDays,
    easeFactor: easeFactor,
    lastOutcome: lastOutcome,
  );
}
