import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';

void main() {
  group('Quran entity value equality', () {
    test('Surah compares by value', () {
      const first = Surah(
        number: 1,
        nameArabic: 'Al-Fatihah Arabic',
        nameEnglish: 'The Opening',
        nameTransliteration: 'Al-Fatihah',
        ayahCount: 7,
        revelationType: 'Meccan',
        page: 1,
      );
      const second = Surah(
        number: 1,
        nameArabic: 'Al-Fatihah Arabic',
        nameEnglish: 'The Opening',
        nameTransliteration: 'Al-Fatihah',
        ayahCount: 7,
        revelationType: 'Meccan',
        page: 1,
      );
      const different = Surah(
        number: 2,
        nameArabic: 'Al-Baqarah Arabic',
        nameEnglish: 'The Cow',
        nameTransliteration: 'Al-Baqarah',
        ayahCount: 286,
        revelationType: 'Medinan',
        page: 2,
      );

      expect(first, equals(second));
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(equals(different)));
    });

    test('Ayah compares by value', () {
      const first = Ayah(
        id: 1,
        surahNumber: 1,
        ayahNumber: 1,
        text: 'In the name of Allah',
        page: 1,
        juz: 1,
        hizb: 1,
      );
      const second = Ayah(
        id: 1,
        surahNumber: 1,
        ayahNumber: 1,
        text: 'In the name of Allah',
        page: 1,
        juz: 1,
        hizb: 1,
      );
      const different = Ayah(
        id: 2,
        surahNumber: 1,
        ayahNumber: 2,
        text: 'All praise is due to Allah',
        page: 1,
        juz: 1,
        hizb: 1,
      );

      expect(first, equals(second));
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(equals(different)));
    });

    test('Bookmark compares by value', () {
      final createdAt = DateTime(2026, 4, 12, 9, 30);
      final first = Bookmark(
        id: 10,
        surahNumber: 18,
        ayahNumber: 5,
        name: 'Friday reading',
        createdAt: createdAt,
      );
      final second = Bookmark(
        id: 10,
        surahNumber: 18,
        ayahNumber: 5,
        name: 'Friday reading',
        createdAt: createdAt,
      );
      final different = Bookmark(
        id: 11,
        surahNumber: 18,
        ayahNumber: 6,
        name: 'Other',
        createdAt: createdAt.add(const Duration(minutes: 1)),
      );

      expect(first, equals(second));
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(equals(different)));
    });

    test('AyahNote compares by value', () {
      final createdAt = DateTime(2026, 4, 12, 10);
      final updatedAt = DateTime(2026, 4, 12, 10, 5);
      final first = AyahNote(
        id: 20,
        surahNumber: 36,
        ayahNumber: 12,
        content: 'Reflection note',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      final second = AyahNote(
        id: 20,
        surahNumber: 36,
        ayahNumber: 12,
        content: 'Reflection note',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      final different = AyahNote(
        id: 21,
        surahNumber: 36,
        ayahNumber: 13,
        content: 'Another note',
        createdAt: createdAt,
        updatedAt: updatedAt.add(const Duration(minutes: 1)),
      );

      expect(first, equals(second));
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(equals(different)));
    });

    test('ReadingPosition compares by value', () {
      final savedAt = DateTime(2026, 4, 12, 11);
      final first = ReadingPosition(
        surahNumber: 55,
        ayahNumber: 13,
        page: 531,
        savedAt: savedAt,
      );
      final second = ReadingPosition(
        surahNumber: 55,
        ayahNumber: 13,
        page: 531,
        savedAt: savedAt,
      );
      final different = ReadingPosition(
        surahNumber: 55,
        ayahNumber: 14,
        page: 532,
        savedAt: savedAt.add(const Duration(minutes: 1)),
      );

      expect(first, equals(second));
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(equals(different)));
    });
  });
}
