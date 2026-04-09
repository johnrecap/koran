import 'dart:convert';

import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';

import '../domain/prayer_time_models.dart';

abstract class HomePrayerSnapshotCacheLocalDataSource {
  Future<CachedHomePrayerSnapshotData?> load();

  Future<void> save(CachedHomePrayerSnapshotData snapshot);
}

class SharedPreferencesHomePrayerSnapshotCacheLocalDataSource
    implements HomePrayerSnapshotCacheLocalDataSource {
  SharedPreferencesHomePrayerSnapshotCacheLocalDataSource();

  static const _storageKey = 'homePrayerSnapshotCache.v1';

  @override
  Future<CachedHomePrayerSnapshotData?> load() async {
    final prefs = await UserPreferences.prefs;
    final payload = prefs.getString(_storageKey);
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        await prefs.remove(_storageKey);
        return null;
      }

      return CachedHomePrayerSnapshotData.fromMap(decoded);
    } catch (error, stackTrace) {
      AppLogger.error(
        'SharedPreferencesHomePrayerSnapshotCacheLocalDataSource.load',
        error,
        stackTrace,
      );
      await prefs.remove(_storageKey);
      return null;
    }
  }

  @override
  Future<void> save(CachedHomePrayerSnapshotData snapshot) async {
    final prefs = await UserPreferences.prefs;
    await prefs.setString(_storageKey, jsonEncode(snapshot.toMap()));
  }
}
