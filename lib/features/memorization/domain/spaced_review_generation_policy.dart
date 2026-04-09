import 'dart:math' as math;

import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_schedule_policy.dart';

abstract final class SpacedReviewGenerationPolicy {
  static List<SpacedReviewItem> generateMissingItems({
    required Khatma khatma,
    required List<SpacedReviewItem> existingItems,
    required DateTime now,
  }) {
    final pagesPerDay = math.max(
      1,
      (Khatma.mushafPageCount / khatma.targetDays).ceil(),
    );
    final completedPages = khatma.furthestPageRead >= khatma.startPage
        ? khatma.furthestPageRead - khatma.startPage + 1
        : 0;
    final completedAssignmentCount = completedPages ~/ pagesPerDay;

    if (completedAssignmentCount <= 0) {
      return const <SpacedReviewItem>[];
    }

    final generated = <SpacedReviewItem>[];
    for (var index = 0; index < completedAssignmentCount; index += 1) {
      final startPage = khatma.startPage + (index * pagesPerDay);
      final endPage = math.min(
        startPage + pagesPerDay - 1,
        Khatma.mushafPageCount,
      );
      final alreadyExists = existingItems.any(
        (item) => item.matchesRange(
          khatmaId: khatma.id,
          startPage: startPage,
          endPage: endPage,
        ),
      );
      if (alreadyExists) {
        continue;
      }

      generated.add(
        SpacedReviewSchedulePolicy.createNewItem(
          khatmaId: khatma.id,
          khatmaTitle: khatma.title,
          startPage: startPage,
          endPage: endPage,
          now: now,
        ),
      );
    }

    return generated;
  }
}
