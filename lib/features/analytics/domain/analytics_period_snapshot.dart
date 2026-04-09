import 'package:quran_kareem/features/memorization/domain/khatma_planner_summary.dart';

class AnalyticsDateRange {
  const AnalyticsDateRange({
    required this.start,
    required this.endExclusive,
  });

  final DateTime start;
  final DateTime endExclusive;

  int get dayCount {
    var count = 0;
    var cursor = DateTime(start.year, start.month, start.day);

    while (cursor.isBefore(endExclusive)) {
      count += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    return count;
  }

  DateTime get endInclusive =>
      endExclusive.subtract(const Duration(microseconds: 1));

  bool contains(DateTime timestamp) {
    return !timestamp.isBefore(start) && timestamp.isBefore(endExclusive);
  }

  List<String> get dayKeys {
    final keys = <String>[];
    for (var index = 0; index < dayCount; index += 1) {
      keys.add(
        KhatmaPlannerSummaryPolicy.dayKey(
          start.add(Duration(days: index)),
        ),
      );
    }
    return keys;
  }
}

enum AnalyticsPeriodType {
  thisWeek,
  thisMonth;

  AnalyticsDateRange currentRange(DateTime now) {
    final normalizedNow = DateTime(now.year, now.month, now.day);

    switch (this) {
      case AnalyticsPeriodType.thisWeek:
        final start = normalizedNow.subtract(
          Duration(days: normalizedNow.weekday - DateTime.monday),
        );
        return AnalyticsDateRange(
          start: start,
          endExclusive: start.add(const Duration(days: 7)),
        );
      case AnalyticsPeriodType.thisMonth:
        final start = DateTime(normalizedNow.year, normalizedNow.month);
        return AnalyticsDateRange(
          start: start,
          endExclusive: DateTime(normalizedNow.year, normalizedNow.month + 1),
        );
    }
  }

  AnalyticsDateRange previousRange(DateTime now) {
    final current = currentRange(now);

    switch (this) {
      case AnalyticsPeriodType.thisWeek:
        final start = current.start.subtract(const Duration(days: 7));
        return AnalyticsDateRange(
          start: start,
          endExclusive: current.start,
        );
      case AnalyticsPeriodType.thisMonth:
        return AnalyticsDateRange(
          start: DateTime(current.start.year, current.start.month - 1),
          endExclusive: current.start,
        );
    }
  }
}

class AnalyticsTopSurahStat {
  const AnalyticsTopSurahStat({
    required this.surahNumber,
    required this.surahName,
    required this.visitCount,
  });

  final int surahNumber;
  final String surahName;
  final int visitCount;
}

class AnalyticsKhatmaProgress {
  const AnalyticsKhatmaProgress({
    required this.id,
    required this.title,
    required this.progress,
    required this.furthestPageRead,
    required this.totalReadMinutes,
  });

  final String id;
  final String title;
  final double progress;
  final int furthestPageRead;
  final int totalReadMinutes;
}

class AnalyticsReadingMetrics {
  const AnalyticsReadingMetrics({
    required this.totalMinutes,
    required this.normalizedVisitCount,
    required this.pagesVisitedCount,
    required this.readingDaysCount,
    required this.averageDailyMinutes,
    required this.currentStreakDays,
    required this.topSurahs,
  });

  final int totalMinutes;
  final int normalizedVisitCount;
  final int pagesVisitedCount;
  final int readingDaysCount;
  final double averageDailyMinutes;
  final int currentStreakDays;
  final List<AnalyticsTopSurahStat> topSurahs;

  bool get hasData =>
      totalMinutes > 0 ||
      normalizedVisitCount > 0 ||
      pagesVisitedCount > 0 ||
      readingDaysCount > 0;
}

class AnalyticsMemorizationMetrics {
  const AnalyticsMemorizationMetrics({
    required this.activeKhatmas,
    required this.completedReviewsCount,
    required this.reviewDueCount,
    required this.overdueReviewCount,
    required this.reviewAdherenceRate,
  });

  final List<AnalyticsKhatmaProgress> activeKhatmas;
  final int completedReviewsCount;
  final int reviewDueCount;
  final int overdueReviewCount;
  final double? reviewAdherenceRate;

  int get activeKhatmaCount => activeKhatmas.length;

  bool get hasReviewData =>
      completedReviewsCount > 0 || reviewDueCount > 0 || overdueReviewCount > 0;

  bool get hasData => activeKhatmas.isNotEmpty || hasReviewData;
}

class AnalyticsPrayerMetrics {
  const AnalyticsPrayerMetrics({
    required this.completedPrayersCount,
    required this.totalPossiblePrayersCount,
    required this.perfectDaysCount,
    required this.trackedDaysCount,
    required this.completionRate,
  });

  final int completedPrayersCount;
  final int totalPossiblePrayersCount;
  final int perfectDaysCount;
  final int trackedDaysCount;
  final double? completionRate;

  bool get hasData => trackedDaysCount > 0;
}

class AnalyticsPeriodSnapshot {
  const AnalyticsPeriodSnapshot({
    required this.type,
    required this.range,
    required this.reading,
    required this.memorization,
    required this.prayer,
  });

  final AnalyticsPeriodType type;
  final AnalyticsDateRange range;
  final AnalyticsReadingMetrics reading;
  final AnalyticsMemorizationMetrics memorization;
  final AnalyticsPrayerMetrics prayer;

  bool get hasAnyData =>
      reading.hasData || memorization.hasData || prayer.hasData;
}
