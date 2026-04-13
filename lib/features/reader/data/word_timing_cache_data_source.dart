import 'dart:convert';

import 'package:quran_kareem/features/reader/domain/word_timing_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local cache for [SurahTimingData] stored in [SharedPreferences].
///
/// Cache key format: `muallim_timing_{reciterId}_{surahNumber}`
/// TTL: 30 days — refreshed on each successful remote fetch.
///
/// Unavailable results (empty timing) are intentionally NOT cached so the
/// app retries on next launch in case connectivity improves.
class WordTimingCacheDataSource {
  WordTimingCacheDataSource({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const Duration _ttl = Duration(days: 30);
  static const String _prefix = 'muallim_timing_';
  static const String _tsPrefix = 'muallim_timing_ts_';

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _dataKey(String reciterId, int surahNumber) =>
      '$_prefix${reciterId}_$surahNumber';

  String _tsKey(String reciterId, int surahNumber) =>
      '$_tsPrefix${reciterId}_$surahNumber';

  /// Returns cached [SurahTimingData] or null on cache miss / expiry.
  Future<SurahTimingData?> get({
    required int surahNumber,
    required String reciterId,
  }) async {
    final prefs = await _getPrefs();
    final tsKey = _tsKey(reciterId, surahNumber);
    final dataKey = _dataKey(reciterId, surahNumber);

    final timestampMs = prefs.getInt(tsKey);
    if (timestampMs == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    if (DateTime.now().difference(cachedAt) > _ttl) {
      // Expired — remove stale data
      await prefs.remove(tsKey);
      await prefs.remove(dataKey);
      return null;
    }

    final jsonStr = prefs.getString(dataKey);
    if (jsonStr == null) return null;

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _deserialize(map, surahNumber: surahNumber, reciterId: reciterId);
    } catch (_) {
      // Corrupted cache — purge silently
      await prefs.remove(tsKey);
      await prefs.remove(dataKey);
      return null;
    }
  }

  /// Stores [data] in cache with current timestamp.
  /// Silently no-ops if [data] is unavailable (empty timing).
  Future<void> put(SurahTimingData data) async {
    if (!data.isAvailable) return;

    final prefs = await _getPrefs();
    final jsonStr = jsonEncode(_serialize(data));
    final tsMs = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString(_dataKey(data.reciterId, data.surahNumber), jsonStr);
    await prefs.setInt(_tsKey(data.reciterId, data.surahNumber), tsMs);
  }

  /// Invalidates the cache entry for [surahNumber] + [reciterId].
  Future<void> invalidate({
    required int surahNumber,
    required String reciterId,
  }) async {
    final prefs = await _getPrefs();
    await prefs.remove(_dataKey(reciterId, surahNumber));
    await prefs.remove(_tsKey(reciterId, surahNumber));
  }

  // ─── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> _serialize(SurahTimingData data) {
    return {
      'audioUrl': data.audioUrl,
      'hasWordSegments': data.hasWordSegments,
      'ayahTimings': data.ayahTimings.map(_serializeAyah).toList(),
    };
  }

  Map<String, dynamic> _serializeAyah(AyahTimingData ayah) {
    return {
      'verseKey': ayah.verseKey,
      'surahNumber': ayah.surahNumber,
      'ayahNumber': ayah.ayahNumber,
      'timestampFrom': ayah.timestampFrom,
      'timestampTo': ayah.timestampTo,
      'segments': ayah.segments
          .map((s) => [s.wordIndex, s.startMs, s.endMs])
          .toList(),
    };
  }

  SurahTimingData _deserialize(
    Map<String, dynamic> map, {
    required int surahNumber,
    required String reciterId,
  }) {
    final ayahList = map['ayahTimings'] as List<dynamic>;
    final ayahTimings = ayahList
        .whereType<Map<String, dynamic>>()
        .map(_deserializeAyah)
        .toList();

    return SurahTimingData(
      surahNumber: surahNumber,
      reciterId: reciterId,
      audioUrl: map['audioUrl'] as String? ?? '',
      ayahTimings: ayahTimings,
      hasWordSegments: map['hasWordSegments'] as bool? ?? false,
    );
  }

  AyahTimingData _deserializeAyah(Map<String, dynamic> map) {
    final rawSegments = map['segments'] as List<dynamic>? ?? [];
    final segments = rawSegments
        .whereType<List<dynamic>>()
        .where((s) => s.length >= 3)
        .map(
          (s) => WordTimingSegment(
            wordIndex: (s[0] as num).toInt(),
            startMs: (s[1] as num).toInt(),
            endMs: (s[2] as num).toInt(),
          ),
        )
        .toList();

    return AyahTimingData(
      verseKey: map['verseKey'] as String,
      surahNumber: (map['surahNumber'] as num).toInt(),
      ayahNumber: (map['ayahNumber'] as num).toInt(),
      timestampFrom: (map['timestampFrom'] as num).toInt(),
      timestampTo: (map['timestampTo'] as num).toInt(),
      segments: List.unmodifiable(segments),
    );
  }
}
