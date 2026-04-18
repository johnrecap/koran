import 'package:flutter/foundation.dart';

enum MuallimPlaybackState { idle, loading, playing, paused, error }

enum MuallimTimingStatus {
  idle,
  loading,
  available,
  unavailable,
  loadError,
  unmappedReciter,
}

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
class MuallimResumeSession {
  const MuallimResumeSession({
    required this.ayah,
    required this.reciterId,
    required this.reciterName,
  });

  final MuallimAyahPosition ayah;
  final String reciterId;
  final String reciterName;

  Map<String, dynamic> toMap() {
    return {
      'ayah': {
        'surahNumber': ayah.surahNumber,
        'ayahNumber': ayah.ayahNumber,
        'ayahUQNumber': ayah.ayahUQNumber,
        'pageNumber': ayah.pageNumber,
      },
      'reciterId': reciterId,
      'reciterName': reciterName,
    };
  }

  factory MuallimResumeSession.fromMap(Map<String, dynamic> map) {
    final ayahMap = Map<String, dynamic>.from(map['ayah'] as Map);
    return MuallimResumeSession(
      ayah: MuallimAyahPosition(
        surahNumber: (ayahMap['surahNumber'] as num).toInt(),
        ayahNumber: (ayahMap['ayahNumber'] as num).toInt(),
        ayahUQNumber: (ayahMap['ayahUQNumber'] as num).toInt(),
        pageNumber: (ayahMap['pageNumber'] as num).toInt(),
      ),
      reciterId: map['reciterId'] as String? ?? '',
      reciterName: map['reciterName'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MuallimResumeSession &&
        other.ayah == ayah &&
        other.reciterId == reciterId &&
        other.reciterName == reciterName;
  }

  @override
  int get hashCode => Object.hash(ayah, reciterId, reciterName);
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
    required this.timingStatus,
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
        timingStatus = MuallimTimingStatus.idle,
        super.initial();

  factory MuallimSnapshot.fromPlayback(
    MuallimPlaybackSnapshot playback, {
    required bool isEnabled,
    MuallimTimingStatus timingStatus = MuallimTimingStatus.idle,
    int? currentWordIndex,
  }) {
    return MuallimSnapshot(
      isEnabled: isEnabled,
      timingStatus: timingStatus,
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
  final MuallimTimingStatus timingStatus;

  @override
  MuallimSnapshot copyWith({
    bool? isEnabled,
    MuallimTimingStatus? timingStatus,
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
      timingStatus: timingStatus ?? this.timingStatus,
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
        other.timingStatus == timingStatus &&
        super == other;
  }

  @override
  int get hashCode => Object.hash(
        isEnabled,
        timingStatus,
        super.hashCode,
      );
}
