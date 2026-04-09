import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/stories/domain/story_verse.dart';
import 'package:quran_kareem/features/stories/presentation/story_verse_card.dart';

void main() {
  testWidgets('displays verse text and the resolved reference', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: StoryVerseCard(
          verse: _verse,
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verse body'), findsOneWidget);
    expect(find.text('Surah Al-Baqarah: 30-32'), findsOneWidget);
    expect(find.text('Verse context'), findsOneWidget);
  });

  testWidgets('tap fires the provided callback', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        child: StoryVerseCard(
          verse: _verse,
          onTap: () {
            tapCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('story-verse-card-2-30-32')));
    await tester.pump();

    expect(tapCount, 1);
  });
}

Widget _buildHarness({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
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
    ),
  );
}

const StoryVerse _verse = StoryVerse(
  surah: 2,
  ayahStart: 30,
  ayahEnd: 32,
  textAr: 'Verse body',
  contextAr: 'Verse context',
);
