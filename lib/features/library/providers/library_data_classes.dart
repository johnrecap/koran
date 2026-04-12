import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/library/data/library_translation_search_remote_data_source.dart';

export 'package:quran_kareem/features/library/data/library_topic_local_data_source.dart'
    show
        AssetLibraryTopicCatalogSource,
        LibraryTopicAyahResolver,
        LibraryTopicCatalogSource,
        QuranDatabaseLibraryTopicAyahResolver;
export 'package:quran_kareem/features/library/data/library_translation_search_remote_data_source.dart'
    show
        LibraryTranslationSearchMatch,
        LibraryTranslationSearchRemoteDataSource,
        LibraryTranslationSearchSource;
export 'package:quran_kareem/features/library/domain/library_topic.dart';

enum LibrarySearchScope {
  fullQuran,
  currentSurah,
}

enum LibrarySearchKind {
  ayahs,
  translations,
  topics,
}

class LibraryAyahSearchResult {
  const LibraryAyahSearchResult({
    required this.ayah,
    required this.surahName,
  });

  final Ayah ayah;
  final String surahName;
}

class LibraryTranslationSearchResult {
  const LibraryTranslationSearchResult({
    required this.ayah,
    required this.surahName,
    required this.translationText,
  });

  final Ayah ayah;
  final String surahName;
  final String translationText;
}

abstract class LibraryTranslationAyahResolver {
  Future<Ayah> resolveMatch(LibraryTranslationSearchMatch match);
}

class QuranDatabaseLibraryTranslationAyahResolver
    implements LibraryTranslationAyahResolver {
  const QuranDatabaseLibraryTranslationAyahResolver();

  @override
  Future<Ayah> resolveMatch(LibraryTranslationSearchMatch match) async {
    try {
      final ayah = await QuranDatabase.getAyah(
        match.surahNumber,
        match.ayahNumber,
      );
      if (ayah != null) {
        return ayah;
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'QuranDatabaseLibraryTranslationAyahResolver.resolveMatch',
        error,
        stackTrace,
      );
      // Fall back to the remote Arabic text when local metadata lookup is
      // unavailable, which keeps search results usable in isolated tests.
    }

    var pageNumber = 1;
    try {
      pageNumber = await QuranDatabase.getPageForAyah(
        match.surahNumber,
        match.ayahNumber,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'QuranDatabaseLibraryTranslationAyahResolver.resolveMatch',
        error,
        stackTrace,
      );
      pageNumber = 1;
    }

    return QuranDatabase.enrichAyahWithCanonicalMetadata(
      Ayah(
        id: (match.surahNumber * 1000) + match.ayahNumber,
        surahNumber: match.surahNumber,
        ayahNumber: match.ayahNumber,
        text: match.arabicText,
        page: pageNumber,
        juz: 1,
        hizb: 1,
      ),
    );
  }
}

abstract class LibraryAyahSearchSource {
  Future<List<Ayah>> searchAyahs({
    required String query,
    int? surahNumber,
  });
}

class LocalLibraryAyahSearchSource implements LibraryAyahSearchSource {
  const LocalLibraryAyahSearchSource();

  @override
  Future<List<Ayah>> searchAyahs({
    required String query,
    int? surahNumber,
  }) {
    return QuranDatabase.searchAyahs(
      query,
      surahNumber: surahNumber,
    );
  }
}
