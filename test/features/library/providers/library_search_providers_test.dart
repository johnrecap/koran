import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('searches ayahs across the full Quran by default', () async {
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
    final container = ProviderContainer(
      overrides: [
        libraryAyahSearchSourceProvider.overrideWithValue(source),
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
      ],
    );
    addTearDown(container.dispose);

    container.read(librarySearchQueryProvider.notifier).state = 'الله';

    final results =
        await container.read(libraryAyahSearchResultsProvider.future);

    expect(source.lastQuery, 'الله');
    expect(source.lastSurahNumber, isNull);
    expect(results, hasLength(1));
    expect(results.single.surahName, 'البقرة');
    expect(results.single.ayah.ayahNumber, 255);
  });

  test(
      'passes the resolved current surah when the current-surah filter is active',
      () async {
    final source = _FakeLibraryAyahSearchSource(results: const <Ayah>[]);
    final container = ProviderContainer(
      overrides: [
        libraryAyahSearchSourceProvider.overrideWithValue(source),
        allSurahsProvider.overrideWith((ref) async => const <Surah>[]),
        libraryCurrentSearchSurahNumberProvider.overrideWith(
          (ref) async => 36,
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(librarySearchQueryProvider.notifier).state = 'يس';
    container.read(librarySearchScopeProvider.notifier).state =
        LibrarySearchScope.currentSurah;

    await container.read(libraryAyahSearchResultsProvider.future);

    expect(source.lastSurahNumber, 36);
  });

  test('surfaces ayah-search failures as provider errors', () async {
    final source = _ThrowingLibraryAyahSearchSource();
    final container = ProviderContainer(
      overrides: [
        libraryAyahSearchSourceProvider.overrideWithValue(source),
        allSurahsProvider.overrideWith((ref) async => const <Surah>[]),
      ],
    );
    addTearDown(container.dispose);

    container.read(librarySearchQueryProvider.notifier).state = 'mercy';

    await expectLater(
      container.read(libraryAyahSearchResultsProvider.future),
      throwsA(isA<StateError>()),
    );
  });

  test('stores recent searches locally and deduplicates them', () async {
    final notifier = LibrarySearchHistoryNotifier();
    await notifier.ready;

    await notifier.recordSearch('  رحمة  ');
    await notifier.recordSearch('مغفرة');
    await notifier.recordSearch('رحمة');

    expect(notifier.state, <String>['رحمة', 'مغفرة']);

    await notifier.clearHistory();
    expect(notifier.state, isEmpty);
  });

  test(
      'searches translation results across the full Quran when translation search is active',
      () async {
    final source = _FakeLibraryTranslationSearchSource(
      results: const [
        LibraryTranslationSearchMatch(
          surahNumber: 2,
          ayahNumber: 255,
          arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
          translationText: 'Mercy belongs to Allah alone.',
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        libraryTranslationSearchSourceProvider.overrideWithValue(source),
        libraryTranslationAyahResolverProvider.overrideWithValue(
          const _FakeLibraryTranslationAyahResolver(),
        ),
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
      ],
    );
    addTearDown(container.dispose);

    container.read(librarySearchQueryProvider.notifier).state = 'mercy';
    container.read(librarySearchKindProvider.notifier).state =
        LibrarySearchKind.translations;

    final results = await container.read(
      libraryTranslationSearchResultsProvider.future,
    );

    expect(source.lastQuery, 'mercy');
    expect(results, hasLength(1));
    expect(results.single.surahName, 'البقرة');
    expect(results.single.translationText, contains('Mercy'));
  });

  test(
      'filters current surah translations locally when translation search uses current surah',
      () async {
    final source = _FakeLibraryTranslationSearchSource(results: const []);
    final container = ProviderContainer(
      overrides: [
        libraryTranslationSearchSourceProvider.overrideWithValue(source),
        allSurahsProvider.overrideWith(
          (ref) async => const [
            Surah(
              number: 36,
              nameArabic: 'يس',
              nameEnglish: 'Ya-Sin',
              nameTransliteration: 'Ya-Sin',
              ayahCount: 83,
              revelationType: 'Meccan',
              page: 440,
            ),
          ],
        ),
        libraryCurrentSearchSurahNumberProvider.overrideWith(
          (ref) async => 36,
        ),
        surahAyahsProvider.overrideWith(
          (ref, surahNumber) async => const [
            Ayah(
              id: 1,
              surahNumber: 36,
              ayahNumber: 1,
              text: 'يس',
              page: 440,
              juz: 23,
              hizb: 45,
            ),
          ],
        ),
        surahTranslationsProvider.overrideWith(
          (ref, surahNumber) async => const {
            1: AyahTranslation(
              ayahNumber: 1,
              verseKey: '36:1',
              text: 'Mercy starts here.',
              resourceId: 85,
            ),
          },
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(librarySearchQueryProvider.notifier).state = 'mercy';
    container.read(librarySearchKindProvider.notifier).state =
        LibrarySearchKind.translations;
    container.read(librarySearchScopeProvider.notifier).state =
        LibrarySearchScope.currentSurah;

    final results = await container.read(
      libraryTranslationSearchResultsProvider.future,
    );

    expect(source.lastQuery, isNull);
    expect(results, hasLength(1));
    expect(results.single.ayah.ayahNumber, 1);
    expect(results.single.translationText, contains('Mercy'));
  });

  test('filters topics locally by selected category and query', () async {
    final source = _FakeLibraryTopicCatalogSource(
      topics: const [
        LibraryTopic(
          id: 'paradise',
          titleArabic: 'الجنة',
          titleEnglish: 'Paradise',
          descriptionArabic: 'نعيم الآخرة',
          descriptionEnglish: 'Descriptions of the Garden',
          category: LibraryTopicCategory.afterlife,
          iconKey: 'spa',
          references: [
            LibraryTopicReference(surahNumber: 55, ayahNumber: 46),
          ],
        ),
        LibraryTopic(
          id: 'fasting',
          titleArabic: 'الصيام',
          titleEnglish: 'Fasting',
          descriptionArabic: 'أحكام الصيام',
          descriptionEnglish: 'Fasting laws and guidance',
          category: LibraryTopicCategory.laws,
          iconKey: 'schedule',
          references: [
            LibraryTopicReference(surahNumber: 2, ayahNumber: 183),
          ],
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        libraryTopicCatalogSourceProvider.overrideWithValue(source),
      ],
    );
    addTearDown(container.dispose);

    container.read(librarySearchKindProvider.notifier).state =
        LibrarySearchKind.topics;
    container.read(librarySelectedTopicCategoryProvider.notifier).state =
        LibraryTopicCategory.afterlife;
    container.read(librarySearchQueryProvider.notifier).state = 'garden';

    final results = await container.read(libraryTopicResultsProvider.future);

    expect(results, hasLength(1));
    expect(results.single.id, 'paradise');
  });

  test('resolves topic references into ayah entries for the details screen',
      () async {
    const topic = LibraryTopic(
      id: 'mercy',
      titleArabic: 'الرحمة',
      titleEnglish: 'Mercy',
      descriptionArabic: 'آيات الرحمة',
      descriptionEnglish: 'Verses about mercy',
      category: LibraryTopicCategory.afterlife,
      iconKey: 'favorite',
      references: [
        LibraryTopicReference(surahNumber: 1, ayahNumber: 1),
      ],
    );
    final source = _FakeLibraryTopicCatalogSource(topics: [topic]);
    final resolver = _FakeLibraryTopicAyahResolver(
      resultsByTopicId: {
        'mercy': const [
          LibraryTopicReferenceResult(
            ayah: Ayah(
              id: 1,
              surahNumber: 1,
              ayahNumber: 1,
              text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              page: 1,
              juz: 1,
              hizb: 1,
            ),
            surahName: 'الفاتحة',
          ),
        ],
      },
    );

    final container = ProviderContainer(
      overrides: [
        libraryTopicCatalogSourceProvider.overrideWithValue(source),
        libraryTopicAyahResolverProvider.overrideWithValue(resolver),
      ],
    );
    addTearDown(container.dispose);

    final results = await container.read(
      libraryTopicReferenceResultsProvider('mercy').future,
    );

    expect(results, hasLength(1));
    expect(results.single.surahName, 'الفاتحة');
    expect(results.single.ayah.ayahNumber, 1);
  });
}

class _FakeLibraryAyahSearchSource implements LibraryAyahSearchSource {
  _FakeLibraryAyahSearchSource({
    required this.results,
  });

  final List<Ayah> results;
  String? lastQuery;
  int? lastSurahNumber;

  @override
  Future<List<Ayah>> searchAyahs({
    required String query,
    int? surahNumber,
  }) async {
    lastQuery = query;
    lastSurahNumber = surahNumber;
    return results;
  }
}

class _ThrowingLibraryAyahSearchSource implements LibraryAyahSearchSource {
  @override
  Future<List<Ayah>> searchAyahs({
    required String query,
    int? surahNumber,
  }) async {
    throw StateError('search failed');
  }
}

class _FakeLibraryTranslationSearchSource
    implements LibraryTranslationSearchSource {
  _FakeLibraryTranslationSearchSource({
    required this.results,
  });

  final List<LibraryTranslationSearchMatch> results;
  String? lastQuery;

  @override
  Future<List<LibraryTranslationSearchMatch>> searchTranslations({
    required String query,
    required int resourceId,
  }) async {
    lastQuery = query;
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
