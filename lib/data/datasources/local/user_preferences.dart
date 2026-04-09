import 'dart:convert';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/quran_entities.dart';

/// Manages user preferences and local data (bookmarks, reading position, etc.)
class UserPreferences {
  static const _mushafSetupCompleteKey = 'mushafSetupComplete';

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
    return p.getString('themeMode') ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    final p = await prefs;
    await p.setString('themeMode', mode);
  }

  // ─── Language ───
  static Future<String> getLanguage() async {
    final p = await prefs;
    return p.getString('language') ?? 'ar';
  }

  static Future<void> setLanguage(String lang) async {
    final p = await prefs;
    await p.setString('language', lang);
  }

  // ─── Font Size ───
  static Future<double> getArabicFontSize() async {
    final p = await prefs;
    return p.getDouble('arabicFontSize') ?? 28.0;
  }

  static Future<void> setArabicFontSize(double size) async {
    final p = await prefs;
    await p.setDouble('arabicFontSize', size);
  }

  // ─── Reading Position ───
  static Future<ReadingPosition?> getLastReadingPosition() async {
    final p = await prefs;
    final json = p.getString('lastReadingPosition');
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
    await p.setString('lastReadingPosition', jsonEncode(pos.toMap()));
  }

  // ─── Reader Mode ───
  static Future<String> getReaderMode() async {
    final p = await prefs;
    return p.getString('readerMode') ?? 'scroll'; // scroll, page, translation
  }

  static Future<void> setReaderMode(String mode) async {
    final p = await prefs;
    await p.setString('readerMode', mode);
  }

  static Future<bool> isNightReaderAutoEnableEnabled() async {
    final p = await prefs;
    return p.getBool('nightReaderAutoEnable') ?? false;
  }

  static Future<void> setNightReaderAutoEnable(bool enabled) async {
    final p = await prefs;
    await p.setBool('nightReaderAutoEnable', enabled);
  }

  static Future<int> getNightReaderStartMinutes() async {
    final p = await prefs;
    return p.getInt('nightReaderStartMinutes') ?? (20 * 60);
  }

  static Future<void> setNightReaderStartMinutes(int minutes) async {
    final p = await prefs;
    await p.setInt('nightReaderStartMinutes', minutes);
  }

  static Future<int> getNightReaderEndMinutes() async {
    final p = await prefs;
    return p.getInt('nightReaderEndMinutes') ?? (5 * 60);
  }

  static Future<void> setNightReaderEndMinutes(int minutes) async {
    final p = await prefs;
    await p.setInt('nightReaderEndMinutes', minutes);
  }

  static Future<ReaderNightStyle> getPreferredNightReaderStyle() async {
    final p = await prefs;
    return ReaderNightStylePolicy.fromPreference(
      p.getString('nightReaderPreferredStyle'),
    );
  }

  static Future<void> setPreferredNightReaderStyle(ReaderNightStyle style) async {
    final p = await prefs;
    await p.setString(
      'nightReaderPreferredStyle',
      ReaderNightStylePolicy.toPreference(style),
    );
  }

  // ─── Tajweed ───
  static Future<bool> isTajweedEnabled() async {
    final p = await prefs;
    return p.getBool('tajweedEnabled') ?? false;
  }

  static Future<void> setTajweedEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool('tajweedEnabled', enabled);
  }

  // ─── Onboarding ───
  static Future<bool> isOnboardingComplete() async {
    final p = await prefs;
    return p.getBool('onboardingComplete') ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    final p = await prefs;
    await p.setBool('onboardingComplete', complete);
  }

  static Future<bool> isMushafSetupComplete() async {
    final p = await prefs;
    return p.getBool(_mushafSetupCompleteKey) ?? false;
  }

  static Future<void> setMushafSetupComplete(bool complete) async {
    final p = await prefs;
    await p.setBool(_mushafSetupCompleteKey, complete);
  }

  // ─── Selected Reciter ───
  static Future<String> getSelectedReciter() async {
    final p = await prefs;
    return p.getString('selectedReciter') ??
        'ar.alafasy'; // Default: Mishary Alafasy
  }

  static Future<void> setSelectedReciter(String reciterId) async {
    final p = await prefs;
    await p.setString('selectedReciter', reciterId);
  }
}
