import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/audio/data/package_audio_downloads_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('PackageAudioDownloadsService', () {
    test('classifies reciters from local surah files', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'audio-downloads-service',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final service = PackageAudioDownloadsService(
        supportedReciters: const [_partialReciter, _availableReciter],
        audioRootPathResolver: () async => tempDir.path,
        refreshPackageStatus: (_) async {},
      );

      final downloadedFile = File(
        '${tempDir.path}${Platform.pathSeparator}partial${Platform.pathSeparator}002.mp3',
      );
      await downloadedFile.parent.create(recursive: true);
      await downloadedFile.writeAsBytes(List<int>.filled(8, 1));

      final ignoredZeroByteFile = File(
        '${tempDir.path}${Platform.pathSeparator}partial${Platform.pathSeparator}003.mp3',
      );
      await ignoredZeroByteFile.writeAsBytes(const <int>[]);

      final summary = await service.loadManagerSummary();

      expect(summary.downloadedReciters, hasLength(1));
      expect(summary.availableReciters, hasLength(1));
      expect(summary.reciterByIndex(_partialReciter.index).downloadedSurahCount,
          1);
      expect(summary.reciterByIndex(_partialReciter.index).totalBytes, 8);
      expect(summary.reciterByIndex(_availableReciter.index).section,
          AudioDownloadReciterSection.available);
    });

    test('downloads a surah file and refreshes package status', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'audio-downloads-service',
      );
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async {
        await server.close(force: true);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      server.listen((request) async {
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentLength = 4;
        request.response.add(const <int>[1, 2, 3, 4]);
        await request.response.close();
      });

      var refreshCount = 0;
      final service = PackageAudioDownloadsService(
        supportedReciters: [
          _partialReciter.copyWith(
            url: 'http://${server.address.host}:${server.port}/audio/',
          ),
        ],
        audioRootPathResolver: () async => tempDir.path,
        refreshPackageStatus: (_) async {
          refreshCount += 1;
        },
      );

      await service.downloadSurah(
        reciterIndex: _partialReciter.index,
        surahNumber: 2,
      );

      final file = File(
        '${tempDir.path}${Platform.pathSeparator}partial${Platform.pathSeparator}002.mp3',
      );
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), const <int>[1, 2, 3, 4]);
      expect(service.currentOperation.status,
          AudioDownloadOperationStatus.completed);
      expect(refreshCount, 1);
    });

    test('retries after a failed download attempt', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'audio-downloads-service',
      );
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async {
        await server.close(force: true);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      var requests = 0;
      server.listen((request) async {
        requests += 1;
        if (requests == 1) {
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
          return;
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentLength = 3;
        request.response.add(const <int>[7, 8, 9]);
        await request.response.close();
      });

      final service = PackageAudioDownloadsService(
        supportedReciters: [
          _partialReciter.copyWith(
            url: 'http://${server.address.host}:${server.port}/audio/',
          ),
        ],
        audioRootPathResolver: () async => tempDir.path,
        refreshPackageStatus: (_) async {},
      );

      await expectLater(
        () => service.downloadSurah(
          reciterIndex: _partialReciter.index,
          surahNumber: 2,
        ),
        throwsA(isA<HttpException>()),
      );
      expect(
        service.currentOperation.status,
        AudioDownloadOperationStatus.failed,
      );

      await service.downloadSurah(
        reciterIndex: _partialReciter.index,
        surahNumber: 2,
      );

      final file = File(
        '${tempDir.path}${Platform.pathSeparator}partial${Platform.pathSeparator}002.mp3',
      );
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), const <int>[7, 8, 9]);
      expect(service.currentOperation.status,
          AudioDownloadOperationStatus.completed);
    });

    test('cancels an active download and removes partial files', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'audio-downloads-service',
      );
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async {
        await server.close(force: true);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      server.listen((request) async {
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentLength = 40;
        for (var i = 0; i < 10; i += 1) {
          request.response.add(List<int>.filled(4, i));
          await request.response.flush();
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        await request.response.close();
      });

      final service = PackageAudioDownloadsService(
        supportedReciters: [
          _partialReciter.copyWith(
            url: 'http://${server.address.host}:${server.port}/audio/',
          ),
        ],
        audioRootPathResolver: () async => tempDir.path,
        refreshPackageStatus: (_) async {},
      );

      final downloadFuture = service.downloadSurah(
        reciterIndex: _partialReciter.index,
        surahNumber: 2,
      );

      await _waitUntil(() => service.currentOperation.isActive);
      await service.cancelActiveDownload();
      await downloadFuture;

      final finalFile = File(
        '${tempDir.path}${Platform.pathSeparator}partial${Platform.pathSeparator}002.mp3',
      );
      final partialFile = File('${finalFile.path}.part');

      expect(await finalFile.exists(), isFalse);
      expect(await partialFile.exists(), isFalse);
      expect(service.currentOperation.status,
          AudioDownloadOperationStatus.canceled);
    });
  });
}

const _partialReciter = ReaderInfo(
  index: 1,
  name: 'Partial',
  readerNamePath: 'partial/',
  url: 'https://example.com/audio/',
);

const _availableReciter = ReaderInfo(
  index: 2,
  name: 'Available',
  readerNamePath: 'available/',
  url: 'https://example.com/audio/',
);

Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  throw TimeoutException('Condition was not met before timeout.');
}
