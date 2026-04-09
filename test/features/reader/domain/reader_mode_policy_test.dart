import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  group('ReaderModePolicy', () {
    test('defaults to scroll mode', () {
      expect(ReaderModePolicy.defaultMode, ReaderMode.scroll);
    });

    test('parses persisted mode and falls back to scroll', () {
      expect(ReaderModePolicy.fromPreference('page'), ReaderMode.page);
      expect(ReaderModePolicy.fromPreference('scroll'), ReaderMode.scroll);
      expect(
        ReaderModePolicy.fromPreference('translation'),
        ReaderMode.translation,
      );
      expect(ReaderModePolicy.fromPreference('unexpected'), ReaderMode.scroll);
    });

    test('serializes reader mode for persistence', () {
      expect(ReaderModePolicy.toPreference(ReaderMode.scroll), 'scroll');
      expect(ReaderModePolicy.toPreference(ReaderMode.page), 'page');
      expect(
        ReaderModePolicy.toPreference(ReaderMode.translation),
        'translation',
      );
    });
  });

  group('ReaderQuickTogglePolicy', () {
    test('toggles only between scroll and page', () {
      expect(
        ReaderQuickTogglePolicy.nextMode(ReaderMode.scroll),
        ReaderMode.page,
      );
      expect(
        ReaderQuickTogglePolicy.nextMode(ReaderMode.page),
        ReaderMode.scroll,
      );
    });

    test('is hidden in translation mode', () {
      expect(
        ReaderQuickTogglePolicy.isAvailable(ReaderMode.translation),
        isFalse,
      );
      expect(
        ReaderQuickTogglePolicy.isAvailable(ReaderMode.scroll),
        isTrue,
      );
      expect(
        ReaderQuickTogglePolicy.isAvailable(ReaderMode.page),
        isTrue,
      );
    });
  });

  group('ReaderEntryTargetPolicy', () {
    test('creates a full reader target from a surah landing page', () {
      final target = ReaderEntryTargetPolicy.forSurah(
        surahNumber: 36,
        pageNumber: 440,
      );

      expect(target.surahNumber, 36);
      expect(target.ayahNumber, 1);
      expect(target.pageNumber, 440);
    });
  });

  group('ReaderLiveTargetPolicy', () {
    test('uses the live reader state instead of a stale entry target', () {
      const staleTarget = ReaderNavigationTarget(
        surahNumber: 2,
        ayahNumber: 1,
        pageNumber: 48,
      );

      final liveTarget = ReaderLiveTargetPolicy.fromCurrentState(
        target: staleTarget,
        currentSurah: 2,
        currentPage: 50,
      );

      expect(liveTarget.surahNumber, 2);
      expect(liveTarget.ayahNumber, 1);
      expect(liveTarget.pageNumber, 50);
    });
  });

  group('ReaderFullscreenSystemUiPolicy', () {
    test('uses immersive mode only while fullscreen is active', () {
      expect(
        ReaderFullscreenSystemUiPolicy.modeFor(isFullscreen: true),
        SystemUiMode.immersiveSticky,
      );
      expect(
        ReaderFullscreenSystemUiPolicy.modeFor(isFullscreen: false),
        SystemUiMode.edgeToEdge,
      );
    });
  });

  group('ReaderRestorePolicy', () {
    test('does not apply restored state after disposal', () async {
      var mounted = true;

      final result = await ReaderRestorePolicy.load(
        loadModePreference: () async => 'page',
        loadLastReadingPosition: () async {
          mounted = false;
          return ReadingPosition(
            surahNumber: 18,
            ayahNumber: 5,
            page: 293,
            savedAt: DateTime(2026),
          );
        },
        currentTarget: ReaderEntryTargetPolicy.defaultTarget,
        currentSurah: 1,
        currentPage: 1,
        isMounted: () => mounted,
      );

      expect(result, isNull);
    });

    test('restores the saved target when the entry target is still default',
        () async {
      final result = await ReaderRestorePolicy.load(
        loadModePreference: () async => 'page',
        loadLastReadingPosition: () async => ReadingPosition(
          surahNumber: 36,
          ayahNumber: 1,
          page: 440,
          savedAt: DateTime(2026),
        ),
        currentTarget: ReaderEntryTargetPolicy.defaultTarget,
        currentSurah: 1,
        currentPage: 1,
        isMounted: () => true,
      );

      expect(result, isNotNull);
      expect(result!.mode, ReaderMode.page);
      expect(result.target.surahNumber, 36);
      expect(result.target.pageNumber, 440);
      expect(result.shouldReplaceTarget, isTrue);
    });
  });

  group('ReaderAppLanguagePolicy', () {
    test('forwards english when the active locale is english', () {
      expect(
        ReaderAppLanguagePolicy.resolve(const Locale('en')),
        'en',
      );
    });

    test('falls back to arabic for unsupported locales', () {
      expect(
        ReaderAppLanguagePolicy.resolve(const Locale('fr')),
        'ar',
      );
    });
  });
}
