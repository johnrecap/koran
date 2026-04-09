import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_dashboard_summary.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_definition.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AchievementBadgeTile extends StatelessWidget {
  const AchievementBadgeTile({
    super.key,
    required this.badge,
  });

  final AchievementBadgeState badge;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _accentForCategory(badge.category);
    final statusText = badge.isUnlocked
        ? l10n.achievementsBadgeStatusUnlocked
        : l10n.achievementsBadgeStatusInProgress;

    return Opacity(
      opacity: badge.isUnlocked ? 1 : 0.92,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: badge.isUnlocked ? 0.06 : 0.04)
              : Colors.white.withValues(alpha: badge.isUnlocked ? 0.94 : 0.84),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:
                accentColor.withValues(alpha: badge.isUnlocked ? 0.28 : 0.16),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
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
                    color: accentColor.withValues(
                        alpha: badge.isUnlocked ? 0.14 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForCategory(badge.category),
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(
                        alpha: badge.isUnlocked ? 0.14 : 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.value(badge.titleKey),
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.value(badge.descriptionKey),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.45,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 8,
                backgroundColor: accentColor.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.achievementsBadgeProgress(
                _formatNumber(context, badge.currentValue),
                _formatNumber(context, badge.targetValue),
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(AchievementBadgeCategory category) {
    switch (category) {
      case AchievementBadgeCategory.reading:
        return Icons.menu_book_rounded;
      case AchievementBadgeCategory.streak:
        return Icons.local_fire_department_rounded;
      case AchievementBadgeCategory.khatma:
        return Icons.auto_stories_rounded;
      case AchievementBadgeCategory.review:
        return Icons.repeat_rounded;
    }
  }

  Color _accentForCategory(AchievementBadgeCategory category) {
    switch (category) {
      case AchievementBadgeCategory.reading:
        return AppColors.gold;
      case AchievementBadgeCategory.streak:
        return AppColors.warmBrown;
      case AchievementBadgeCategory.khatma:
        return AppColors.meccan;
      case AchievementBadgeCategory.review:
        return AppColors.medinan;
    }
  }

  String _formatNumber(BuildContext context, int value) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }
}
