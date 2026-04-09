import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  group('ReaderInteractionPolicy', () {
    test('disables package word selection in page mode', () {
      expect(
        ReaderInteractionPolicy.shouldEnablePackageWordSelection(
          ReaderMode.page,
        ),
        isFalse,
      );
    });

    test('disables package word selection in scroll mode', () {
      expect(
        ReaderInteractionPolicy.shouldEnablePackageWordSelection(
          ReaderMode.scroll,
        ),
        isFalse,
      );
    });

    test('disables package word selection in translation mode', () {
      expect(
        ReaderInteractionPolicy.shouldEnablePackageWordSelection(
          ReaderMode.translation,
        ),
        isFalse,
      );
    });
  });

  group('ReaderShellChromePolicy', () {
    test('hides shell chrome only for reader fullscreen sessions', () {
      expect(
        ReaderShellChromePolicy.shouldHideBottomNavigation(
          location: '/reader',
          isFullscreen: true,
        ),
        isTrue,
      );
    });

    test('keeps shell chrome visible outside fullscreen reader sessions', () {
      expect(
        ReaderShellChromePolicy.shouldHideBottomNavigation(
          location: '/reader',
          isFullscreen: false,
        ),
        isFalse,
      );
      expect(
        ReaderShellChromePolicy.shouldHideBottomNavigation(
          location: '/library',
          isFullscreen: true,
        ),
        isFalse,
      );
    });
  });

  group('ReaderViewportInsetPolicy', () {
    test('adds shell overlap padding in normal reader mode', () {
      final padding = ReaderViewportInsetPolicy.contentPadding(
        isFullscreen: false,
        systemTopInset: 24,
        systemBottomInset: 12,
      );

      expect(padding.top, 0);
      expect(
        padding.bottom,
        ReaderViewportInsetPolicy.shellBottomNavigationInset + 12,
      );
    });

    test('adds breathing room plus safe areas in fullscreen', () {
      final padding = ReaderViewportInsetPolicy.contentPadding(
        isFullscreen: true,
        systemTopInset: 18,
        systemBottomInset: 6,
      );

      expect(
        padding.top,
        18 + ReaderViewportInsetPolicy.fullscreenVerticalInset,
      );
      expect(
        padding.bottom,
        6 + ReaderViewportInsetPolicy.fullscreenVerticalInset,
      );
    });
  });

  group('ReaderScrollTargetPolicy', () {
    test(
      'suppresses target-page realignment while exact viewport restore is pending',
      () {
        expect(
          ReaderScrollTargetPolicy.effectiveTargetPageNumber(
            requestedPageNumber: 312,
            preserveExactViewport: true,
          ),
          isNull,
        );
      },
    );

    test(
      'keeps explicit target-page navigation when no exact restore is pending',
      () {
        expect(
          ReaderScrollTargetPolicy.effectiveTargetPageNumber(
            requestedPageNumber: 312,
            preserveExactViewport: false,
          ),
          312,
        );
      },
    );
  });

  group('ReaderScrollRestorePolicy', () {
    test(
      'defers restore while the rebuilt extent is still smaller than the saved offset',
      () {
        expect(
          ReaderScrollRestorePolicy.shouldDeferRestore(
            savedOffset: 1200,
            maxScrollExtent: 300,
            attempt: 0,
          ),
          isTrue,
        );
      },
    );

    test('stops deferring and clamps on later attempts', () {
      expect(
        ReaderScrollRestorePolicy.shouldDeferRestore(
          savedOffset: 1200,
          maxScrollExtent: 300,
          attempt: ReaderScrollRestorePolicy.maxDeferredAttempts,
        ),
        isFalse,
      );
      expect(
        ReaderScrollRestorePolicy.clampOffset(
          savedOffset: 1200,
          minScrollExtent: 0,
          maxScrollExtent: 300,
        ),
        300,
      );
    });
  });

  group('ReaderPendingSavePolicy', () {
    test('invalidates stale debounced saves after explicit navigation', () {
      final currentGeneration = ReaderPendingSavePolicy.invalidate(0);

      expect(
        ReaderPendingSavePolicy.shouldPersist(
          scheduledGeneration: 0,
          currentGeneration: currentGeneration,
        ),
        isFalse,
      );
      expect(
        ReaderPendingSavePolicy.shouldPersist(
          scheduledGeneration: currentGeneration,
          currentGeneration: currentGeneration,
        ),
        isTrue,
      );
    });
  });

  group('ReaderVerseActionPolicy', () {
    test('resolves the matching surah name for verse actions', () {
      const surahs = [
        Surah(
          number: 1,
          nameArabic: 'ط§ظ„ظپط§طھط­ط©',
          nameEnglish: 'Al-Fatihah',
          nameTransliteration: 'Al-Fatihah',
          ayahCount: 7,
          revelationType: 'Meccan',
          page: 1,
        ),
        Surah(
          number: 2,
          nameArabic: 'ط§ظ„ط¨ظ‚ط±ط©',
          nameEnglish: 'Al-Baqarah',
          nameTransliteration: 'Al-Baqarah',
          ayahCount: 286,
          revelationType: 'Medinan',
          page: 2,
        ),
      ];

      expect(
        ReaderVerseActionPolicy.resolveSurahName(
          surahs: surahs,
          surahNumber: 2,
        ),
        'ط§ظ„ط¨ظ‚ط±ط©',
      );
    });

    test('returns null when surah metadata is unavailable', () {
      expect(
        ReaderVerseActionPolicy.resolveSurahName(
          surahs: const <Surah>[],
          surahNumber: 2,
        ),
        isNull,
      );
    });

    test('builds the clipboard payload from ayah text number and surah name',
        () {
      const ayah = Ayah(
        id: 281,
        surahNumber: 2,
        ayahNumber: 255,
        text: 'Allah! There is no god but He.',
        page: 42,
        juz: 3,
        hizb: 1,
      );

      expect(
        ReaderVerseActionPolicy.buildCopyText(
          ayah: ayah,
          surahPrefix: 'Surah',
          surahName: 'ط§ظ„ط¨ظ‚ط±ط©',
        ),
        'Allah! There is no god but He. ﴿255﴾\n[Surah ط§ظ„ط¨ظ‚ط±ط©]',
      );
    });

    test('builds the share payload from localized ayah metadata', () {
      const ayah = Ayah(
        id: 281,
        surahNumber: 2,
        ayahNumber: 255,
        text: 'Allah! There is no god but He.',
        page: 42,
        juz: 3,
        hizb: 1,
      );

      expect(
        ReaderVerseActionPolicy.buildShareText(
          ayah: ayah,
          surahPrefix: 'Surah',
          surahName: 'ط·آ§ط¸â€‍ط·آ¨ط¸â€ڑط·آ±ط·آ©',
        ),
        'Allah! There is no god but He. ﴿255﴾\n[Surah ط·آ§ط¸â€‍ط·آ¨ط¸â€ڑط·آ±ط·آ©]',
      );
    });

    test('builds the share-card payload from ayah text and localized reference',
        () {
      const ayah = Ayah(
        id: 281,
        surahNumber: 2,
        ayahNumber: 255,
        text: 'Allah! There is no god but He.',
        page: 42,
        juz: 3,
        hizb: 1,
      );

      final payload = ReaderVerseActionPolicy.buildShareCardPayload(
        ayah: ayah,
        surahPrefix: 'Surah',
        surahName: 'Al-Baqarah',
      );

      expect(payload.ayahText, 'Allah! There is no god but He.');
      expect(payload.referenceText, '[Surah Al-Baqarah]');
      expect(payload.supportingText, isNull);
    });
  });
}
