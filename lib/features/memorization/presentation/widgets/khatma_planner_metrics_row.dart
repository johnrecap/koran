import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_planner_summary.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class KhatmaPlannerMetricsRow extends StatelessWidget {
  const KhatmaPlannerMetricsRow({
    super.key,
    required this.summary,
  });

  final KhatmaPlannerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlannerMetricCard(
            label: context.l10n.memorizationPlannerReadingStreak,
            value: _formatNumber(context, summary.streakDays),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PlannerMetricCard(
            label: context.l10n.memorizationPlannerTrackedTime,
            value: _formatMinutes(context, summary.totalReadMinutes),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PlannerMetricCard(
            label: context.l10n.memorizationPlannerPagesRemaining,
            value: _formatNumber(context, summary.remainingPages),
          ),
        ),
      ],
    );
  }

  String _formatNumber(BuildContext context, int value) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }

  String _formatMinutes(BuildContext context, int minutes) {
    if (minutes <= 0) {
      return _formatNumber(context, 0);
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return context.l10n.memorizationPlannerTrackedTimeValue(
      _formatNumber(context, hours),
      _formatNumber(context, remainingMinutes),
    );
  }
}

class _PlannerMetricCard extends StatelessWidget {
  const _PlannerMetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
