/// General app constants
class AppConstants {
  AppConstants._();

  static const String appName = 'القرآن الكريم';
  static const String appNameEn = 'Quran Kareem';
  static const String appSubtitle = 'النسخة الفاخرة';

  // Database
  static const String quranDbName = 'quran_uthmani.db';
  static const String quranDbAssetPath = 'assets/db/quran_uthmani.db';

  // API endpoints
  static const String quranApiBaseUrl = 'https://api.quran.com/api/v4';
  static const String aladhanApiBaseUrl = 'https://api.aladhan.com/v1';
  static const int defaultTranslationResourceId = 85;
  static const int translationApiPageSize = 50;

  // Debounce durations
  static const int scrollDebounceMs = 500;
  static const int searchDebounceMs = 300;

  // UI constants
  static const double cardRadius = 16.0;
  static const double cardRadiusLarge = 24.0;
  static const double cardRadiusChildren = 30.0;
  static const double bottomSheetMinRatio = 0.45;
  static const double bottomSheetMaxRatio = 0.95;

  // Total surahs and ayahs
  static const int totalSurahs = 114;
  static const int totalAyahs = 6236;
  static const int totalPages = 604;
  static const int totalJuz = 30;
}
