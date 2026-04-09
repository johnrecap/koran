import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_payload.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';

enum ReaderMode { scroll, page, translation }

abstract final class ReaderModePolicy {
  static ReaderMode get defaultMode => ReaderMode.scroll;

  static ReaderMode fromPreference(String? value) {
    switch (value) {
      case 'page':
        return ReaderMode.page;
      case 'translation':
        return ReaderMode.translation;
      case 'scroll':
      default:
        return defaultMode;
    }
  }

  static String toPreference(ReaderMode mode) {
    return switch (mode) {
      ReaderMode.scroll => 'scroll',
      ReaderMode.page => 'page',
      ReaderMode.translation => 'translation',
    };
  }
}

abstract final class ReaderQuickTogglePolicy {
  static bool isAvailable(ReaderMode mode) {
    return mode != ReaderMode.translation;
  }

  static ReaderMode nextMode(ReaderMode mode) {
    return switch (mode) {
      ReaderMode.scroll => ReaderMode.page,
      ReaderMode.page => ReaderMode.scroll,
      ReaderMode.translation => throw StateError(
          'Translation mode does not support the page/scroll quick toggle.',
        ),
    };
  }
}

abstract final class ReaderEntryTargetPolicy {
  static const defaultTarget = ReaderNavigationTarget(
    surahNumber: 1,
    ayahNumber: 1,
    pageNumber: 1,
  );

  static ReaderNavigationTarget forSurah({
    required int surahNumber,
    required int pageNumber,
    int ayahNumber = 1,
  }) {
    return ReaderNavigationTarget(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      pageNumber: pageNumber,
    );
  }

  static ReaderNavigationTarget fromReadingPosition(ReadingPosition? position) {
    if (position == null) {
      return defaultTarget;
    }

    return ReaderNavigationTarget(
      surahNumber: position.surahNumber,
      ayahNumber: position.ayahNumber,
      pageNumber: position.page,
    );
  }

  static bool shouldRestoreSavedTarget({
    required ReaderNavigationTarget target,
    required int currentSurah,
    required int currentPage,
  }) {
    return target.surahNumber == defaultTarget.surahNumber &&
        target.ayahNumber == defaultTarget.ayahNumber &&
        target.pageNumber == defaultTarget.pageNumber &&
        currentSurah == defaultTarget.surahNumber &&
        currentPage == defaultTarget.pageNumber;
  }
}

class ReaderRestoreState {
  const ReaderRestoreState({
    required this.mode,
    required this.target,
    required this.shouldReplaceTarget,
  });

  final ReaderMode mode;
  final ReaderNavigationTarget target;
  final bool shouldReplaceTarget;
}

abstract final class ReaderRestorePolicy {
  static Future<ReaderRestoreState?> load({
    required Future<String?> Function() loadModePreference,
    required Future<ReadingPosition?> Function() loadLastReadingPosition,
    required ReaderNavigationTarget currentTarget,
    required int currentSurah,
    required int currentPage,
    required bool Function() isMounted,
  }) async {
    final savedMode = await loadModePreference();
    if (!isMounted()) {
      return null;
    }

    final resolvedMode = ReaderModePolicy.fromPreference(savedMode);
    if (!ReaderEntryTargetPolicy.shouldRestoreSavedTarget(
      target: currentTarget,
      currentSurah: currentSurah,
      currentPage: currentPage,
    )) {
      return ReaderRestoreState(
        mode: resolvedMode,
        target: currentTarget,
        shouldReplaceTarget: false,
      );
    }

    final lastReadingPosition = await loadLastReadingPosition();
    if (!isMounted()) {
      return null;
    }

    return ReaderRestoreState(
      mode: resolvedMode,
      target: ReaderEntryTargetPolicy.fromReadingPosition(lastReadingPosition),
      shouldReplaceTarget: true,
    );
  }
}

abstract final class ReaderLiveTargetPolicy {
  static ReaderNavigationTarget fromCurrentState({
    required ReaderNavigationTarget target,
    required int currentSurah,
    required int currentPage,
  }) {
    return target.copyWith(
      surahNumber: currentSurah,
      pageNumber: currentPage,
    );
  }
}

abstract final class ReaderPendingSavePolicy {
  static int invalidate(int currentGeneration) => currentGeneration + 1;

  static bool shouldPersist({
    required int scheduledGeneration,
    required int currentGeneration,
  }) {
    return scheduledGeneration == currentGeneration;
  }
}

abstract final class ReaderVerseActionPolicy {
  static String? resolveSurahName({
    required Iterable<Surah> surahs,
    required int surahNumber,
  }) {
    for (final surah in surahs) {
      if (surah.number == surahNumber) {
        return surah.nameArabic;
      }
    }
    return null;
  }

  static String buildCopyText({
    required Ayah ayah,
    required String surahPrefix,
    required String surahName,
  }) {
    return _buildVerseActionText(
      ayah: ayah,
      surahPrefix: surahPrefix,
      surahName: surahName,
    );
  }

  static String buildShareText({
    required Ayah ayah,
    required String surahPrefix,
    required String surahName,
  }) {
    return _buildVerseActionText(
      ayah: ayah,
      surahPrefix: surahPrefix,
      surahName: surahName,
    );
  }

  static AyahShareCardPayload buildShareCardPayload({
    required Ayah ayah,
    required String surahPrefix,
    required String surahName,
  }) {
    return AyahShareCardPayload(
      ayahText: ayah.text,
      referenceText: '[$surahPrefix $surahName]',
      supportingText: null,
    );
  }

  static String _buildVerseActionText({
    required Ayah ayah,
    required String surahPrefix,
    required String surahName,
  }) {
    return '${ayah.text} ﴿${ayah.ayahNumber}﴾\n[$surahPrefix $surahName]';
  }
}

abstract final class ReaderAppLanguagePolicy {
  static String resolve(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'en';
      case 'ar':
      default:
        return 'ar';
    }
  }
}

abstract final class ReaderFullscreenSystemUiPolicy {
  static SystemUiMode modeFor({required bool isFullscreen}) {
    return isFullscreen
        ? SystemUiMode.immersiveSticky
        : SystemUiMode.edgeToEdge;
  }
}
