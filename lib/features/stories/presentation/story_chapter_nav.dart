import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';

class StoryChapterNav extends StatelessWidget {
  const StoryChapterNav({
    super.key,
    required this.currentChapterIndex,
    required this.totalChapters,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentChapterIndex;
  final int totalChapters;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkNav : Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.camel.withValues(alpha: isDark ? 0.2 : 0.14),
            ),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('story-chapter-nav-previous'),
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded),
                label: Text(context.l10n.storiesPreviousChapter),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDark ? AppColors.textDark : AppColors.textLight,
                  side: BorderSide(
                    color: AppColors.camel.withValues(alpha: 0.28),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.storiesChapterOf(
                  localizations.formatDecimal(currentChapterIndex + 1),
                  localizations.formatDecimal(totalChapters),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                key: const Key('story-chapter-nav-next'),
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
                label: Text(context.l10n.storiesNextChapter),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
