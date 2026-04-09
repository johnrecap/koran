import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';

enum AnalyticsDeltaDirection {
  up,
  down,
  neutral,
}

class AnalyticsMetricDelta {
  const AnalyticsMetricDelta({
    required this.currentValue,
    required this.previousValue,
    required this.direction,
    required this.percentageChange,
  });

  final double currentValue;
  final double previousValue;
  final AnalyticsDeltaDirection direction;
  final double? percentageChange;

  bool get isNew => previousValue == 0 && currentValue > 0;
  bool get isNeutral => direction == AnalyticsDeltaDirection.neutral;
  bool get hasPercentage => percentageChange != null;
  int get roundedPercentage => ((percentageChange ?? 0) * 100).round();
}

class AnalyticsDashboardSummary {
  const AnalyticsDashboardSummary({
    required this.periodType,
    required this.current,
    required this.previous,
    required this.totalMinutesDelta,
    required this.normalizedVisitsDelta,
    required this.averageDailyMinutesDelta,
    required this.readingDaysDelta,
    required this.prayerCompletionDelta,
  });

  final AnalyticsPeriodType periodType;
  final AnalyticsPeriodSnapshot current;
  final AnalyticsPeriodSnapshot previous;
  final AnalyticsMetricDelta totalMinutesDelta;
  final AnalyticsMetricDelta normalizedVisitsDelta;
  final AnalyticsMetricDelta averageDailyMinutesDelta;
  final AnalyticsMetricDelta readingDaysDelta;
  final AnalyticsMetricDelta prayerCompletionDelta;
}

abstract final class AnalyticsDashboardSummaryPolicy {
  static AnalyticsDashboardSummary build({
    required AnalyticsPeriodType periodType,
    required AnalyticsPeriodSnapshot current,
    required AnalyticsPeriodSnapshot previous,
  }) {
    return AnalyticsDashboardSummary(
      periodType: periodType,
      current: current,
      previous: previous,
      totalMinutesDelta: _buildDelta(
        current.reading.totalMinutes.toDouble(),
        previous.reading.totalMinutes.toDouble(),
      ),
      normalizedVisitsDelta: _buildDelta(
        current.reading.normalizedVisitCount.toDouble(),
        previous.reading.normalizedVisitCount.toDouble(),
      ),
      averageDailyMinutesDelta: _buildDelta(
        current.reading.averageDailyMinutes,
        previous.reading.averageDailyMinutes,
      ),
      readingDaysDelta: _buildDelta(
        current.reading.readingDaysCount.toDouble(),
        previous.reading.readingDaysCount.toDouble(),
      ),
      prayerCompletionDelta: _buildDelta(
        current.prayer.completionRate ?? 0,
        previous.prayer.completionRate ?? 0,
      ),
    );
  }

  static AnalyticsMetricDelta _buildDelta(double current, double previous) {
    if (current == previous) {
      return AnalyticsMetricDelta(
        currentValue: current,
        previousValue: previous,
        direction: AnalyticsDeltaDirection.neutral,
        percentageChange: 0,
      );
    }

    if (previous == 0) {
      return AnalyticsMetricDelta(
        currentValue: current,
        previousValue: previous,
        direction: current > 0
            ? AnalyticsDeltaDirection.up
            : AnalyticsDeltaDirection.neutral,
        percentageChange: null,
      );
    }

    return AnalyticsMetricDelta(
      currentValue: current,
      previousValue: previous,
      direction: current > previous
          ? AnalyticsDeltaDirection.up
          : AnalyticsDeltaDirection.down,
      percentageChange: ((current - previous).abs() / previous),
    );
  }
}
