import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/data/asbaab_data_source.dart';
import 'package:quran_kareem/features/tafsir/data/related_ayahs_data_source.dart';
import 'package:quran_kareem/features/tafsir/data/tafsir_browser_repository.dart';
import 'package:quran_kareem/features/tafsir/data/word_meaning_data_source.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_kareem/features/tafsir/providers/insight_section_providers.dart';
import 'package:quran_kareem/features/tafsir/providers/tafsir_browser_providers.dart';

void main() {
  group('insight section providers', () {
    test('register local data source implementations by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(wordMeaningDataSourceProvider),
        isA<LocalWordMeaningDataSource>(),
      );
      expect(
        container.read(asbaabDataSourceProvider),
        isA<LocalAsbaabDataSource>(),
      );
      expect(
        container.read(relatedAyahsDataSourceProvider),
        isA<LocalRelatedAyahsDataSource>(),
      );
    });

    test('word meaning section provider delegates to its data source', () async {
      final source = _FakeWordMeaningDataSource(
        const InsightSectionLoaded<List<WordMeaningEntry>>(
          <WordMeaningEntry>[
            WordMeaningEntry(word: 'اللَّهُ', meaning: 'Allah'),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          wordMeaningDataSourceProvider.overrideWithValue(source),
        ],
      );
      addTearDown(container.dispose);

      final result =
          await container.read(wordMeaningSectionProvider(_target).future);

      expect(result, isA<InsightSectionLoaded<List<WordMeaningEntry>>>());
      expect(source.lastSurahNumber, 2);
      expect(source.lastAyahNumber, 255);
    });

    test('asbaab section provider delegates to its data source', () async {
      final source = _FakeAsbaabDataSource(
        const InsightSectionUnavailable(),
      );
      final container = ProviderContainer(
        overrides: [
          asbaabDataSourceProvider.overrideWithValue(source),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(asbaabSectionProvider(_target).future);

      expect(result, isA<InsightSectionUnavailable>());
      expect(source.lastSurahNumber, 2);
      expect(source.lastAyahNumber, 255);
    });

    test('related ayahs section provider delegates to its data source',
        () async {
      final source = _FakeRelatedAyahsDataSource(
        const InsightSectionLoaded<List<RelatedAyahEntry>>(
          <RelatedAyahEntry>[
            RelatedAyahEntry(
              surahNumber: 3,
              ayahNumber: 18,
              tag: 'thematic',
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          relatedAyahsDataSourceProvider.overrideWithValue(source),
        ],
      );
      addTearDown(container.dispose);

      final result =
          await container.read(relatedAyahsSectionProvider(_target).future);

      expect(result, isA<InsightSectionLoaded<List<RelatedAyahEntry>>>());
      expect(source.lastSurahNumber, 2);
      expect(source.lastAyahNumber, 255);
    });

    test('tafsir section provider adapts loaded tafsir content', () async {
      final container = ProviderContainer(
        overrides: [
          tafsirBrowserRepositoryProvider.overrideWithValue(
            const _FakeTafsirBrowserRepository(
              content: TafsirBrowserLoadedContent(
                verseText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
                bodyText: 'Tafsir body',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result =
          await container.read(tafsirSectionProvider(_target).future);

      expect(result, isA<InsightSectionLoaded<TafsirBrowserLoadedContent>>());
      final loaded = result as InsightSectionLoaded<TafsirBrowserLoadedContent>;
      expect(loaded.content.bodyText, 'Tafsir body');
    });

    test('tafsir section provider adapts unavailable tafsir content', () async {
      final container = ProviderContainer(
        overrides: [
          tafsirBrowserRepositoryProvider.overrideWithValue(
            const _FakeTafsirBrowserRepository(
              content: TafsirBrowserSourceUnavailableContent(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result =
          await container.read(tafsirSectionProvider(_target).future);

      expect(result, isA<InsightSectionUnavailable>());
    });

    test('tafsir section provider adapts error tafsir content', () async {
      final container = ProviderContainer(
        overrides: [
          tafsirBrowserRepositoryProvider.overrideWithValue(
            const _FakeTafsirBrowserRepository(
              content: TafsirBrowserErrorContent(
                error: FormatException('bad content'),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result =
          await container.read(tafsirSectionProvider(_target).future);

      expect(result, isA<InsightSectionError>());
      expect((result as InsightSectionError).error, isA<FormatException>());
    });

    test('resolver maps each insight section type to the matching provider',
        () {
      expect(
        insightSectionProviderResolver(InsightSectionType.tafsir),
        same(tafsirSectionProvider),
      );
      expect(
        insightSectionProviderResolver(InsightSectionType.wordMeaning),
        same(wordMeaningSectionProvider),
      );
      expect(
        insightSectionProviderResolver(InsightSectionType.asbaabAlNuzul),
        same(asbaabSectionProvider),
      );
      expect(
        insightSectionProviderResolver(InsightSectionType.relatedAyahs),
        same(relatedAyahsSectionProvider),
      );
    });
  });
}

const _target = ReaderAyahInsightsTarget(
  surahNumber: 2,
  ayahNumber: 255,
  ayahUQNumber: 281,
  pageNumber: 42,
);

class _FakeWordMeaningDataSource implements WordMeaningDataSource {
  _FakeWordMeaningDataSource(this.result);

  final InsightSectionData result;
  int? lastSurahNumber;
  int? lastAyahNumber;

  @override
  Future<InsightSectionData> fetchForAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    lastSurahNumber = surahNumber;
    lastAyahNumber = ayahNumber;
    return result;
  }
}

class _FakeAsbaabDataSource implements AsbaabDataSource {
  _FakeAsbaabDataSource(this.result);

  final InsightSectionData result;
  int? lastSurahNumber;
  int? lastAyahNumber;

  @override
  Future<InsightSectionData> fetchForAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    lastSurahNumber = surahNumber;
    lastAyahNumber = ayahNumber;
    return result;
  }
}

class _FakeRelatedAyahsDataSource implements RelatedAyahsDataSource {
  _FakeRelatedAyahsDataSource(this.result);

  final InsightSectionData result;
  int? lastSurahNumber;
  int? lastAyahNumber;

  @override
  Future<InsightSectionData> fetchForAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    lastSurahNumber = surahNumber;
    lastAyahNumber = ayahNumber;
    return result;
  }
}

class _FakeTafsirBrowserRepository implements TafsirBrowserRepository {
  const _FakeTafsirBrowserRepository({
    required this.content,
  });

  final TafsirBrowserContentState content;

  @override
  Future<TafsirBrowserContentState> fetchContent({
    required ReaderAyahInsightsTarget target,
  }) async {
    return content;
  }

  @override
  Future<List<TafsirBrowserSourceOption>> fetchSourceOptions() async {
    return const <TafsirBrowserSourceOption>[];
  }

  @override
  Future<void> selectSource({
    required String sourceId,
    required int pageNumber,
  }) async {}
}
