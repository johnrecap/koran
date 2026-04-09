import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_policy.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('TafsirBrowserPolicy', () {
    final canonicalSurahs = <SurahModel>[
      SurahModel(
        surahNumber: 1,
        arabicName: 'الفاتحة',
        englishName: 'Al-Fatihah',
        ayahs: [
          AyahModel(
            ayahUQNumber: 1,
            ayahNumber: 1,
            text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            ayaTextEmlaey: 'بسم الله الرحمن الرحيم',
            juz: 1,
            page: 1,
            surahNumber: 1,
          ),
          AyahModel(
            ayahUQNumber: 7,
            ayahNumber: 7,
            text: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ',
            ayaTextEmlaey: 'صراط الذين أنعمت عليهم',
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
            text: 'ذَٰلِكَ الْكِتَابُ',
            ayaTextEmlaey: 'ذلك الكتاب',
            juz: 1,
            page: 2,
            surahNumber: 2,
          ),
        ],
      ),
    ];

    test('moves to the next canonical ayah across surah boundaries', () {
      const current = ReaderAyahInsightsTarget(
        surahNumber: 1,
        ayahNumber: 7,
        ayahUQNumber: 7,
        pageNumber: 1,
      );

      final next = TafsirBrowserPolicy.nextTarget(
        current: current,
        canonicalSurahs: canonicalSurahs,
      );

      expect(next, isNotNull);
      expect(next!.surahNumber, 2);
      expect(next.ayahNumber, 1);
      expect(next.ayahUQNumber, 8);
      expect(next.pageNumber, 2);
    });

    test('moves to the previous canonical ayah across surah boundaries', () {
      const current = ReaderAyahInsightsTarget(
        surahNumber: 2,
        ayahNumber: 1,
        ayahUQNumber: 8,
        pageNumber: 2,
      );

      final previous = TafsirBrowserPolicy.previousTarget(
        current: current,
        canonicalSurahs: canonicalSurahs,
      );

      expect(previous, isNotNull);
      expect(previous!.surahNumber, 1);
      expect(previous.ayahNumber, 7);
      expect(previous.ayahUQNumber, 7);
      expect(previous.pageNumber, 1);
    });

    test('returns null when navigating before the first Quran ayah', () {
      const current = ReaderAyahInsightsTarget(
        surahNumber: 1,
        ayahNumber: 1,
        ayahUQNumber: 1,
        pageNumber: 1,
      );

      final previous = TafsirBrowserPolicy.previousTarget(
        current: current,
        canonicalSurahs: canonicalSurahs,
      );

      expect(previous, isNull);
    });

    test('returns null when navigating after the last available Quran ayah',
        () {
      const current = ReaderAyahInsightsTarget(
        surahNumber: 2,
        ayahNumber: 2,
        ayahUQNumber: 9,
        pageNumber: 2,
      );

      final next = TafsirBrowserPolicy.nextTarget(
        current: current,
        canonicalSurahs: canonicalSurahs,
      );

      expect(next, isNull);
    });

  });
}
