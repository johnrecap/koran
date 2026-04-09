import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_library/quran_library.dart';
import 'package:sqflite/sqflite.dart';
import 'quran_metadata_lookup.dart';
import '../../../domain/entities/quran_entities.dart';

class QuranDatabaseException implements Exception {
  const QuranDatabaseException(this.message);

  final String message;

  @override
  String toString() => 'QuranDatabaseException: $message';
}

typedef QuranDatabaseDebugQuery = Future<List<Map<String, Object?>>> Function(
  String table, {
  List<String>? columns,
  String? where,
  List<Object?>? whereArgs,
  String? orderBy,
});
typedef QuranDatabaseDebugInit = Future<Database> Function();

/// Local SQLite database for Quran text (Tanzil Uthmani)
class QuranDatabase {
  static Database? _database;
  static Future<Database>? _databaseFuture;
  static QuranDatabaseDebugQuery? _debugQuery;
  static QuranDatabaseDebugInit? _debugInit;
  static List<SurahModel>? _debugCanonicalSurahs;
  static String? _surahTableName;
  static String? _ayahTableName;
  static const String _dbName = 'quran_uthmani.db';
  static const List<String> _surahTableCandidates = <String>[
    'suras',
    'chapters',
  ];
  static const List<String> _ayahTableCandidates = <String>[
    'quran_text',
    'verses',
  ];

  static void debugOverrideQueryForTest(QuranDatabaseDebugQuery? query) {
    _debugQuery = query;
    _surahTableName = null;
    _ayahTableName = null;
  }

  static void debugOverrideCanonicalSurahsForTest(List<SurahModel>? surahs) {
    _debugCanonicalSurahs = surahs;
  }

  static void debugOverrideInitForTest(QuranDatabaseDebugInit? init) {
    _debugInit = init;
    _surahTableName = null;
    _ayahTableName = null;
  }

  static Future<void> debugResetForTest() async {
    _debugQuery = null;
    _debugInit = null;
    _debugCanonicalSurahs = null;
    await _database?.close();
    _database = null;
    _databaseFuture = null;
    _surahTableName = null;
    _ayahTableName = null;
  }

  /// Get or initialize the database
  static Future<Database> get database async {
    final cachedDatabase = _database;
    if (cachedDatabase != null) {
      return cachedDatabase;
    }

    final inFlightDatabase = _databaseFuture;
    if (inFlightDatabase != null) {
      return inFlightDatabase;
    }

    final future = _createDatabase();
    _databaseFuture = future;

    try {
      final database = await future;
      _database = database;
      return database;
    } catch (error, stackTrace) {
      AppLogger.error('QuranDatabase.database', error, stackTrace);
      if (identical(_databaseFuture, future)) {
        _databaseFuture = null;
      }
      rethrow;
    }
  }

  static Future<Database> _createDatabase() {
    final debugInit = _debugInit;
    if (debugInit != null) {
      return debugInit();
    }

    return _initDatabase();
  }

  /// Copy the pre-built DB from assets to the app's documents directory
  /// Includes version check: if existing DB is too small (incomplete), replace it.
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Check if the database already exists
    final dbFile = File(path);
    final exists = await dbFile.exists();

    if (exists) {
      // Version check: old DB was ~32KB (only Al-Fatiha)
      // Full DB is ~1500KB+. Replace if too small.
      final size = await dbFile.length();
      if (size < 100000) {
        // DB is incomplete, replace it
        await dbFile.delete();
      }
    }

    if (!await dbFile.exists()) {
      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (error, stackTrace) {
        AppLogger.error('QuranDatabase._initDatabase', error, stackTrace);
      }

      // Copy from assets
      final data = await rootBundle.load('assets/db/$_dbName');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(path, readOnly: true);
    await _ensureSchemaDetected(databaseInstance: db);
    return db;
  }

  /// Get all surahs
  static Future<List<Surah>> getSurahs() async {
    final surahTableName = await _surahTableOrThrow();
    try {
      final maps = await _query(surahTableName);
      return _mapSurahs(maps, _canonicalSurahs);
    } catch (error, stackTrace) {
      AppLogger.error('QuranDatabase.getSurahs', error, stackTrace);
      throw const QuranDatabaseException(
        'Unable to load surahs from the local Quran database.',
      );
    }
  }

  /// Get all ayahs for a specific surah
  static Future<List<Ayah>> getAyahsBySurah(int surahNumber) async {
    final ayahTableName = await _ayahTableOrThrow();
    final surahColumn = _surahColumnFor(ayahTableName);
    final ayahOrderBy = _ayahOrderByFor(ayahTableName);
    try {
      final maps = await _query(
        ayahTableName,
        where: '$surahColumn = ?',
        whereArgs: [surahNumber],
        orderBy: ayahOrderBy,
      );
      return _mapAyahs(maps, _canonicalSurahs);
    } catch (error, stackTrace) {
      AppLogger.error('QuranDatabase.getAyahsBySurah', error, stackTrace);
      throw QuranDatabaseException(
        'Unable to load ayahs for surah $surahNumber from the local Quran database.',
      );
    }
  }

  /// Get all ayahs for a specific page
  static Future<List<Ayah>> getAyahsByPage(int page) async {
    final pageAyahs = QuranLibrary().getPageAyahsByPageNumber(pageNumber: page);
    return QuranMetadataLookup.toDomainAyahs(pageAyahs);
  }

  /// Search ayahs by text, optionally scoped to a single surah.
  static Future<List<Ayah>> searchAyahs(
    String query, {
    int? surahNumber,
  }) async {
    final ayahTableName = await _ayahTableOrThrow();
    final surahColumn = _surahColumnFor(ayahTableName);
    final ayahColumn = _ayahColumnFor(ayahTableName);
    try {
      final maps = await _query(
        ayahTableName,
        where: surahNumber == null
            ? 'text LIKE ?'
            : 'text LIKE ? AND $surahColumn = ?',
        whereArgs:
            surahNumber == null ? ['%$query%'] : ['%$query%', surahNumber],
        orderBy: '$surahColumn ASC, $ayahColumn ASC',
      );
      return _mapAyahs(maps, _canonicalSurahs);
    } catch (error, stackTrace) {
      AppLogger.error('QuranDatabase.searchAyahs', error, stackTrace);
      throw const QuranDatabaseException(
        'Unable to search ayahs in the local Quran database.',
      );
    }
  }

  /// Get a specific ayah
  static Future<Ayah?> getAyah(int surahNumber, int ayahNumber) async {
    final ayahTableName = await _ayahTableOrThrow();
    final surahColumn = _surahColumnFor(ayahTableName);
    final ayahColumn = _ayahColumnFor(ayahTableName);
    try {
      final maps = await _query(
        ayahTableName,
        where: '$surahColumn = ? AND $ayahColumn = ?',
        whereArgs: [surahNumber, ayahNumber],
      );
      if (maps.isNotEmpty) {
        return QuranMetadataLookup.enrichDomainAyah(
          Ayah.fromMap(maps.first),
          _canonicalSurahs,
        );
      }
      return null;
    } catch (error, stackTrace) {
      AppLogger.error('QuranDatabase.getAyah', error, stackTrace);
      throw QuranDatabaseException(
        'Unable to load ayah $surahNumber:$ayahNumber from the local Quran database.',
      );
    }
  }

  /// Get page number for a specific Surah and Ayah
  static Future<int> getPageForAyah(int surahNumber, int ayahNumber) async {
    final canonicalSurahs = QuranCtrl.instance.surahs;
    final canonicalPage = QuranMetadataLookup.resolveAyahPage(
      canonicalSurahs,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    if (canonicalPage > 1 || (surahNumber == 1 && ayahNumber == 1)) {
      return canonicalPage;
    }
    await _ensureSchemaDetected();
    final ayahTableName = _ayahTableName;
    if (ayahTableName != null) {
      final surahColumn = _surahColumnFor(ayahTableName);
      final ayahColumn = _ayahColumnFor(ayahTableName);
      try {
        final maps = await _query(
          ayahTableName,
          columns: ['page'],
          where: '$surahColumn = ? AND $ayahColumn = ?',
          whereArgs: [surahNumber, ayahNumber],
        );
        if (maps.isNotEmpty) {
          return maps.first['page'] as int;
        }
      } catch (error, stackTrace) {
        AppLogger.error('QuranDatabase.getPageForAyah', error, stackTrace);
      }
    }

    try {
      final surahs = await getSurahs();
      final surah = surahs.firstWhere((s) => s.number == surahNumber);
      return surah.page;
    } catch (error, stackTrace) {
      AppLogger.error(
        'QuranDatabase.getPageForAyahFallbackSurah',
        error,
        stackTrace,
      );
    }
    return 1;
  }

  static Future<void> _ensureSchemaDetected({Database? databaseInstance}) async {
    if (_surahTableName != null && _ayahTableName != null) {
      return;
    }

    final debugQuery = _debugQuery;
    if (debugQuery != null) {
      final availableTables = <String>{};
      for (final table in [..._surahTableCandidates, ..._ayahTableCandidates]) {
        if (await _debugTableExists(debugQuery, table)) {
          availableTables.add(table);
        }
      }
      _surahTableName = _firstSupportedTable(
        availableTables,
        _surahTableCandidates,
      );
      _ayahTableName = _firstSupportedTable(
        availableTables,
        _ayahTableCandidates,
      );
      return;
    }

    final db = databaseInstance;
    if (db == null) {
      await database;
      if (_surahTableName != null && _ayahTableName != null) {
        return;
      }
    }

    final schemaDatabase = db ?? _database;
    if (schemaDatabase == null) {
      return;
    }

    try {
      final tables = await schemaDatabase.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final availableTables = tables
          .map((row) => row['name'])
          .whereType<String>()
          .toSet();
      _surahTableName = _firstSupportedTable(
        availableTables,
        _surahTableCandidates,
      );
      _ayahTableName = _firstSupportedTable(
        availableTables,
        _ayahTableCandidates,
      );
    } catch (error, stackTrace) {
      if (_debugInit != null) {
        _surahTableName ??= _surahTableCandidates.first;
        _ayahTableName ??= _ayahTableCandidates.first;
        return;
      }
      AppLogger.error('QuranDatabase._ensureSchemaDetected', error, stackTrace);
      rethrow;
    }
  }

  static Future<bool> _debugTableExists(
    QuranDatabaseDebugQuery debugQuery,
    String table,
  ) async {
    try {
      await debugQuery(table);
      return true;
    } catch (error, stackTrace) {
      if (_isMissingTableError(error)) {
        return false;
      }
      AppLogger.error('QuranDatabase._debugTableExists', error, stackTrace);
      rethrow;
    }
  }

  static bool _isMissingTableError(Object error) {
    return error.toString().contains('no such table');
  }

  static String? _firstSupportedTable(
    Set<String> availableTables,
    List<String> candidates,
  ) {
    for (final table in candidates) {
      if (availableTables.contains(table)) {
        return table;
      }
    }
    return null;
  }

  static Future<String> _surahTableOrThrow() async {
    await _ensureSchemaDetected();
    final surahTableName = _surahTableName;
    if (surahTableName != null) {
      return surahTableName;
    }
    throw const QuranDatabaseException(
      'Unable to load surahs from the local Quran database.',
    );
  }

  static Future<String> _ayahTableOrThrow() async {
    await _ensureSchemaDetected();
    final ayahTableName = _ayahTableName;
    if (ayahTableName != null) {
      return ayahTableName;
    }
    throw const QuranDatabaseException(
      'Unable to load ayahs from the local Quran database.',
    );
  }

  static String _surahColumnFor(String ayahTableName) {
    return ayahTableName == 'verses' ? 'surah_number' : 'sura';
  }

  static String _ayahColumnFor(String ayahTableName) {
    return ayahTableName == 'verses' ? 'ayah_number' : 'aya';
  }

  static String _ayahOrderByFor(String ayahTableName) {
    return ayahTableName == 'verses' ? 'ayah_number ASC' : 'aya ASC';
  }

  static List<Surah> _mapSurahs(
    List<Map<String, Object?>> maps,
    List<SurahModel> canonicalSurahs,
  ) {
    return maps.map((map) {
      final surah = Surah.fromMap(map);
      return Surah(
        number: surah.number,
        nameArabic: surah.nameArabic,
        nameEnglish: surah.nameEnglish,
        nameTransliteration: surah.nameTransliteration,
        ayahCount: surah.ayahCount,
        revelationType: surah.revelationType,
        page: QuranMetadataLookup.resolveSurahStartPage(
          canonicalSurahs,
          surahNumber: surah.number,
        ),
      );
    }).toList(growable: false);
  }

  static List<Ayah> _mapAyahs(
    List<Map<String, Object?>> maps,
    List<SurahModel> canonicalSurahs,
  ) {
    return maps
        .map((map) => QuranMetadataLookup.enrichDomainAyah(
              Ayah.fromMap(map),
              canonicalSurahs,
            ))
        .toList(growable: false);
  }

  static Future<List<Map<String, Object?>>> _query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final debugQuery = _debugQuery;
    if (debugQuery != null) {
      return debugQuery(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );
    }

    final db = await database;
    return db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  static List<SurahModel> get _canonicalSurahs {
    final debugCanonicalSurahs = _debugCanonicalSurahs;
    if (debugCanonicalSurahs != null) {
      return debugCanonicalSurahs;
    }
    return QuranCtrl.instance.surahs;
  }
}
