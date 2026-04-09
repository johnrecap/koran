import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/stories/domain/story_chapter.dart';
import 'package:quran_kareem/features/stories/domain/story_verse.dart';
import 'package:quran_kareem/features/stories/presentation/story_chapter_view.dart';

void main() {
  testWidgets('renders narrative text, verse cards, and lesson box',
      (tester) async {
    var tappedVerseCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahsProvider.overrideWith(
            (ref) async => const <Surah>[
              Surah(
                number: 2,
                nameArabic: 'البقرة',
                nameEnglish: 'Al-Baqarah',
                nameTransliteration: 'Al-Baqarah',
                ayahCount: 286,
                revelationType: 'Medinan',
                page: 2,
              ),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: StoryChapterView(
              chapter: _chapter,
              onVersePressed: (_) {
                tappedVerseCount += 1;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chapter narrative body'), findsOneWidget);
    expect(find.text('Verse body'), findsOneWidget);
    expect(find.text('Lesson body'), findsOneWidget);

    await tester.tap(find.byKey(const Key('story-verse-card-2-30-30')));
    await tester.pump();

    expect(tappedVerseCount, 1);
  });
}

const StoryChapter _chapter = StoryChapter(
  id: 'ch1',
  order: 1,
  titleAr: 'الفصل الأول',
  titleEn: 'Chapter One',
  narrativeAr: 'Chapter narrative body',
  lessonAr: 'نص الدرس',
  lessonEn: 'Lesson body',
  verses: <StoryVerse>[
    StoryVerse(
      surah: 2,
      ayahStart: 30,
      ayahEnd: 30,
      textAr: 'Verse body',
      contextAr: 'Verse context',
    ),
  ],
);
