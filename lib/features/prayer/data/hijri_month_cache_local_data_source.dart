import 'dart:convert';

import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';

import '../domain/hijri_calendar_month.dart';

abstract class HijriMonthCacheLocalDataSource {
  Future<HijriCalendarMonthData?> load({
    required int hijriYear,
    required int hijriMonth,
  });

  Future<void> save(HijriCalendarMonthData month);
}

class SharedPreferencesHijriMonthCacheLocalDataSource
    implements HijriMonthCacheLocalDataSource {
  static const _storagePrefix = StorageKeys.hijriMonthCachePrefix;

  @override
  Future<HijriCalendarMonthData?> load({
    required int hijriYear,
    required int hijriMonth,
  }) async {
    final prefs = await UserPreferences.prefs;
    final key = _storageKey(
      hijriYear: hijriYear,
      hijriMonth: hijriMonth,
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

      return HijriCalendarMonthData.fromMap(decoded);
    } catch (error, stackTrace) {
      AppLogger.error(
        'SharedPreferencesHijriMonthCacheLocalDataSource.load',
        error,
        stackTrace,
      );
      await prefs.remove(key);
      return null;
    }
  }

  @override
  Future<void> save(HijriCalendarMonthData month) async {
    final prefs = await UserPreferences.prefs;
    final key = _storageKey(
      hijriYear: month.reference.year,
      hijriMonth: month.reference.month,
    );
    await prefs.setString(key, jsonEncode(month.toMap()));
  }

  String _storageKey({
    required int hijriYear,
    required int hijriMonth,
  }) {
    final normalizedMonth = hijriMonth.toString().padLeft(2, '0');
    return '$_storagePrefix.$hijriYear-$normalizedMonth';
  }
}
