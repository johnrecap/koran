import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/widgets/app_error_widget.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/presentation/story_card.dart';
import 'package:quran_kareem/features/stories/presentation/story_category_tabs.dart';
import 'package:quran_kareem/features/stories/providers/story_providers.dart';

class StoriesHubScreen extends ConsumerStatefulWidget {
  const StoriesHubScreen({
    super.key,
    this.onStoryPressed,
  });

  final void Function(BuildContext context, QuranStory story)? onStoryPressed;

  @override
  ConsumerState<StoriesHubScreen> createState() => _StoriesHubScreenState();
}

class _StoriesHubScreenState extends ConsumerState<StoriesHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (_isSearchVisible) {
      _searchDebounce?.cancel();
      _searchController.clear();
      ref.read(storyFilterProvider.notifier).state =
          ref.read(storyFilterProvider).copyWith(searchQuery: '');
    }

    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        if (!mounted) {
          return;
        }

        ref.read(storyFilterProvider.notifier).state =
            ref.read(storyFilterProvider).copyWith(searchQuery: value.trim());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storiesAsync = ref.watch(storyIndexProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          context.l10n.quranStories,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('stories-hub-search-toggle'),
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
            ),
          ),
        ],
      ),
      body: storiesAsync.when(
        data: (_) => _StoriesHubLoadedBody(
          searchController: _searchController,
          isSearchVisible: _isSearchVisible,
          onSearchChanged: _onSearchChanged,
          onStoryPressed: (story) {
            final callback = widget.onStoryPressed;
            if (callback != null) {
              callback(context, story);
              return;
            }

            context.push('/library/stories/${story.id}');
          },
        ),
        loading: () => const _StoriesHubLoadingView(),
        error: (_, __) => AppErrorWidget(
          message: context.l10n.errorLoadingData,
          onRetry: () {
            ref.invalidate(storyIndexProvider);
          },
        ),
      ),
    );
  }
}

class _StoriesHubLoadedBody extends ConsumerWidget {
  const _StoriesHubLoadedBody({
    required this.searchController,
    required this.isSearchVisible,
    required this.onSearchChanged,
    required this.onStoryPressed,
  });

  final TextEditingController searchController;
  final bool isSearchVisible;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<QuranStory> onStoryPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stories = ref.watch(filteredStoriesProvider);
    final progressByStory = ref.watch(storyProgressNotifierProvider);
    final bookmarks = ref.watch(storyBookmarkNotifierProvider);
    final stats = ref.watch(storyCompletionStatsProvider);
    final localizations = MaterialLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSearchVisible)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              key: const Key('stories-hub-search-field'),
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.storiesSearchHint,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Amiri',
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceDarkNav
                    : AppColors.camel.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            context.l10n.storiesReadSummary(
              localizations.formatDecimal(stats.readCount),
              localizations.formatDecimal(stats.totalCount),
            ),
            key: const Key('stories-hub-stats'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: StoryCategoryTabs(),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (stories.isEmpty) {
                return _StoriesHubEmptyState(
                  title: context.l10n.storiesNoResults,
                );
              }

              final crossAxisCount = constraints.maxWidth < 520 ? 1 : 2;

              return GridView.builder(
                key: const Key('stories-hub-grid'),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: crossAxisCount == 1 ? 2.35 : 0.88,
                ),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return StoryCard(
                    story: story,
                    progress: progressByStory[story.id],
                    isBookmarked: bookmarks.contains(story.id),
                    onTap: () => onStoryPressed(story),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoriesHubLoadingView extends StatelessWidget {
  const _StoriesHubLoadingView();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 520 ? 1 : 2;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 1 ? 2.35 : 0.88,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return const _StoryCardSkeleton();
          },
        );
      },
    );
  }
}

class _StoryCardSkeleton extends StatelessWidget {
  const _StoryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.camel.withValues(alpha: isDark ? 0.18 : 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.camel.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 14),
            const _SkeletonLine(widthFactor: 0.72),
            const SizedBox(height: 8),
            const _SkeletonLine(widthFactor: 0.9),
            const SizedBox(height: 6),
            const _SkeletonLine(widthFactor: 0.78),
            const Spacer(),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SkeletonChip(),
                _SkeletonChip(),
                _SkeletonChip(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.camel.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SkeletonChip extends StatelessWidget {
  const _SkeletonChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.camel.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _StoriesHubEmptyState extends StatelessWidget {
  const _StoriesHubEmptyState({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 64,
              color: AppColors.gold.withValues(alpha: 0.28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textDark
                    : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
