import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:quran_kareem/features/stories/presentation/stories_hub_screen.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_progress_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_providers.dart';

void main() {
  testWidgets('renders the grid with the expected stories and stats',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          storyIndexProvider.overrideWith((ref) async => _stories),
          storyProgressNotifierProvider.overrideWith(
            (ref) => StoryProgressNotifier(
              loadProgress: () async => <String, StoryReadingProgress>{
                'maryam': StoryReadingProgress(
                  storyId: 'maryam',
                  lastChapterIndex: 6,
                  completedAt: DateTime.utc(2026, 4, 8, 12),
                ),
              },
              saveProgress: (_) async {},
            ),
          ),
          storyBookmarkNotifierProvider.overrideWith(
            (ref) => StoryBookmarkNotifier(
              loadBookmarks: () async => <String>{'maryam'},
              toggleBookmark: (_) async {},
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quran Stories'), findsOneWidget);
    expect(find.byKey(const Key('stories-hub-grid')), findsOneWidget);
    expect(find.byKey(const Key('story-card-yusuf')), findsOneWidget);
    expect(find.byKey(const Key('story-card-maryam')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('story-card-nuh')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('story-card-nuh')), findsOneWidget);
    expect(find.text('1 of 3 stories read'), findsOneWidget);
  });

  testWidgets('category tabs reduce the visible stories', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          storyIndexProvider.overrideWith((ref) async => _stories),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('story-category-tab-quranic')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-card-maryam')), findsOneWidget);
    expect(find.byKey(const Key('story-card-yusuf')), findsNothing);
    expect(find.byKey(const Key('story-card-nuh')), findsNothing);
  });

  testWidgets('search filters stories by title after debounce', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          storyIndexProvider.overrideWith((ref) async => _stories),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stories-hub-search-toggle')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('stories-hub-search-field')),
      'Maryam',
    );
    await tester.pump(
      const Duration(milliseconds: AppConstants.searchDebounceMs + 50),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-card-maryam')), findsOneWidget);
    expect(find.byKey(const Key('story-card-yusuf')), findsNothing);
    expect(find.byKey(const Key('story-card-nuh')), findsNothing);
  });
}

Widget _buildHarness({
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const StoriesHubScreen(),
    ),
  );
}

const List<QuranStory> _stories = <QuranStory>[
  QuranStory(
    id: 'yusuf',
    file: 'yusuf.json',
    titleAr: 'يوسف عليه السلام',
    titleEn: 'Yusuf (Peace be upon him)',
    category: StoryCategory.prophets,
    iconKey: 'sparkles',
    summaryAr: 'ملخص يوسف',
    summaryEn: 'Yusuf summary',
    chapterCount: 12,
    totalVerses: 15,
    estimatedReadingMinutes: 25,
    mainSurahsAr: <String>['يوسف'],
    mainSurahsNumbers: <int>[12],
    order: 1,
  ),
  QuranStory(
    id: 'maryam',
    file: 'maryam.json',
    titleAr: 'مريم عليها السلام',
    titleEn: 'Maryam',
    category: StoryCategory.quranic,
    iconKey: 'leaf',
    summaryAr: 'ملخص مريم',
    summaryEn: 'Maryam summary',
    chapterCount: 7,
    totalVerses: 8,
    estimatedReadingMinutes: 15,
    mainSurahsAr: <String>['آل عمران'],
    mainSurahsNumbers: <int>[3],
    order: 2,
  ),
  QuranStory(
    id: 'nuh',
    file: 'nuh.json',
    titleAr: 'نوح عليه السلام',
    titleEn: 'Noah (Peace be upon him)',
    category: StoryCategory.prophets,
    iconKey: 'waves',
    summaryAr: 'ملخص نوح',
    summaryEn: 'Noah summary',
    chapterCount: 9,
    totalVerses: 11,
    estimatedReadingMinutes: 18,
    mainSurahsAr: <String>['نوح'],
    mainSurahsNumbers: <int>[71],
    order: 3,
  ),
];
