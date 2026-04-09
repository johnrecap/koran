import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_kareem/features/audio/presentation/screens/audio_reciter_downloads_screen.dart';
import 'package:quran_kareem/features/audio/providers/audio_download_providers.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

import 'audio_download_manager_screen_test.dart';

void main() {
  testWidgets('renders surah states and delegates row actions', (tester) async {
    final service = FakeAudioDownloadsService(
      summary: const AudioDownloadManagerSummary(
        downloadedReciters: [
          AudioDownloadReciterSummary(
            reciterIndex: 1,
            reciterName: 'Reader A',
            readerNamePath: 'reader-a/',
            downloadedSurahCount: 2,
            totalBytes: 32,
            section: AudioDownloadReciterSection.downloaded,
          ),
        ],
        availableReciters: [],
      ),
      detail: const AudioReciterDownloadsDetail(
        reciter: AudioDownloadReciterSummary(
          reciterIndex: 1,
          reciterName: 'Reader A',
          readerNamePath: 'reader-a/',
          downloadedSurahCount: 2,
          totalBytes: 32,
          section: AudioDownloadReciterSection.downloaded,
        ),
        items: [
          SurahDownloadItem(
            surahNumber: 1,
            state: SurahDownloadItemState.downloaded,
            localBytes: 16,
          ),
          SurahDownloadItem(
            surahNumber: 2,
            state: SurahDownloadItemState.available,
            localBytes: 0,
          ),
          SurahDownloadItem(
            surahNumber: 3,
            state: SurahDownloadItemState.failed,
            localBytes: 0,
          ),
        ],
        isStorageSupported: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioDownloadsServiceProvider.overrideWithValue(service),
          allSurahsProvider.overrideWith((ref) async => _surahs),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: AudioReciterDownloadsScreen(reciterIndex: 1),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('الفاتحة'), findsOneWidget);
    expect(find.text('البقرة'), findsOneWidget);
    expect(find.text('آل عمران'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}

const _surahs = <Surah>[
  Surah(
    number: 1,
    nameArabic: 'الفاتحة',
    nameEnglish: 'Al-Fatihah',
    nameTransliteration: 'Al-Fatihah',
    ayahCount: 7,
    revelationType: 'Meccan',
    page: 1,
  ),
  Surah(
    number: 2,
    nameArabic: 'البقرة',
    nameEnglish: 'Al-Baqarah',
    nameTransliteration: 'Al-Baqarah',
    ayahCount: 286,
    revelationType: 'Medinan',
    page: 2,
  ),
  Surah(
    number: 3,
    nameArabic: 'آل عمران',
    nameEnglish: 'Ali Imran',
    nameTransliteration: 'Ali Imran',
    ayahCount: 200,
    revelationType: 'Medinan',
    page: 50,
  ),
];
