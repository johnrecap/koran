import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/stories/data/story_detail_data_source.dart';
import 'package:quran_kareem/features/stories/data/story_index_data_source.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_progress_notifier.dart';

final storyIndexDataSourceProvider = Provider<StoryIndexDataSource>(
  (ref) => StoryIndexDataSource(),
);

final storyDetailDataSourceProvider = Provider<StoryDetailDataSource>(
  (ref) => StoryDetailDataSource(),
);

final storyIndexProvider = FutureProvider<List<QuranStory>>((ref) async {
  return ref.watch(storyIndexDataSourceProvider).loadIndex();
});

final storyDetailProvider = FutureProvider.family<QuranStory, String>(
  (ref, file) async {
    return ref.watch(storyDetailDataSourceProvider).loadStory(file);
  },
);

final storyProgressNotifierProvider = StateNotifierProvider<
    StoryProgressNotifier, Map<String, StoryReadingProgress>>((ref) {
  return StoryProgressNotifier();
});

final storyBookmarkNotifierProvider =
    StateNotifierProvider<StoryBookmarkNotifier, Set<String>>((ref) {
  return StoryBookmarkNotifier();
});

final storyFilterProvider = StateProvider<StoryFilter>(
  (ref) => const StoryFilter(),
);

final filteredStoriesProvider = Provider<List<QuranStory>>((ref) {
  final stories = ref.watch(storyIndexProvider).maybeWhen(
        data: (stories) => stories,
        orElse: () => const <QuranStory>[],
      );
  final filter = ref.watch(storyFilterProvider);
  final normalizedQuery = filter.searchQuery.trim().toLowerCase();

  final filtered = stories.where((story) {
    if (filter.category != null && story.category != filter.category) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    return story.titleAr.toLowerCase().contains(normalizedQuery) ||
        story.titleEn.toLowerCase().contains(normalizedQuery);
  }).toList(growable: true);

  filtered.sort(_compareStories);
  return List<QuranStory>.unmodifiable(filtered);
});

final storyCompletionStatsProvider = Provider<StoryCompletionStats>((ref) {
  final stories = ref.watch(storyIndexProvider).maybeWhen(
        data: (stories) => stories,
        orElse: () => const <QuranStory>[],
      );
  final progressByStory = ref.watch(storyProgressNotifierProvider);
  final readCount = stories
      .where((story) => progressByStory[story.id]?.isCompleted ?? false)
      .length;

  return StoryCompletionStats(
    readCount: readCount,
    totalCount: stories.length,
  );
});

class StoryFilter {
  const StoryFilter({
    this.category,
    this.searchQuery = '',
  });

  final StoryCategory? category;
  final String searchQuery;

  StoryFilter copyWith({
    StoryCategory? category,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return StoryFilter(
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class StoryCompletionStats {
  const StoryCompletionStats({
    required this.readCount,
    required this.totalCount,
  });

  final int readCount;
  final int totalCount;

  double get completionPercent {
    if (totalCount <= 0) {
      return 0;
    }

    return ((readCount / totalCount) * 100).clamp(0, 100).toDouble();
  }
}

int _compareStories(QuranStory left, QuranStory right) {
  final orderComparison =
      (left.order ?? 1 << 30).compareTo(right.order ?? 1 << 30);
  if (orderComparison != 0) {
    return orderComparison;
  }

  return left.titleAr.compareTo(right.titleAr);
}
