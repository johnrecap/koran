import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/data/reciter_id_mapping.dart';

void main() {
  group('ReciterIdMapping', () {
    test('returns Quran.com ID for Abdul Basit Murattal', () {
      expect(
        ReciterIdMapping.quranComIdFor('Abdul_Basit_Murattal_192kbps'),
        equals(1),
      );
    });

    test('returns Quran.com ID for Minshawy', () {
      expect(
        ReciterIdMapping.quranComIdFor('Minshawy_Murattal_128kbps'),
        equals(3),
      );
    });

    test('returns Quran.com ID for Husary', () {
      expect(
        ReciterIdMapping.quranComIdFor('Husary_128kbps'),
        equals(5),
      );
    });

    test('returns Quran.com ID for Ajamy (islamic.network path)', () {
      expect(
        ReciterIdMapping.quranComIdFor('128/ar.ahmedajamy'),
        equals(8),
      );
    });

    test('returns Quran.com ID for Maher Muaiqly', () {
      expect(
        ReciterIdMapping.quranComIdFor('MaherAlMuaiqly128kbps'),
        equals(10),
      );
    });

    test('returns Quran.com ID for Juhaynee', () {
      expect(
        ReciterIdMapping.quranComIdFor('Abdullaah_3awwaad_Al-Juhaynee_128kbps'),
        equals(9),
      );
    });

    test('returns Quran.com ID for Muhammad Ayyoub', () {
      expect(
        ReciterIdMapping.quranComIdFor('128/ar.muhammadayyoub'),
        equals(11),
      );
    });

    test('returns null for Fares Abbad (no timing available)', () {
      expect(
        ReciterIdMapping.quranComIdFor('Fares_Abbad_64kbps'),
        isNull,
      );
    });

    test('returns null for Saood Shuraym (no timing available)', () {
      expect(
        ReciterIdMapping.quranComIdFor('Saood_ash-Shuraym_128kbps'),
        isNull,
      );
    });

    test('returns null for completely unknown reciter path', () {
      expect(
        ReciterIdMapping.quranComIdFor('unknown/reciter/path'),
        isNull,
      );
    });

    test('hasTimingSupport returns true for mapped reciters', () {
      expect(
        ReciterIdMapping.hasTimingSupport('Abdul_Basit_Murattal_192kbps'),
        isTrue,
      );
      expect(
        ReciterIdMapping.hasTimingSupport('MaherAlMuaiqly128kbps'),
        isTrue,
      );
    });

    test('hasTimingSupport returns false for null-mapped reciters', () {
      expect(
        ReciterIdMapping.hasTimingSupport('Fares_Abbad_64kbps'),
        isFalse,
      );
    });

    test('hasTimingSupport returns false for unknown reciters', () {
      expect(
        ReciterIdMapping.hasTimingSupport('not_in_the_table'),
        isFalse,
      );
    });
  });
}
