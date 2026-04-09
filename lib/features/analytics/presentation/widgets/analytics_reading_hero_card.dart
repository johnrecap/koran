import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_dashboard_summary.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AnalyticsReadingHeroCard extends StatelessWidget {
  const AnalyticsReadingHeroCard({
    super.key,
    required this.summary,
  });

  final AnalyticsDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reading = summary.current.reading;

    return Container(
      key: const Key('analytics-reading-hero'),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF243425),
                  AppColors.surfaceDarkNav,
                ]
              : [
                  const Color(0xFFF0F7EA),
                  Colors.white,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.18 : 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.analyticsReadingHeroEyebrow,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(context, reading.totalMinutes),
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.analyticsReadingHeroTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _deltaText(context, summary.totalMinutesDelta),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatChip(
                value: _formatNumber(context, reading.normalizedVisitCount),
                label: l10n.analyticsReadingVisitsLabel,
              ),
              _HeroStatChip(
                value: _formatNumber(context, reading.currentStreakDays),
                label: l10n.analyticsReadingStreakLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _deltaText(BuildContext context, AnalyticsMetricDelta delta) {
    final l10n = context.l10n;
    if (delta.isNew) {
      return l10n.analyticsDeltaNew;
    }
    if (delta.isNeutral) {
      return l10n.analyticsDeltaNoChange;
    }

    final percentage = _formatNumber(context, delta.roundedPercentage);
    final arrow = delta.direction == AnalyticsDeltaDirection.up ? '↑' : '↓';
    return '$arrow ${l10n.analyticsDeltaComparedToPrevious('$percentage%')}';
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

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.camel.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.08 : 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
