import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/story_chapter.dart';
import 'package:quran_kareem/features/stories/domain/story_verse.dart';
import 'package:quran_kareem/features/stories/presentation/story_lesson_box.dart';
import 'package:quran_kareem/features/stories/presentation/story_verse_card.dart';

class StoryChapterView extends StatelessWidget {
  const StoryChapterView({
    super.key,
    required this.chapter,
    this.onVersePressed,
  });

  final StoryChapter chapter;
  final ValueChanged<StoryVerse>? onVersePressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final localizations = MaterialLocalizations.of(context);
    final title = isEnglish && chapter.titleEn.trim().isNotEmpty
        ? chapter.titleEn
        : chapter.titleAr;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.storiesVerseCount(
              localizations.formatDecimal(chapter.verses.length),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDarkNav : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.camel.withValues(alpha: isDark ? 0.2 : 0.14),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                chapter.narrativeAr,
                softWrap: true,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  height: 1.9,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
          ),
          if (chapter.verses.isNotEmpty) ...[
            const SizedBox(height: 18),
            for (final verse in chapter.verses) ...[
              StoryVerseCard(
                verse: verse,
                onTap: onVersePressed == null
                    ? null
                    : () => onVersePressed!(verse),
              ),
              if (verse != chapter.verses.last) const SizedBox(height: 14),
            ],
          ],
          const SizedBox(height: 18),
          StoryLessonBox(
            lessonAr: chapter.lessonAr,
            lessonEn: chapter.lessonEn,
          ),
        ],
      ),
    );
  }
}
