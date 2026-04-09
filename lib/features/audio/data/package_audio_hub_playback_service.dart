import 'dart:async';

import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/audio/data/audio_hub_playback_service.dart';
import 'package:quran_kareem/features/audio/data/audio_bootstrap_wait_policy.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_snapshot.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_state_policy.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_policy.dart';
import 'package:quran_library/quran_library.dart';

class PackageAudioHubPlaybackService implements AudioHubPlaybackService {
  PackageAudioHubPlaybackService({
    AudioCtrl? audioCtrl,
    AudioBootstrapWaitPolicy bootstrapWaitPolicy =
        const AudioBootstrapWaitPolicy(),
  })  : _audioCtrl = audioCtrl ?? AudioCtrl.instance,
        _bootstrapWaitPolicy = bootstrapWaitPolicy;

  final AudioCtrl _audioCtrl;
  final AudioBootstrapWaitPolicy _bootstrapWaitPolicy;
  final StreamController<AudioHubPlaybackSnapshot> _controller =
      StreamController<AudioHubPlaybackSnapshot>.broadcast();
  final StreamController<bool> _sessionController =
      StreamController<bool>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  bool _initialized = false;
  bool _hasActiveSession = false;

  @override
  List<AudioHubReciterOption> get availableReciters {
    final readers = ReadersConstants.activeSurahReaders;

    return List<AudioHubReciterOption>.unmodifiable(
      readers.asMap().entries.map(
            (entry) => AudioHubReciterOption(
              index: entry.key,
              id: entry.value.readerNamePath,
              name: entry.value.name,
            ),
          ),
    );
  }

  @override
  Stream<AudioHubPlaybackSnapshot> get snapshots => _controller.stream;

  @override
  bool get hasActiveSession => _hasActiveSession;

  @override
  Stream<bool> get sessionActivity => _sessionController.stream;

  @override
  Future<AudioHubPlaybackSnapshot> ensureInitialized() async {
    if (_initialized) {
      return _currentSnapshot();
    }

    await _waitForPackageAudioBootstrap();
    if (!QuranCtrl.instance.state.isQuranLoaded) {
      await QuranCtrl.instance.loadQuranDataV3();
    }

    await _restorePersistedReciterSelection();
    _audioCtrl.loadLastSurahAndPosition();
    _subscribe();
    _initialized = true;
    _syncSessionState();

    final snapshot = _currentSnapshot();
    _controller.add(snapshot);
    return snapshot;
  }

  @override
  Future<void> play() async {
    await ensureInitialized();

    _hasActiveSession = true;
    _emitSessionActivity();
    _audioCtrl.state.isPlayingSurahsMode = true;
    _audioCtrl.enableSurahAutoNextListener();
    _audioCtrl.enableSurahPositionSaving();
    _audioCtrl.state.isPlaying.value = true;

    if (_audioCtrl.state.audioPlayer.audioSource == null ||
        _audioCtrl.state.audioPlayer.processingState == ProcessingState.idle) {
      await _audioCtrl.lastAudioSource();
    }

    await _audioCtrl.state.audioPlayer.play();
    _emitSnapshot();
  }

  @override
  Future<void> pause() async {
    await ensureInitialized();

    _audioCtrl.state.isPlaying.value = false;
    await _audioCtrl.state.audioPlayer.pause();
    _audioCtrl.disableSurahAutoNextListener();
    _audioCtrl.disableSurahPositionSaving();
    _emitSnapshot();
  }

  @override
  Future<void> stop() async {
    await ensureInitialized();

    final current = _currentSnapshot();
    final currentPosition = _audioCtrl.state.audioPlayer.position;
    _audioCtrl.state.lastPosition.value = currentPosition.inSeconds;
    _audioCtrl.state.box.write(
      StorageConstants.lastPosition,
      currentPosition.inSeconds,
    );
    _audioCtrl.saveLastSurahListen(current.selectedSurahNumber);
    _audioCtrl.state.isPlaying.value = false;
    _audioCtrl.disableSurahAutoNextListener();
    _audioCtrl.disableSurahPositionSaving();
    await _audioCtrl.state.audioPlayer.stop();
    _hasActiveSession = false;
    _emitSessionActivity();
    _emitSnapshot();
  }

  @override
  Future<void> playNextSurah() async {
    await ensureInitialized();
    final current = _currentSnapshot();
    if (!current.hasNext) {
      return;
    }

    await selectSurah(current.selectedSurahNumber + 1);
  }

  @override
  Future<void> playPreviousSurah() async {
    await ensureInitialized();
    final current = _currentSnapshot();
    if (!current.hasPrevious) {
      return;
    }

    await selectSurah(current.selectedSurahNumber - 1);
  }

  @override
  Future<void> seek(Duration position) async {
    await ensureInitialized();

    final current = _currentSnapshot();
    final safePosition = _clampDuration(
      position,
      min: Duration.zero,
      max: current.duration,
    );
    await _audioCtrl.state.audioPlayer.seek(safePosition);
    _audioCtrl.state.lastPosition.value = safePosition.inSeconds;
    _emitSnapshot();
  }

  @override
  Future<void> selectSurah(int surahNumber, {bool autoPlay = true}) async {
    await ensureInitialized();

    final safeSurahNumber = surahNumber.clamp(1, 114);
    _hasActiveSession = true;
    _emitSessionActivity();
    _audioCtrl.state.isPlayingSurahsMode = true;
    _audioCtrl.disableSurahAutoNextListener();
    _audioCtrl.disableSurahPositionSaving();
    _audioCtrl.state.currentAudioListSurahNum.value = safeSurahNumber;
    _audioCtrl.state.selectedSurahIndex.value = safeSurahNumber - 1;
    _audioCtrl.state.lastPosition.value = 0;
    _audioCtrl.saveLastSurahListen(safeSurahNumber);
    await _audioCtrl.changeAudioSource();

    if (autoPlay) {
      await play();
      return;
    }

    _emitSnapshot();
  }

  @override
  Future<void> selectReciter(
    String reciterId, {
    bool restartPlayback = true,
  }) async {
    await ensureInitialized();

    final option = _findReciterById(reciterId);
    if (option == null) {
      return;
    }

    final current = _currentSnapshot();
    if (option.id == current.currentReciterId) {
      return;
    }

    final shouldResumePlayback = restartPlayback && current.isPlaying;
    final previousState = await _captureReciterSelectionState(current);

    _audioCtrl.state.isPlaying.value = false;
    _audioCtrl.state.isPlayingSurahsMode = true;
    _audioCtrl.disableSurahAutoNextListener();
    _audioCtrl.disableSurahPositionSaving();
    _audioCtrl.state.surahReaderIndex.value = option.index;
    _audioCtrl.state.lastPosition.value = 0;
    try {
      await _audioCtrl.initializeSurahDownloadStatus();
      await _changeAudioSourceOrThrow();
      _audioCtrl.state.box
          .write(StorageConstants.surahReaderIndex, option.index);
      await UserPreferences.setSelectedReciter(option.id);
      _audioCtrl.saveLastSurahListen(current.selectedSurahNumber);
    } catch (error, stackTrace) {
      AppLogger.error(
        'PackageAudioHubPlaybackService.selectReciter',
        error,
        stackTrace,
      );
      try {
        await _restoreReciterSelectionState(previousState);
      } catch (restoreError, restoreStackTrace) {
        AppLogger.error(
          'PackageAudioHubPlaybackService.selectReciter.restore',
          restoreError,
          restoreStackTrace,
        );
      }
      rethrow;
    }

    if (shouldResumePlayback) {
      _hasActiveSession = true;
      _emitSessionActivity();
      await play();
      return;
    }

    _emitSnapshot();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _controller.close();
    _sessionController.close();
  }

  Future<void> _waitForPackageAudioBootstrap() async {
    await _bootstrapWaitPolicy.waitUntilReady(() => _isPackageAudioReady);
  }

  bool get _isPackageAudioReady {
    return _audioCtrl.state.surahsPlayList != null ||
        _audioCtrl.state.audioServiceInitialized.value;
  }

  Future<void> _restorePersistedReciterSelection() async {
    final options = availableReciters;
    if (options.isEmpty) {
      return;
    }

    final persistedReciterId = await UserPreferences.getSelectedReciter();
    final resolvedIndex = AudioHubReciterPolicy.resolveReaderIndex(
      options: options,
      persistedReciterId: persistedReciterId,
      fallbackIndex: _audioCtrl.state.surahReaderIndex.value,
    );

    _audioCtrl.state.surahReaderIndex.value = resolvedIndex;
    _audioCtrl.state.box
        .write(StorageConstants.surahReaderIndex, resolvedIndex);
  }

  void _subscribe() {
    if (_subscriptions.isNotEmpty) {
      return;
    }

    _subscriptions.add(
      _audioCtrl.state.audioPlayer.playerStateStream.listen((_) {
        _syncSessionState();
        _emitSessionActivity();
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

    _controller.add(_currentSnapshot());
  }

  void _emitSessionActivity() {
    if (_sessionController.isClosed) {
      return;
    }

    _sessionController.add(_hasActiveSession);
  }

  void _syncSessionState() {
    final player = _audioCtrl.state.audioPlayer;
    final resolved = AudioHubPlaybackStatePolicy.resolve(
      playerPlaying: player.playing,
      processingState: player.processingState,
      packageIsPlaying: _audioCtrl.state.isPlaying.value,
      hasActiveSession: _hasActiveSession,
    );

    _audioCtrl.state.isPlaying.value = resolved.normalizedPackageIsPlaying;
    _hasActiveSession = resolved.hasActiveSession;
  }

  AudioHubPlaybackSnapshot _currentSnapshot() {
    final player = _audioCtrl.state.audioPlayer;
    final persistedPosition =
        Duration(seconds: _audioCtrl.state.lastPosition.value);
    final livePosition = player.position;
    final duration = player.duration ?? Duration.zero;
    final reciter = _currentReciter();
    final resolved = AudioHubPlaybackStatePolicy.resolve(
      playerPlaying: player.playing,
      processingState: player.processingState,
      packageIsPlaying: _audioCtrl.state.isPlaying.value,
      hasActiveSession: _hasActiveSession,
    );

    return AudioHubPlaybackSnapshot(
      selectedSurahNumber: _audioCtrl.state.selectedSurahIndex.value + 1,
      currentReciterId: reciter?.id ?? '',
      currentReciterName: reciter?.name ?? '',
      hasActiveSession: resolved.hasActiveSession,
      isPlaying: resolved.isPlaying,
      isBuffering: _audioCtrl.state.isDownloading.value ||
          player.processingState == ProcessingState.loading ||
          player.processingState == ProcessingState.buffering,
      position: livePosition > Duration.zero ? livePosition : persistedPosition,
      duration: duration,
    );
  }

  AudioHubReciterOption? _findReciterById(String reciterId) {
    for (final option in availableReciters) {
      if (option.id == reciterId) {
        return option;
      }
    }

    return null;
  }

  AudioHubReciterOption? _currentReciter() {
    final options = availableReciters;
    if (options.isEmpty) {
      return null;
    }

    final resolvedIndex = AudioHubReciterPolicy.resolveReaderIndex(
      options: options,
      persistedReciterId: null,
      fallbackIndex: _audioCtrl.state.surahReaderIndex.value,
    );
    return options[resolvedIndex];
  }

  Duration _clampDuration(
    Duration value, {
    required Duration min,
    required Duration max,
  }) {
    if (max <= Duration.zero) {
      return min;
    }

    if (value < min) {
      return min;
    }

    if (value > max) {
      return max;
    }

    return value;
  }

  Future<_AudioReciterSelectionState> _captureReciterSelectionState(
    AudioHubPlaybackSnapshot snapshot,
  ) async {
    return _AudioReciterSelectionState(
      persistedReciterId: await UserPreferences.getSelectedReciter(),
      readerIndex: _audioCtrl.state.surahReaderIndex.value,
      selectedSurahIndex: _audioCtrl.state.selectedSurahIndex.value,
      lastPositionSeconds: _audioCtrl.state.lastPosition.value,
      wasPlaying: snapshot.isPlaying,
      hadActiveSession: _hasActiveSession,
      wasPlayingSurahsMode: _audioCtrl.state.isPlayingSurahsMode,
    );
  }

  Future<void> _restoreReciterSelectionState(
    _AudioReciterSelectionState previousState,
  ) async {
    _audioCtrl.state.surahReaderIndex.value = previousState.readerIndex;
    _audioCtrl.state.selectedSurahIndex.value =
        previousState.selectedSurahIndex;
    _audioCtrl.state.lastPosition.value = previousState.lastPositionSeconds;
    _audioCtrl.state.isPlaying.value = false;
    _audioCtrl.state.isPlayingSurahsMode = previousState.wasPlayingSurahsMode;
    _audioCtrl.state.box.write(
      StorageConstants.surahReaderIndex,
      previousState.readerIndex,
    );
    await UserPreferences.setSelectedReciter(previousState.persistedReciterId);
    await _audioCtrl.initializeSurahDownloadStatus();
    await _changeAudioSourceOrThrow();

    _hasActiveSession = previousState.hadActiveSession;
    _emitSessionActivity();

    if (previousState.wasPlaying) {
      await play();
      return;
    }

    _emitSnapshot();
  }

  Future<void> _changeAudioSourceOrThrow() async {
    await _audioCtrl.state.audioPlayer.stop();
    final audioSource = _audioCtrl.state
            .isSurahDownloadedByNumber(
              _audioCtrl.state.selectedSurahIndex.value + 1,
            )
            .value
        ? AudioSource.file(
            _audioCtrl.localSurahFilePath,
            tag: _audioCtrl.mediaItem,
          )
        : AudioSource.uri(
            Uri.parse(_audioCtrl.urlSurahFilePath),
            tag: _audioCtrl.mediaItem,
          );
    await _audioCtrl.state.audioPlayer.setAudioSource(audioSource);
  }
}

class _AudioReciterSelectionState {
  const _AudioReciterSelectionState({
    required this.persistedReciterId,
    required this.readerIndex,
    required this.selectedSurahIndex,
    required this.lastPositionSeconds,
    required this.wasPlaying,
    required this.hadActiveSession,
    required this.wasPlayingSurahsMode,
  });

  final String persistedReciterId;
  final int readerIndex;
  final int selectedSurahIndex;
  final int lastPositionSeconds;
  final bool wasPlaying;
  final bool hadActiveSession;
  final bool wasPlayingSurahsMode;
}
