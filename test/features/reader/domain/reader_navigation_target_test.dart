import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  group('ReaderNavigationTarget', () {
    test('stores explicit surah, ayah, and page numbers', () {
      const target = ReaderNavigationTarget(
        surahNumber: 2,
        ayahNumber: 255,
        pageNumber: 42,
      );

      expect(target.surahNumber, 2);
      expect(target.ayahNumber, 255);
      expect(target.pageNumber, 42);
    });

    test('supports copyWith while preserving unspecified fields', () {
      const target = ReaderNavigationTarget(
        surahNumber: 18,
        ayahNumber: 10,
        pageNumber: 293,
      );

      final updated = target.copyWith(ayahNumber: 11);

      expect(updated.surahNumber, 18);
      expect(updated.ayahNumber, 11);
      expect(updated.pageNumber, 293);
    });
  });

  group('ReaderChromePolicy', () {
    test('shows external banner only in scroll mode', () {
      expect(
        ReaderChromePolicy.shouldShowExternalBanner(ReaderMode.scroll),
        isTrue,
      );
      expect(
        ReaderChromePolicy.shouldShowExternalBanner(ReaderMode.page),
        isFalse,
      );
    });
  });
}
