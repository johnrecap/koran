import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/data/word_timing_cache_data_source.dart';
import 'package:quran_kareem/features/reader/domain/word_timing_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  group('WordTimingCacheDataSource', () {
    test('returns null when cache entry is missing', () async {
      final cache = WordTimingCacheDataSource();

      final result = await cache.get(
        surahNumber: 1,
        reciterId: 'reader-1',
      );

      expect(result, isNull);
    });

    test('returns cached timing data on cache hit', () async {
      final cache = WordTimingCacheDataSource();

      await cache.put(_sampleTimingData());
      final result = await cache.get(
        surahNumber: 1,
        reciterId: 'reader-1',
      );

      expect(result, isNotNull);
      expect(result!.surahNumber, 1);
      expect(result.reciterId, 'reader-1');
      expect(result.audioUrl, 'https://cdn.example.com/1.mp3');
      expect(result.hasWordSegments, isTrue);
      expect(result.ayahTimings.length, 1);
      expect(result.forAyah(1)?.segments.length, 3);
      expect(result.forAyah(1)?.segments[1].wordIndex, 1);
    });

    test('returns null and removes stale entries after ttl expiry', () async {
      final staleTimestamp = DateTime.now()
          .subtract(const Duration(days: 31))
          .millisecondsSinceEpoch;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'muallim_timing_reader-1_1': jsonEncode(_serializedSample()),
        'muallim_timing_ts_reader-1_1': staleTimestamp,
      });

      final cache = WordTimingCacheDataSource();
      final result = await cache.get(
        surahNumber: 1,
        reciterId: 'reader-1',
      );
      final prefs = await SharedPreferences.getInstance();

      expect(result, isNull);
      expect(prefs.containsKey('muallim_timing_reader-1_1'), isFalse);
      expect(prefs.containsKey('muallim_timing_ts_reader-1_1'), isFalse);
    });
  });
}

SurahTimingData _sampleTimingData() {
  return const SurahTimingData(
    surahNumber: 1,
    reciterId: 'reader-1',
    audioUrl: 'https://cdn.example.com/1.mp3',
    hasWordSegments: true,
    ayahTimings: [
      AyahTimingData(
        verseKey: '1:1',
        surahNumber: 1,
        ayahNumber: 1,
        timestampFrom: 0,
        timestampTo: 3200,
        segments: [
          WordTimingSegment(wordIndex: 0, startMs: 0, endMs: 900),
          WordTimingSegment(wordIndex: 1, startMs: 901, endMs: 1800),
          WordTimingSegment(wordIndex: 2, startMs: 1801, endMs: 3200),
        ],
      ),
    ],
  );
}

Map<String, Object> _serializedSample() {
  return <String, Object>{
    'audioUrl': 'https://cdn.example.com/1.mp3',
    'hasWordSegments': true,
    'ayahTimings': <Object>[
      <String, Object>{
        'verseKey': '1:1',
        'surahNumber': 1,
        'ayahNumber': 1,
        'timestampFrom': 0,
        'timestampTo': 3200,
        'segments': <Object>[
          <int>[0, 0, 900],
          <int>[1, 901, 1800],
          <int>[2, 1801, 3200],
        ],
      },
    ],
  };
}
