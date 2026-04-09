import 'package:flutter/foundation.dart';

@immutable
class AudioHubPlaybackSnapshot {
  const AudioHubPlaybackSnapshot({
    required this.selectedSurahNumber,
    required this.currentReciterId,
    required this.currentReciterName,
    required this.hasActiveSession,
    required this.isPlaying,
    required this.isBuffering,
    required this.position,
    required this.duration,
  });

  final int selectedSurahNumber;
  final String currentReciterId;
  final String currentReciterName;
  final bool hasActiveSession;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;

  bool get hasPrevious => selectedSurahNumber > 1;
  bool get hasNext => selectedSurahNumber < 114;
  bool get canSeek => duration > Duration.zero;

  double get sliderValue {
    final maxMillis = duration.inMilliseconds;
    if (maxMillis <= 0) {
      return 0;
    }

    final positionMillis = position.inMilliseconds.clamp(0, maxMillis);
    return positionMillis.toDouble();
  }

  double get sliderMax {
    final maxMillis = duration.inMilliseconds;
    if (maxMillis <= 0) {
      return 1;
    }

    return maxMillis.toDouble();
  }

  AudioHubPlaybackSnapshot copyWith({
    int? selectedSurahNumber,
    String? currentReciterId,
    String? currentReciterName,
    bool? hasActiveSession,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
  }) {
    return AudioHubPlaybackSnapshot(
      selectedSurahNumber: selectedSurahNumber ?? this.selectedSurahNumber,
      currentReciterId: currentReciterId ?? this.currentReciterId,
      currentReciterName: currentReciterName ?? this.currentReciterName,
      hasActiveSession: hasActiveSession ?? this.hasActiveSession,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AudioHubPlaybackSnapshot &&
        other.selectedSurahNumber == selectedSurahNumber &&
        other.currentReciterId == currentReciterId &&
        other.currentReciterName == currentReciterName &&
        other.hasActiveSession == hasActiveSession &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering &&
        other.position == position &&
        other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(
        selectedSurahNumber,
        currentReciterId,
        currentReciterName,
        hasActiveSession,
        isPlaying,
        isBuffering,
        position,
        duration,
      );
}
