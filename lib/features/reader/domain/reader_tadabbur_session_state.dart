import 'package:flutter/foundation.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';

@immutable
class ReaderTadabburSessionState {
  const ReaderTadabburSessionState({
    required this.entryAyah,
    required this.currentAyah,
    required this.draftReflection,
    required this.hasPendingAutosave,
    required this.isTimerRunning,
    required this.selectedTimerDuration,
    required this.remainingTimerDuration,
  });

  factory ReaderTadabburSessionState.initial(Ayah entryAyah) {
    const defaultDuration = Duration(minutes: 5);
    return ReaderTadabburSessionState(
      entryAyah: entryAyah,
      currentAyah: entryAyah,
      draftReflection: '',
      hasPendingAutosave: false,
      isTimerRunning: false,
      selectedTimerDuration: defaultDuration,
      remainingTimerDuration: defaultDuration,
    );
  }

  final Ayah entryAyah;
  final Ayah currentAyah;
  final String draftReflection;
  final bool hasPendingAutosave;
  final bool isTimerRunning;
  final Duration selectedTimerDuration;
  final Duration remainingTimerDuration;

  ReaderTadabburSessionState copyWith({
    Ayah? currentAyah,
    String? draftReflection,
    bool? hasPendingAutosave,
    bool? isTimerRunning,
    Duration? selectedTimerDuration,
    Duration? remainingTimerDuration,
  }) {
    return ReaderTadabburSessionState(
      entryAyah: entryAyah,
      currentAyah: currentAyah ?? this.currentAyah,
      draftReflection: draftReflection ?? this.draftReflection,
      hasPendingAutosave: hasPendingAutosave ?? this.hasPendingAutosave,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      selectedTimerDuration:
          selectedTimerDuration ?? this.selectedTimerDuration,
      remainingTimerDuration:
          remainingTimerDuration ?? this.remainingTimerDuration,
    );
  }
}
