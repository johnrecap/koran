import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/reader_tadabbur_navigation_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_tadabbur_session_state.dart';
import 'package:quran_kareem/features/reader/providers/ayah_notes_provider.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

final readerTadabburAutosaveDebounceProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 350),
);

final readerTadabburTimerTickProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 1),
);

abstract class ReaderTadabburAyahLoader {
  Future<Ayah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
  });
}

final readerTadabburAyahLoaderProvider = Provider<ReaderTadabburAyahLoader>(
  (ref) => const _QuranDatabaseReaderTadabburAyahLoader(),
);

final readerTadabburSessionControllerProvider = StateNotifierProvider
    .autoDispose
    .family<ReaderTadabburSessionController, ReaderTadabburSessionState, Ayah>(
  (ref, entryAyah) {
    return ReaderTadabburSessionController(
      ref: ref,
      entryAyah: entryAyah,
      ayahLoader: ref.watch(readerTadabburAyahLoaderProvider),
      autosaveDebounce: ref.watch(readerTadabburAutosaveDebounceProvider),
      timerTick: ref.watch(readerTadabburTimerTickProvider),
    );
  },
);

class ReaderTadabburSessionController
    extends StateNotifier<ReaderTadabburSessionState> {
  ReaderTadabburSessionController({
    required this.ref,
    required Ayah entryAyah,
    required ReaderTadabburAyahLoader ayahLoader,
    required Duration autosaveDebounce,
    required Duration timerTick,
  })  : _ayahLoader = ayahLoader,
        _autosaveDebounce = autosaveDebounce,
        _timerTick = timerTick,
        super(ReaderTadabburSessionState.initial(entryAyah)) {
    ready = _loadDraftFor(entryAyah);
  }

  final Ref ref;
  final ReaderTadabburAyahLoader _ayahLoader;
  final Duration _autosaveDebounce;
  final Duration _timerTick;
  Timer? _autosaveTimer;
  Timer? _countdownTimer;

  late final Future<void> ready;

  AyahNotesNotifier get _notes => ref.read(ayahNotesProvider.notifier);

  void startTimer() {
    _countdownTimer?.cancel();
    state = state.copyWith(
      isTimerRunning: true,
      remainingTimerDuration: state.selectedTimerDuration,
    );

    _countdownTimer = Timer.periodic(_timerTick, (_) {
      final nextRemaining = state.remainingTimerDuration - _timerTick;
      if (nextRemaining <= Duration.zero) {
        _resetTimer(remainingDuration: Duration.zero);
        return;
      }

      state = state.copyWith(
        isTimerRunning: true,
        remainingTimerDuration: nextRemaining,
      );
    });
  }

  void updateReflection(String value) {
    state = state.copyWith(
      draftReflection: value,
      hasPendingAutosave: true,
    );
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, () {
      unawaited(flushPendingReflection());
    });
  }

  Future<void> flushPendingReflection() async {
    _autosaveTimer?.cancel();
    _autosaveTimer = null;
    if (!state.hasPendingAutosave) {
      return;
    }

    await _notes.ready;
    await _notes.saveNote(
      surahNumber: state.currentAyah.surahNumber,
      ayahNumber: state.currentAyah.ayahNumber,
      content: state.draftReflection,
    );

    state = state.copyWith(hasPendingAutosave: false);
  }

  Future<void> goToPrevious() async {
    await ready;
    final surahs = await ref.read(surahsProvider.future);
    final previous = ReaderTadabburNavigationPolicy.previousAyah(
      surahs: surahs,
      surahNumber: state.currentAyah.surahNumber,
      ayahNumber: state.currentAyah.ayahNumber,
    );
    if (previous == null) {
      return;
    }

    await flushPendingReflection();
    _resetTimer();
    await _loadDraftForReference(previous);
  }

  Future<void> goToNext() async {
    await ready;
    final surahs = await ref.read(surahsProvider.future);
    final next = ReaderTadabburNavigationPolicy.nextAyah(
      surahs: surahs,
      surahNumber: state.currentAyah.surahNumber,
      ayahNumber: state.currentAyah.ayahNumber,
    );
    if (next == null) {
      return;
    }

    await flushPendingReflection();
    _resetTimer();
    await _loadDraftForReference(next);
  }

  Future<void> _loadDraftForReference(
    ReaderTadabburAyahReference reference,
  ) async {
    final ayah = await _ayahLoader.loadAyah(
      surahNumber: reference.surahNumber,
      ayahNumber: reference.ayahNumber,
    );
    if (ayah == null) {
      return;
    }

    await _loadDraftFor(ayah);
  }

  Future<void> _loadDraftFor(Ayah ayah) async {
    await _notes.ready;
    final existing = _notes.noteFor(ayah.surahNumber, ayah.ayahNumber);
    state = state.copyWith(
      currentAyah: ayah,
      draftReflection: existing?.content ?? '',
      hasPendingAutosave: false,
      isTimerRunning: false,
      remainingTimerDuration: state.selectedTimerDuration,
    );
  }

  void _resetTimer({
    Duration? remainingDuration,
  }) {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    state = state.copyWith(
      isTimerRunning: false,
      remainingTimerDuration: remainingDuration ?? state.selectedTimerDuration,
    );
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}

class _QuranDatabaseReaderTadabburAyahLoader
    implements ReaderTadabburAyahLoader {
  const _QuranDatabaseReaderTadabburAyahLoader();

  @override
  Future<Ayah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
  }) {
    return QuranDatabase.getAyah(surahNumber, ayahNumber);
  }
}
