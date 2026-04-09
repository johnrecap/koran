enum AudioDownloadReciterSection {
  downloaded,
  available,
}

enum AudioDownloadOperationStatus {
  idle,
  downloading,
  completed,
  failed,
  canceled,
}

enum SurahDownloadItemState {
  available,
  downloaded,
  downloading,
  failed,
}

class AudioDownloadReciterSummary {
  const AudioDownloadReciterSummary({
    required this.reciterIndex,
    required this.reciterName,
    required this.readerNamePath,
    required this.downloadedSurahCount,
    required this.totalBytes,
    required this.section,
  });

  final int reciterIndex;
  final String reciterName;
  final String readerNamePath;
  final int downloadedSurahCount;
  final int totalBytes;
  final AudioDownloadReciterSection section;

  bool get isFullyDownloaded => downloadedSurahCount >= 114;

  bool get isPartiallyDownloaded =>
      downloadedSurahCount > 0 && !isFullyDownloaded;
}

class AudioDownloadManagerSummary {
  const AudioDownloadManagerSummary({
    required this.downloadedReciters,
    required this.availableReciters,
    this.isStorageSupported = true,
  });

  final List<AudioDownloadReciterSummary> downloadedReciters;
  final List<AudioDownloadReciterSummary> availableReciters;
  final bool isStorageSupported;

  int get totalBytes => downloadedReciters.fold<int>(
        0,
        (sum, reciter) => sum + reciter.totalBytes,
      );

  AudioDownloadReciterSummary reciterByIndex(int reciterIndex) {
    for (final reciter in downloadedReciters) {
      if (reciter.reciterIndex == reciterIndex) {
        return reciter;
      }
    }
    for (final reciter in availableReciters) {
      if (reciter.reciterIndex == reciterIndex) {
        return reciter;
      }
    }

    throw StateError('Reciter $reciterIndex is not part of this summary.');
  }
}

class AudioDownloadOperationState {
  const AudioDownloadOperationState({
    required this.status,
    this.reciterIndex,
    this.surahNumber,
    this.progress = 0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.errorMessage,
  });

  const AudioDownloadOperationState.idle()
      : this(
          status: AudioDownloadOperationStatus.idle,
        );

  final AudioDownloadOperationStatus status;
  final int? reciterIndex;
  final int? surahNumber;
  final double progress;
  final int receivedBytes;
  final int totalBytes;
  final String? errorMessage;

  bool get isActive => status == AudioDownloadOperationStatus.downloading;

  AudioDownloadOperationState copyWith({
    AudioDownloadOperationStatus? status,
    int? reciterIndex,
    int? surahNumber,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AudioDownloadOperationState(
      status: status ?? this.status,
      reciterIndex: reciterIndex ?? this.reciterIndex,
      surahNumber: surahNumber ?? this.surahNumber,
      progress: progress ?? this.progress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SurahDownloadItem {
  const SurahDownloadItem({
    required this.surahNumber,
    required this.state,
    required this.localBytes,
  });

  final int surahNumber;
  final SurahDownloadItemState state;
  final int localBytes;

  bool get isDownloaded => state == SurahDownloadItemState.downloaded;
}

class AudioReciterDownloadsDetail {
  const AudioReciterDownloadsDetail({
    required this.reciter,
    required this.items,
    required this.isStorageSupported,
  });

  final AudioDownloadReciterSummary reciter;
  final List<SurahDownloadItem> items;
  final bool isStorageSupported;
}
