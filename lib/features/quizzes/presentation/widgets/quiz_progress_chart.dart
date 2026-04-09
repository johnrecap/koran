import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

class QuizProgressChart extends StatelessWidget {
  const QuizProgressChart({
    super.key,
    required this.entries,
  });

  final List<QuizHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartEntries = _normalizedEntries(entries);

    return Container(
      key: const Key('quiz-progress-chart'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.26 : 0.14),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: chartEntries.length < 3
          ? _QuizProgressChartEmptyState(message: context.l10n.quizHistoryChartMinimum)
          : SizedBox(
              height: 220,
              child: LineChart(
                _buildChartData(
                  context: context,
                  entries: chartEntries,
                ),
              ),
            ),
    );
  }

  List<QuizHistoryEntry> _normalizedEntries(List<QuizHistoryEntry> values) {
    final sortedEntries = List<QuizHistoryEntry>.from(values)
      ..sort((left, right) => left.completedAt.compareTo(right.completedAt));

    if (sortedEntries.length <= 20) {
      return sortedEntries;
    }

    return sortedEntries.sublist(sortedEntries.length - 20);
  }

  LineChartData _buildChartData({
    required BuildContext context,
    required List<QuizHistoryEntry> entries,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);
    final chartSpots = <FlSpot>[
      for (var index = 0; index < entries.length; index += 1)
        FlSpot(index.toDouble(), _percentageFor(entries[index])),
    ];

    return LineChartData(
      minY: 0,
      maxY: 100,
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 14,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final entry = entries[spot.x.toInt()];
              final percentageLabel =
                  '${localizations.formatDecimal(_percentageFor(entry).round())}%';

              return LineTooltipItem(
                percentageLabel,
                TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  fontWeight: FontWeight.w800,
                ),
              );
            }).toList(growable: false);
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        horizontalInterval: 25,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) {
          return FlLine(
            color: AppColors.gold.withValues(alpha: isDark ? 0.18 : 0.10),
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 25,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDark : AppColors.textMuted,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= entries.length) {
                return const SizedBox.shrink();
              }

              final shouldShow =
                  index == 0 ||
                  index == entries.length - 1 ||
                  index == entries.length ~/ 2;
              if (!shouldShow) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  localizations.formatShortDate(entries[index].completedAt),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.textMuted,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: chartSpots,
          isCurved: true,
          barWidth: 3.2,
          color: AppColors.gold,
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.gold.withValues(alpha: isDark ? 0.20 : 0.12),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) {
              return FlDotCirclePainter(
                radius: 4.2,
                color: AppColors.gold,
                strokeColor: isDark ? AppColors.surfaceDarkNav : Colors.white,
                strokeWidth: 2,
              );
            },
          ),
        ),
      ],
    );
  }

  double _percentageFor(QuizHistoryEntry entry) {
    if (entry.totalQuestions <= 0) {
      return 0;
    }

    return (entry.score / entry.totalQuestions) * 100;
  }
}

class _QuizProgressChartEmptyState extends StatelessWidget {
  const _QuizProgressChartEmptyState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 220,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
