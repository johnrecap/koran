import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_library/quran_library.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  tearDown(() async {
    await QuranDatabase.debugResetForTest();
  });

  test('loads surahs from fallback chapters table', () async {
    QuranDatabase.debugOverrideCanonicalSurahsForTest(_fakeCanonicalSurahs);
    QuranDatabase.debugOverrideQueryForTest(
      const _FakeQuranDatabaseQuery(
        failingTables: {'suras'},
        rowsByTable: {
          'chapters': [
            {
              'id': 1,
              'name_arabic': 'الفاتحة',
              'name_simple': 'Al-Fatihah',
              'name_transliteration': 'Al-Fatihah',
              'verses_count': 7,
              'revelation_type': 'Meccan',
            },
          ],
        },
      ).call,
    );

    final surahs = await QuranDatabase.getSurahs();

    expect(surahs, hasLength(1));
    expect(surahs.single.number, 1);
    expect(surahs.single.nameArabic, 'الفاتحة');
  });

  test('throws a typed exception when no supported surah tables exist',
      () async {
    QuranDatabase.debugOverrideQueryForTest(
      const _FakeQuranDatabaseQuery(
        failingTables: {'suras', 'chapters'},
      ).call,
    );

    await expectLater(
      QuranDatabase.getSurahs(),
      throwsA(isA<QuranDatabaseException>()),
    );
  });

  test('loads ayahs from fallback verses table', () async {
    QuranDatabase.debugOverrideCanonicalSurahsForTest(_fakeCanonicalSurahs);
    QuranDatabase.debugOverrideQueryForTest(
      const _FakeQuranDatabaseQuery(
        failingTables: {'quran_text'},
        rowsByTable: {
          'verses': [
            {
              'id': 1,
              'surah_number': 1,
              'ayah_number': 1,
              'text': 'بسم الله',
              'page': 1,
              'juz': 1,
              'hizb': 1,
            },
          ],
        },
      ).call,
    );

    final ayahs = await QuranDatabase.getAyahsBySurah(1);

    expect(ayahs, hasLength(1));
    expect(ayahs.single.ayahNumber, 1);
    expect(ayahs.single.text, 'بسم الله');
  });

  test('throws a typed exception when no supported ayah tables exist',
      () async {
    QuranDatabase.debugOverrideQueryForTest(
      const _FakeQuranDatabaseQuery(
        failingTables: {'quran_text', 'verses'},
      ).call,
    );

    await expectLater(
      QuranDatabase.getAyahsBySurah(1),
      throwsA(isA<QuranDatabaseException>()),
    );
  });

  test('shares one in-flight database initialization across concurrent callers',
      () async {
    final completer = Completer<Database>();
    final fakeDatabase = _FakeDatabase();
    var initCalls = 0;

    QuranDatabase.debugOverrideInitForTest(() {
      initCalls += 1;
      return completer.future;
    });

    final first = QuranDatabase.database;
    final second = QuranDatabase.database;

    expect(initCalls, 1);

    completer.complete(fakeDatabase);

    expect(await first, same(fakeDatabase));
    expect(await second, same(fakeDatabase));
    expect(initCalls, 1);
  });

  test('retries database initialization after a failed in-flight attempt',
      () async {
    final fakeDatabase = _FakeDatabase();
    var initCalls = 0;
    var shouldFail = true;

    QuranDatabase.debugOverrideInitForTest(() async {
      initCalls += 1;
      if (shouldFail) {
        throw StateError('boom');
      }

      return fakeDatabase;
    });

    await expectLater(QuranDatabase.database, throwsStateError);

    shouldFail = false;

    expect(await QuranDatabase.database, same(fakeDatabase));
    expect(initCalls, 2);
  });

  test('throws a typed exception when ayah search query fails', () async {
    QuranDatabase.debugOverrideInitForTest(
        () async => _ThrowingQueryDatabase());

    await expectLater(
      QuranDatabase.searchAyahs('mercy'),
      throwsA(isA<QuranDatabaseException>()),
    );
  });

  test('loads a single ayah from fallback verses table', () async {
    QuranDatabase.debugOverrideCanonicalSurahsForTest(_fakeCanonicalSurahs);
    QuranDatabase.debugOverrideQueryForTest(
      const _FakeQuranDatabaseQuery(
        failingTables: {'quran_text'},
        rowsByTable: {
          'verses': [
            {
              'id': 1,
              'surah_number': 1,
              'ayah_number': 1,
              'text': 'ط¨ط³ظ… ط§ظ„ظ„ظ‡',
              'page': 1,
              'juz': 1,
              'hizb': 1,
            },
          ],
        },
      ).call,
    );

    final ayah = await QuranDatabase.getAyah(1, 1);

    expect(ayah, isNotNull);
    expect(ayah!.surahNumber, 1);
    expect(ayah.ayahNumber, 1);
    expect(ayah.text, 'ط¨ط³ظ… ط§ظ„ظ„ظ‡');
  });

  test('returns null when a supported ayah lookup finds no rows', () async {
    QuranDatabase.debugOverrideCanonicalSurahsForTest(_fakeCanonicalSurahs);
    QuranDatabase.debugOverrideQueryForTest(
      const _FakeQuranDatabaseQuery().call,
    );

    final ayah = await QuranDatabase.getAyah(1, 1);

    expect(ayah, isNull);
  });

  test('throws a typed exception when no supported ayah lookup tables exist',
      () async {
    QuranDatabase.debugOverrideQueryForTest(
      const _FakeQuranDatabaseQuery(
        failingTables: {'quran_text', 'verses'},
      ).call,
    );

    await expectLater(
      QuranDatabase.getAyah(1, 1),
      throwsA(isA<QuranDatabaseException>()),
    );
  });
}

final _fakeCanonicalSurahs = <SurahModel>[
  SurahModel(
    surahNumber: 1,
    arabicName: 'الفاتحة',
    englishName: 'Al-Fatihah',
    revelationType: 'Meccan',
    ayahs: [
      AyahModel(
        ayahUQNumber: 1,
        ayahNumber: 1,
        text: 'بسم الله',
        ayaTextEmlaey: 'بسم الله',
        juz: 1,
        page: 1,
        surahNumber: 1,
        hizb: 1,
      ),
    ],
  ),
];

class _FakeQuranDatabaseQuery {
  const _FakeQuranDatabaseQuery({
    this.rowsByTable = const <String, List<Map<String, Object?>>>{},
    this.failingTables = const <String>{},
  });

  final Map<String, List<Map<String, Object?>>> rowsByTable;
  final Set<String> failingTables;

  Future<List<Map<String, Object?>>> call(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    if (failingTables.contains(table)) {
      throw StateError('no such table: $table');
    }

    return rowsByTable[table] ?? const <Map<String, Object?>>[];
  }
}

class _FakeDatabase extends Fake implements Database {
  @override
  Future<void> close() async {}
}

class _ThrowingQueryDatabase extends _FakeDatabase {
  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    throw StateError('search failed');
  }
}
