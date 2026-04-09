import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/quran_metadata_lookup.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('QuranMetadataLookup', () {
    final canonicalSurahs = [
      SurahModel(
        surahNumber: 1,
        arabicName: 'الفاتحة',
        englishName: 'Al-Fatihah',
        ayahs: [
          AyahModel(
            ayahUQNumber: 1,
            ayahNumber: 1,
            text: 'بسم الله',
            ayaTextEmlaey: 'بسم الله',
            juz: 1,
            page: 1,
            surahNumber: 1,
          ),
        ],
      ),
      SurahModel(
        surahNumber: 2,
        arabicName: 'البقرة',
        englishName: 'Al-Baqarah',
        ayahs: [
          AyahModel(
            ayahUQNumber: 8,
            ayahNumber: 1,
            text: 'الم',
            ayaTextEmlaey: 'الم',
            juz: 1,
            page: 2,
            surahNumber: 2,
          ),
          AyahModel(
            ayahUQNumber: 9,
            ayahNumber: 2,
            text: 'ذلك الكتاب',
            ayaTextEmlaey: 'ذلك الكتاب',
            juz: 1,
            page: 2,
            surahNumber: 2,
          ),
          AyahModel(
            ayahUQNumber: 10,
            ayahNumber: 3,
            text: 'هدى للمتقين',
            ayaTextEmlaey: 'هدى للمتقين',
            juz: 1,
            page: 2,
            surahNumber: 2,
          ),
        ],
      ),
    ];

    test('resolves the real starting page for a surah', () {
      expect(
        QuranMetadataLookup.resolveSurahStartPage(
          canonicalSurahs,
          surahNumber: 2,
        ),
        2,
      );
    });

    test('resolves the real page for a specific ayah', () {
      expect(
        QuranMetadataLookup.resolveAyahPage(
          canonicalSurahs,
          surahNumber: 2,
          ayahNumber: 3,
        ),
        2,
      );
    });

    test('maps quran_library ayahs to domain ayahs with page metadata', () {
      final domainAyahs =
          QuranMetadataLookup.toDomainAyahs(canonicalSurahs[1].ayahs);

      expect(domainAyahs, hasLength(3));
      expect(domainAyahs.first.surahNumber, 2);
      expect(domainAyahs.first.ayahNumber, 1);
      expect(domainAyahs.first.page, 2);
    });
  });
}
