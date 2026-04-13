import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/reader/data/muallim_ayah_audio_service.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/providers/muallim_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  test('enables Muallim mode and starts playback from a specific ayah', () async {
    final service = _FakeMuallimAyahAudioService();
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(muallimStateProvider.notifier);
    await notifier.enable();
    await notifier.startFromAyah(
      const MuallimAyahPosition(
        surahNumber: 2,
        ayahNumber: 5,
        ayahUQNumber: 12,
        pageNumber: 2,
      ),
    );

    final state = container.read(muallimStateProvider);
    expect(state.isEnabled, isTrue);
    expect(state.playbackState, MuallimPlaybackState.loading);
    expect(service.lastPlayedAyahUQNumber, 12);
  });

  test(
      'exposes an auto-navigation target when scroll mode crosses into a new page',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);

    container.read(readerModeProvider.notifier).state = ReaderMode.scroll;
    container.read(quranPageIndexProvider.notifier).state = 10;
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(
      const MuallimPlaybackSnapshot(
        playbackState: MuallimPlaybackState.playing,
        currentAyah: MuallimAyahPosition(
          surahNumber: 3,
          ayahNumber: 7,
          ayahUQNumber: 300,
          pageNumber: 11,
        ),
        position: Duration(seconds: 2),
        duration: Duration(seconds: 5),
        currentReciterId: 'reader-1',
        currentReciterName: 'Reader One',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final target = container.read(muallimAutoNavigationTargetProvider);
    expect(
      target,
      const ReaderNavigationTarget(
        surahNumber: 3,
        ayahNumber: 7,
        pageNumber: 11,
      ),
    );
  });

  test('updates the selected reciter in Muallim state', () async {
    final service = _FakeMuallimAyahAudioService();
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);

    await container.read(muallimStateProvider.notifier).selectReciter(
          'reader-2',
          restartPlayback: false,
        );

    final state = container.read(muallimStateProvider);
    expect(state.currentReciterId, 'reader-2');
    expect(state.currentReciterName, 'Reader Two');
  });
}

class _FakeMuallimAyahAudioService implements MuallimAyahAudioService {
  final StreamController<MuallimPlaybackSnapshot> _controller =
      StreamController<MuallimPlaybackSnapshot>.broadcast();

  int? lastPlayedAyahUQNumber;
  String _currentReciterId = 'reader-1';
  String _currentReciterName = 'Reader One';

  @override
  List<AudioHubReciterOption> get availableReciters => const [
        AudioHubReciterOption(
          index: 0,
          id: 'reader-1',
          name: 'Reader One',
        ),
        AudioHubReciterOption(
          index: 1,
          id: 'reader-2',
          name: 'Reader Two',
        ),
      ];

  @override
  Stream<MuallimPlaybackSnapshot> get snapshots => _controller.stream;

  @override
  Future<MuallimPlaybackSnapshot> ensureInitialized() async {
    return MuallimPlaybackSnapshot(
      playbackState: MuallimPlaybackState.idle,
      currentAyah: null,
      position: Duration.zero,
      duration: Duration.zero,
      currentReciterId: _currentReciterId,
      currentReciterName: _currentReciterName,
    );
  }

  @override
  Future<void> nextAyah({
    BuildContext? context,
  }) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> playFromAyah(
    MuallimAyahPosition ayah, {
    BuildContext? context,
    bool isDarkMode = false,
  }) async {
    lastPlayedAyahUQNumber = ayah.ayahUQNumber;
  }

  @override
  Future<void> previousAyah({
    BuildContext? context,
  }) async {}

  @override
  Future<void> resume({
    BuildContext? context,
    bool isDarkMode = false,
  }) async {}

  @override
  Future<void> selectReciter(
    String reciterId, {
    BuildContext? context,
    bool restartPlayback = true,
    bool isDarkMode = false,
  }) async {
    for (final reciter in availableReciters) {
      if (reciter.id == reciterId) {
        _currentReciterId = reciter.id;
        _currentReciterName = reciter.name;
        break;
      }
    }
  }

  @override
  void clearSelectionHighlights() {}

  @override
  Future<void> stop() async {}

  @override
  void dispose() {
    _controller.close();
  }

  void emit(MuallimPlaybackSnapshot snapshot) {
    _controller.add(snapshot);
  }
}
