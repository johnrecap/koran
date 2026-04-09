import 'package:quran_kareem/features/reader/data/reader_translation_remote_data_source.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';

class ReaderTranslationRepository {
  static const int maxPagesPerRequest = 50;

  const ReaderTranslationRepository({
    required ReaderTranslationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ReaderTranslationRemoteDataSource _remoteDataSource;

  Future<Map<int, AyahTranslation>> fetchSurahTranslations({
    required int surahNumber,
    required int resourceId,
  }) async {
    final translationsByAyah = <int, AyahTranslation>{};
    final visitedPages = <int>{};
    var nextPage = 1;

    while (visitedPages.length < maxPagesPerRequest &&
        visitedPages.add(nextPage)) {
      final page = await _remoteDataSource.fetchTranslationsPage(
        surahNumber: surahNumber,
        resourceId: resourceId,
        page: nextPage,
      );

      for (final translation in page.translations) {
        translationsByAyah[translation.ayahNumber] = translation;
      }

      final upcomingPage = page.nextPage;
      if (upcomingPage == null) {
        return translationsByAyah;
      }

      nextPage = upcomingPage;
    }

    return translationsByAyah;
  }
}
