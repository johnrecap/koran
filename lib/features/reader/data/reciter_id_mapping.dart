/// Maps quran_library ayah reciter [readerNamePath] values to their
/// corresponding Quran.com API v4 chapter_recitation IDs.
///
/// Source: https://api.quran.com/api/v4/chapter_recitations
///
/// A null value means no timing data is available for that reciter on
/// Quran.com — the app falls back to ayah-level highlighting only.
class ReciterIdMapping {
  ReciterIdMapping._();

  /// Returns the Quran.com reciter ID for the given [readerNamePath],
  /// or null if no mapping is known.
  static int? quranComIdFor(String readerNamePath) {
    return _mapping[readerNamePath];
  }

  /// True when word-timing data is potentially available for [readerNamePath].
  static bool hasTimingSupport(String readerNamePath) {
    return _mapping.containsKey(readerNamePath) &&
        _mapping[readerNamePath] != null;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Mapping table
  //
  // quran_library readerNamePath (ayah mode)   →  Quran.com chapter_recitation ID
  // ────────────────────────────────────────────────────────────────────────────
  // Quran.com reciter IDs verified via:
  //   GET https://api.quran.com/api/v4/chapter_recitations
  // ────────────────────────────────────────────────────────────────────────────
  static const Map<String, int?> _mapping = {
    // عبد الباسط عبد الصمد — Mishary Murattal
    'Abdul_Basit_Murattal_192kbps': 1,

    // محمد صديق المنشاوي — Murattal
    'Minshawy_Murattal_128kbps': 3,

    // محمود خليل الحصري
    'Husary_128kbps': 5,

    // أحمد العجمي — everyayah.com path uses ar.ahmedajamy
    '128/ar.ahmedajamy': 8,

    // ماهر المعيقلي (both murattal & tajweed share same path/ID on everyayah)
    'MaherAlMuaiqly128kbps': 10,

    // عبد الله الجهني
    'Abdullaah_3awwaad_Al-Juhaynee_128kbps': 9,

    // محمد أيوب
    '128/ar.muhammadayyoub': 11,

    // فارس عباد — no Quran.com timing data available
    'Fares_Abbad_64kbps': null,

    // ياسر الدوسري — مجود
    'Yasser_Ad-Dussary_128kbps': 167,

    // سعود الشريم — no reliable Quran.com timing available
    'Saood_ash-Shuraym_128kbps': null,
  };
}
