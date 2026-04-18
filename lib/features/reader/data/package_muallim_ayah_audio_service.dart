import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/reader/data/muallim_ayah_audio_service.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';
import 'package:quran_library/quran_library.dart';

class PackageMuallimAyahAudioService implements MuallimAyahAudioService {
  PackageMuallimAyahAudioService({
    AudioCtrl? audioCtrl,
  }) : _audioCtrl = audioCtrl ?? AudioCtrl.instance;

  final AudioCtrl _audioCtrl;
  final StreamController<MuallimPlaybackSnapshot> _controller =
      StreamController<MuallimPlaybackSnapshot>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  bool _initialized = false;
  bool _hasActiveSession = false;

  @override
  List<AudioHubReciterOption> get availableReciters {
    return List<AudioHubReciterOption>.unmodifiable(
      ReadersConstants.activeAyahReaders.map(
        (reader) => AudioHubReciterOption(
          index: reader.index,
          id: reader.readerNamePath,
          name: reader.name,
        ),
      ),
    );
  }

  @override
  Stream<MuallimPlaybackSnapshot> get snapshots => _controller.stream;

  @override
  Future<MuallimPlaybackSnapshot> ensureInitialized() async {
    if (_initialized) {
      return _currentSnapshot();
    }

    if (!QuranCtrl.instance.state.isQuranLoaded) {
      await QuranCtrl.instance.loadQuranDataV3();
    }

    _subscribe();
    _initialized = true;
    final snapshot = _currentSnapshot();
    _emitSnapshot();
    return snapshot;
  }

  @override
  Future<void> playFromAyah(
    MuallimAyahPosition ayah, {
    BuildContext? context,
    bool isDarkMode = false,
  }) async {
    final playbackContext = context;
    if (playbackContext == null) {
      throw StateError('Muallim playback requires a BuildContext.');
    }

    await ensureInitialized();
    if (!playbackContext.mounted) {
      return;
    }

    _hasActiveSession = true;
    _audioCtrl.state.isPlayingSurahsMode = false;
    _audioCtrl.disableSurahAutoNextListener();
    _audioCtrl.disableSurahPositionSaving();
    await _audioCtrl.playAyah(
      playbackContext,
      ayah.ayahUQNumber,
      playSingleAyah: false,
      isDarkMode: isDarkMode,
    );
    _emitSnapshot();
  }

  @override
  Future<void> pause() async {
    await ensureInitialized();
    _audioCtrl.state.isPlaying.value = false;
    await _audioCtrl.pausePlayer();
    _emitSnapshot();
  }

  @override
  Future<void> resume({
    BuildContext? context,
    bool isDarkMode = false,
  }) async {
    await ensureInitialized();
    if (context != null && !context.mounted) {
      return;
    }

    final player = _audioCtrl.state.audioPlayer;
    if (player.audioSource == null ||
        player.processingState == ProcessingState.idle ||
        player.processingState == ProcessingState.completed) {
      final currentAyah = _resolveCurrentAyah();
      if (currentAyah == null) {
        return;
      }
      await playFromAyah(
        currentAyah,
        context: context,
        isDarkMode: isDarkMode,
      );
      return;
    }

    _hasActiveSession = true;
    _audioCtrl.state.isPlaying.value = true;
    await player.play();
    _emitSnapshot();
  }

  @override
  Future<void> stop() async {
    await ensureInitialized();
    _hasActiveSession = false;
    _audioCtrl.state.isPlaying.value = false;
    await _audioCtrl.state.stopAllAudio();
    clearSelectionHighlights();
    _emitSnapshot();
  }

  @override
  Future<void> nextAyah({
    BuildContext? context,
  }) async {
    final playbackContext = context;
    if (playbackContext == null) {
      throw StateError('Muallim next-ayah requires a BuildContext.');
    }

    await ensureInitialized();
    if (!playbackContext.mounted) {
      return;
    }
    _hasActiveSession = true;
    await _audioCtrl.skipNextAyah(
      playbackContext,
      _audioCtrl.state.currentAyahUniqueNumber.value,
    );
    _emitSnapshot();
  }

  @override
  Future<void> previousAyah({
    BuildContext? context,
  }) async {
    final playbackContext = context;
    if (playbackContext == null) {
      throw StateError('Muallim previous-ayah requires a BuildContext.');
    }

    await ensureInitialized();
    if (!playbackContext.mounted) {
      return;
    }
    _hasActiveSession = true;
    await _audioCtrl.skipPreviousAyah(
      playbackContext,
      _audioCtrl.state.currentAyahUniqueNumber.value,
    );
    _emitSnapshot();
  }

  @override
  Future<void> selectReciter(
    String reciterId, {
    BuildContext? context,
    bool restartPlayback = true,
    bool isDarkMode = false,
  }) async {
    await ensureInitialized();
    if (context != null && !context.mounted) {
      return;
    }

    final option = availableReciters.cast<AudioHubReciterOption?>().firstWhere(
          (item) => item?.id == reciterId,
          orElse: () => null,
        );
    if (option == null) {
      return;
    }

    _audioCtrl.state.box.write(StorageConstants.ayahReaderIndex, option.index);
    _audioCtrl.state.ayahReaderIndex.value = option.index;

    if (restartPlayback && _hasActiveSession) {
      final currentAyah = _resolveCurrentAyah();
      if (currentAyah != null) {
        await playFromAyah(
          currentAyah,
          context: context,
          isDarkMode: isDarkMode,
        );
        return;
      }
    }

    _emitSnapshot();
  }

  @override
  void clearSelectionHighlights() {
    QuranCtrl.instance.clearSelection();
    QuranCtrl.instance.clearExternalHighlights();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _controller.close();
  }

  void _subscribe() {
    if (_subscriptions.isNotEmpty) {
      return;
    }

    _subscriptions.add(
      _audioCtrl.state.audioPlayer.playerStateStream.listen((_) {
        _emitSnapshot();
      }),
    );
    _subscriptions.add(
      _audioCtrl.state.audioPlayer.sequenceStateStream.listen((_) {
        _emitSnapshot();
      }),
    );
    _subscriptions.add(
      _audioCtrl.positionDataStream.listen((_) {
        _emitSnapshot();
      }),
    );
  }

  void _emitSnapshot() {
    if (_controller.isClosed) {
      return;
    }
    try {
      _controller.add(_currentSnapshot());
    } catch (error, stackTrace) {
      AppLogger.error(
        'PackageMuallimAyahAudioService._emitSnapshot',
        error,
        stackTrace,
      );
    }
  }

  MuallimPlaybackSnapshot _currentSnapshot() {
    final player = _audioCtrl.state.audioPlayer;
    final position = player.position;
    final duration = player.duration ?? Duration.zero;

    return MuallimPlaybackSnapshot(
      playbackState: _resolvePlaybackState(player: player),
      currentAyah: _resolveCurrentAyah(),
      position: position,
      duration: duration,
      currentReciterId: _currentReciter()?.id ?? '',
      currentReciterName: _currentReciter()?.name ?? '',
    );
  }

  MuallimPlaybackState _resolvePlaybackState({
    required AudioPlayer player,
  }) {
    if (_audioCtrl.state.isAudioPreparing.value ||
        player.processingState == ProcessingState.loading ||
        player.processingState == ProcessingState.buffering) {
      return MuallimPlaybackState.loading;
    }

    if (player.playing) {
      return MuallimPlaybackState.playing;
    }

    if (!_hasActiveSession ||
        player.processingState == ProcessingState.idle ||
        player.processingState == ProcessingState.completed) {
      return MuallimPlaybackState.idle;
    }

    return MuallimPlaybackState.paused;
  }

  MuallimAyahPosition? _resolveCurrentAyah() {
    try {
      final ayah = _audioCtrl.currentAyah;
      final surahNumber = ayah.surahNumber;
      if (surahNumber == null) {
        return null;
      }
      return MuallimAyahPosition(
        surahNumber: surahNumber,
        ayahNumber: ayah.ayahNumber,
        ayahUQNumber: ayah.ayahUQNumber,
        pageNumber: QuranCtrl.instance.getPageNumberByAyahUqNumber(
          ayah.ayahUQNumber,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  AudioHubReciterOption? _currentReciter() {
    final options = availableReciters;
    if (options.isEmpty) {
      return null;
    }

    final currentIndex = _audioCtrl.state.ayahReaderIndex.value;
    if (currentIndex < 0 || currentIndex >= options.length) {
      return options.first;
    }

    return options[currentIndex];
  }
}
