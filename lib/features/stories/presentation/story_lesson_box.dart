import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';

class StoryLessonBox extends StatelessWidget {
  const StoryLessonBox({
    super.key,
    required this.lessonAr,
    required this.lessonEn,
  });

  final String lessonAr;
  final String lessonEn;

  @override
  Widget build(BuildContext context) {
    final lesson = _resolveLesson(context);
    if (lesson.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.meccan.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.meccan.withValues(alpha: isDark ? 0.3 : 0.24),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.meccan.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.meccan.withValues(alpha: isDark ? 0.24 : 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.meccan,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.storiesLesson,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.meccan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveLesson(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (isEnglish && lessonEn.trim().isNotEmpty) {
      return lessonEn;
    }
    return lessonAr.trim();
  }
}
