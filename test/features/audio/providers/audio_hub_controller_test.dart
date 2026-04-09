import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/audio/data/audio_hub_playback_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_snapshot.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/audio/providers/audio_providers.dart';

void main() {
  test('loads the initial playback snapshot and reacts to later updates',
      () async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration(seconds: 12),
        duration: Duration(minutes: 3),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        audioHubPlaybackServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(audioHubControllerProvider.notifier).ready;

    expect(
      container.read(audioHubControllerProvider).value,
      const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration(seconds: 12),
        duration: Duration(minutes: 3),
      ),
    );

    service.emit(
      const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: true,
        isBuffering: false,
        position: Duration(seconds: 42),
        duration: Duration(minutes: 3),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(container.read(audioHubControllerProvider).value?.isPlaying, isTrue);
    expect(
      container.read(audioHubControllerProvider).value?.position,
      const Duration(seconds: 42),
    );
  });

  test('togglePlayPause delegates to play and pause based on current state',
      () async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 1,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration.zero,
        duration: Duration(minutes: 1),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        audioHubPlaybackServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(audioHubControllerProvider.notifier);
    await controller.ready;

    await controller.togglePlayPause();
    expect(service.playCalls, 1);
    expect(service.pauseCalls, 0);

    service.emit(
      const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 1,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: true,
        isBuffering: false,
        position: Duration(seconds: 5),
        duration: Duration(minutes: 1),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    await controller.togglePlayPause();
    expect(service.playCalls, 1);
    expect(service.pauseCalls, 1);
  });

  test('selectReciter delegates the requested reciter id to the service',
      () async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 1,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration.zero,
        duration: Duration(minutes: 1),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        audioHubPlaybackServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(audioHubControllerProvider.notifier);
    await controller.ready;

    await controller.selectReciter('reader-b');

    expect(service.lastSelectedReciterId, 'reader-b');
  });

  test('stop delegates to the playback service', () async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 1,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: true,
        isBuffering: false,
        position: Duration(seconds: 12),
        duration: Duration(minutes: 1),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        audioHubPlaybackServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(audioHubControllerProvider.notifier);
    await controller.ready;

    await controller.stop();

    expect(service.stopCalls, 1);
  });

  test('converts bootstrap timeout failures into AsyncError state', () async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 1,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: false,
        isPlaying: false,
        isBuffering: false,
        position: Duration.zero,
        duration: Duration.zero,
      ),
      initializeError: TimeoutException(
        'Audio controller did not finish bootstrapping.',
        const Duration(seconds: 15),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        audioHubPlaybackServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(audioHubControllerProvider.notifier).ready;

    final state = container.read(audioHubControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<TimeoutException>());
  });

  test('converts snapshot stream errors into AsyncError state', () async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 1,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: false,
        isPlaying: false,
        isBuffering: false,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        audioHubPlaybackServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(audioHubControllerProvider.notifier).ready;

    service.emitError(StateError('snapshot failed'));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(audioHubControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<StateError>());
  });
}

class FakeAudioHubPlaybackService implements AudioHubPlaybackService {
  FakeAudioHubPlaybackService({
    required AudioHubPlaybackSnapshot initialSnapshot,
    this.ensureCompleter,
    this.initializeError,
  }) : _snapshot = initialSnapshot;

  final Completer<void>? ensureCompleter;
  final Object? initializeError;

  final _controller = StreamController<AudioHubPlaybackSnapshot>.broadcast();
  final _sessionController = StreamController<bool>.broadcast();
  AudioHubPlaybackSnapshot _snapshot;
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  int nextCalls = 0;
  int previousCalls = 0;
  Duration? lastSeekPosition;
  int? lastSelectedSurahNumber;
  bool? lastAutoPlayValue;
  String? lastSelectedReciterId;

  @override
  List<AudioHubReciterOption> get availableReciters =>
      const <AudioHubReciterOption>[
        AudioHubReciterOption(index: 0, id: 'reader-a', name: 'Reader A'),
        AudioHubReciterOption(index: 1, id: 'reader-b', name: 'Reader B'),
      ];

  @override
  bool get hasActiveSession => _snapshot.hasActiveSession;

  @override
  Stream<bool> get sessionActivity => _sessionController.stream;

  @override
  Stream<AudioHubPlaybackSnapshot> get snapshots => _controller.stream;

  @override
  Future<AudioHubPlaybackSnapshot> ensureInitialized() async {
    if (initializeError != null) {
      throw initializeError!;
    }
    if (ensureCompleter != null) {
      await ensureCompleter!.future;
    }
    return _snapshot;
  }

  @override
  Future<void> pause() async {
    pauseCalls += 1;
  }

  @override
  Future<void> play() async {
    playCalls += 1;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> playNextSurah() async {
    nextCalls += 1;
  }

  @override
  Future<void> playPreviousSurah() async {
    previousCalls += 1;
  }

  @override
  Future<void> seek(Duration position) async {
    lastSeekPosition = position;
  }

  @override
  Future<void> selectSurah(int surahNumber, {bool autoPlay = true}) async {
    lastSelectedSurahNumber = surahNumber;
    lastAutoPlayValue = autoPlay;
  }

  @override
  Future<void> selectReciter(
    String reciterId, {
    bool restartPlayback = true,
  }) async {
    lastSelectedReciterId = reciterId;
  }

  void emit(AudioHubPlaybackSnapshot snapshot) {
    _snapshot = snapshot;
    _controller.add(snapshot);
    _sessionController.add(snapshot.hasActiveSession);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  @override
  void dispose() {
    _controller.close();
    _sessionController.close();
  }
}
