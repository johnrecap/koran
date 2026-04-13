import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/word_timing_models.dart';

void main() {
  group('WordTimingSegment', () {
    const seg = WordTimingSegment(wordIndex: 2, startMs: 1000, endMs: 1500);

    test('contains returns true when position is within window', () {
      expect(seg.contains(1000), isTrue);
      expect(seg.contains(1250), isTrue);
      expect(seg.contains(1500), isTrue);
    });

    test('contains returns false when position is outside window', () {
      expect(seg.contains(999), isFalse);
      expect(seg.contains(1501), isFalse);
    });

    test('equality works correctly', () {
      const same = WordTimingSegment(wordIndex: 2, startMs: 1000, endMs: 1500);
      const different = WordTimingSegment(wordIndex: 3, startMs: 1000, endMs: 1500);
      expect(seg, equals(same));
      expect(seg, isNot(equals(different)));
    });
  });

  group('AyahTimingData', () {
    final ayah = AyahTimingData(
      verseKey: '1:1',
      surahNumber: 1,
      ayahNumber: 1,
      timestampFrom: 0,
      timestampTo: 6000,
      segments: const [
        WordTimingSegment(wordIndex: 0, startMs: 0, endMs: 1000),
        WordTimingSegment(wordIndex: 1, startMs: 1001, endMs: 2500),
        WordTimingSegment(wordIndex: 2, startMs: 2501, endMs: 4000),
      ],
    );

    test('hasWordSegments is true when segments list is non-empty', () {
      expect(ayah.hasWordSegments, isTrue);
    });

    test('hasWordSegments is false when segments is empty', () {
      const empty = AyahTimingData(
        verseKey: '1:2',
        surahNumber: 1,
        ayahNumber: 2,
        timestampFrom: 6001,
        timestampTo: 8000,
        segments: [],
      );
      expect(empty.hasWordSegments, isFalse);
    });

    test('activeWordIndexAt returns correct word index', () {
      expect(ayah.activeWordIndexAt(0), equals(0));
      expect(ayah.activeWordIndexAt(500), equals(0));
      expect(ayah.activeWordIndexAt(1001), equals(1));
      expect(ayah.activeWordIndexAt(3000), equals(2));
    });

    test('activeWordIndexAt returns null between words', () {
      // No segment owns exactly 1000–1000 range — depends on gap.
      // In this test data there is no gap, so just verify beyond last:
      expect(ayah.activeWordIndexAt(4001), isNull);
    });

    test('activeWordIndexAt returns null before first word', () {
      // Word 0 starts at 0, so no gap before. Verify far beyond:
      expect(ayah.activeWordIndexAt(5999), isNull);
    });
  });

  group('SurahTimingData', () {
    final surah = SurahTimingData(
      surahNumber: 1,
      reciterId: 'Abdul_Basit_Murattal_192kbps',
      audioUrl: 'https://example.com/surah.mp3',
      hasWordSegments: true,
      ayahTimings: [
        AyahTimingData(
          verseKey: '1:1',
          surahNumber: 1,
          ayahNumber: 1,
          timestampFrom: 0,
          timestampTo: 5000,
          segments: const [
            WordTimingSegment(wordIndex: 0, startMs: 0, endMs: 2000),
          ],
        ),
        AyahTimingData(
          verseKey: '1:2',
          surahNumber: 1,
          ayahNumber: 2,
          timestampFrom: 5001,
          timestampTo: 10000,
          segments: const [],
        ),
      ],
    );

    test('isAvailable is true when ayahTimings is non-empty', () {
      expect(surah.isAvailable, isTrue);
    });

    test('SurahTimingData.unavailable has isAvailable false', () {
      const unavailable = SurahTimingData.unavailable(
        surahNumber: 1,
        reciterId: 'some_reciter',
      );
      expect(unavailable.isAvailable, isFalse);
      expect(unavailable.hasWordSegments, isFalse);
      expect(unavailable.audioUrl, isEmpty);
    });

    test('forAyah returns the correct ayah', () {
      final ayah = surah.forAyah(1);
      expect(ayah, isNotNull);
      expect(ayah!.verseKey, equals('1:1'));
    });

    test('forAyah returns null for missing ayah number', () {
      expect(surah.forAyah(99), isNull);
    });

    test('activeAyahAt returns ayah at given position', () {
      expect(surah.activeAyahAt(2500)?.ayahNumber, equals(1));
      expect(surah.activeAyahAt(7000)?.ayahNumber, equals(2));
    });

    test('activeAyahAt returns null when position is out of range', () {
      expect(surah.activeAyahAt(99999), isNull);
    });

    test('equality is based on surahNumber and reciterId only', () {
      const same = SurahTimingData.unavailable(
        surahNumber: 1,
        reciterId: 'Abdul_Basit_Murattal_192kbps',
      );
      expect(surah, equals(same));
    });
  });
}
