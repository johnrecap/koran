import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/audio/data/audio_downloads_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_kareem/features/audio/presentation/screens/audio_download_manager_screen.dart';
import 'package:quran_kareem/features/audio/providers/audio_download_providers.dart';

void main() {
  testWidgets('renders downloaded and available reciter sections',
      (tester) async {
    final service = FakeAudioDownloadsService(
      summary: const AudioDownloadManagerSummary(
        downloadedReciters: [
          AudioDownloadReciterSummary(
            reciterIndex: 1,
            reciterName: 'Reader A',
            readerNamePath: 'reader-a/',
            downloadedSurahCount: 12,
            totalBytes: 2048,
            section: AudioDownloadReciterSection.downloaded,
          ),
        ],
        availableReciters: [
          AudioDownloadReciterSummary(
            reciterIndex: 2,
            reciterName: 'Reader B',
            readerNamePath: 'reader-b/',
            downloadedSurahCount: 0,
            totalBytes: 0,
            section: AudioDownloadReciterSection.available,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      _buildHarness(service: service),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Downloaded reciters'), findsOneWidget);
    expect(find.text('Available to download'), findsOneWidget);
    expect(find.text('Reader A'), findsOneWidget);
    expect(find.text('Reader B'), findsOneWidget);
    expect(find.textContaining('Total storage'), findsOneWidget);
  });
}

Widget _buildHarness({
  required FakeAudioDownloadsService service,
}) {
  return ProviderScope(
    overrides: [
      audioDownloadsServiceProvider.overrideWithValue(service),
    ],
    child: const MaterialApp(
      locale: Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: AudioDownloadManagerScreen(),
    ),
  );
}

class FakeAudioDownloadsService implements AudioDownloadsService {
  FakeAudioDownloadsService({
    required this.summary,
    this.detail,
    this.currentOperation = const AudioDownloadOperationState.idle(),
  });

  final AudioDownloadManagerSummary summary;
  final AudioReciterDownloadsDetail? detail;
  @override
  AudioDownloadOperationState currentOperation;

  final StreamController<AudioDownloadOperationState> _controller =
      StreamController<AudioDownloadOperationState>.broadcast();

  @override
  Stream<AudioDownloadOperationState> get operationStates => _controller.stream;

  @override
  Future<void> cancelActiveDownload() async {}

  @override
  Future<void> deleteSurah({
    required int reciterIndex,
    required int surahNumber,
  }) async {}

  @override
  Future<void> downloadSurah({
    required int reciterIndex,
    required int surahNumber,
  }) async {}

  @override
  Future<AudioReciterDownloadsDetail> loadReciterDetail(
      int reciterIndex) async {
    if (detail != null) {
      return detail!;
    }
    throw UnimplementedError();
  }

  @override
  Future<AudioDownloadManagerSummary> loadManagerSummary() async => summary;

  @override
  void dispose() {
    _controller.close();
  }
}
