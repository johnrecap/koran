import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/stories/data/story_detail_data_source.dart';
import 'package:quran_kareem/features/stories/data/story_index_data_source.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:quran_kareem/features/stories/providers/story_progress_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_providers.dart';

void main() {
  group('story providers', () {
    test('storyIndexProvider loads stories from the index data source',
        () async {
      final stories = <QuranStory>[
        _buildStory(
          id: 'adam',
          titleAr: 'آدم',
          titleEn: 'Adam',
          category: StoryCategory.prophets,
          order: 2,
        ),
        _buildStory(
          id: 'maryam',
          titleAr: 'مريم',
          titleEn: 'Maryam',
          category: StoryCategory.quranic,
          order: 1,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          storyIndexDataSourceProvider.overrideWithValue(
            _FakeStoryIndexDataSource(stories),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(storyIndexProvider),
        isA<AsyncLoading<List<QuranStory>>>(),
      );
      expect(await container.read(storyIndexProvider.future), same(stories));
    });

    test(
        'storyDetailProvider loads a story by file from the detail data source',
        () async {
      final story = _buildStory(
        id: 'musa',
        file: 'musa.json',
        titleAr: 'موسى',
        titleEn: 'Moses',
        category: StoryCategory.prophets,
        order: 4,
      );
      final container = ProviderContainer(
        overrides: [
          storyDetailDataSourceProvider.overrideWithValue(
            _FakeStoryDetailDataSource(<String, QuranStory>{
              'musa.json': story,
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        await container.read(storyDetailProvider('musa.json').future),
        same(story),
      );
    });

    test(
        'filteredStoriesProvider sorts by order and filters by category and search',
        () async {
      final container = ProviderContainer(
        overrides: [
          storyIndexDataSourceProvider.overrideWithValue(
            _FakeStoryIndexDataSource(<QuranStory>[
              _buildStory(
                id: 'musa',
                titleAr: 'موسى',
                titleEn: 'Moses',
                category: StoryCategory.prophets,
                order: 3,
              ),
              _buildStory(
                id: 'maryam',
                titleAr: 'مريم',
                titleEn: 'Maryam',
                category: StoryCategory.quranic,
                order: 2,
              ),
              _buildStory(
                id: 'yusuf',
                titleAr: 'يوسف',
                titleEn: 'Joseph',
                category: StoryCategory.prophets,
                order: 1,
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(storyIndexProvider.future);

      expect(
        container
            .read(filteredStoriesProvider)
            .map((story) => story.id)
            .toList(),
        <String>['yusuf', 'maryam', 'musa'],
      );

      container.read(storyFilterProvider.notifier).state = const StoryFilter(
        category: StoryCategory.prophets,
        searchQuery: 'يوس',
      );

      expect(
        container
            .read(filteredStoriesProvider)
            .map((story) => story.id)
            .toList(),
        <String>['yusuf'],
      );

      container.read(storyFilterProvider.notifier).state = const StoryFilter(
        searchQuery: 'MOS',
      );

      expect(
        container
            .read(filteredStoriesProvider)
            .map((story) => story.id)
            .toList(),
        <String>['musa'],
      );
    });

    test('storyCompletionStatsProvider counts completed stories and percent',
        () async {
      final container = ProviderContainer(
        overrides: [
          storyIndexDataSourceProvider.overrideWithValue(
            _FakeStoryIndexDataSource(<QuranStory>[
              _buildStory(
                id: 'adam',
                titleAr: 'آدم',
                titleEn: 'Adam',
                category: StoryCategory.prophets,
                order: 1,
              ),
              _buildStory(
                id: 'musa',
                titleAr: 'موسى',
                titleEn: 'Moses',
                category: StoryCategory.prophets,
                order: 2,
              ),
              _buildStory(
                id: 'yusuf',
                titleAr: 'يوسف',
                titleEn: 'Joseph',
                category: StoryCategory.prophets,
                order: 3,
              ),
              _buildStory(
                id: 'maryam',
                titleAr: 'مريم',
                titleEn: 'Maryam',
                category: StoryCategory.quranic,
                order: 4,
              ),
            ]),
          ),
          storyProgressNotifierProvider.overrideWith(
            (ref) => StoryProgressNotifier(
              loadProgress: () async => <String, StoryReadingProgress>{
                'adam': StoryReadingProgress(
                  storyId: 'adam',
                  lastChapterIndex: 4,
                  completedAt: DateTime.utc(2026, 4, 8, 10),
                ),
                'musa': StoryReadingProgress(
                  storyId: 'musa',
                  lastChapterIndex: 7,
                  completedAt: DateTime.utc(2026, 4, 8, 11),
                ),
                'yusuf': const StoryReadingProgress(
                  storyId: 'yusuf',
                  lastChapterIndex: 2,
                ),
              },
              saveProgress: (_) async {},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(storyIndexProvider.future);
      await container.read(storyProgressNotifierProvider.notifier).ready;

      final stats = container.read(storyCompletionStatsProvider);

      expect(stats.readCount, 2);
      expect(stats.totalCount, 4);
      expect(stats.completionPercent, 50);
    });
  });
}

QuranStory _buildStory({
  required String id,
  String? file,
  required String titleAr,
  required String titleEn,
  required StoryCategory category,
  required int order,
}) {
  return QuranStory(
    id: id,
    file: file ?? '$id.json',
    titleAr: titleAr,
    titleEn: titleEn,
    category: category,
    iconKey: 'icon_$id',
    summaryAr: 'summary $titleAr',
    summaryEn: 'summary $titleEn',
    chapterCount: 3,
    totalVerses: 4,
    estimatedReadingMinutes: 5,
    mainSurahsAr: const <String>['البقرة'],
    mainSurahsNumbers: const <int>[2],
    order: order,
  );
}

class _FakeStoryIndexDataSource extends StoryIndexDataSource {
  _FakeStoryIndexDataSource(this._stories);

  final List<QuranStory> _stories;

  @override
  Future<List<QuranStory>> loadIndex() async => _stories;
}

class _FakeStoryDetailDataSource extends StoryDetailDataSource {
  _FakeStoryDetailDataSource(this._storiesByFile);

  final Map<String, QuranStory> _storiesByFile;

  @override
  Future<QuranStory> loadStory(String file) async {
    return _storiesByFile[file]!;
  }
}
