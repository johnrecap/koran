import 'package:quran_library/quran_library.dart';

class AudioHubPlaybackStatePolicy {
  const AudioHubPlaybackStatePolicy._();

  static AudioHubPlaybackStateResolution resolve({
    required bool playerPlaying,
    required ProcessingState processingState,
    required bool packageIsPlaying,
    required bool hasActiveSession,
  }) {
    if (processingState == ProcessingState.idle) {
      return const AudioHubPlaybackStateResolution(
        isPlaying: false,
        hasActiveSession: false,
        normalizedPackageIsPlaying: false,
      );
    }

    return AudioHubPlaybackStateResolution(
      isPlaying: playerPlaying,
      hasActiveSession: hasActiveSession || playerPlaying || packageIsPlaying,
      normalizedPackageIsPlaying: packageIsPlaying,
    );
  }
}

class AudioHubPlaybackStateResolution {
  const AudioHubPlaybackStateResolution({
    required this.isPlaying,
    required this.hasActiveSession,
    required this.normalizedPackageIsPlaying,
  });

  final bool isPlaying;
  final bool hasActiveSession;
  final bool normalizedPackageIsPlaying;
}
