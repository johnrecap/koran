import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_schedule_policy.dart';

class SpacedReviewQueueSummary {
  const SpacedReviewQueueSummary({
    required this.activeKhatma,
    required this.dueItems,
    required this.upcomingItems,
  });

  final Khatma? activeKhatma;
  final List<SpacedReviewItem> dueItems;
  final List<SpacedReviewItem> upcomingItems;

  bool get hasActiveKhatma => activeKhatma != null;
  bool get hasItems => dueItems.isNotEmpty || upcomingItems.isNotEmpty;
  int get dueCount => dueItems.length;

  SpacedReviewItem? get highlightedItem {
    if (dueItems.isNotEmpty) {
      return dueItems.first;
    }
    if (upcomingItems.isNotEmpty) {
      return upcomingItems.first;
    }

    return null;
  }
}

abstract final class SpacedReviewQueueSummaryPolicy {
  static SpacedReviewQueueSummary build({
    required Khatma? activeKhatma,
    required List<SpacedReviewItem> items,
    required DateTime now,
  }) {
    if (activeKhatma == null) {
      return const SpacedReviewQueueSummary(
        activeKhatma: null,
        dueItems: <SpacedReviewItem>[],
        upcomingItems: <SpacedReviewItem>[],
      );
    }

    final scopedItems = items
        .where((item) => item.khatmaId == activeKhatma.id)
        .toList()
      ..sort((first, second) {
        return first.nextReviewAt.compareTo(second.nextReviewAt);
      });

    final dueItems = <SpacedReviewItem>[];
    final upcomingItems = <SpacedReviewItem>[];

    for (final item in scopedItems) {
      if (SpacedReviewSchedulePolicy.isDue(item: item, now: now)) {
        dueItems.add(item);
      } else {
        upcomingItems.add(item);
      }
    }

    return SpacedReviewQueueSummary(
      activeKhatma: activeKhatma,
      dueItems: dueItems,
      upcomingItems: upcomingItems,
    );
  }
}
