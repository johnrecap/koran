import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_library/quran_library.dart';

class AudioDownloadStoragePolicy {
  const AudioDownloadStoragePolicy();

  String buildSurahFilePath({
    required String audioRootPath,
    required ReaderInfo reciter,
    required int surahNumber,
  }) {
    final normalizedReciterPath =
        reciter.readerNamePath.replaceAll('\\', '/').split('/');
    final relativeSegments = normalizedReciterPath.where((part) {
      return part.isNotEmpty;
    }).toList();

    return path.joinAll(
      <String>[
        audioRootPath,
        ...relativeSegments,
        '${surahNumber.toString().padLeft(3, '0')}.mp3',
      ],
    );
  }

  Future<AudioDownloadManagerSummary> buildManagerSummary({
    required String audioRootPath,
    required List<ReaderInfo> reciters,
  }) async {
    final downloaded = <AudioDownloadReciterSummary>[];
    final available = <AudioDownloadReciterSummary>[];

    for (final reciter in reciters) {
      var downloadedSurahCount = 0;
      var totalBytes = 0;

      for (var surahNumber = 1; surahNumber <= 114; surahNumber += 1) {
        final file = File(
          buildSurahFilePath(
            audioRootPath: audioRootPath,
            reciter: reciter,
            surahNumber: surahNumber,
          ),
        );

        if (!await _isValidDownloadedFile(file)) {
          continue;
        }

        downloadedSurahCount += 1;
        totalBytes += await file.length();
      }

      final summary = AudioDownloadReciterSummary(
        reciterIndex: reciter.index,
        reciterName: reciter.name,
        readerNamePath: reciter.readerNamePath,
        downloadedSurahCount: downloadedSurahCount,
        totalBytes: totalBytes,
        section: downloadedSurahCount > 0
            ? AudioDownloadReciterSection.downloaded
            : AudioDownloadReciterSection.available,
      );

      if (summary.section == AudioDownloadReciterSection.downloaded) {
        downloaded.add(summary);
      } else {
        available.add(summary);
      }
    }

    return AudioDownloadManagerSummary(
      downloadedReciters: downloaded,
      availableReciters: available,
    );
  }

  Future<bool> _isValidDownloadedFile(File file) async {
    try {
      if (!await file.exists()) {
        return false;
      }

      return await file.length() > 0;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AudioDownloadStoragePolicy._isValidDownloadedFile',
        error,
        stackTrace,
      );
      return false;
    }
  }
}
