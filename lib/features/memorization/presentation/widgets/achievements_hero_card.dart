import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_dashboard_summary.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AchievementsHeroCard extends StatelessWidget {
  const AchievementsHeroCard({
    super.key,
    required this.summary,
  });

  final AchievementDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levelValue = _formatNumber(context, summary.level);
    final xpValue = _formatNumber(context, summary.totalXp);
    final currentProgress = _formatNumber(
      context,
      summary.totalXp - summary.currentLevelStartXp,
    );
    final nextProgress = _formatNumber(
      context,
      summary.nextLevelXp - summary.currentLevelStartXp,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF3B2C1E),
                  AppColors.surfaceDarkNav,
                ]
              : [
                  const Color(0xFFFFF0D4),
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
      child: Stack(
        children: [
          PositionedDirectional(
            top: -10,
            end: -6,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.achievementsLevelValue(levelValue),
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.achievementsXpValue(xpValue),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l10n.achievementsNextLevelLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: summary.progressToNextLevel,
                  minHeight: 10,
                  backgroundColor: AppColors.camel.withValues(alpha: 0.14),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.achievementsProgressValue(currentProgress, nextProgress),
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
                    value: _formatNumber(context, summary.totalVisits),
                    label: l10n.achievementsStatVisits,
                  ),
                  _HeroStatChip(
                    value: _formatNumber(context, summary.totalTrackedMinutes),
                    label: l10n.achievementsStatMinutes,
                  ),
                  _HeroStatChip(
                    value: _formatNumber(context, summary.completedKhatmas),
                    label: l10n.achievementsStatKhatmas,
                  ),
                  _HeroStatChip(
                    value: _formatNumber(context, summary.reviewedReviews),
                    label: l10n.achievementsStatReviews,
                  ),
                ],
              ),
            ],
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
