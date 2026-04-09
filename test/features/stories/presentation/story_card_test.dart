import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:quran_kareem/features/stories/presentation/story_card.dart';

void main() {
  testWidgets('displays localized title, chapter count, and reading time',
      (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        child: StoryCard(
          story: _story(),
          onTap: () {
            tapCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-card-adam')), findsOneWidget);
    expect(find.text('Adam (Peace be upon him)'), findsOneWidget);
    expect(find.text('10 chapters'), findsOneWidget);
    expect(find.text('20 min'), findsOneWidget);

    await tester.tap(find.byKey(const Key('story-card-adam')));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('shows a progress bar when the story is partially read',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: StoryCard(
          story: _story(),
          progress: const StoryReadingProgress(
            storyId: 'adam',
            lastChapterIndex: 4,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-card-progress-adam')), findsOneWidget);
    expect(find.byKey(const Key('story-card-complete-adam')), findsNothing);
  });

  testWidgets('shows a completion badge when the story is fully read',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: StoryCard(
          story: _story(),
          progress: StoryReadingProgress(
            storyId: 'adam',
            lastChapterIndex: 9,
            completedAt: DateTime.utc(2026, 4, 8, 14),
          ),
          isBookmarked: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('story-card-complete-adam')), findsOneWidget);
    expect(find.byKey(const Key('story-card-bookmark-adam')), findsOneWidget);
  });
}

Widget _buildHarness({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: child,
        ),
      ),
    ),
  );
}

QuranStory _story() {
  return const QuranStory(
    id: 'adam',
    file: 'adam.json',
    titleAr: 'آدم عليه السلام',
    titleEn: 'Adam (Peace be upon him)',
    category: StoryCategory.prophets,
    iconKey: 'user',
    summaryAr: 'ملخص القصة',
    summaryEn: 'Story summary',
    chapterCount: 10,
    totalVerses: 10,
    estimatedReadingMinutes: 20,
    mainSurahsAr: <String>['البقرة'],
    mainSurahsNumbers: <int>[2],
    order: 1,
  );
}
