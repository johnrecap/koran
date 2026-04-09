import 'dart:convert';

import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/prayer_day_tracking.dart';
import '../domain/prayer_time_models.dart';
import '../domain/prayer_times_policies.dart';

abstract class PrayerTrackingLocalDataSource {
  Future<Map<String, PrayerDayTracking>> loadTrackings(
    Iterable<String> dateKeys,
  );

  Future<Map<String, PrayerDayTracking>> getTrackingsForDateRange(
    String startKey,
    String endKey,
  );

  Future<void> setPrayerCompleted({
    required String dateKey,
    required PrayerType prayer,
    required bool completed,
  });
}

class SharedPreferencesPrayerTrackingLocalDataSource
    implements PrayerTrackingLocalDataSource {
  SharedPreferencesPrayerTrackingLocalDataSource();

  static const _storageKey = 'prayerTracking.v1';

  @override
  Future<Map<String, PrayerDayTracking>> loadTrackings(
    Iterable<String> dateKeys,
  ) async {
    final prefs = await UserPreferences.prefs;
    final decoded = await _loadStorageMap(prefs);

    final result = <String, PrayerDayTracking>{};
    for (final key in dateKeys) {
      final rawValue = decoded[key];
      final prayerNames = rawValue is List
          ? rawValue.whereType<String>().toList(growable: false)
          : const <String>[];
      result[key] = PrayerDayTracking(
        dateKey: key,
        completedPrayers: prayerNames
            .map(_prayerTypeFromStorageName)
            .whereType<PrayerType>()
            .toSet(),
      );
    }
    return result;
  }

  @override
  Future<Map<String, PrayerDayTracking>> getTrackingsForDateRange(
    String startKey,
    String endKey,
  ) async {
    final start = PrayerTimesPolicies.parseDateKey(startKey);
    final end = PrayerTimesPolicies.parseDateKey(endKey);
    if (end.isBefore(start)) {
      return <String, PrayerDayTracking>{};
    }

    final dateKeys = <String>[];
    var cursor = DateTime(start.year, start.month, start.day);
    final inclusiveEnd = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(inclusiveEnd)) {
      dateKeys.add(PrayerTimesPolicies.dateKey(cursor));
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    return loadTrackings(dateKeys);
  }

  @override
  Future<void> setPrayerCompleted({
    required String dateKey,
    required PrayerType prayer,
    required bool completed,
  }) async {
    final prefs = await UserPreferences.prefs;
    final decoded = await _loadStorageMap(prefs);

    final currentList =
        (decoded[dateKey] as List<dynamic>? ?? const <dynamic>[])
            .whereType<String>()
            .toSet();
    final prayerName = prayer.name;
    if (completed) {
      currentList.add(prayerName);
    } else {
      currentList.remove(prayerName);
    }

    decoded[dateKey] = currentList.toList(growable: false);
    await prefs.setString(_storageKey, jsonEncode(decoded));
  }

  PrayerType? _prayerTypeFromStorageName(String value) {
    for (final prayer in PrayerType.values) {
      if (prayer.name == value) {
        return prayer;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _loadStorageMap(SharedPreferences prefs) async {
    final payload = prefs.getString(_storageKey);
    if (payload == null || payload.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'SharedPreferencesPrayerTrackingLocalDataSource._loadStorageMap',
        error,
        stackTrace,
      );
      // Rebuild the payload from scratch on the next write.
    }

    await prefs.remove(_storageKey);
    return <String, dynamic>{};
  }
}
