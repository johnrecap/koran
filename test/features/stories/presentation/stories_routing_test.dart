import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_progress_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_providers.dart';
import 'package:quran_kareem/features/stories/presentation/stories_hub_screen.dart';

void main() {
  test('app router source registers the stories hub and reader routes', () {
    final routerSource =
        File('lib/core/router/app_router.dart').readAsStringSync();

    expect(routerSource, contains("path: '/library/stories'"));
    expect(routerSource, contains("path: '/library/stories/:storyId'"));
    expect(routerSource, contains('AppTransitionPage<void>('));
    expect(routerSource, contains('ShellRoute('));
    expect(routerSource, contains('StoriesHubScreen'));
    expect(routerSource, contains('StoryReaderScreen'));
  });

  testWidgets('hub pushes the selected story to the reader route',
      (tester) async {
    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('story-card-adam')));
    await tester.pumpAndSettle();

    expect(find.text('Reader route adam'), findsOneWidget);
  });
}

Widget _buildHarness() {
  return ProviderScope(
    overrides: [
      storyIndexProvider.overrideWith((ref) async => <QuranStory>[_story]),
      storyProgressNotifierProvider.overrideWith(
        (ref) => StoryProgressNotifier(
          loadProgress: () async => const {},
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
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/library/stories',
        routes: [
          GoRoute(
            path: '/library/stories',
            builder: (context, state) => const StoriesHubScreen(),
          ),
          GoRoute(
            path: '/library/stories/:storyId',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text(
                  'Reader route ${state.pathParameters['storyId']}',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

const QuranStory _story = QuranStory(
  id: 'adam',
  file: 'adam.json',
  titleAr: 'آدم عليه السلام',
  titleEn: 'Adam (Peace be upon him)',
  category: StoryCategory.prophets,
  iconKey: 'user',
  summaryAr: 'ملخص آدم',
  summaryEn: 'Adam summary',
  chapterCount: 2,
  totalVerses: 2,
  estimatedReadingMinutes: 10,
  mainSurahsAr: <String>['البقرة'],
  mainSurahsNumbers: <int>[2],
  order: 1,
);
