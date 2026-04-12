import 'dart:convert';

import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';

import '../domain/prayer_time_models.dart';

abstract class PrayerMonthCacheLocalDataSource {
  Future<CachedPrayerTimesMonthData?> load({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  });

  Future<void> save(CachedPrayerTimesMonthData monthData);
}

class SharedPreferencesPrayerMonthCacheLocalDataSource
    implements PrayerMonthCacheLocalDataSource {
  static const _storagePrefix = StorageKeys.prayerMonthCachePrefix;

  @override
  Future<CachedPrayerTimesMonthData?> load({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    final prefs = await UserPreferences.prefs;
    final key = _storageKey(
      latitude: latitude,
      longitude: longitude,
      year: year,
      month: month,
    );
    final payload = prefs.getString(key);
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        await prefs.remove(key);
        return null;
      }

      return CachedPrayerTimesMonthData.fromMap(decoded);
    } catch (error, stackTrace) {
      AppLogger.error(
        'SharedPreferencesPrayerMonthCacheLocalDataSource.load',
        error,
        stackTrace,
      );
      await prefs.remove(key);
      return null;
    }
  }

  @override
  Future<void> save(CachedPrayerTimesMonthData monthData) async {
    final prefs = await UserPreferences.prefs;
    final key = _storageKey(
      latitude: monthData.location.latitude,
      longitude: monthData.location.longitude,
      year: monthData.month.gregorianYear,
      month: monthData.month.gregorianMonth,
    );
    await prefs.setString(key, jsonEncode(monthData.toMap()));
  }

  String _storageKey({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) {
    final normalizedMonth = month.toString().padLeft(2, '0');
    final lat = latitude.toStringAsFixed(2);
    final lng = longitude.toStringAsFixed(2);
    return '$_storagePrefix.$year-$normalizedMonth.$lat.$lng';
  }
}
