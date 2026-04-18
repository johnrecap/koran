import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:quran_kareem/features/notifications/data/adhan_audio_cache_service.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_muezzin.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_playback_mode.dart';

/// Service for playing full adhan audio or takbeer-only mode using just_audio.
///
/// Uses locally cached files when available and falls back to CDN streaming.
class AdhanAudioPlaybackService {
  AdhanAudioPlaybackService({
    required AdhanAudioCacheService cacheService,
    AudioPlayer? player,
  })  : _cacheService = cacheService,
        _player = player ?? AudioPlayer();

  final AdhanAudioCacheService _cacheService;
  final AudioPlayer _player;

  /// Whether adhan audio is currently playing.
  bool get isPlaying => _player.playing;

  /// Stream of the current playing state.
  Stream<bool> get playingStream =>
      _player.playingStream.asBroadcastStream();

  /// Stream of the current playback position.
  Stream<Duration> get positionStream => _player.positionStream;

  /// The total duration of the loaded audio (null if not loaded).
  Duration? get duration => _player.duration;

  /// Plays the adhan for the given [muezzin] in the specified [mode].
  ///
  /// - [AdhanPlaybackMode.fullAdhan]: plays the complete adhan audio (~3-5 min).
  /// - [AdhanPlaybackMode.takbeerOnly]: plays only the opening ~30 seconds.
  /// - [AdhanPlaybackMode.notificationOnly]: does nothing (handled by notification).
  ///
  /// Returns `true` if playback started successfully, `false` on failure.
  Future<bool> play({
    required AdhanMuezzin muezzin,
    required AdhanPlaybackMode mode,
  }) async {
    if (mode == AdhanPlaybackMode.notificationOnly) {
      return false;
    }

    try {
      await stop();

      // Try cached file first, fall back to CDN URL.
      final cachedPath = await _cacheService.cachedFilePathFor(muezzin);
      if (cachedPath != null) {
        await _player.setFilePath(cachedPath);
      } else {
        await _player.setUrl(muezzin.cdnUrl);
      }

      // For takbeer-only mode, clip to the first 30 seconds.
      if (mode == AdhanPlaybackMode.takbeerOnly) {
        await _player.setClip(
          start: Duration.zero,
          end: const Duration(seconds: 30),
        );
      }

      await _player.play();
      return true;
    } on Object {
      return false;
    }
  }

  /// Plays a short preview of the given [muezzin] (first 15 seconds).
  Future<bool> preview(AdhanMuezzin muezzin) async {
    try {
      await stop();

      final cachedPath = await _cacheService.cachedFilePathFor(muezzin);
      if (cachedPath != null) {
        await _player.setFilePath(cachedPath);
      } else {
        await _player.setUrl(muezzin.cdnUrl);
      }

      await _player.setClip(
        start: Duration.zero,
        end: const Duration(seconds: 15),
      );
      await _player.play();
      return true;
    } on Object {
      return false;
    }
  }

  /// Stops any currently playing adhan audio.
  Future<void> stop() async {
    if (_player.playing) {
      await _player.stop();
    }
    await _player.seek(Duration.zero);
  }

  /// Releases audio resources. Call when the service is no longer needed.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
