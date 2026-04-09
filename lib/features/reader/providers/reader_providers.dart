import 'package:flutter/widgets.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/reader/data/reader_save_recorder.dart';
import 'package:quran_kareem/features/reader/data/reader_translation_remote_data_source.dart';
import 'package:quran_kareem/features/reader/data/reader_translation_repository.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_presentation_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_insights_sheet.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

export 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
export 'package:quran_kareem/features/reader/domain/reader_night_presentation_policy.dart';
export 'package:quran_kareem/features/reader/domain/reader_night_style.dart';

/// Provider for loading ayahs of a specific surah
final surahAyahsProvider = FutureProvider.family<List<Ayah>, int>(
  (ref, surahNumber) async {
    return QuranDatabase.getAyahsBySurah(surahNumber);
  },
);

/// Provider for loading all surahs
final surahsProvider = FutureProvider<List<Surah>>(
  (ref) async {
    return QuranDatabase.getSurahs();
  },
);

/// Provider for current surah number being read
final currentSurahProvider = StateProvider<int>((ref) => 1);

/// Provider for current QCF page index (1-604)
final quranPageIndexProvider = StateProvider<int>((ref) => 1);

/// Explicit reader navigation target used by both scroll and page modes.
final readerNavigationTargetProvider =
    StateProvider<ReaderNavigationTarget>((ref) {
  return ReaderEntryTargetPolicy.defaultTarget;
});

final readerSessionIntentProvider =
    StateProvider<ReaderSessionIntent>((ref) {
  return const ReaderSessionIntent.general();
});

final readerNightSessionOverrideProvider =
    StateProvider<ReaderNightPresentation?>((ref) => null);

final readerNightEvaluationTimeProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final readerNightPresentationProvider = Provider<ReaderNightPresentation>((ref) {
  final settings = ref.watch(
    appSettingsControllerProvider.select((value) => value.nightReaderSettings),
  );
  final sessionOverride = ref.watch(readerNightSessionOverrideProvider);
  final nowLocal = ref.watch(readerNightEvaluationTimeProvider);

  return ReaderNightPresentationPolicy.resolve(
    autoEnable: settings.autoEnable,
    startMinutes: settings.startMinutes,
    endMinutes: settings.endMinutes,
    preferredNightStyle: settings.preferredStyle,
    nowLocal: nowLocal,
    sessionOverride: sessionOverride,
  );
});

/// Provider for app-owned Arabic text sizing.
final quranFontSizeProvider = Provider<double>((ref) {
  return ref.watch(
    appSettingsControllerProvider.select((settings) => settings.arabicFontSize),
  );
});

/// Provider for reader mode (scroll / page / translation)
final readerModeProvider =
    StateProvider<ReaderMode>((ref) => ReaderModePolicy.defaultMode);

final readerTranslationResourceIdProvider =
    StateProvider<int>((ref) => AppConstants.defaultTranslationResourceId);

final readerTranslationHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final readerTranslationRemoteDataSourceProvider =
    Provider<ReaderTranslationRemoteDataSource>((ref) {
  return ReaderTranslationRemoteDataSource(
    client: ref.watch(readerTranslationHttpClientProvider),
  );
});

final readerTranslationRepositoryProvider =
    Provider<ReaderTranslationRepository>((ref) {
  return ReaderTranslationRepository(
    remoteDataSource: ref.watch(readerTranslationRemoteDataSourceProvider),
  );
});

final readerAyahPlaybackLauncherProvider = Provider<ReaderAyahPlaybackLauncher>(
  (ref) => const PackageReaderAyahPlaybackLauncher(),
);

final readerAyahInsightsSheetLauncherProvider =
    Provider<ReaderAyahInsightsSheetLauncher>(
  (ref) => const PackageReaderAyahInsightsSheetLauncher(),
);

final surahTranslationsProvider =
    FutureProvider.family<Map<int, AyahTranslation>, int>((
  ref,
  surahNumber,
) async {
  final repository = ref.watch(readerTranslationRepositoryProvider);
  final resourceId = ref.watch(readerTranslationResourceIdProvider);
  return repository.fetchSurahTranslations(
    surahNumber: surahNumber,
    resourceId: resourceId,
  );
});

/// Provider for hiding app chrome while the reader stays visible.
final readerFullscreenModeProvider = StateProvider<bool>((ref) => false);

abstract final class ReaderChromePolicy {
  static bool shouldShowExternalBanner(
    ReaderMode mode, {
    bool isFullscreen = false,
  }) {
    return mode == ReaderMode.scroll && !isFullscreen;
  }
}

abstract final class ReaderShellChromePolicy {
  static const double bottomNavigationInset = 100.0;

  static bool shouldHideBottomNavigation({
    required String location,
    required bool isFullscreen,
  }) {
    return isFullscreen && location.startsWith('/reader');
  }
}

abstract final class ReaderViewportInsetPolicy {
  static const double fullscreenVerticalInset = 16.0;
  static const double shellBottomNavigationInset =
      ReaderShellChromePolicy.bottomNavigationInset;

  static EdgeInsets contentPadding({
    required bool isFullscreen,
    required double systemTopInset,
    required double systemBottomInset,
  }) {
    if (isFullscreen) {
      return EdgeInsets.only(
        top: systemTopInset + fullscreenVerticalInset,
        bottom: systemBottomInset + fullscreenVerticalInset,
      );
    }

    return EdgeInsets.only(
      bottom: shellBottomNavigationInset + systemBottomInset,
    );
  }
}

abstract final class ReaderScrollViewportPolicy {
  static const double leadingBannerOffset = 204.0;
}

abstract final class ReaderScrollTargetPolicy {
  static int? effectiveTargetPageNumber({
    required int requestedPageNumber,
    required bool preserveExactViewport,
  }) {
    if (preserveExactViewport) {
      return null;
    }

    return requestedPageNumber;
  }
}

abstract final class ReaderScrollRestorePolicy {
  static const int maxDeferredAttempts = 6;

  static bool shouldDeferRestore({
    required double savedOffset,
    required double maxScrollExtent,
    required int attempt,
  }) {
    if (savedOffset <= 0) {
      return false;
    }

    if (attempt >= maxDeferredAttempts) {
      return false;
    }

    return maxScrollExtent < savedOffset;
  }

  static double clampOffset({
    required double savedOffset,
    required double minScrollExtent,
    required double maxScrollExtent,
  }) {
    return savedOffset.clamp(minScrollExtent, maxScrollExtent).toDouble();
  }
}

abstract final class ReaderInteractionPolicy {
  static bool shouldEnablePackageWordSelection(ReaderMode mode) {
    switch (mode) {
      case ReaderMode.scroll:
      case ReaderMode.page:
      case ReaderMode.translation:
        return false;
    }
  }
}

final lastReadingPositionStoreProvider = Provider<LastReadingPositionStore>(
  (ref) => const UserPreferencesLastReadingPositionStore(),
);

/// Provider for last reading position (async)
final lastReadingPositionProvider =
    FutureProvider<ReadingPosition?>((ref) async {
  return ref.watch(lastReadingPositionStoreProvider).load();
});

final readerSaveRecorderProvider = Provider<ReaderSaveRecorder>((ref) {
  return ReaderSaveRecorder(
    saveLastReadingPosition: ref.watch(lastReadingPositionStoreProvider).save,
    upsertSession: ref.read(sessionsProvider.notifier).upsertSession,
    recordKhatmaProgress: ({
      required String khatmaId,
      required int pageNumber,
      required DateTime timestamp,
    }) async {
      int completedSurahs = 0;
      try {
        final surahs = await ref.read(surahsProvider.future);
        completedSurahs = _countCompletedSurahsForPage(surahs, pageNumber);
      } catch (e, st) {
        AppLogger.error('ReaderSaveRecorder.recordKhatmaProgress', e, st);
        completedSurahs = 0;
      }

      await ref.read(khatmasProvider.notifier).recordPlannerProgress(
            khatmaId: khatmaId,
            pageNumber: pageNumber,
            timestamp: timestamp,
            completedSurahs: completedSurahs,
          );
    },
    resolveSurahName: (surahNumber) async {
      try {
        final surahs = await ref.read(surahsProvider.future);
        for (final surah in surahs) {
          if (surah.number == surahNumber) {
            return surah.nameArabic;
          }
        }
      } catch (e, st) {
        AppLogger.error('ReaderSaveRecorder.resolveSurahName', e, st);
      }

      return surahNumber.toString();
    },
    loadReaderSessionIntent: () {
      return ref.read(readerSessionIntentProvider);
    },
    onSaved: () {
      ref.invalidate(lastReadingPositionProvider);
    },
  );
});

int _countCompletedSurahsForPage(List<Surah> surahs, int pageNumber) {
  var completed = 0;
  for (final surah in surahs) {
    if (surah.page < pageNumber) {
      completed += 1;
    }
  }

  return completed.clamp(0, 114);
}

abstract class LastReadingPositionStore {
  Future<ReadingPosition?> load();

  Future<void> save(ReadingPosition position);
}

class UserPreferencesLastReadingPositionStore
    implements LastReadingPositionStore {
  const UserPreferencesLastReadingPositionStore();

  @override
  Future<ReadingPosition?> load() {
    return UserPreferences.getLastReadingPosition();
  }

  @override
  Future<void> save(ReadingPosition position) {
    return UserPreferences.setLastReadingPosition(position);
  }
}
