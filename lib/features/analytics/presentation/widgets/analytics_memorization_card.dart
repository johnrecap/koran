import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_empty_state.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AnalyticsMemorizationCard extends StatelessWidget {
  const AnalyticsMemorizationCard({
    super.key,
    required this.snapshot,
  });

  final AnalyticsPeriodSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final memorization = snapshot.memorization;

    if (!memorization.hasData) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: AnalyticsEmptyState(
          icon: Icons.psychology_outlined,
          title: context.l10n.analyticsMemorizationEmptyTitle,
          subtitle: context.l10n.analyticsMemorizationEmptySubtitle,
        ),
      );
    }

    return Padding(
      key: const Key('analytics-memorization-card'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                label: context.l10n.analyticsMemorizationActiveKhatmasLabel,
                value: _formatNumber(context, memorization.activeKhatmaCount),
              ),
              _MetricChip(
                label: context.l10n.analyticsMemorizationDueReviewsLabel,
                value: _formatNumber(context, memorization.reviewDueCount),
              ),
              _MetricChip(
                label: context.l10n.analyticsMemorizationAdherenceLabel,
                value: memorization.reviewAdherenceRate == null
                    ? context.l10n.analyticsReviewAdherenceEmptyValue
                    : _formatPercentage(
                        context,
                        memorization.reviewAdherenceRate!,
                      ),
              ),
            ],
          ),
          if (memorization.activeKhatmas.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final khatma in memorization.activeKhatmas)
              _KhatmaProgressRow(khatma: khatma),
          ],
          if (!memorization.hasReviewData) ...[
            const SizedBox(height: 16),
            Text(
              key: const Key('analytics-review-empty-hint'),
              context.l10n.analyticsReviewEmptySubtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
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

class _KhatmaProgressRow extends StatelessWidget {
  const _KhatmaProgressRow({
    required this.khatma,
  });

  final AnalyticsKhatmaProgress khatma;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            khatma.title,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: khatma.progress,
              minHeight: 8,
              backgroundColor: AppColors.camel.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(khatma.progress * 100).round()}%',
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
