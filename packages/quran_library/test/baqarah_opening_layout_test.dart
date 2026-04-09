import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('resolveAyahLinePresentation', () {
    test('preserves authentic presentation for centered Baqarah opening lines', () {
      final segments = <QpcV4WordSegment>[
        const QpcV4WordSegment(
          wordId: 37,
          ayahUq: 8,
          surahNumber: 2,
          ayahNumber: 1,
          wordNumber: 1,
          glyphs: 'abc',
          isAyahEnd: false,
        ),
        const QpcV4WordSegment(
          wordId: 77,
          ayahUq: 12,
          surahNumber: 2,
          ayahNumber: 5,
          wordNumber: 9,
          glyphs: 'def',
          isAyahEnd: true,
        ),
      ];

      final presentation = resolveAyahLinePresentation(
        normalizeBaqarahOpeningLayout: true,
        surahFilterNumber: 2,
        isCentered: true,
        segments: segments,
      );

      expect(presentation.isCentered, isTrue);
      expect(presentation.constrainedWidth, isNull);
    });

    test('keeps later Baqarah ayahs on their original presentation', () {
      final segments = <QpcV4WordSegment>[
        const QpcV4WordSegment(
          wordId: 78,
          ayahUq: 13,
          surahNumber: 2,
          ayahNumber: 6,
          wordNumber: 1,
          glyphs: 'abc',
          isAyahEnd: false,
        ),
      ];

      final presentation = resolveAyahLinePresentation(
        normalizeBaqarahOpeningLayout: true,
        surahFilterNumber: 2,
        isCentered: true,
        segments: segments,
      );

      expect(presentation.isCentered, isTrue);
      expect(presentation.constrainedWidth, isNull);
    });

    test('does nothing when the scroll-only override is disabled', () {
      final segments = <QpcV4WordSegment>[
        const QpcV4WordSegment(
          wordId: 37,
          ayahUq: 8,
          surahNumber: 2,
          ayahNumber: 1,
          wordNumber: 1,
          glyphs: 'abc',
          isAyahEnd: false,
        ),
      ];

      final presentation = resolveAyahLinePresentation(
        normalizeBaqarahOpeningLayout: false,
        surahFilterNumber: 2,
        isCentered: true,
        segments: segments,
      );

      expect(presentation.isCentered, isTrue);
      expect(presentation.constrainedWidth, isNull);
    });
  });
}
