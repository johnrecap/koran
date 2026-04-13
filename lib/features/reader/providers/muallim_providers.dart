import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/reader/data/muallim_ayah_audio_service.dart';
import 'package:quran_kareem/features/reader/data/package_muallim_ayah_audio_service.dart';
import 'package:quran_kareem/features/reader/data/word_timing_cache_data_source.dart';
import 'package:quran_kareem/features/reader/data/word_timing_remote_data_source.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';
import 'package:quran_kareem/features/reader/domain/muallim_policies.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/word_timing_models.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_library/quran_library.dart';

final muallimAyahAudioServiceProvider = Provider<MuallimAyahAudioService>((ref) {
  final service = PackageMuallimAyahAudioService();
  ref.onDispose(service.dispose);
  return service;
});

// ─── Wave 2: Word Timing Providers ───────────────────────────────────────────

final muallimHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final muallimWordTimingCacheProvider = Provider<WordTimingCacheDataSource>(
  (ref) => WordTimingCacheDataSource(),
);

final muallimWordTimingRemoteProvider = Provider<WordTimingRemoteDataSource>(
  (ref) => WordTimingRemoteDataSource(
    client: ref.watch(muallimHttpClientProvider),
  ),
);

/// Fetches (cache-first, then remote) timing data for [surahNumber] + [reciterId].
/// Always resolves — returns [SurahTimingData.unavailable] on any failure.
typedef SurahTimingKey = ({int surahNumber, String reciterId});

final surahTimingProvider =
    FutureProvider.family<SurahTimingData, SurahTimingKey>(
  (ref, key) async {
    final (:surahNumber, :reciterId) = key;
    final cache = ref.read(muallimWordTimingCacheProvider);
    final remote = ref.read(muallimWordTimingRemoteProvider);

    // 1. Try cache
    try {
      final cached = await cache.get(
        surahNumber: surahNumber,
        reciterId: reciterId,
      );
      if (cached != null) return cached;
    } catch (e, st) {
      AppLogger.error('surahTimingProvider.cache.get', e, st);
    }

    // 2. Fetch remote
    try {
      final data = await remote.fetchSurahTimings(
        surahNumber: surahNumber,
        readerNamePath: reciterId,
      );
      await cache.put(data);
      return data;
    } catch (e, st) {
      AppLogger.error('surahTimingProvider.remote.fetch', e, st);
      return SurahTimingData.unavailable(
        surahNumber: surahNumber,
        reciterId: reciterId,
      );
    }
  },
);

// muallimStateProvider is declared here so muallimWordHighlightProvider
// and muallimAutoNavigationTargetProvider can reference it.
final muallimStateProvider =
    StateNotifierProvider<MuallimNotifier, MuallimSnapshot>((ref) {
  return MuallimNotifier(
    ref.watch(muallimAyahAudioServiceProvider),
    ref.read(muallimWordTimingCacheProvider),
    ref.read(muallimWordTimingRemoteProvider),
  );
});

/// Emits the current (ayahUQNumber, wordIndex) pair for rendering.
/// Null [ayahUQNumber] means nothing is being recited.
/// Null [wordIndex] means timing data is unavailable — fall back to ayah-level.
@immutable
class MuallimWordHighlight {
  const MuallimWordHighlight({
    required this.ayahUQNumber,
    required this.wordIndex,
  });

  const MuallimWordHighlight.none()
      : ayahUQNumber = null,
        wordIndex = null;

  final int? ayahUQNumber;
  final int? wordIndex;

  bool get isActive => ayahUQNumber != null;
}

final muallimWordHighlightProvider = Provider<MuallimWordHighlight>((ref) {
  final snapshot = ref.watch(muallimStateProvider);
  if (!snapshot.isEnabled || snapshot.currentAyah == null) {
    return const MuallimWordHighlight.none();
  }
  return MuallimWordHighlight(
    ayahUQNumber: snapshot.currentAyah!.ayahUQNumber,
    wordIndex: snapshot.currentWordIndex,
  );
});

// ─────────────────────────────────────────────────────────────────────────────

final muallimAutoNavigationTargetProvider = Provider<ReaderNavigationTarget?>(
  (ref) {
    final snapshot = ref.watch(muallimStateProvider);
    final currentPage = ref.watch(quranPageIndexProvider);
    final readerMode = ref.watch(readerModeProvider);
    final currentAyah = snapshot.currentAyah;

    if (!MuallimPageSyncPolicy.shouldNavigate(
      isEnabled: snapshot.isEnabled,
      readerMode: readerMode,
      currentDisplayedPage: currentPage,
      currentAyahPage: currentAyah?.pageNumber,
    )) {
      return null;
    }

    if (currentAyah == null) {
      return null;
    }

    return ReaderNavigationTarget(
      surahNumber: currentAyah.surahNumber,
      ayahNumber: currentAyah.ayahNumber,
      pageNumber: currentAyah.pageNumber,
    );
  },
);

class MuallimNotifier extends StateNotifier<MuallimSnapshot> {
  MuallimNotifier(
    this._service,
    this._timingCache,
    this._timingRemote,
  ) : super(const MuallimSnapshot.initial()) {
    _subscription = _service.snapshots.listen(_applyPlaybackSnapshot);
    unawaited(_bootstrap());
  }

  final MuallimAyahAudioService _service;
  final WordTimingCacheDataSource _timingCache;
  final WordTimingRemoteDataSource _timingRemote;
  StreamSubscription<MuallimPlaybackSnapshot>? _subscription;

  /// Cached timing for the currently-loaded surah.
  SurahTimingData? _currentSurahTiming;
  String? _loadedTimingReciterId;
  int? _loadedTimingSurahNumber;

  Future<void> _bootstrap() async {
    try {
      final playback = await _service.ensureInitialized();
      _applyPlaybackSnapshot(playback);
    } catch (error, stackTrace) {
      AppLogger.error('MuallimNotifier._bootstrap', error, stackTrace);
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
    }
  }

  Future<void> enable() async {
    state = state.copyWith(isEnabled: true);
  }

  Future<void> disable() async {
    await _service.stop();
    _service.clearSelectionHighlights();
    state = state.copyWith(
      isEnabled: false,
      playbackState: MuallimPlaybackState.idle,
      clearCurrentAyah: true,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  Future<void> startFromAyah(
    MuallimAyahPosition ayah, {
    BuildContext? context,
    bool isDarkMode = false,
  }) async {
    await enable();
    state = state.copyWith(
      playbackState: MuallimPlaybackState.loading,
      currentAyah: ayah,
      position: Duration.zero,
      duration: Duration.zero,
      clearWordIndex: true,
    );

    // Pre-fetch timing data for the new surah+reciter in the background.
    unawaited(
      _ensureTimingLoaded(
        surahNumber: ayah.surahNumber,
        reciterId: state.currentReciterId,
      ),
    );

    try {
      await _service.playFromAyah(
        ayah,
        context: context,
        isDarkMode: isDarkMode,
      );
    } catch (error, stackTrace) {
      AppLogger.error('MuallimNotifier.startFromAyah', error, stackTrace);
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
    }
  }

  Future<void> playFromCurrentTarget(
    ReaderNavigationTarget target, {
    BuildContext? context,
    bool isDarkMode = false,
  }) async {
    final ayahUQNumber =
        QuranCtrl.instance.getAyahUQBySurahAndAyah(target.surahNumber, target.ayahNumber);
    if (ayahUQNumber == null) {
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
      return;
    }

    await startFromAyah(
      MuallimAyahPosition(
        surahNumber: target.surahNumber,
        ayahNumber: target.ayahNumber,
        ayahUQNumber: ayahUQNumber,
        pageNumber: target.pageNumber,
      ),
      context: context,
      isDarkMode: isDarkMode,
    );
  }

  Future<void> togglePlayback(
    ReaderNavigationTarget fallbackTarget, {
    BuildContext? context,
    bool isDarkMode = false,
  }) async {
    if (state.playbackState == MuallimPlaybackState.playing) {
      await pause();
      return;
    }

    if (state.playbackState == MuallimPlaybackState.paused) {
      await resume(
        context: context,
        isDarkMode: isDarkMode,
      );
      return;
    }

    final currentAyah = state.currentAyah;
    if (currentAyah != null &&
        state.playbackState != MuallimPlaybackState.error) {
      await startFromAyah(
        currentAyah,
        context: context,
        isDarkMode: isDarkMode,
      );
      return;
    }

    await playFromCurrentTarget(
      fallbackTarget,
      context: context,
      isDarkMode: isDarkMode,
    );
  }

  Future<void> pause() async {
    try {
      await _service.pause();
    } catch (error, stackTrace) {
      AppLogger.error('MuallimNotifier.pause', error, stackTrace);
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
    }
  }

  Future<void> resume({
    BuildContext? context,
    bool isDarkMode = false,
  }) async {
    try {
      await _service.resume(
        context: context,
        isDarkMode: isDarkMode,
      );
    } catch (error, stackTrace) {
      AppLogger.error('MuallimNotifier.resume', error, stackTrace);
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
    }
  }

  Future<void> stop() async {
    try {
      await _service.stop();
      state = state.copyWith(
        playbackState: MuallimPlaybackState.idle,
        clearCurrentAyah: true,
        position: Duration.zero,
        duration: Duration.zero,
      );
    } catch (error, stackTrace) {
      AppLogger.error('MuallimNotifier.stop', error, stackTrace);
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
    }
  }

  Future<void> nextAyah({
    BuildContext? context,
  }) async {
    try {
      await _service.nextAyah(context: context);
    } catch (error, stackTrace) {
      AppLogger.error('MuallimNotifier.nextAyah', error, stackTrace);
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
    }
  }

  Future<void> previousAyah({
    BuildContext? context,
  }) async {
    try {
      await _service.previousAyah(context: context);
    } catch (error, stackTrace) {
      AppLogger.error('MuallimNotifier.previousAyah', error, stackTrace);
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
    }
  }

  Future<void> selectReciter(
    String reciterId, {
    BuildContext? context,
    bool restartPlayback = true,
    bool isDarkMode = false,
  }) async {
    try {
      await _service.selectReciter(
        reciterId,
        context: context,
        restartPlayback: restartPlayback,
        isDarkMode: isDarkMode,
      );
      final playback = await _service.ensureInitialized();
      _applyPlaybackSnapshot(playback);
    } catch (error, stackTrace) {
      AppLogger.error('MuallimNotifier.selectReciter', error, stackTrace);
      state = state.copyWith(playbackState: MuallimPlaybackState.error);
    }
  }

  void _applyPlaybackSnapshot(MuallimPlaybackSnapshot playback) {
    final newAyah = playback.currentAyah;
    final prevAyah = state.currentAyah;

    // When the surah or reciter changes, kick off a timing fetch.
    final surahChanged = newAyah?.surahNumber != prevAyah?.surahNumber;
    final reciterChanged = playback.currentReciterId != state.currentReciterId;
    if ((surahChanged || reciterChanged) &&
        newAyah != null &&
        playback.currentReciterId.isNotEmpty) {
      unawaited(
        _ensureTimingLoaded(
          surahNumber: newAyah.surahNumber,
          reciterId: playback.currentReciterId,
        ),
      );
    }

    // Resolve word index from current timing data.
    final wordIndex = _resolveWordIndex(
      positionMs: playback.position.inMilliseconds,
      ayahNumber: newAyah?.ayahNumber,
    );

    state = MuallimSnapshot.fromPlayback(
      playback,
      isEnabled: state.isEnabled,
      currentWordIndex: wordIndex,
    );
  }

  /// Loads timing data for [surahNumber]+[reciterId] if not already loaded.
  /// Updates [_currentSurahTiming] atomically — safe to call concurrently.
  Future<void> _ensureTimingLoaded({
    required int surahNumber,
    required String reciterId,
  }) async {
    if (_loadedTimingSurahNumber == surahNumber &&
        _loadedTimingReciterId == reciterId) {
      return; // Already loaded for this surah+reciter combination.
    }

    _loadedTimingSurahNumber = surahNumber;
    _loadedTimingReciterId = reciterId;
    _currentSurahTiming = null; // Clear stale data while fetching.

    try {
      // Cache-first lookup.
      final cached = await _timingCache.get(
        surahNumber: surahNumber,
        reciterId: reciterId,
      );
      if (cached != null) {
        _currentSurahTiming = cached;
        return;
      }

      // Remote fetch.
      final data = await _timingRemote.fetchSurahTimings(
        surahNumber: surahNumber,
        readerNamePath: reciterId,
      );
      await _timingCache.put(data);
      _currentSurahTiming = data;
    } catch (e, st) {
      AppLogger.error('MuallimNotifier._ensureTimingLoaded', e, st);
      // Leave _currentSurahTiming as null — ayah-level highlight fallback.
    }
  }

  /// Returns the 0-based word index active at [positionMs] within [ayahNumber],
  /// or null if timing data is unavailable / no word matches.
  int? _resolveWordIndex({
    required int positionMs,
    required int? ayahNumber,
  }) {
    if (ayahNumber == null) return null;
    final timing = _currentSurahTiming;
    if (timing == null || !timing.isAvailable) return null;

    final ayahData = timing.forAyah(ayahNumber);
    if (ayahData == null || !ayahData.hasWordSegments) return null;

    return ayahData.activeWordIndexAt(positionMs);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
