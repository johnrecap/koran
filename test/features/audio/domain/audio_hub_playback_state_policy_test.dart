import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_state_policy.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  test('clears stale package playing state when the player is idle', () {
    final resolved = AudioHubPlaybackStatePolicy.resolve(
      playerPlaying: false,
      processingState: ProcessingState.idle,
      packageIsPlaying: true,
      hasActiveSession: true,
    );

    expect(resolved.isPlaying, isFalse);
    expect(resolved.hasActiveSession, isFalse);
    expect(resolved.normalizedPackageIsPlaying, isFalse);
  });

  test('preserves a paused active session when the player is ready', () {
    final resolved = AudioHubPlaybackStatePolicy.resolve(
      playerPlaying: false,
      processingState: ProcessingState.ready,
      packageIsPlaying: false,
      hasActiveSession: true,
    );

    expect(resolved.isPlaying, isFalse);
    expect(resolved.hasActiveSession, isTrue);
    expect(resolved.normalizedPackageIsPlaying, isFalse);
  });

  test('treats active player playback as playing regardless of package flag',
      () {
    final resolved = AudioHubPlaybackStatePolicy.resolve(
      playerPlaying: true,
      processingState: ProcessingState.ready,
      packageIsPlaying: false,
      hasActiveSession: false,
    );

    expect(resolved.isPlaying, isTrue);
    expect(resolved.hasActiveSession, isTrue);
    expect(resolved.normalizedPackageIsPlaying, isFalse);
  });
}
