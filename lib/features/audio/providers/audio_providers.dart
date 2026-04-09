import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/audio/data/audio_hub_playback_service.dart';
import 'package:quran_kareem/features/audio/data/package_audio_hub_playback_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_snapshot.dart';

final audioHubPlaybackServiceProvider =
    Provider<AudioHubPlaybackService>((ref) {
  final service = PackageAudioHubPlaybackService();
  ref.onDispose(service.dispose);
  return service;
});

final audioHubSessionActivityProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(audioHubPlaybackServiceProvider);
  yield service.hasActiveSession;
  yield* service.sessionActivity;
});

final audioHubControllerProvider = StateNotifierProvider<AudioHubController,
    AsyncValue<AudioHubPlaybackSnapshot>>((ref) {
  return AudioHubController(
    playbackService: ref.watch(audioHubPlaybackServiceProvider),
  );
});

class AudioHubController
    extends StateNotifier<AsyncValue<AudioHubPlaybackSnapshot>> {
  AudioHubController({
    required AudioHubPlaybackService playbackService,
  })  : _playbackService = playbackService,
        super(const AsyncValue<AudioHubPlaybackSnapshot>.loading()) {
    ready = _initialize();
  }

  final AudioHubPlaybackService _playbackService;
  StreamSubscription<AudioHubPlaybackSnapshot>? _subscription;
  late final Future<void> ready;

  Future<void> _initialize() async {
    try {
      final initial = await _playbackService.ensureInitialized();
      state = AsyncValue<AudioHubPlaybackSnapshot>.data(initial);
      _subscription = _playbackService.snapshots.listen(
        (snapshot) {
          state = AsyncValue<AudioHubPlaybackSnapshot>.data(snapshot);
        },
        onError: (Object error, StackTrace stackTrace) {
          AppLogger.error('AudioHubController.snapshots', error, stackTrace);
          state = AsyncValue<AudioHubPlaybackSnapshot>.error(
            error,
            stackTrace,
          );
        },
      );
    } catch (error, stackTrace) {
      state = AsyncValue<AudioHubPlaybackSnapshot>.error(error, stackTrace);
    }
  }

  Future<void> togglePlayPause() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    if (current.isPlaying) {
      await _playbackService.pause();
      return;
    }

    await _playbackService.play();
  }

  Future<void> playNextSurah() async {
    await _playbackService.playNextSurah();
  }

  Future<void> playPreviousSurah() async {
    await _playbackService.playPreviousSurah();
  }

  Future<void> seek(Duration position) async {
    await _playbackService.seek(position);
  }

  Future<void> stop() async {
    await _playbackService.stop();
  }

  Future<void> selectSurah(int surahNumber, {bool autoPlay = true}) async {
    await _playbackService.selectSurah(surahNumber, autoPlay: autoPlay);
  }

  Future<void> selectReciter(
    String reciterId, {
    bool restartPlayback = true,
  }) async {
    await _playbackService.selectReciter(
      reciterId,
      restartPlayback: restartPlayback,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
