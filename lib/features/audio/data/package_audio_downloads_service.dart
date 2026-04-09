import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/audio/data/audio_downloads_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_storage_policy.dart';
import 'package:quran_library/quran_library.dart';

class PackageAudioDownloadsService implements AudioDownloadsService {
  PackageAudioDownloadsService({
    AudioDownloadStoragePolicy storagePolicy =
        const AudioDownloadStoragePolicy(),
    AudioCtrl? audioCtrl,
    List<ReaderInfo>? supportedReciters,
    Future<String> Function()? audioRootPathResolver,
    Future<void> Function(int reciterIndex)? refreshPackageStatus,
    http.Client Function()? httpClientFactory,
  })  : _storagePolicy = storagePolicy,
        _audioCtrl = audioCtrl,
        _supportedReciters = supportedReciters,
        _audioRootPathResolver = audioRootPathResolver,
        _refreshPackageStatusOverride = refreshPackageStatus,
        _httpClientFactory = httpClientFactory;

  final AudioDownloadStoragePolicy _storagePolicy;
  final AudioCtrl? _audioCtrl;
  final List<ReaderInfo>? _supportedReciters;
  final Future<String> Function()? _audioRootPathResolver;
  final Future<void> Function(int reciterIndex)? _refreshPackageStatusOverride;
  final http.Client Function()? _httpClientFactory;
  final StreamController<AudioDownloadOperationState> _operationController =
      StreamController<AudioDownloadOperationState>.broadcast();

  AudioDownloadOperationState _currentOperation =
      const AudioDownloadOperationState.idle();
  http.Client? _activeClient;
  bool _cancelRequested = false;

  @override
  Stream<AudioDownloadOperationState> get operationStates =>
      _operationController.stream;

  @override
  AudioDownloadOperationState get currentOperation => _currentOperation;

  @override
  Future<AudioDownloadManagerSummary> loadManagerSummary() async {
    if (kIsWeb) {
      return AudioDownloadManagerSummary(
        downloadedReciters: const [],
        availableReciters: _buildUnsupportedReciters(),
        isStorageSupported: false,
      );
    }

    final audioRootPath = await _resolveAudioRootPath();
    return _storagePolicy.buildManagerSummary(
      audioRootPath: audioRootPath,
      reciters: _reciters,
    );
  }

  @override
  Future<AudioReciterDownloadsDetail> loadReciterDetail(
      int reciterIndex) async {
    final reciter = _resolveReciter(reciterIndex);
    if (kIsWeb) {
      return AudioReciterDownloadsDetail(
        reciter: AudioDownloadReciterSummary(
          reciterIndex: reciter.index,
          reciterName: reciter.name,
          readerNamePath: reciter.readerNamePath,
          downloadedSurahCount: 0,
          totalBytes: 0,
          section: AudioDownloadReciterSection.available,
        ),
        items: List<SurahDownloadItem>.generate(
          114,
          (index) => SurahDownloadItem(
            surahNumber: index + 1,
            state: SurahDownloadItemState.available,
            localBytes: 0,
          ),
        ),
        isStorageSupported: false,
      );
    }

    final audioRootPath = await _resolveAudioRootPath();
    final summary = (await _storagePolicy.buildManagerSummary(
      audioRootPath: audioRootPath,
      reciters: _reciters,
    ))
        .reciterByIndex(reciterIndex);

    final items = <SurahDownloadItem>[];
    for (var surahNumber = 1; surahNumber <= 114; surahNumber += 1) {
      final file = File(
        _storagePolicy.buildSurahFilePath(
          audioRootPath: audioRootPath,
          reciter: reciter,
          surahNumber: surahNumber,
        ),
      );
      final localBytes = await _safeFileLength(file);
      final state = _resolveItemState(
        reciterIndex: reciterIndex,
        surahNumber: surahNumber,
        localBytes: localBytes,
      );

      items.add(
        SurahDownloadItem(
          surahNumber: surahNumber,
          state: state,
          localBytes: localBytes,
        ),
      );
    }

    return AudioReciterDownloadsDetail(
      reciter: summary,
      items: items,
      isStorageSupported: true,
    );
  }

  @override
  Future<void> downloadSurah({
    required int reciterIndex,
    required int surahNumber,
  }) async {
    if (kIsWeb) {
      _emitOperation(
        AudioDownloadOperationState(
          status: AudioDownloadOperationStatus.failed,
          reciterIndex: reciterIndex,
          surahNumber: surahNumber,
          errorMessage: 'Offline storage is not supported on web.',
        ),
      );
      return;
    }

    if (_currentOperation.isActive &&
        (_currentOperation.reciterIndex != reciterIndex ||
            _currentOperation.surahNumber != surahNumber)) {
      throw StateError('Another audio download is already in progress.');
    }

    final reciter = _resolveReciter(reciterIndex);
    final audioRootPath = await _resolveAudioRootPath();
    final filePath = _storagePolicy.buildSurahFilePath(
      audioRootPath: audioRootPath,
      reciter: reciter,
      surahNumber: surahNumber,
    );
    final partialPath = '$filePath.part';
    final finalFile = File(filePath);
    final partialFile = File(partialPath);
    final url =
        '${reciter.url}${reciter.readerNamePath}${surahNumber.toString().padLeft(3, '0')}.mp3';

    _cancelRequested = false;
    _emitOperation(
      AudioDownloadOperationState(
        status: AudioDownloadOperationStatus.downloading,
        reciterIndex: reciterIndex,
        surahNumber: surahNumber,
      ),
    );

    try {
      if (await partialFile.exists()) {
        await partialFile.delete();
      }
      await partialFile.parent.create(recursive: true);

      final client = _httpClientFactory?.call() ?? http.Client();
      _activeClient = client;
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Unexpected status code ${response.statusCode}.',
          uri: Uri.parse(url),
        );
      }

      final sink = partialFile.openWrite();
      try {
        var receivedBytes = 0;
        final totalBytes = response.contentLength ?? 0;

        await for (final chunk in response.stream) {
          if (_cancelRequested) {
            throw const _AudioDownloadCanceled();
          }

          sink.add(chunk);
          receivedBytes += chunk.length;
          _emitOperation(
            AudioDownloadOperationState(
              status: AudioDownloadOperationStatus.downloading,
              reciterIndex: reciterIndex,
              surahNumber: surahNumber,
              receivedBytes: receivedBytes,
              totalBytes: totalBytes,
              progress: totalBytes > 0 ? receivedBytes / totalBytes : 0,
            ),
          );
        }
      } finally {
        await sink.close();
      }

      if (_cancelRequested) {
        throw const _AudioDownloadCanceled();
      }

      if (!await partialFile.exists() || await partialFile.length() <= 0) {
        throw const HttpException('Downloaded audio file is empty.');
      }

      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await partialFile.rename(filePath);
      await _refreshPackageStatus(reciterIndex);
      _emitOperation(
        AudioDownloadOperationState(
          status: AudioDownloadOperationStatus.completed,
          reciterIndex: reciterIndex,
          surahNumber: surahNumber,
          progress: 1,
          receivedBytes: await finalFile.length(),
          totalBytes: await finalFile.length(),
        ),
      );
    } on _AudioDownloadCanceled {
      await _deleteIfExists(partialFile);
      _emitOperation(
        AudioDownloadOperationState(
          status: AudioDownloadOperationStatus.canceled,
          reciterIndex: reciterIndex,
          surahNumber: surahNumber,
        ),
      );
    } catch (error) {
      if (_cancelRequested) {
        await _deleteIfExists(partialFile);
        _emitOperation(
          AudioDownloadOperationState(
            status: AudioDownloadOperationStatus.canceled,
            reciterIndex: reciterIndex,
            surahNumber: surahNumber,
          ),
        );
        return;
      }
      await _deleteIfExists(partialFile);
      _emitOperation(
        AudioDownloadOperationState(
          status: AudioDownloadOperationStatus.failed,
          reciterIndex: reciterIndex,
          surahNumber: surahNumber,
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    } finally {
      _activeClient?.close();
      _activeClient = null;
      _cancelRequested = false;
    }
  }

  @override
  Future<void> deleteSurah({
    required int reciterIndex,
    required int surahNumber,
  }) async {
    if (kIsWeb) {
      return;
    }

    final reciter = _resolveReciter(reciterIndex);
    final audioRootPath = await _resolveAudioRootPath();
    final filePath = _storagePolicy.buildSurahFilePath(
      audioRootPath: audioRootPath,
      reciter: reciter,
      surahNumber: surahNumber,
    );
    await _deleteIfExists(File(filePath));
    await _refreshPackageStatus(reciterIndex);
  }

  @override
  Future<void> cancelActiveDownload() async {
    if (!_currentOperation.isActive) {
      return;
    }

    _cancelRequested = true;
    _activeClient?.close();
  }

  @override
  void dispose() {
    _activeClient?.close();
    _operationController.close();
  }

  Future<String> _resolveAudioRootPath() async {
    if (_audioRootPathResolver != null) {
      return _audioRootPathResolver();
    }
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  ReaderInfo _resolveReciter(int reciterIndex) {
    for (final reciter in _reciters) {
      if (reciter.index == reciterIndex) {
        return reciter;
      }
    }

    throw StateError('Reciter $reciterIndex is not supported.');
  }

  List<AudioDownloadReciterSummary> _buildUnsupportedReciters() {
    return List<AudioDownloadReciterSummary>.unmodifiable(
      _reciters.map(
        (reciter) => AudioDownloadReciterSummary(
          reciterIndex: reciter.index,
          reciterName: reciter.name,
          readerNamePath: reciter.readerNamePath,
          downloadedSurahCount: 0,
          totalBytes: 0,
          section: AudioDownloadReciterSection.available,
        ),
      ),
    );
  }

  SurahDownloadItemState _resolveItemState({
    required int reciterIndex,
    required int surahNumber,
    required int localBytes,
  }) {
    if (_currentOperation.reciterIndex == reciterIndex &&
        _currentOperation.surahNumber == surahNumber) {
      switch (_currentOperation.status) {
        case AudioDownloadOperationStatus.downloading:
          return SurahDownloadItemState.downloading;
        case AudioDownloadOperationStatus.failed:
          return SurahDownloadItemState.failed;
        case AudioDownloadOperationStatus.idle:
        case AudioDownloadOperationStatus.completed:
        case AudioDownloadOperationStatus.canceled:
          break;
      }
    }

    if (localBytes > 0) {
      return SurahDownloadItemState.downloaded;
    }

    return SurahDownloadItemState.available;
  }

  Future<int> _safeFileLength(File file) async {
    try {
      if (!await file.exists()) {
        return 0;
      }

      final length = await file.length();
      return length > 0 ? length : 0;
    } catch (error, stackTrace) {
      AppLogger.error(
        'PackageAudioDownloadsService._safeFileLength',
        error,
        stackTrace,
      );
      return 0;
    }
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _refreshPackageStatus(int reciterIndex) async {
    if (_refreshPackageStatusOverride != null) {
      await _refreshPackageStatusOverride(reciterIndex);
      return;
    }
    if (kIsWeb) {
      return;
    }

    final audioCtrl = _audioCtrl ?? AudioCtrl.instance;
    final currentReaderIndex = audioCtrl.state.surahReaderIndex.value;
    if (currentReaderIndex == reciterIndex) {
      await audioCtrl.initializeSurahDownloadStatus();
      return;
    }

    final previousIndex = currentReaderIndex;
    audioCtrl.state.surahReaderIndex.value = reciterIndex;
    try {
      await audioCtrl.initializeSurahDownloadStatus();
    } finally {
      audioCtrl.state.surahReaderIndex.value = previousIndex;
    }
  }

  void _emitOperation(AudioDownloadOperationState state) {
    _currentOperation = state;
    if (!_operationController.isClosed) {
      _operationController.add(state);
    }
  }

  List<ReaderInfo> get _reciters =>
      _supportedReciters ?? ReadersConstants.activeSurahReaders;
}

class _AudioDownloadCanceled implements Exception {
  const _AudioDownloadCanceled();
}
