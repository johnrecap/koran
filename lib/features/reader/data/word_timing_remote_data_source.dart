import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/features/reader/data/reciter_id_mapping.dart';
import 'package:quran_kareem/features/reader/domain/word_timing_models.dart';

class WordTimingRemoteException implements Exception {
  const WordTimingRemoteException(this.message);
  final String message;

  @override
  String toString() => 'WordTimingRemoteException: $message';
}

/// Fetches word-level timing segments from the Quran.com API v4.
///
/// Endpoint:
///   GET /chapter_recitations/{reciter_id}/{chapter_number}?segments=true
///
/// Response shape:
/// ```json
/// {
///   "audio_file": {
///     "audio_url": "...",
///     "timestamps": [
///       {
///         "verse_key": "1:1",
///         "timestamp_from": 0,
///         "timestamp_to": 6493,
///         "segments": [[word_index, start_ms, end_ms], ...]
///       }
///     ]
///   }
/// }
/// ```
class WordTimingRemoteDataSource {
  WordTimingRemoteDataSource({
    required http.Client client,
    this.baseUrl = AppConstants.quranApiBaseUrl,
  }) : _client = client;

  final http.Client _client;
  final String baseUrl;

  /// Fetches timing data for [surahNumber] using [readerNamePath].
  ///
  /// Returns [SurahTimingData.unavailable] when:
  /// - The reciter has no Quran.com mapping.
  /// - The API returns no timing data.
  /// - The API returns a non-200 status.
  ///
  /// Throws [WordTimingRemoteException] on network or parsing errors that are
  /// unexpected (malformed JSON, etc.).
  Future<SurahTimingData> fetchSurahTimings({
    required int surahNumber,
    required String readerNamePath,
  }) async {
    final quranComId = ReciterIdMapping.quranComIdFor(readerNamePath);
    if (quranComId == null) {
      return SurahTimingData.unavailable(
        surahNumber: surahNumber,
        reciterId: readerNamePath,
      );
    }

    final uri = Uri.parse(
      '$baseUrl/chapter_recitations/$quranComId/$surahNumber',
    ).replace(queryParameters: {'segments': 'true'});

    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw WordTimingRemoteException('Network error: $e');
    }

    if (response.statusCode == 404) {
      // Reciter or surah not available — treat as graceful unavailable.
      return SurahTimingData.unavailable(
        surahNumber: surahNumber,
        reciterId: readerNamePath,
      );
    }

    if (response.statusCode != 200) {
      throw WordTimingRemoteException(
        'Unexpected status code: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw const WordTimingRemoteException('Failed to parse JSON response.');
    }

    return _parseResponse(
      payload: payload,
      surahNumber: surahNumber,
      readerNamePath: readerNamePath,
    );
  }

  SurahTimingData _parseResponse({
    required Map<String, dynamic> payload,
    required int surahNumber,
    required String readerNamePath,
  }) {
    final audioFile = payload['audio_file'];
    if (audioFile is! Map<String, dynamic>) {
      return SurahTimingData.unavailable(
        surahNumber: surahNumber,
        reciterId: readerNamePath,
      );
    }

    final audioUrl = audioFile['audio_url'] as String? ?? '';
    final rawTimestamps = audioFile['timestamps'];

    if (rawTimestamps is! List || rawTimestamps.isEmpty) {
      return SurahTimingData.unavailable(
        surahNumber: surahNumber,
        reciterId: readerNamePath,
      );
    }

    final ayahTimings = <AyahTimingData>[];
    var hasWordSegments = false;

    for (final entry in rawTimestamps) {
      if (entry is! Map<String, dynamic>) continue;

      final ayahData = _parseAyahTiming(entry);
      if (ayahData == null) continue;

      if (ayahData.hasWordSegments) hasWordSegments = true;
      ayahTimings.add(ayahData);
    }

    return SurahTimingData(
      surahNumber: surahNumber,
      reciterId: readerNamePath,
      audioUrl: audioUrl,
      ayahTimings: ayahTimings,
      hasWordSegments: hasWordSegments,
    );
  }

  AyahTimingData? _parseAyahTiming(Map<String, dynamic> entry) {
    final verseKey = entry['verse_key'] as String?;
    if (verseKey == null) return null;

    final parts = verseKey.split(':');
    if (parts.length != 2) return null;

    final surahNumber = int.tryParse(parts[0]);
    final ayahNumber = int.tryParse(parts[1]);
    if (surahNumber == null || ayahNumber == null) return null;

    final timestampFrom = _parseInt(entry['timestamp_from']) ?? 0;
    final timestampTo = _parseInt(entry['timestamp_to']) ?? 0;

    final segments = _parseSegments(entry['segments']);

    return AyahTimingData(
      verseKey: verseKey,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      timestampFrom: timestampFrom,
      timestampTo: timestampTo,
      segments: segments,
    );
  }

  List<WordTimingSegment> _parseSegments(Object? raw) {
    if (raw is! List) return const [];

    final result = <WordTimingSegment>[];
    for (final item in raw) {
      if (item is! List || item.length < 3) continue;

      final wordIndex = _parseInt(item[0]);
      final startMs = _parseInt(item[1]);
      final endMs = _parseInt(item[2]);

      if (wordIndex == null || startMs == null || endMs == null) continue;
      if (startMs > endMs) continue;

      result.add(
        WordTimingSegment(
          wordIndex: wordIndex,
          startMs: startMs,
          endMs: endMs,
        ),
      );
    }

    return List.unmodifiable(result);
  }

  int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
