import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/library/presentation/screens/library_screen.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows recent searches and opens the reader from an ayah result',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'librarySearchHistory': jsonEncode(<String>['رحمة']),
      },
    );

    final source = _FakeLibraryAyahSearchSource(
      results: const [
        Ayah(
          id: 1,
          surahNumber: 2,
          ayahNumber: 255,
          text: 'الله لا إله إلا هو',
          page: 42,
          juz: 3,
          hizb: 1,
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHarness(source: source),
    );
    await tester.pumpAndSettle();

    expect(find.text('رحمة'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'الله');
    await tester.pumpAndSettle();

    expect(find.text('Full Quran'), findsOneWidget);
    expect(find.text('Current surah'), findsOneWidget);
    expect(find.text('البقرة'), findsOneWidget);

    await tester.tap(find.text('البقرة'));
    await tester.pumpAndSettle();

    expect(find.text('Reader route'), findsOneWidget);
  });

  testWidgets(
      'switches to translation search and opens the reader from a translation result',
      (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    final ayahSource = _FakeLibraryAyahSearchSource(results: const []);
    final translationSource = _FakeLibraryTranslationSearchSource(
      results: const [
        LibraryTranslationSearchMatch(
          surahNumber: 2,
          ayahNumber: 255,
          arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
          translationText: 'Mercy belongs to Allah alone.',
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHarness(
        source: ayahSource,
        translationSource: translationSource,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'mercy');
    await tester.pumpAndSettle();

    expect(find.text('Ayahs'), findsOneWidget);
    expect(find.text('Translations'), findsOneWidget);

    await tester.tap(find.text('Translations'));
    await tester.pumpAndSettle();

    expect(find.text('Mercy belongs to Allah alone.'), findsOneWidget);
    expect(find.text('البقرة'), findsOneWidget);

    await tester.tap(find.text('البقرة'));
    await tester.pumpAndSettle();

    expect(find.text('Reader route'), findsOneWidget);
  });

  testWidgets(
      'shows the topic browser, opens topic details, and jumps to the reader from a topic ayah',
      (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    final ayahSource = _FakeLibraryAyahSearchSource(results: const []);
    final topicSource = _FakeLibraryTopicCatalogSource(
      topics: const [
        LibraryTopic(
          id: 'paradise',
          titleArabic: 'الجنة',
          titleEnglish: 'Paradise',
          descriptionArabic: 'نعيم وثمار وظلال',
          descriptionEnglish: 'Verses about the Garden and its reward',
          category: LibraryTopicCategory.afterlife,
          iconKey: 'spa',
          references: [
            LibraryTopicReference(surahNumber: 55, ayahNumber: 46),
          ],
        ),
      ],
    );
    final topicResolver = _FakeLibraryTopicAyahResolver(
      resultsByTopicId: {
        'paradise': const [
          LibraryTopicReferenceResult(
            ayah: Ayah(
              id: 1,
              surahNumber: 55,
              ayahNumber: 46,
              text: 'وَلِمَنْ خَافَ مَقَامَ رَبِّهِ جَنَّتَانِ',
              page: 533,
              juz: 27,
              hizb: 53,
            ),
            surahName: 'Ar-Rahman',
          ),
        ],
      },
    );

    await tester.pumpWidget(
      _buildHarness(
        source: ayahSource,
        topicSource: topicSource,
        topicResolver: topicResolver,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Topics'), findsOneWidget);

    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Afterlife'), findsOneWidget);
    expect(find.text('Paradise'), findsOneWidget);

    await tester.tap(find.text('Paradise'));
    await tester.pumpAndSettle();

    expect(find.text('Ar-Rahman'), findsOneWidget);

    await tester.tap(find.text('Ar-Rahman'));
    await tester.pumpAndSettle();

    expect(find.text('Reader route'), findsOneWidget);
  });
}

Widget _buildHarness({
  required LibraryAyahSearchSource source,
  LibraryTranslationSearchSource? translationSource,
  LibraryTopicCatalogSource? topicSource,
  LibraryTopicAyahResolver? topicResolver,
}) {
  return ProviderScope(
    overrides: [
      libraryAyahSearchSourceProvider.overrideWithValue(source),
      if (translationSource != null)
        libraryTranslationSearchSourceProvider.overrideWithValue(
          translationSource,
        ),
      libraryTranslationAyahResolverProvider.overrideWithValue(
        const _FakeLibraryTranslationAyahResolver(),
      ),
      if (topicSource != null)
        libraryTopicCatalogSourceProvider.overrideWithValue(topicSource),
      if (topicResolver != null)
        libraryTopicAyahResolverProvider.overrideWithValue(topicResolver),
      allSurahsProvider.overrideWith(
        (ref) async => const [
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
      libraryStoredReadingPositionProvider.overrideWith(
        (ref) async => ReadingPosition(
          surahNumber: 2,
          ayahNumber: 255,
          page: 42,
          savedAt: DateTime(2026, 3, 24, 9, 30),
        ),
      ),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/library',
        routes: [
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Reader route')),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FakeLibraryAyahSearchSource implements LibraryAyahSearchSource {
  _FakeLibraryAyahSearchSource({
    required this.results,
  });

  final List<Ayah> results;

  @override
  Future<List<Ayah>> searchAyahs({
    required String query,
    int? surahNumber,
  }) async {
    return results;
  }
}

class _FakeLibraryTranslationSearchSource
    implements LibraryTranslationSearchSource {
  _FakeLibraryTranslationSearchSource({
    required this.results,
  });

  final List<LibraryTranslationSearchMatch> results;

  @override
  Future<List<LibraryTranslationSearchMatch>> searchTranslations({
    required String query,
    required int resourceId,
  }) async {
    return results;
  }
}

class _FakeLibraryTranslationAyahResolver
    implements LibraryTranslationAyahResolver {
  const _FakeLibraryTranslationAyahResolver();

  @override
  Future<Ayah> resolveMatch(LibraryTranslationSearchMatch match) async {
    return Ayah(
      id: (match.surahNumber * 1000) + match.ayahNumber,
      surahNumber: match.surahNumber,
      ayahNumber: match.ayahNumber,
      text: match.arabicText,
      page: 42,
      juz: 0,
      hizb: 0,
    );
  }
}

class _FakeLibraryTopicCatalogSource implements LibraryTopicCatalogSource {
  _FakeLibraryTopicCatalogSource({
    required this.topics,
  });

  final List<LibraryTopic> topics;

  @override
  Future<List<LibraryTopic>> loadTopics() async {
    return topics;
  }
}

class _FakeLibraryTopicAyahResolver implements LibraryTopicAyahResolver {
  _FakeLibraryTopicAyahResolver({
    required this.resultsByTopicId,
  });

  final Map<String, List<LibraryTopicReferenceResult>> resultsByTopicId;

  @override
  Future<List<LibraryTopicReferenceResult>> resolveTopic(
    LibraryTopic topic,
  ) async {
    return resultsByTopicId[topic.id] ?? const <LibraryTopicReferenceResult>[];
  }
}
