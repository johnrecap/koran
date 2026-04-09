import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_empty_state.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AnalyticsTopSurahsCard extends StatelessWidget {
  const AnalyticsTopSurahsCard({
    super.key,
    required this.topSurahs,
  });

  final List<AnalyticsTopSurahStat> topSurahs;

  @override
  Widget build(BuildContext context) {
    if (topSurahs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: AnalyticsEmptyState(
          icon: Icons.auto_stories_outlined,
          title: context.l10n.analyticsTopSurahsEmptyTitle,
          subtitle: context.l10n.analyticsTopSurahsEmptySubtitle,
        ),
      );
    }

    return Padding(
      key: const Key('analytics-top-surahs-card'),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
      child: Column(
        children: [
          for (var index = 0; index < topSurahs.length; index += 1)
            _SurahRow(
              rank: index + 1,
              stat: topSurahs[index],
            ),
        ],
      ),
    );
  }
}

class _SurahRow extends StatelessWidget {
  const _SurahRow({
    required this.rank,
    required this.stat,
  });

  final int rank;
  final AnalyticsTopSurahStat stat;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.camel.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.16),
            ),
            child: Center(
              child: Text(
                _formatNumber(context, rank),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stat.surahName,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            context.l10n.analyticsVisitCount(
              _formatNumber(context, stat.visitCount),
            ),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
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
}
