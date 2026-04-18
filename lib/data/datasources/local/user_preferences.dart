import 'dart:convert';
import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/quran_entities.dart';

/// Manages user preferences and local data (bookmarks, reading position, etc.)
class UserPreferences {
  static const _mushafSetupCompleteKey = StorageKeys.mushafSetupComplete;

  static SharedPreferences? _prefs;

  static void resetCache() {
    _prefs = null;
  }

  static Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─── Theme ───
  static Future<String> getThemeMode() async {
    final p = await prefs;
    return p.getString(StorageKeys.themeMode) ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    final p = await prefs;
    await p.setString(StorageKeys.themeMode, mode);
  }

  // ─── Language ───
  static Future<String> getLanguage() async {
    final p = await prefs;
    return p.getString(StorageKeys.language) ?? 'ar';
  }

  static Future<void> setLanguage(String lang) async {
    final p = await prefs;
    await p.setString(StorageKeys.language, lang);
  }

  // ─── Font Size ───
  static Future<double> getArabicFontSize() async {
    final p = await prefs;
    return p.getDouble(StorageKeys.arabicFontSize) ?? 28.0;
  }

  static Future<void> setArabicFontSize(double size) async {
    final p = await prefs;
    await p.setDouble(StorageKeys.arabicFontSize, size);
  }

  // ─── Reading Position ───
  static Future<ReadingPosition?> getLastReadingPosition() async {
    final p = await prefs;
    final json = p.getString(StorageKeys.lastReadingPosition);
    if (json == null) return null;
    try {
      return ReadingPosition.fromMap(jsonDecode(json));
    } catch (error, stackTrace) {
      AppLogger.error(
        'UserPreferences.getLastReadingPosition',
        error,
        stackTrace,
      );
      return null;
    }
  }

  static Future<void> setLastReadingPosition(ReadingPosition pos) async {
    final p = await prefs;
    await p.setString(
      StorageKeys.lastReadingPosition,
      jsonEncode(pos.toMap()),
    );
  }

  // ─── Reader Mode ───
  static Future<String> getReaderMode() async {
    final p = await prefs;
    return p.getString(StorageKeys.readerMode) ??
        'scroll'; // scroll, page, translation
  }

  static Future<void> setReaderMode(String mode) async {
    final p = await prefs;
    await p.setString(StorageKeys.readerMode, mode);
  }

  static Future<bool> isNightReaderAutoEnableEnabled() async {
    final p = await prefs;
    return p.getBool(StorageKeys.nightReaderAutoEnable) ?? false;
  }

  static Future<void> setNightReaderAutoEnable(bool enabled) async {
    final p = await prefs;
    await p.setBool(StorageKeys.nightReaderAutoEnable, enabled);
  }

  static Future<int> getNightReaderStartMinutes() async {
    final p = await prefs;
    return p.getInt(StorageKeys.nightReaderStartMinutes) ?? (20 * 60);
  }

  static Future<void> setNightReaderStartMinutes(int minutes) async {
    final p = await prefs;
    await p.setInt(StorageKeys.nightReaderStartMinutes, minutes);
  }

  static Future<int> getNightReaderEndMinutes() async {
    final p = await prefs;
    return p.getInt(StorageKeys.nightReaderEndMinutes) ?? (5 * 60);
  }

  static Future<void> setNightReaderEndMinutes(int minutes) async {
    final p = await prefs;
    await p.setInt(StorageKeys.nightReaderEndMinutes, minutes);
  }

  static Future<ReaderNightStyle> getPreferredNightReaderStyle() async {
    final p = await prefs;
    return ReaderNightStylePolicy.fromPreference(
      p.getString(StorageKeys.nightReaderPreferredStyle),
    );
  }

  static Future<void> setPreferredNightReaderStyle(ReaderNightStyle style) async {
    final p = await prefs;
    await p.setString(
      StorageKeys.nightReaderPreferredStyle,
      ReaderNightStylePolicy.toPreference(style),
    );
  }

  // ─── Tajweed ───
  static Future<bool> isTajweedEnabled() async {
    final p = await prefs;
    return p.getBool(StorageKeys.tajweedEnabled) ?? false;
  }

  static Future<void> setTajweedEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(StorageKeys.tajweedEnabled, enabled);
  }

  // ─── Onboarding ───
  static Future<bool> isOnboardingComplete() async {
    final p = await prefs;
    return p.getBool(StorageKeys.onboardingComplete) ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    final p = await prefs;
    await p.setBool(StorageKeys.onboardingComplete, complete);
  }

  static Future<bool> isMushafSetupComplete() async {
    final p = await prefs;
    return p.getBool(_mushafSetupCompleteKey) ?? false;
  }

  static Future<void> setMushafSetupComplete(bool complete) async {
    final p = await prefs;
    await p.setBool(_mushafSetupCompleteKey, complete);
  }

  // ─── Permissions Flow ───
  static Future<bool> isPermissionsFlowComplete() async {
    final p = await prefs;
    return p.getBool(StorageKeys.permissionsFlowComplete) ?? false;
  }

  static Future<void> setPermissionsFlowComplete(bool complete) async {
    final p = await prefs;
    await p.setBool(StorageKeys.permissionsFlowComplete, complete);
  }

  // ─── Selected Reciter ───
  static Future<String> getSelectedReciter() async {
    final p = await prefs;
    return p.getString(StorageKeys.selectedReciter) ??
        'ar.alafasy'; // Default: Mishary Alafasy
  }

  static Future<void> setSelectedReciter(String reciterId) async {
    final p = await prefs;
    await p.setString(StorageKeys.selectedReciter, reciterId);
  }
}
