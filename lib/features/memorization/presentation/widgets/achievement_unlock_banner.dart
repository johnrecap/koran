import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_dashboard_summary.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AchievementUnlockBanner extends StatelessWidget {
  const AchievementUnlockBanner({
    super.key,
    required this.summary,
    required this.unlocks,
    required this.onDismiss,
  });

  final AchievementDashboardSummary summary;
  final List<AchievementUnlock> unlocks;
  final Future<void> Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.gold.withValues(alpha: 0.2),
                  AppColors.surfaceDarkNav,
                ]
              : [
                  AppColors.gold.withValues(alpha: 0.16),
                  const Color(0xFFFFF7EA),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.achievementsUnlocksTitle,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final unlock in unlocks)
                Chip(
                  avatar: Icon(
                    unlock.type == AchievementUnlockType.level
                        ? Icons.trending_up_rounded
                        : Icons.workspace_premium_rounded,
                    size: 16,
                    color: AppColors.gold,
                  ),
                  label: Text(_labelForUnlock(context, unlock)),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.88),
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton(
              onPressed: () async {
                await onDismiss();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.achievementsUnlocksDismiss),
            ),
          ),
        ],
      ),
    );
  }

  String _labelForUnlock(BuildContext context, AchievementUnlock unlock) {
    final l10n = context.l10n;
    if (unlock.type == AchievementUnlockType.level) {
      return l10n.achievementsLevelValue(
        _formatNumber(context, unlock.level ?? 0),
      );
    }

    final badge = summary.badgeById(unlock.badgeId!);
    if (badge == null) {
      return unlock.id;
    }

    return l10n.value(badge.titleKey);
  }

  String _formatNumber(BuildContext context, int value) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }
}
