import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/audio/data/audio_downloads_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_kareem/features/audio/providers/audio_download_providers.dart';

void main() {
  test('manager summary provider reloads after controller refresh', () async {
    final service = _FakeAudioDownloadsService();
    final container = ProviderContainer(
      overrides: [
        audioDownloadsServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    final initial =
        await container.read(audioDownloadManagerSummaryProvider.future);
    expect(initial.downloadedReciters.first.downloadedSurahCount, 1);

    service.summary = const AudioDownloadManagerSummary(
      downloadedReciters: [
        AudioDownloadReciterSummary(
          reciterIndex: 1,
          reciterName: 'Reader A',
          readerNamePath: 'reader-a/',
          downloadedSurahCount: 2,
          totalBytes: 20,
          section: AudioDownloadReciterSection.downloaded,
        ),
      ],
      availableReciters: [],
    );

    container.read(audioDownloadsControllerProvider).refresh();

    final refreshed =
        await container.read(audioDownloadManagerSummaryProvider.future);
    expect(refreshed.downloadedReciters.first.downloadedSurahCount, 2);
  });

  test('controller delegates download delete and cancel actions to service',
      () async {
    final service = _FakeAudioDownloadsService();
    final container = ProviderContainer(
      overrides: [
        audioDownloadsServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(audioDownloadsControllerProvider);

    await controller.downloadSurah(reciterIndex: 1, surahNumber: 2);
    await controller.deleteSurah(reciterIndex: 1, surahNumber: 2);
    await controller.cancelActiveDownload();

    expect(service.downloadCalls, [
      (reciterIndex: 1, surahNumber: 2),
    ]);
    expect(service.deleteCalls, [
      (reciterIndex: 1, surahNumber: 2),
    ]);
    expect(service.cancelCalls, 1);
  });

  test('operation provider mirrors current and streamed operation states',
      () async {
    final service = _FakeAudioDownloadsService(
      currentOperation: const AudioDownloadOperationState(
        status: AudioDownloadOperationStatus.downloading,
        reciterIndex: 1,
        surahNumber: 2,
        progress: 0.2,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        audioDownloadsServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    final values = <AudioDownloadOperationState?>[];
    final subscription = container.listen(
      audioDownloadOperationProvider,
      (_, next) {
        values.add(next.valueOrNull);
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    service.emitOperation(
      const AudioDownloadOperationState(
        status: AudioDownloadOperationStatus.completed,
        reciterIndex: 1,
        surahNumber: 2,
        progress: 1,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(
      values.whereType<AudioDownloadOperationState>().last.status,
      AudioDownloadOperationStatus.completed,
    );
  });
}

class _FakeAudioDownloadsService implements AudioDownloadsService {
  _FakeAudioDownloadsService({
    this.currentOperation = const AudioDownloadOperationState.idle(),
  });

  @override
  AudioDownloadOperationState currentOperation;

  AudioDownloadManagerSummary summary = const AudioDownloadManagerSummary(
    downloadedReciters: [
      AudioDownloadReciterSummary(
        reciterIndex: 1,
        reciterName: 'Reader A',
        readerNamePath: 'reader-a/',
        downloadedSurahCount: 1,
        totalBytes: 10,
        section: AudioDownloadReciterSection.downloaded,
      ),
    ],
    availableReciters: [],
  );

  final StreamController<AudioDownloadOperationState> _controller =
      StreamController<AudioDownloadOperationState>.broadcast();
  final List<({int reciterIndex, int surahNumber})> downloadCalls = [];
  final List<({int reciterIndex, int surahNumber})> deleteCalls = [];
  int cancelCalls = 0;

  @override
  Stream<AudioDownloadOperationState> get operationStates => _controller.stream;

  @override
  Future<void> cancelActiveDownload() async {
    cancelCalls += 1;
  }

  @override
  Future<void> deleteSurah({
    required int reciterIndex,
    required int surahNumber,
  }) async {
    deleteCalls.add((reciterIndex: reciterIndex, surahNumber: surahNumber));
  }

  @override
  Future<void> downloadSurah({
    required int reciterIndex,
    required int surahNumber,
  }) async {
    downloadCalls.add((reciterIndex: reciterIndex, surahNumber: surahNumber));
  }

  void emitOperation(AudioDownloadOperationState state) {
    currentOperation = state;
    _controller.add(state);
  }

  @override
  Future<AudioReciterDownloadsDetail> loadReciterDetail(int reciterIndex) async {
    return const AudioReciterDownloadsDetail(
      reciter: AudioDownloadReciterSummary(
        reciterIndex: 1,
        reciterName: 'Reader A',
        readerNamePath: 'reader-a/',
        downloadedSurahCount: 1,
        totalBytes: 10,
        section: AudioDownloadReciterSection.downloaded,
      ),
      items: [],
      isStorageSupported: true,
    );
  }

  @override
  Future<AudioDownloadManagerSummary> loadManagerSummary() async => summary;

  @override
  void dispose() {
    _controller.close();
  }
}
