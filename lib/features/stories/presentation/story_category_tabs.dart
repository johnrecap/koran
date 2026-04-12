import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/providers/story_providers.dart';

class StoryCategoryTabs extends ConsumerWidget {
  const StoryCategoryTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(storyFilterProvider);
    final bookmarks = ref.watch(storyBookmarkNotifierProvider);
    final hasBookmarks = bookmarks.isNotEmpty;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StoryCategoryChip(
          key: const Key('story-category-tab-all'),
          label: context.l10n.storiesAll,
          selected: filter.category == null && !filter.showFavorites,
          onSelected: () {
            ref.read(storyFilterProvider.notifier).state = filter.copyWith(
              clearCategory: true,
              showFavorites: false,
            );
          },
        ),
        _StoryCategoryChip(
          key: const Key('story-category-tab-favorites'),
          label: context.l10n.storiesFavorites,
          selected: filter.showFavorites,
          onSelected: hasBookmarks
              ? () {
                  ref.read(storyFilterProvider.notifier).state =
                      filter.copyWith(
                    clearCategory: true,
                    showFavorites: true,
                  );
                }
              : null,
        ),
        _StoryCategoryChip(
          key: const Key('story-category-tab-prophets'),
          label: context.l10n.storiesProphets,
          selected: filter.category == StoryCategory.prophets,
          onSelected: () {
            ref.read(storyFilterProvider.notifier).state = filter.copyWith(
              category: StoryCategory.prophets,
              showFavorites: false,
            );
          },
        ),
        _StoryCategoryChip(
          key: const Key('story-category-tab-quranic'),
          label: context.l10n.storiesQuranic,
          selected: filter.category == StoryCategory.quranic,
          onSelected: () {
            ref.read(storyFilterProvider.notifier).state = filter.copyWith(
              category: StoryCategory.quranic,
              showFavorites: false,
            );
          },
        ),
      ],
    );
  }
}

class _StoryCategoryChip extends StatelessWidget {
  const _StoryCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected != null ? (_) => onSelected!() : null,
      selectedColor: AppColors.gold.withValues(alpha: 0.18),
      side: BorderSide(
        color: AppColors.gold.withValues(alpha: 0.35),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Amiri',
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.gold : null,
      ),
      showCheckmark: false,
    );
  }
}
