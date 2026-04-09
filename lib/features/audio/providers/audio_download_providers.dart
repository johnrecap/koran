import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/audio/data/audio_downloads_service.dart';
import 'package:quran_kareem/features/audio/data/package_audio_downloads_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';

final audioDownloadsServiceProvider = Provider<AudioDownloadsService>((ref) {
  final service = PackageAudioDownloadsService();
  ref.onDispose(service.dispose);
  return service;
});

final _audioDownloadsRefreshTickProvider = StateProvider<int>((ref) => 0);

final audioDownloadOperationProvider =
    StreamProvider<AudioDownloadOperationState>((ref) async* {
  final service = ref.watch(audioDownloadsServiceProvider);
  yield service.currentOperation;
  yield* service.operationStates;
});

final audioDownloadManagerSummaryProvider =
    FutureProvider<AudioDownloadManagerSummary>((ref) async {
  ref.watch(_audioDownloadsRefreshTickProvider);
  return ref.watch(audioDownloadsServiceProvider).loadManagerSummary();
});

final audioReciterDownloadsProvider =
    FutureProvider.family<AudioReciterDownloadsDetail, int>((
  ref,
  reciterIndex,
) async {
  ref.watch(_audioDownloadsRefreshTickProvider);
  return ref
      .watch(audioDownloadsServiceProvider)
      .loadReciterDetail(reciterIndex);
});

final audioDownloadsControllerProvider = Provider<AudioDownloadsController>((
  ref,
) {
  return AudioDownloadsController(ref);
});

class AudioDownloadsController {
  AudioDownloadsController(this._ref);

  final Ref _ref;

  AudioDownloadsService get _service =>
      _ref.read(audioDownloadsServiceProvider);

  Future<void> downloadSurah({
    required int reciterIndex,
    required int surahNumber,
  }) async {
    await _service.downloadSurah(
      reciterIndex: reciterIndex,
      surahNumber: surahNumber,
    );
    _refresh();
  }

  Future<void> deleteSurah({
    required int reciterIndex,
    required int surahNumber,
  }) async {
    await _service.deleteSurah(
      reciterIndex: reciterIndex,
      surahNumber: surahNumber,
    );
    _refresh();
  }

  Future<void> cancelActiveDownload() async {
    await _service.cancelActiveDownload();
    _refresh();
  }

  void refresh() {
    _refresh();
  }

  void _refresh() {
    _ref.read(_audioDownloadsRefreshTickProvider.notifier).state += 1;
  }
}
