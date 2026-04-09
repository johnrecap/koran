import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_dashboard_summary.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_empty_state.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AnalyticsPrayerCard extends StatelessWidget {
  const AnalyticsPrayerCard({
    super.key,
    required this.snapshot,
    required this.delta,
  });

  final AnalyticsPeriodSnapshot snapshot;
  final AnalyticsMetricDelta delta;

  @override
  Widget build(BuildContext context) {
    final prayer = snapshot.prayer;

    if (!prayer.hasData) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: AnalyticsEmptyState(
          key: const Key('analytics-prayer-empty-state'),
          icon: Icons.mosque_outlined,
          title: context.l10n.analyticsPrayerEmptyTitle,
          subtitle: context.l10n.analyticsPrayerEmptySubtitle,
        ),
      );
    }

    return Padding(
      key: const Key('analytics-prayer-card'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatPercentage(context, prayer.completionRate ?? 0),
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _deltaText(context, delta),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          if ((prayer.completionRate ?? 0) == 1) ...[
            const SizedBox(height: 6),
            Text(
              context.l10n.analyticsPrayerPerfectState,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                label: context.l10n.analyticsPrayerPerfectDaysLabel,
                value: _formatNumber(context, prayer.perfectDaysCount),
              ),
              _MetricChip(
                label: context.l10n.analyticsPrayerTrackedDaysLabel,
                value: _formatNumber(context, prayer.trackedDaysCount),
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

  String _formatNumber(BuildContext context, int value) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }

  String _formatPercentage(BuildContext context, double value) {
    final percent = (value * 100).round();
    return '${_formatNumber(context, percent)}%';
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
