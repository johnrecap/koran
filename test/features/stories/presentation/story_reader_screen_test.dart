import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/domain/story_chapter.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:quran_kareem/features/stories/domain/story_verse.dart';
import 'package:quran_kareem/features/stories/presentation/story_reader_screen.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_progress_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_providers.dart';

void main() {
  testWidgets('loads the story and displays the first chapter', (tester) async {
    final container = _createContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: const StoryReaderScreen(storyId: 'adam'),
      ),
    );
    await _pumpReaderFrame(tester);

    expect(find.text('Adam (Peace be upon him)'), findsOneWidget);
    expect(find.text('The Beginning'), findsOneWidget);
    expect(find.text('Chapter one narrative'), findsOneWidget);
    expect(find.text('First lesson'), findsOneWidget);
  });

  testWidgets('resumes at the next unread chapter from stored progress',
      (tester) async {
    final container = _createContainer(
      progressByStory: <String, StoryReadingProgress>{
        'adam': const StoryReadingProgress(
          storyId: 'adam',
          lastChapterIndex: 0,
        ),
      },
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: const StoryReaderScreen(storyId: 'adam'),
      ),
    );
    await _pumpReaderFrame(tester);

    expect(find.text('The Test'), findsOneWidget);
    expect(find.text('Chapter two narrative'), findsOneWidget);
    expect(find.text('The Beginning'), findsNothing);
  });

  testWidgets('next button advances to the following chapter', (tester) async {
    final container = _createContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: const StoryReaderScreen(storyId: 'adam'),
      ),
    );
    await _pumpReaderFrame(tester);

    await tester.tap(find.byKey(const Key('story-chapter-nav-next')));
    await _pumpReaderFrame(tester);

    expect(find.text('The Test'), findsOneWidget);
    expect(find.text('Chapter two narrative'), findsOneWidget);
  });

  testWidgets('verse tap opens the reader route and back returns to the story',
      (tester) async {
    final container = _createContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildRouterHarness(
        container: container,
        initialLocation: '/library/stories/adam',
      ),
    );
    await _pumpReaderFrame(tester);

    expect(find.text('The Beginning'), findsOneWidget);

    await tester.tap(find.byKey(const Key('story-verse-card-2-30-30')));
    await tester.pumpAndSettle();

    expect(find.text('Reader route'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('The Beginning'), findsOneWidget);
    expect(find.text('Reader route'), findsNothing);
  });
}

ProviderContainer _createContainer({
  Map<String, StoryReadingProgress> progressByStory =
      const <String, StoryReadingProgress>{},
}) {
  return ProviderContainer(
    overrides: [
      storyIndexProvider.overrideWith((ref) async => <QuranStory>[_storyMeta]),
      storyDetailProvider.overrideWith((ref, file) async => _storyDetail),
      storyProgressNotifierProvider.overrideWith(
        (ref) => StoryProgressNotifier(
          loadProgress: () async => progressByStory,
          saveProgress: (_) async {},
        ),
      ),
      storyBookmarkNotifierProvider.overrideWith(
        (ref) => StoryBookmarkNotifier(
          loadBookmarks: () async => const <String>{},
          toggleBookmark: (_) async {},
        ),
      ),
    ],
  );
}

Widget _buildHarness({
  required ProviderContainer container,
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

Widget _buildRouterHarness({
  required ProviderContainer container,
  required String initialLocation,
  Locale locale = const Locale('en'),
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/library/stories/:storyId',
            builder: (context, state) => StoryReaderScreen(
              storyId: state.pathParameters['storyId']!,
              onVersePressed: (context, ref, verse) async {
                await context.push('/reader');
              },
            ),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Reader route')),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _pumpReaderFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pumpAndSettle();
}

const QuranStory _storyMeta = QuranStory(
  id: 'adam',
  file: 'adam.json',
  titleAr: 'آدم عليه السلام',
  titleEn: 'Adam (Peace be upon him)',
  category: StoryCategory.prophets,
  iconKey: 'user',
  summaryAr: 'ملخص',
  summaryEn: 'Summary',
  chapterCount: 2,
  totalVerses: 2,
  estimatedReadingMinutes: 10,
  mainSurahsAr: <String>['البقرة'],
  mainSurahsNumbers: <int>[2],
  order: 1,
);

const QuranStory _storyDetail = QuranStory(
  id: 'adam',
  file: 'adam.json',
  titleAr: 'آدم عليه السلام',
  titleEn: 'Adam (Peace be upon him)',
  category: StoryCategory.prophets,
  iconKey: 'user',
  summaryAr: 'ملخص',
  summaryEn: 'Summary',
  chapterCount: 2,
  totalVerses: 2,
  estimatedReadingMinutes: 10,
  mainSurahsAr: <String>['البقرة'],
  mainSurahsNumbers: <int>[2],
  order: 1,
  chapters: <StoryChapter>[
    StoryChapter(
      id: 'ch1',
      order: 1,
      titleAr: 'البداية',
      titleEn: 'The Beginning',
      narrativeAr: 'Chapter one narrative',
      lessonAr: 'درس أول',
      lessonEn: 'First lesson',
      verses: <StoryVerse>[
        StoryVerse(
          surah: 2,
          ayahStart: 30,
          ayahEnd: 30,
          textAr: 'Verse one',
          contextAr: 'Context one',
        ),
      ],
    ),
    StoryChapter(
      id: 'ch2',
      order: 2,
      titleAr: 'الاختبار',
      titleEn: 'The Test',
      narrativeAr: 'Chapter two narrative',
      lessonAr: 'درس ثان',
      lessonEn: 'Second lesson',
      verses: <StoryVerse>[
        StoryVerse(
          surah: 2,
          ayahStart: 31,
          ayahEnd: 32,
          textAr: 'Verse two',
          contextAr: 'Context two',
        ),
      ],
    ),
  ],
);
