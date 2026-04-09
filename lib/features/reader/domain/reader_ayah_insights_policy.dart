import 'package:flutter/material.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_library/quran_library.dart';

class ReaderAyahInsightsTarget {
  const ReaderAyahInsightsTarget({
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahUQNumber,
    required this.pageNumber,
  });

  final int surahNumber;
  final int ayahNumber;
  final int ayahUQNumber;
  final int pageNumber;

  int get pageIndex => pageNumber - 1;
}

abstract interface class ReaderAyahPlaybackLauncher {
  Future<void> play(
    BuildContext context,
    ReaderAyahInsightsTarget target, {
    required bool isDark,
  });
}

abstract interface class ReaderAyahInsightsSheetLauncher {
  Future<void> show(
    BuildContext context,
    ReaderAyahInsightsTarget target, {
    required bool isDark,
  });
}

abstract final class ReaderAyahInsightsPolicy {
  static ReaderAyahInsightsTarget resolve({
    required Ayah ayah,
    required Iterable<SurahModel> canonicalSurahs,
  }) {
    final canonicalAyah = _findCanonicalAyah(
      canonicalSurahs: canonicalSurahs,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
    );
    final ayahUQNumber = canonicalAyah?.ayahUQNumber ?? ayah.id;
    if (ayahUQNumber <= 0) {
      throw StateError('Unable to resolve ayah unique number.');
    }

    final canonicalPage = canonicalAyah?.page ?? ayah.page;
    final pageNumber = canonicalPage > 0 ? canonicalPage : 1;

    return ReaderAyahInsightsTarget(
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      ayahUQNumber: ayahUQNumber,
      pageNumber: pageNumber,
    );
  }

  static AyahModel? _findCanonicalAyah({
    required Iterable<SurahModel> canonicalSurahs,
    required int surahNumber,
    required int ayahNumber,
  }) {
    for (final surah in canonicalSurahs) {
      if (surah.surahNumber != surahNumber) {
        continue;
      }

      for (final ayah in surah.ayahs) {
        if (ayah.ayahNumber == ayahNumber) {
          return ayah;
        }
      }
    }

    return null;
  }
}
