import 'dart:async';

import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';

abstract class AudioDownloadsService {
  Stream<AudioDownloadOperationState> get operationStates;

  AudioDownloadOperationState get currentOperation;

  Future<AudioDownloadManagerSummary> loadManagerSummary();

  Future<AudioReciterDownloadsDetail> loadReciterDetail(int reciterIndex);

  Future<void> downloadSurah({
    required int reciterIndex,
    required int surahNumber,
  });

  Future<void> deleteSurah({
    required int reciterIndex,
    required int surahNumber,
  });

  Future<void> cancelActiveDownload();

  void dispose();
}
