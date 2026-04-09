import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AnalyticsReadingDetailCard extends StatelessWidget {
  const AnalyticsReadingDetailCard({
    super.key,
    required this.snapshot,
  });

  final AnalyticsPeriodSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('analytics-reading-detail-card'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _MetricTile(
            label: context.l10n.analyticsReadingAverageDailyLabel,
            value: _formatDuration(
              context,
              snapshot.reading.averageDailyMinutes.round(),
            ),
          ),
          _MetricTile(
            label: context.l10n.analyticsReadingPagesLabel,
            value: _formatNumber(context, snapshot.reading.pagesVisitedCount),
          ),
          _MetricTile(
            label: context.l10n.analyticsReadingDaysLabel,
            value: _formatNumber(context, snapshot.reading.readingDaysCount),
          ),
        ],
      ),
    );
  }

  String _formatDuration(BuildContext context, int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return context.l10n.memorizationPlannerTrackedTimeValue(
      _formatNumber(context, hours),
      _formatNumber(context, minutes),
    );
  }

  String _formatNumber(BuildContext context, int value) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.camel.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
