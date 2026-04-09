import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:quran_kareem/features/reader/data/reader_translation_remote_data_source.dart';
import 'package:quran_kareem/features/reader/data/reader_translation_repository.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';

void main() {
  group('ReaderTranslationRepository', () {
    test('collects translations across valid pagination', () async {
      final dataSource = _FakeReaderTranslationRemoteDataSource({
        1: _page(ayahNumber: 1, nextPage: 2),
        2: _page(ayahNumber: 2, nextPage: 3),
        3: _page(ayahNumber: 3, nextPage: null),
      });
      final repository = ReaderTranslationRepository(
        remoteDataSource: dataSource,
      );

      final result = await repository.fetchSurahTranslations(
        surahNumber: 2,
        resourceId: 20,
      );

      expect(result.keys.toList(), orderedEquals([1, 2, 3]));
      expect(dataSource.requestedPages, orderedEquals([1, 2, 3]));
    });

    test('stops when the API repeats the next page value', () async {
      final dataSource = _FakeReaderTranslationRemoteDataSource({
        1: _page(ayahNumber: 1, nextPage: 2),
        2: _page(ayahNumber: 2, nextPage: 2),
      });
      final repository = ReaderTranslationRepository(
        remoteDataSource: dataSource,
      );

      final result = await repository.fetchSurahTranslations(
        surahNumber: 2,
        resourceId: 20,
      );

      expect(result.keys.toList(), orderedEquals([1, 2]));
      expect(dataSource.requestedPages, orderedEquals([1, 2]));
    });

    test('stops when pagination exceeds the repository max-page guard',
        () async {
      final pages = <int, ReaderTranslationPage>{
        for (var page = 1;
            page <= ReaderTranslationRepository.maxPagesPerRequest + 1;
            page++)
          page: _page(ayahNumber: page, nextPage: page + 1),
      };
      final dataSource = _FakeReaderTranslationRemoteDataSource(pages);
      final repository = ReaderTranslationRepository(
        remoteDataSource: dataSource,
      );

      final result = await repository.fetchSurahTranslations(
        surahNumber: 2,
        resourceId: 20,
      );

      expect(result.length, ReaderTranslationRepository.maxPagesPerRequest);
      expect(
        dataSource.requestedPages,
        orderedEquals(
          List<int>.generate(
            ReaderTranslationRepository.maxPagesPerRequest,
            (index) => index + 1,
          ),
        ),
      );
    });
  });
}

ReaderTranslationPage _page({
  required int ayahNumber,
  required int? nextPage,
}) {
  return ReaderTranslationPage(
    translations: [
      AyahTranslation(
        ayahNumber: ayahNumber,
        verseKey: '2:$ayahNumber',
        text: 'Translation $ayahNumber',
        resourceId: 20,
      ),
    ],
    nextPage: nextPage,
  );
}

class _FakeReaderTranslationRemoteDataSource
    extends ReaderTranslationRemoteDataSource {
  _FakeReaderTranslationRemoteDataSource(this._pages)
      : super(client: MockClient((_) async => throw UnimplementedError()));

  final Map<int, ReaderTranslationPage> _pages;
  final List<int> requestedPages = <int>[];

  @override
  Future<ReaderTranslationPage> fetchTranslationsPage({
    required int surahNumber,
    required int resourceId,
    int page = 1,
  }) async {
    requestedPages.add(page);

    final result = _pages[page];
    if (result == null) {
      throw StateError('Unexpected page request: $page');
    }

    return result;
  }
}
