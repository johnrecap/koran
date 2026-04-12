import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';
import 'package:quran_kareem/features/stories/domain/story_chapter.dart';
import 'package:quran_kareem/features/stories/domain/story_verse.dart';
import 'package:quran_kareem/features/stories/presentation/shareable_story_card.dart';

void main() {
  testWidgets('renders story branding, verse text, and lesson', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const SizedBox(
          width: 380,
          child: ShareableStoryCard(
            story: _story,
            chapter: _chapter,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('shareable-story-card-surface')), findsOneWidget);
    expect(find.text('Quran Kareem'), findsOneWidget);
    expect(find.text('Adam (Peace be upon him)'), findsOneWidget);
    expect(find.text('The Beginning'), findsOneWidget);
    expect(find.text('Verse one'), findsOneWidget);
    expect(find.text('First lesson'), findsOneWidget);
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
      body: Center(child: child),
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
  summaryAr: 'ملخص',
  summaryEn: 'Summary',
  chapterCount: 2,
  totalVerses: 2,
  estimatedReadingMinutes: 10,
  mainSurahsAr: <String>['البقرة'],
  mainSurahsNumbers: <int>[2],
  order: 1,
);

const StoryChapter _chapter = StoryChapter(
  id: 'ch1',
  order: 1,
  titleAr: 'البداية',
  titleEn: 'The Beginning',
  narrativeAr: 'Narrative',
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
);
