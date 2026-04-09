import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    this.progress,
    this.isBookmarked = false,
    this.onTap,
  });

  final QuranStory story;
  final StoryReadingProgress? progress;
  final bool isBookmarked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final title = isArabic ? story.titleAr : story.titleEn;
    final summary = isArabic ? story.summaryAr : story.summaryEn;
    final percent = progress?.completionPercent(story.chapterCount) ?? 0;
    final showProgress = percent > 0 && !(progress?.isCompleted ?? false);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('story-card-${story.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkNav : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _accentColorFor(story.category).withValues(
                alpha: isDark ? 0.26 : 0.14,
              ),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: _accentColorFor(story.category).withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _accentColorFor(story.category).withValues(
                          alpha: isDark ? 0.2 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _iconFor(story.iconKey),
                        color: _accentColorFor(story.category),
                      ),
                    ),
                    const Spacer(),
                    if (isBookmarked)
                      Icon(
                        Icons.favorite_rounded,
                        key: Key('story-card-bookmark-${story.id}'),
                        color: AppColors.gold,
                        size: 20,
                      ),
                    if (progress?.isCompleted ?? false) ...[
                      if (isBookmarked) const SizedBox(width: 6),
                      Container(
                        key: Key('story-card-complete-${story.id}'),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.meccan.withValues(
                            alpha: isDark ? 0.25 : 0.16,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.meccan,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      label: _categoryLabel(context, story.category),
                      color: _accentColorFor(story.category),
                    ),
                    _MetaChip(
                      label: context.l10n.storiesChapterCount(
                        localizations.formatDecimal(story.chapterCount),
                      ),
                    ),
                    _MetaChip(
                      label: context.l10n.storiesMinutesCount(
                        localizations
                            .formatDecimal(story.estimatedReadingMinutes),
                      ),
                    ),
                  ],
                ),
                if (showProgress) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      key: Key('story-card-progress-${story.id}'),
                      value: percent / 100,
                      minHeight: 6,
                      backgroundColor:
                          _accentColorFor(story.category).withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _accentColorFor(story.category),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: (color ?? AppColors.camel).withValues(
          alpha: isDark ? 0.16 : 0.1,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color ?? (isDark ? AppColors.textDark : AppColors.textLight),
        ),
      ),
    );
  }
}

String _categoryLabel(BuildContext context, StoryCategory category) {
  return switch (category) {
    StoryCategory.prophets => context.l10n.storiesProphets,
    StoryCategory.quranic => context.l10n.storiesQuranic,
  };
}

Color _accentColorFor(StoryCategory category) {
  return switch (category) {
    StoryCategory.prophets => AppColors.gold,
    StoryCategory.quranic => AppColors.meccan,
  };
}

IconData _iconFor(String iconKey) {
  return switch (iconKey) {
    'alert-triangle' => Icons.warning_amber_rounded,
    'beef' => Icons.restaurant_rounded,
    'book' => Icons.book_rounded,
    'book-open' => Icons.auto_stories_rounded,
    'book-x' => Icons.menu_book_rounded,
    'coins' => Icons.monetization_on_rounded,
    'cross' => Icons.add_rounded,
    'crown' => Icons.workspace_premium_rounded,
    'fish' => Icons.set_meal_rounded,
    'flame' => Icons.local_fire_department_rounded,
    'globe' => Icons.public_rounded,
    'heart' => Icons.favorite_outline_rounded,
    'leaf' => Icons.energy_savings_leaf_rounded,
    'map' => Icons.map_rounded,
    'map-pin' => Icons.place_rounded,
    'message-circle' => Icons.chat_bubble_outline_rounded,
    'moon' => Icons.dark_mode_rounded,
    'scale' => Icons.balance_rounded,
    'shield' => Icons.shield_outlined,
    'shield-alert' => Icons.gpp_bad_rounded,
    'ship' => Icons.directions_boat_rounded,
    'sparkles' => Icons.auto_awesome_rounded,
    'star' => Icons.star_rounded,
    'sun' => Icons.light_mode_rounded,
    'tree-deciduous' => Icons.park_rounded,
    'user' => Icons.person_rounded,
    'user-check' => Icons.verified_rounded,
    'user-plus' => Icons.person_add_alt_1_rounded,
    'users' => Icons.groups_rounded,
    'waves' => Icons.waves_rounded,
    'wind' => Icons.air_rounded,
    _ => Icons.auto_stories_rounded,
  };
}
