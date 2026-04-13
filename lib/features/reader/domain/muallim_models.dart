import 'package:flutter/foundation.dart';

enum MuallimPlaybackState { idle, loading, playing, paused, error }

@immutable
class MuallimAyahPosition {
  const MuallimAyahPosition({
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahUQNumber,
    required this.pageNumber,
  });

  final int surahNumber;
  final int ayahNumber;
  final int ayahUQNumber;
  final int pageNumber;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MuallimAyahPosition &&
        other.surahNumber == surahNumber &&
        other.ayahNumber == ayahNumber &&
        other.ayahUQNumber == ayahUQNumber &&
        other.pageNumber == pageNumber;
  }

  @override
  int get hashCode =>
      Object.hash(surahNumber, ayahNumber, ayahUQNumber, pageNumber);
}

@immutable
class MuallimPlaybackSnapshot {
  const MuallimPlaybackSnapshot({
    required this.playbackState,
    required this.currentAyah,
    required this.position,
    required this.duration,
    required this.currentReciterId,
    required this.currentReciterName,
    this.currentWordIndex,
  });

  const MuallimPlaybackSnapshot.initial()
      : playbackState = MuallimPlaybackState.idle,
        currentAyah = null,
        position = Duration.zero,
        duration = Duration.zero,
        currentReciterId = '',
        currentReciterName = '',
        currentWordIndex = null;

  final MuallimPlaybackState playbackState;
  final MuallimAyahPosition? currentAyah;
  final Duration position;
  final Duration duration;
  final String currentReciterId;
  final String currentReciterName;

  /// The 0-based index of the word currently being recited within [currentAyah].
  /// Null when word-level timing data is unavailable or no word is active.
  final int? currentWordIndex;

  MuallimPlaybackSnapshot copyWith({
    MuallimPlaybackState? playbackState,
    MuallimAyahPosition? currentAyah,
    bool clearCurrentAyah = false,
    Duration? position,
    Duration? duration,
    String? currentReciterId,
    String? currentReciterName,
    int? currentWordIndex,
    bool clearWordIndex = false,
  }) {
    return MuallimPlaybackSnapshot(
      playbackState: playbackState ?? this.playbackState,
      currentAyah: clearCurrentAyah ? null : (currentAyah ?? this.currentAyah),
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentReciterId: currentReciterId ?? this.currentReciterId,
      currentReciterName: currentReciterName ?? this.currentReciterName,
      currentWordIndex:
          clearWordIndex ? null : (currentWordIndex ?? this.currentWordIndex),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MuallimPlaybackSnapshot &&
        other.playbackState == playbackState &&
        other.currentAyah == currentAyah &&
        other.position == position &&
        other.duration == duration &&
        other.currentReciterId == currentReciterId &&
        other.currentReciterName == currentReciterName &&
        other.currentWordIndex == currentWordIndex;
  }

  @override
  int get hashCode => Object.hash(
        playbackState,
        currentAyah,
        position,
        duration,
        currentReciterId,
        currentReciterName,
        currentWordIndex,
      );
}

@immutable
class MuallimSnapshot extends MuallimPlaybackSnapshot {
  const MuallimSnapshot({
    required this.isEnabled,
    required super.playbackState,
    required super.currentAyah,
    required super.position,
    required super.duration,
    required super.currentReciterId,
    required super.currentReciterName,
    super.currentWordIndex,
  });

  const MuallimSnapshot.initial()
      : isEnabled = false,
        super.initial();

  factory MuallimSnapshot.fromPlayback(
    MuallimPlaybackSnapshot playback, {
    required bool isEnabled,
    int? currentWordIndex,
  }) {
    return MuallimSnapshot(
      isEnabled: isEnabled,
      playbackState: playback.playbackState,
      currentAyah: playback.currentAyah,
      position: playback.position,
      duration: playback.duration,
      currentReciterId: playback.currentReciterId,
      currentReciterName: playback.currentReciterName,
      currentWordIndex: currentWordIndex ?? playback.currentWordIndex,
    );
  }

  final bool isEnabled;

  @override
  MuallimSnapshot copyWith({
    bool? isEnabled,
    MuallimPlaybackState? playbackState,
    MuallimAyahPosition? currentAyah,
    bool clearCurrentAyah = false,
    Duration? position,
    Duration? duration,
    String? currentReciterId,
    String? currentReciterName,
    int? currentWordIndex,
    bool clearWordIndex = false,
  }) {
    return MuallimSnapshot(
      isEnabled: isEnabled ?? this.isEnabled,
      playbackState: playbackState ?? this.playbackState,
      currentAyah: clearCurrentAyah ? null : (currentAyah ?? this.currentAyah),
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentReciterId: currentReciterId ?? this.currentReciterId,
      currentReciterName: currentReciterName ?? this.currentReciterName,
      currentWordIndex:
          clearWordIndex ? null : (currentWordIndex ?? this.currentWordIndex),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MuallimSnapshot &&
        other.isEnabled == isEnabled &&
        super == other;
  }

  @override
  int get hashCode => Object.hash(
        isEnabled,
        super.hashCode,
      );
}
