import 'package:flutter/foundation.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';

@immutable
class ReaderTadabburAyahReference {
  const ReaderTadabburAyahReference({
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ReaderTadabburAyahReference &&
        other.surahNumber == surahNumber &&
        other.ayahNumber == ayahNumber;
  }

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);
}

abstract final class ReaderTadabburNavigationPolicy {
  static ReaderTadabburAyahReference? previousAyah({
    required List<Surah> surahs,
    required int surahNumber,
    required int ayahNumber,
  }) {
    final currentIndex =
        surahs.indexWhere((surah) => surah.number == surahNumber);
    if (currentIndex == -1) {
      return null;
    }

    final currentSurah = surahs[currentIndex];
    if (ayahNumber > 1 && ayahNumber <= currentSurah.ayahCount) {
      return ReaderTadabburAyahReference(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber - 1,
      );
    }

    if (currentIndex == 0) {
      return null;
    }

    final previousSurah = surahs[currentIndex - 1];
    return ReaderTadabburAyahReference(
      surahNumber: previousSurah.number,
      ayahNumber: previousSurah.ayahCount,
    );
  }

  static ReaderTadabburAyahReference? nextAyah({
    required List<Surah> surahs,
    required int surahNumber,
    required int ayahNumber,
  }) {
    final currentIndex =
        surahs.indexWhere((surah) => surah.number == surahNumber);
    if (currentIndex == -1) {
      return null;
    }

    final currentSurah = surahs[currentIndex];
    if (ayahNumber >= 1 && ayahNumber < currentSurah.ayahCount) {
      return ReaderTadabburAyahReference(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber + 1,
      );
    }

    if (currentIndex == surahs.length - 1) {
      return null;
    }

    final nextSurah = surahs[currentIndex + 1];
    return ReaderTadabburAyahReference(
      surahNumber: nextSurah.number,
      ayahNumber: 1,
    );
  }
}
