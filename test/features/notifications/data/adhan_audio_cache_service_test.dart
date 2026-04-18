import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/notifications/data/adhan_audio_cache_service.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_muezzin.dart';

void main() {
  group('AdhanAudioCacheService', () {
    test('returns a valid cached file without downloading it again', () async {
      final tempDir = await Directory.systemTemp.createTemp('adhan-cache');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final cachedFile = File(
        '${tempDir.path}${Platform.pathSeparator}adhan${Platform.pathSeparator}${AdhanMuezzin.misharyAlafasy.cacheFileName}',
      );
      await cachedFile.parent.create(recursive: true);
      await cachedFile.writeAsBytes(const <int>[1, 2, 3]);

      var requests = 0;
      final service = AdhanAudioCacheService(
        documentsDirectoryResolver: () async => tempDir,
        httpClientFactory: () {
          requests += 1;
          throw UnimplementedError(
              'network should not be hit for cached files');
        },
      );

      final restored = await service.getOrDownload(
        AdhanMuezzin.misharyAlafasy,
      );

      expect(restored.path, cachedFile.path);
      expect(await restored.readAsBytes(), const <int>[1, 2, 3]);
      expect(requests, 0);
    });

    test('downloads and stores adhan audio when no cached file exists',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('adhan-cache');
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
        request.response.add(const <int>[4, 5, 6, 7]);
        await request.response.close();
      });

      final service = AdhanAudioCacheService(
        documentsDirectoryResolver: () async => tempDir,
        urlResolver: (_) =>
            'http://${server.address.host}:${server.port}/adhan',
      );

      final file = await service.getOrDownload(AdhanMuezzin.mansourAlZahrani);

      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), const <int>[4, 5, 6, 7]);
      expect(
        file.path,
        '${tempDir.path}${Platform.pathSeparator}adhan${Platform.pathSeparator}${AdhanMuezzin.mansourAlZahrani.cacheFileName}',
      );
      expect(
        await service.cachedFilePathFor(AdhanMuezzin.mansourAlZahrani),
        file.path,
      );
    });

    test('deletes one cached adhan file and can clear the whole cache',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('adhan-cache');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final service = AdhanAudioCacheService(
        documentsDirectoryResolver: () async => tempDir,
      );

      final firstFile = File(
        '${tempDir.path}${Platform.pathSeparator}adhan${Platform.pathSeparator}${AdhanMuezzin.misharyAlafasy.cacheFileName}',
      );
      final secondFile = File(
        '${tempDir.path}${Platform.pathSeparator}adhan${Platform.pathSeparator}${AdhanMuezzin.ahmedAlNafis.cacheFileName}',
      );
      await firstFile.parent.create(recursive: true);
      await firstFile.writeAsBytes(const <int>[1]);
      await secondFile.writeAsBytes(const <int>[2]);

      await service.deleteCached(AdhanMuezzin.misharyAlafasy);

      expect(await firstFile.exists(), isFalse);
      expect(await secondFile.exists(), isTrue);

      await service.clearAll();

      expect(await secondFile.exists(), isFalse);
    });
  });
}
