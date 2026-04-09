import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';

class StoryCompletionView extends StatelessWidget {
  const StoryCompletionView({
    super.key,
    required this.story,
    required this.onMarkAsRead,
    required this.onBackToHub,
  });

  final QuranStory story;
  final VoidCallback onMarkAsRead;
  final VoidCallback onBackToHub;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final title = isEnglish && story.titleEn.trim().isNotEmpty
        ? story.titleEn
        : story.titleAr;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.meccan.withValues(alpha: isDark ? 0.22 : 0.14),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 44,
                color: AppColors.meccan,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.storiesCompletedTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.storiesCompletedMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _StoryCompletionStatChip(
                  label: context.l10n.storiesChapterCount(
                    localizations.formatDecimal(story.chapterCount),
                  ),
                ),
                _StoryCompletionStatChip(
                  label: context.l10n.storiesVerseCount(
                    localizations.formatDecimal(story.totalVerses),
                  ),
                ),
                _StoryCompletionStatChip(
                  label: context.l10n.storiesMinutesCount(
                    localizations.formatDecimal(story.estimatedReadingMinutes),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('story-completion-mark-read'),
                onPressed: onMarkAsRead,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(context.l10n.storiesMarkAsRead),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.meccan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('story-completion-back'),
                onPressed: onBackToHub,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(context.l10n.storiesBackToHub),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDark ? AppColors.textDark : AppColors.textLight,
                  side: BorderSide(
                    color: AppColors.camel.withValues(alpha: 0.28),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

class _StoryCompletionStatChip extends StatelessWidget {
  const _StoryCompletionStatChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.camel.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }
}
