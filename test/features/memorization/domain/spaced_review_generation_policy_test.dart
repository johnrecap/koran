import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_generation_policy.dart';

void main() {
  test('generates one review item per completed assignment range', () {
    final khatma = Khatma(
      id: 'khatma-1',
      title: 'Monthly Khatma',
      targetDays: 30,
      startDate: DateTime(2026, 3, 1),
      furthestPageRead: 45,
    );

    final items = SpacedReviewGenerationPolicy.generateMissingItems(
      khatma: khatma,
      existingItems: const <SpacedReviewItem>[],
      now: DateTime(2026, 3, 28, 10),
    );

    expect(items, hasLength(2));
    expect(items.first.startPage, 1);
    expect(items.first.endPage, 21);
    expect(items.last.startPage, 22);
    expect(items.last.endPage, 42);
  });

  test('does not generate duplicate items for an existing khatma page range', () {
    final khatma = Khatma(
      id: 'khatma-1',
      title: 'Monthly Khatma',
      targetDays: 30,
      startDate: DateTime(2026, 3, 1),
      furthestPageRead: 45,
    );

    final existing = SpacedReviewItem(
      id: SpacedReviewItem.buildId(
        khatmaId: 'khatma-1',
        startPage: 1,
        endPage: 21,
      ),
      khatmaId: 'khatma-1',
      khatmaTitle: 'Monthly Khatma',
      startPage: 1,
      endPage: 21,
      createdAt: DateTime(2026, 3, 27),
      nextReviewAt: DateTime(2026, 3, 28),
      repetitionCount: 0,
      intervalDays: 1,
      easeFactor: 2.3,
    );

    final items = SpacedReviewGenerationPolicy.generateMissingItems(
      khatma: khatma,
      existingItems: [existing],
      now: DateTime(2026, 3, 28, 10),
    );

    expect(items, hasLength(1));
    expect(items.single.startPage, 22);
    expect(items.single.endPage, 42);
  });

  test('does not generate review items before the first assignment range is complete',
      () {
    final khatma = Khatma(
      id: 'khatma-1',
      title: 'Monthly Khatma',
      targetDays: 30,
      startDate: DateTime(2026, 3, 1),
      furthestPageRead: 20,
    );

    final items = SpacedReviewGenerationPolicy.generateMissingItems(
      khatma: khatma,
      existingItems: const <SpacedReviewItem>[],
      now: DateTime(2026, 3, 28, 10),
    );

    expect(items, isEmpty);
  });
}
