import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_library/quran_library.dart';

abstract final class QuranMetadataLookup {
  static int resolveSurahStartPage(
    List<SurahModel> canonicalSurahs, {
    required int surahNumber,
  }) {
    if (surahNumber < 1 || surahNumber > canonicalSurahs.length) {
      return 1;
    }

    final ayahs = canonicalSurahs[surahNumber - 1].ayahs;
    if (ayahs.isEmpty) {
      return 1;
    }

    final page = ayahs.first.page;
    return page > 0 ? page : 1;
  }

  static int resolveAyahPage(
    List<SurahModel> canonicalSurahs, {
    required int surahNumber,
    required int ayahNumber,
  }) {
    if (surahNumber < 1 || surahNumber > canonicalSurahs.length) {
      return 1;
    }

    final ayah = canonicalSurahs[surahNumber - 1].ayahs.where(
          (candidate) => candidate.ayahNumber == ayahNumber,
        );
    if (ayah.isEmpty) {
      return 1;
    }

    final page = ayah.first.page;
    return page > 0 ? page : 1;
  }

  static Ayah enrichDomainAyah(
    Ayah ayah,
    List<SurahModel> canonicalSurahs,
  ) {
    if (ayah.surahNumber < 1 || ayah.surahNumber > canonicalSurahs.length) {
      return ayah;
    }

    final canonicalAyah = canonicalSurahs[ayah.surahNumber - 1].ayahs.where(
          (candidate) => candidate.ayahNumber == ayah.ayahNumber,
        );
    if (canonicalAyah.isEmpty) {
      return ayah;
    }

    final match = canonicalAyah.first;
    return Ayah(
      id: ayah.id,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      text: ayah.text,
      page: match.page > 0 ? match.page : ayah.page,
      juz: match.juz > 0 ? match.juz : ayah.juz,
      hizb: (match.hizb ?? 0) > 0 ? match.hizb! : ayah.hizb,
    );
  }

  static List<Ayah> toDomainAyahs(Iterable<AyahModel> ayahs) {
    return ayahs.map(toDomainAyah).toList(growable: false);
  }

  static Ayah toDomainAyah(AyahModel ayah) {
    return Ayah(
      id: ayah.ayahUQNumber,
      surahNumber: ayah.surahNumber ?? 0,
      ayahNumber: ayah.ayahNumber,
      text: ayah.text,
      page: ayah.page > 0 ? ayah.page : 1,
      juz: ayah.juz > 0 ? ayah.juz : 1,
      hizb: (ayah.hizb ?? 0) > 0 ? ayah.hizb! : 1,
    );
  }
}
