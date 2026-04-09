import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_dashboard_summary.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';

void main() {
  test('computes up and down deltas between two periods', () {
    final summary = AnalyticsDashboardSummaryPolicy.build(
      periodType: AnalyticsPeriodType.thisWeek,
      current: _snapshot(
        range: AnalyticsPeriodType.thisWeek.currentRange(
          DateTime(2026, 4, 3, 12),
        ),
        totalMinutes: 90,
        visits: 6,
        readingDays: 4,
        averageDailyMinutes: 12.85,
        prayerRate: 0.6,
      ),
      previous: _snapshot(
        range: AnalyticsPeriodType.thisWeek.previousRange(
          DateTime(2026, 4, 3, 12),
        ),
        totalMinutes: 60,
        visits: 8,
        readingDays: 5,
        averageDailyMinutes: 8.57,
        prayerRate: 0.8,
      ),
    );

    expect(summary.totalMinutesDelta.direction, AnalyticsDeltaDirection.up);
    expect(summary.totalMinutesDelta.roundedPercentage, 50);
    expect(
      summary.normalizedVisitsDelta.direction,
      AnalyticsDeltaDirection.down,
    );
    expect(summary.normalizedVisitsDelta.roundedPercentage, 25);
    expect(
      summary.averageDailyMinutesDelta.direction,
      AnalyticsDeltaDirection.up,
    );
    expect(
        summary.prayerCompletionDelta.direction, AnalyticsDeltaDirection.down);
  });

  test('returns neutral deltas for identical period values', () {
    final current = _snapshot(
      range: AnalyticsPeriodType.thisMonth.currentRange(
        DateTime(2026, 4, 3, 12),
      ),
      totalMinutes: 40,
      visits: 2,
      readingDays: 2,
      averageDailyMinutes: 1.3,
      prayerRate: 0.2,
    );

    final summary = AnalyticsDashboardSummaryPolicy.build(
      periodType: AnalyticsPeriodType.thisMonth,
      current: current,
      previous: current,
    );

    expect(
        summary.totalMinutesDelta.direction, AnalyticsDeltaDirection.neutral);
    expect(summary.totalMinutesDelta.roundedPercentage, 0);
    expect(summary.readingDaysDelta.direction, AnalyticsDeltaDirection.neutral);
  });

  test(
      'marks zero-previous-value growth as new instead of forcing a percentage',
      () {
    final summary = AnalyticsDashboardSummaryPolicy.build(
      periodType: AnalyticsPeriodType.thisWeek,
      current: _snapshot(
        range: AnalyticsPeriodType.thisWeek.currentRange(
          DateTime(2026, 4, 3, 12),
        ),
        totalMinutes: 15,
        visits: 1,
        readingDays: 1,
        averageDailyMinutes: 2.14,
        prayerRate: 0.1,
      ),
      previous: _snapshot(
        range: AnalyticsPeriodType.thisWeek.previousRange(
          DateTime(2026, 4, 3, 12),
        ),
      ),
    );

    expect(summary.totalMinutesDelta.direction, AnalyticsDeltaDirection.up);
    expect(summary.totalMinutesDelta.isNew, isTrue);
    expect(summary.totalMinutesDelta.hasPercentage, isFalse);
  });

  test('derives ISO week and calendar month comparison ranges correctly', () {
    final weekCurrent = AnalyticsPeriodType.thisWeek.currentRange(
      DateTime(2026, 4, 3, 12),
    );
    final weekPrevious = AnalyticsPeriodType.thisWeek.previousRange(
      DateTime(2026, 4, 3, 12),
    );
    final monthCurrent = AnalyticsPeriodType.thisMonth.currentRange(
      DateTime(2026, 4, 3, 12),
    );
    final monthPrevious = AnalyticsPeriodType.thisMonth.previousRange(
      DateTime(2026, 4, 3, 12),
    );

    expect(weekCurrent.start, DateTime(2026, 3, 30));
    expect(weekCurrent.endExclusive, DateTime(2026, 4, 6));
    expect(weekPrevious.start, DateTime(2026, 3, 23));
    expect(weekPrevious.endExclusive, DateTime(2026, 3, 30));
    expect(monthCurrent.start, DateTime(2026, 4, 1));
    expect(monthCurrent.endExclusive, DateTime(2026, 5, 1));
    expect(monthPrevious.start, DateTime(2026, 3, 1));
    expect(monthPrevious.endExclusive, DateTime(2026, 4, 1));
  });
}

AnalyticsPeriodSnapshot _snapshot({
  required AnalyticsDateRange range,
  int totalMinutes = 0,
  int visits = 0,
  int readingDays = 0,
  double averageDailyMinutes = 0,
  double? prayerRate,
}) {
  return AnalyticsPeriodSnapshot(
    type: AnalyticsPeriodType.thisWeek,
    range: range,
    reading: AnalyticsReadingMetrics(
      totalMinutes: totalMinutes,
      normalizedVisitCount: visits,
      pagesVisitedCount: 0,
      readingDaysCount: readingDays,
      averageDailyMinutes: averageDailyMinutes,
      currentStreakDays: 0,
      topSurahs: const <AnalyticsTopSurahStat>[],
    ),
    memorization: const AnalyticsMemorizationMetrics(
      activeKhatmas: <AnalyticsKhatmaProgress>[],
      completedReviewsCount: 0,
      reviewDueCount: 0,
      overdueReviewCount: 0,
      reviewAdherenceRate: null,
    ),
    prayer: AnalyticsPrayerMetrics(
      completedPrayersCount: prayerRate == null ? 0 : 1,
      totalPossiblePrayersCount: prayerRate == null ? 0 : 1,
      perfectDaysCount: 0,
      trackedDaysCount: prayerRate == null ? 0 : 1,
      completionRate: prayerRate,
    ),
  );
}
