import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_kareem/features/reader/data/word_timing_remote_data_source.dart';
import 'package:quran_kareem/features/reader/domain/word_timing_models.dart';

// Minimal valid API response for surah 1 with Basit (ID 1)
Map<String, dynamic> _buildApiResponse({
  String audioUrl = 'https://cdn.example.com/audio/1.mp3',
  List<Map<String, dynamic>> timestamps = const [],
}) {
  return {
    'audio_file': {
      'audio_url': audioUrl,
      'timestamps': timestamps,
    },
  };
}

Map<String, dynamic> _buildTimestamp({
  required String verseKey,
  required int from,
  required int to,
  List<List<int>> segments = const [],
}) {
  return {
    'verse_key': verseKey,
    'timestamp_from': from,
    'timestamp_to': to,
    'segments': segments,
  };
}

MockClient _mockClient(int statusCode, Map<String, dynamic> body) {
  return MockClient((_) async => http.Response(jsonEncode(body), statusCode));
}

void main() {
  group('WordTimingRemoteDataSource', () {
    late WordTimingRemoteDataSource sut;

    setUp(() {
      // Default: overridden per test
    });

    test(
      'returns unavailable when reciter has no Quran.com mapping',
      () async {
        sut = WordTimingRemoteDataSource(
          client: MockClient((_) async => http.Response('{}', 200)),
          baseUrl: 'https://test.example.com',
        );

        final result = await sut.fetchSurahTimings(
          surahNumber: 1,
          readerNamePath: 'Fares_Abbad_64kbps', // null-mapped reciter
        );

        expect(result.isAvailable, isFalse);
        expect(result.reciterId, equals('Fares_Abbad_64kbps'));
      },
    );

    test('returns unavailable when API returns 404', () async {
      sut = WordTimingRemoteDataSource(
        client: MockClient((_) async => http.Response('Not Found', 404)),
        baseUrl: 'https://test.example.com',
      );

      final result = await sut.fetchSurahTimings(
        surahNumber: 1,
        readerNamePath: 'Abdul_Basit_Murattal_192kbps',
      );

      expect(result.isAvailable, isFalse);
    });

    test('throws WordTimingRemoteException for unexpected status codes', () {
      sut = WordTimingRemoteDataSource(
        client: MockClient((_) async => http.Response('Error', 500)),
        baseUrl: 'https://test.example.com',
      );

      expect(
        () => sut.fetchSurahTimings(
          surahNumber: 1,
          readerNamePath: 'Abdul_Basit_Murattal_192kbps',
        ),
        throwsA(isA<WordTimingRemoteException>()),
      );
    });

    test(
      'returns unavailable when API response has no timestamps array',
      () async {
        sut = WordTimingRemoteDataSource(
          client: _mockClient(200, {'audio_file': {'audio_url': '', 'timestamps': []}}),
          baseUrl: 'https://test.example.com',
        );

        final result = await sut.fetchSurahTimings(
          surahNumber: 1,
          readerNamePath: 'Abdul_Basit_Murattal_192kbps',
        );

        expect(result.isAvailable, isFalse);
      },
    );

    test('parses timestamps without word segments', () async {
      final body = _buildApiResponse(timestamps: [
        _buildTimestamp(verseKey: '1:1', from: 0, to: 5000),
        _buildTimestamp(verseKey: '1:2', from: 5001, to: 10000),
      ]);

      sut = WordTimingRemoteDataSource(
        client: _mockClient(200, body),
        baseUrl: 'https://test.example.com',
      );

      final result = await sut.fetchSurahTimings(
        surahNumber: 1,
        readerNamePath: 'Abdul_Basit_Murattal_192kbps',
      );

      expect(result.isAvailable, isTrue);
      expect(result.ayahTimings.length, equals(2));
      expect(result.hasWordSegments, isFalse);
      expect(result.forAyah(1)?.timestampFrom, equals(0));
      expect(result.forAyah(2)?.timestampTo, equals(10000));
    });

    test('parses timestamps WITH word segments correctly', () async {
      final body = _buildApiResponse(timestamps: [
        _buildTimestamp(
          verseKey: '1:1',
          from: 0,
          to: 6000,
          segments: [
            [0, 0, 1000],
            [1, 1001, 2500],
            [2, 2501, 4000],
          ],
        ),
      ]);

      sut = WordTimingRemoteDataSource(
        client: _mockClient(200, body),
        baseUrl: 'https://test.example.com',
      );

      final result = await sut.fetchSurahTimings(
        surahNumber: 1,
        readerNamePath: 'Abdul_Basit_Murattal_192kbps',
      );

      expect(result.isAvailable, isTrue);
      expect(result.hasWordSegments, isTrue);

      final ayah = result.forAyah(1)!;
      expect(ayah.segments.length, equals(3));
      expect(ayah.segments[0].wordIndex, equals(0));
      expect(ayah.segments[0].startMs, equals(0));
      expect(ayah.segments[0].endMs, equals(1000));
      expect(ayah.segments[2].wordIndex, equals(2));
    });

    test('skips malformed segment entries gracefully', () async {
      final body = _buildApiResponse(timestamps: [
        {
          'verse_key': '1:1',
          'timestamp_from': 0,
          'timestamp_to': 5000,
          'segments': [
            [0, 0, 1000],     // valid
            [1, 'bad'],        // malformed — too short
            null,              // null entry
            [2, 2000, 3000],  // valid
          ],
        },
      ]);

      sut = WordTimingRemoteDataSource(
        client: _mockClient(200, body),
        baseUrl: 'https://test.example.com',
      );

      final result = await sut.fetchSurahTimings(
        surahNumber: 1,
        readerNamePath: 'Abdul_Basit_Murattal_192kbps',
      );

      final ayah = result.forAyah(1)!;
      expect(ayah.segments.length, equals(2));
      expect(ayah.segments[0].wordIndex, equals(0));
      expect(ayah.segments[1].wordIndex, equals(2));
    });

    test('skips invalid verse_key entries gracefully', () async {
      final body = _buildApiResponse(timestamps: [
        {'verse_key': 'bad-key', 'timestamp_from': 0, 'timestamp_to': 100},
        _buildTimestamp(verseKey: '1:1', from: 0, to: 5000),
      ]);

      sut = WordTimingRemoteDataSource(
        client: _mockClient(200, body),
        baseUrl: 'https://test.example.com',
      );

      final result = await sut.fetchSurahTimings(
        surahNumber: 1,
        readerNamePath: 'Abdul_Basit_Murattal_192kbps',
      );

      // Only the valid ayah is included
      expect(result.ayahTimings.length, equals(1));
      expect(result.ayahTimings[0].verseKey, equals('1:1'));
    });

    test('throws WordTimingRemoteException on network error', () {
      sut = WordTimingRemoteDataSource(
        client: MockClient((_) async => throw Exception('No internet')),
        baseUrl: 'https://test.example.com',
      );

      expect(
        () => sut.fetchSurahTimings(
          surahNumber: 1,
          readerNamePath: 'Abdul_Basit_Murattal_192kbps',
        ),
        throwsA(isA<WordTimingRemoteException>()),
      );
    });
  });
}
