import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';

abstract final class SpacedReviewSchedulePolicy {
  static const double initialEaseFactor = 2.3;
  static const double minimumEaseFactor = 1.3;
  static const double maximumEaseFactor = 3.0;

  static SpacedReviewItem createNewItem({
    required String khatmaId,
    required String khatmaTitle,
    required int startPage,
    required int endPage,
    required DateTime now,
  }) {
    final normalizedNow = normalizeDate(now);
    return SpacedReviewItem(
      id: SpacedReviewItem.buildId(
        khatmaId: khatmaId,
        startPage: startPage,
        endPage: endPage,
      ),
      khatmaId: khatmaId,
      khatmaTitle: khatmaTitle,
      startPage: startPage,
      endPage: endPage,
      createdAt: normalizedNow,
      nextReviewAt: normalizedNow.add(const Duration(days: 1)),
      repetitionCount: 0,
      intervalDays: 1,
      easeFactor: initialEaseFactor,
    );
  }

  static SpacedReviewItem applyOutcome({
    required SpacedReviewItem item,
    required ReviewOutcome outcome,
    required DateTime reviewedAt,
  }) {
    final normalizedReviewedAt = normalizeDate(reviewedAt);
    final nextIntervalDays = _nextIntervalDays(item, outcome);
    final nextEaseFactor = _nextEaseFactor(item.easeFactor, outcome);
    final nextRepetitionCount = switch (outcome) {
      ReviewOutcome.hard => 0,
      ReviewOutcome.medium || ReviewOutcome.easy => item.repetitionCount + 1,
    };

    return item.copyWith(
      lastReviewedAt: normalizedReviewedAt,
      nextReviewAt: normalizedReviewedAt.add(Duration(days: nextIntervalDays)),
      repetitionCount: nextRepetitionCount,
      intervalDays: nextIntervalDays,
      easeFactor: nextEaseFactor,
      lastOutcome: outcome,
    );
  }

  static bool isDue({
    required SpacedReviewItem item,
    required DateTime now,
  }) {
    return !normalizeDate(item.nextReviewAt).isAfter(normalizeDate(now));
  }

  static int relativeDayOffset({
    required DateTime now,
    required DateTime target,
  }) {
    return normalizeDate(target).difference(normalizeDate(now)).inDays;
  }

  static DateTime normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static int _nextIntervalDays(SpacedReviewItem item, ReviewOutcome outcome) {
    switch (outcome) {
      case ReviewOutcome.hard:
        return 1;
      case ReviewOutcome.medium:
        if (item.repetitionCount == 0) {
          return 2;
        }
        if (item.repetitionCount == 1) {
          return 4;
        }
        final growthFactor = (item.easeFactor - 0.15).clamp(1.4, 2.6);
        return _growInterval(item.intervalDays, growthFactor, minGrowth: 1);
      case ReviewOutcome.easy:
        if (item.repetitionCount == 0) {
          return 3;
        }
        if (item.repetitionCount == 1) {
          return 7;
        }
        final growthFactor = (item.easeFactor + 0.15).clamp(1.6, 3.0);
        return _growInterval(item.intervalDays, growthFactor, minGrowth: 2);
    }
  }

  static double _nextEaseFactor(double current, ReviewOutcome outcome) {
    final delta = switch (outcome) {
      ReviewOutcome.hard => -0.2,
      ReviewOutcome.medium => -0.05,
      ReviewOutcome.easy => 0.15,
    };
    return (current + delta).clamp(
      minimumEaseFactor,
      maximumEaseFactor,
    );
  }

  static int _growInterval(
    int currentIntervalDays,
    double factor, {
    required int minGrowth,
  }) {
    final next = (currentIntervalDays * factor).round();
    return next > currentIntervalDays
        ? next
        : currentIntervalDays + minGrowth;
  }
}
