import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/reader_tadabbur_navigation_policy.dart';

void main() {
  group('ReaderTadabburNavigationPolicy', () {
    test('returns the previous ayah inside the same surah when available', () {
      expect(
        ReaderTadabburNavigationPolicy.previousAyah(
          surahs: _surahs,
          surahNumber: 2,
          ayahNumber: 3,
        ),
        const ReaderTadabburAyahReference(
          surahNumber: 2,
          ayahNumber: 2,
        ),
      );
    });

    test('moves to the last ayah of the previous surah at surah boundaries',
        () {
      expect(
        ReaderTadabburNavigationPolicy.previousAyah(
          surahs: _surahs,
          surahNumber: 2,
          ayahNumber: 1,
        ),
        const ReaderTadabburAyahReference(
          surahNumber: 1,
          ayahNumber: 7,
        ),
      );
    });

    test('moves to the first ayah of the next surah at surah boundaries', () {
      expect(
        ReaderTadabburNavigationPolicy.nextAyah(
          surahs: _surahs,
          surahNumber: 2,
          ayahNumber: 3,
        ),
        const ReaderTadabburAyahReference(
          surahNumber: 3,
          ayahNumber: 1,
        ),
      );
    });

    test('returns null at the first and last ayah of the mushaf', () {
      expect(
        ReaderTadabburNavigationPolicy.previousAyah(
          surahs: _surahs,
          surahNumber: 1,
          ayahNumber: 1,
        ),
        isNull,
      );
      expect(
        ReaderTadabburNavigationPolicy.nextAyah(
          surahs: _surahs,
          surahNumber: 3,
          ayahNumber: 5,
        ),
        isNull,
      );
    });
  });
}

const _surahs = <Surah>[
  Surah(
    number: 1,
    nameArabic: 'الفاتحة',
    nameEnglish: 'Al-Fatihah',
    nameTransliteration: 'Al-Fatihah',
    ayahCount: 7,
    revelationType: 'Meccan',
    page: 1,
  ),
  Surah(
    number: 2,
    nameArabic: 'البقرة',
    nameEnglish: 'Al-Baqarah',
    nameTransliteration: 'Al-Baqarah',
    ayahCount: 3,
    revelationType: 'Medinan',
    page: 2,
  ),
  Surah(
    number: 3,
    nameArabic: 'آل عمران',
    nameEnglish: 'Ali Imran',
    nameTransliteration: 'Ali Imran',
    ayahCount: 5,
    revelationType: 'Medinan',
    page: 50,
  ),
];
