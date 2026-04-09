import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_storage_policy.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('AudioDownloadStoragePolicy', () {
    test('builds a surah file path from the reciter path and padded surah', () {
      const reciter = ReaderInfo(
        index: 4,
        name: 'Reciter A',
        readerNamePath: 'abdulBasit/murattal/mp3/',
        url: 'https://example.com/',
      );
      const policy = AudioDownloadStoragePolicy();

      final resolved = policy.buildSurahFilePath(
        audioRootPath: '/downloads',
        reciter: reciter,
        surahNumber: 1,
      );

      expect(
        resolved,
        path.join('/downloads', 'abdulBasit', 'murattal', 'mp3', '001.mp3'),
      );
    });

    test('classifies zero, partial, and full reciter download states',
        () async {
      final root = await Directory.systemTemp.createTemp(
        'audio-download-policy',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      const availableReciter = ReaderInfo(
        index: 1,
        name: 'Available',
        readerNamePath: 'available/',
        url: 'https://example.com/',
      );
      const partialReciter = ReaderInfo(
        index: 2,
        name: 'Partial',
        readerNamePath: 'partial/',
        url: 'https://example.com/',
      );
      const fullReciter = ReaderInfo(
        index: 3,
        name: 'Full',
        readerNamePath: 'full/',
        url: 'https://example.com/',
      );
      const policy = AudioDownloadStoragePolicy();

      await _writeFile(
        policy.buildSurahFilePath(
          audioRootPath: root.path,
          reciter: partialReciter,
          surahNumber: 2,
        ),
        bytes: 12,
      );
      await _writeFile(
        policy.buildSurahFilePath(
          audioRootPath: root.path,
          reciter: partialReciter,
          surahNumber: 3,
        ),
        bytes: 0,
      );

      for (var surahNumber = 1; surahNumber <= 114; surahNumber += 1) {
        await _writeFile(
          policy.buildSurahFilePath(
            audioRootPath: root.path,
            reciter: fullReciter,
            surahNumber: surahNumber,
          ),
          bytes: 4,
        );
      }

      final summary = await policy.buildManagerSummary(
        audioRootPath: root.path,
        reciters: const [
          availableReciter,
          partialReciter,
          fullReciter,
        ],
      );

      final available = summary.reciterByIndex(availableReciter.index);
      final partial = summary.reciterByIndex(partialReciter.index);
      final full = summary.reciterByIndex(fullReciter.index);

      expect(available.section, AudioDownloadReciterSection.available);
      expect(available.downloadedSurahCount, 0);
      expect(available.isFullyDownloaded, isFalse);

      expect(partial.section, AudioDownloadReciterSection.downloaded);
      expect(partial.downloadedSurahCount, 1);
      expect(partial.isPartiallyDownloaded, isTrue);
      expect(partial.totalBytes, 12);

      expect(full.section, AudioDownloadReciterSection.downloaded);
      expect(full.downloadedSurahCount, 114);
      expect(full.isFullyDownloaded, isTrue);
      expect(full.totalBytes, 456);

      expect(summary.totalBytes, 468);
      expect(summary.downloadedReciters, hasLength(2));
      expect(summary.availableReciters, hasLength(1));
    });
  });
}

Future<void> _writeFile(
  String filePath, {
  required int bytes,
}) async {
  final file = File(filePath);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(List<int>.filled(bytes, 1));
}
