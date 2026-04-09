import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('ReaderAyahInsightsPolicy', () {
    final canonicalSurahs = <SurahModel>[
      SurahModel(
        surahNumber: 2,
        arabicName: 'البقرة',
        englishName: 'Al-Baqarah',
        ayahs: [
          AyahModel(
            ayahUQNumber: 281,
            ayahNumber: 255,
            text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
            ayaTextEmlaey: 'الله لا إله إلا هو',
            juz: 3,
            page: 42,
            surahNumber: 2,
          ),
        ],
      ),
    ];

    test(
      'resolves ayah uq number from canonical metadata instead of entity id',
      () {
        const ayah = Ayah(
          id: 9999,
          surahNumber: 2,
          ayahNumber: 255,
          text: 'الله لا إله إلا هو',
          page: 42,
          juz: 3,
          hizb: 1,
        );

        final target = ReaderAyahInsightsPolicy.resolve(
          ayah: ayah,
          canonicalSurahs: canonicalSurahs,
        );

        expect(target.surahNumber, 2);
        expect(target.ayahNumber, 255);
        expect(target.ayahUQNumber, 281);
        expect(target.pageIndex, 41);
      },
    );

    test('falls back to entity id when canonical ayah metadata is missing', () {
      const ayah = Ayah(
        id: 777,
        surahNumber: 36,
        ayahNumber: 1,
        text: 'يس',
        page: 440,
        juz: 22,
        hizb: 43,
      );

      final target = ReaderAyahInsightsPolicy.resolve(
        ayah: ayah,
        canonicalSurahs: const <SurahModel>[],
      );

      expect(target.ayahUQNumber, 777);
      expect(target.pageIndex, 439);
    });
  });
}
