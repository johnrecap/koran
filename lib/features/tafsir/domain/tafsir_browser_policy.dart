import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_library/quran_library.dart';

abstract final class TafsirBrowserPolicy {
  static ReaderAyahInsightsTarget? nextTarget({
    required ReaderAyahInsightsTarget current,
    required Iterable<SurahModel> canonicalSurahs,
  }) {
    return _adjacentTarget(
      current: current,
      canonicalSurahs: canonicalSurahs,
      offset: 1,
    );
  }

  static ReaderAyahInsightsTarget? previousTarget({
    required ReaderAyahInsightsTarget current,
    required Iterable<SurahModel> canonicalSurahs,
  }) {
    return _adjacentTarget(
      current: current,
      canonicalSurahs: canonicalSurahs,
      offset: -1,
    );
  }

  static ReaderAyahInsightsTarget? _adjacentTarget({
    required ReaderAyahInsightsTarget current,
    required Iterable<SurahModel> canonicalSurahs,
    required int offset,
  }) {
    final flattenedAyahs = canonicalSurahs
        .expand((surah) => surah.ayahs)
        .where((ayah) => ayah.ayahUQNumber > 0)
        .toList(growable: false);

    final currentIndex = flattenedAyahs
        .indexWhere((ayah) => ayah.ayahUQNumber == current.ayahUQNumber);
    if (currentIndex < 0) {
      return null;
    }

    final adjacentIndex = currentIndex + offset;
    if (adjacentIndex < 0 || adjacentIndex >= flattenedAyahs.length) {
      return null;
    }

    final adjacentAyah = flattenedAyahs[adjacentIndex];
    return ReaderAyahInsightsTarget(
      surahNumber: adjacentAyah.surahNumber ?? current.surahNumber,
      ayahNumber: adjacentAyah.ayahNumber,
      ayahUQNumber: adjacentAyah.ayahUQNumber,
      pageNumber:
          adjacentAyah.page > 0 ? adjacentAyah.page : current.pageNumber,
    );
  }
}
