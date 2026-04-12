import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/features/library/providers/library_data_classes.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  tearDown(() async {
    await QuranDatabase.debugResetForTest();
  });

  test(
      'translation resolver enriches fallback ayah metadata when direct lookup is unavailable',
      () async {
    QuranDatabase.debugOverrideCanonicalSurahsForTest(_fakeCanonicalSurahs);
    QuranDatabase.debugOverrideQueryForTest(
      (
        String table, {
        List<String>? columns,
        String? where,
        List<Object?>? whereArgs,
        String? orderBy,
      }) async {
        return const <Map<String, Object?>>[];
      },
    );

    const resolver = QuranDatabaseLibraryTranslationAyahResolver();
    const match = LibraryTranslationSearchMatch(
      surahNumber: 1,
      ayahNumber: 1,
      arabicText: 'Test Arabic Text',
      translationText: 'Test translation',
    );

    final ayah = await resolver.resolveMatch(match);

    expect(ayah.page, 5);
    expect(ayah.juz, 2);
    expect(ayah.hizb, 3);
    expect(ayah.text, 'Test Arabic Text');
  });
}

final _fakeCanonicalSurahs = <SurahModel>[
  SurahModel(
    surahNumber: 1,
    arabicName: 'Test Surah',
    englishName: 'Test Surah',
    revelationType: 'Meccan',
    ayahs: [
      AyahModel(
        ayahUQNumber: 1,
        ayahNumber: 1,
        text: 'Canonical text',
        ayaTextEmlaey: 'Canonical text',
        juz: 2,
        page: 5,
        surahNumber: 1,
        hizb: 3,
      ),
    ],
  ),
];
