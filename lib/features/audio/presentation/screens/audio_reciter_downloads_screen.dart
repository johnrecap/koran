import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_kareem/features/audio/providers/audio_download_providers.dart';
import 'package:quran_kareem/features/audio/presentation/widgets/surah_download_status_tile.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

class AudioReciterDownloadsScreen extends ConsumerWidget {
  const AudioReciterDownloadsScreen({
    super.key,
    required this.reciterIndex,
  });

  final int reciterIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detailAsync = ref.watch(audioReciterDownloadsProvider(reciterIndex));
    final surahsAsync = ref.watch(allSurahsProvider);
    final operation = ref.watch(audioDownloadOperationProvider).valueOrNull ??
        ref.read(audioDownloadsServiceProvider).currentOperation;

    return Scaffold(
      backgroundColor: AppColors.bgAudioDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgAudioDark,
        title: detailAsync.when(
          data: (detail) => Text(
            detail.reciter.reciterName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Amiri',
                ),
          ),
          loading: () => Text(
            l10n.audioDownloadsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Amiri',
                ),
          ),
          error: (_, __) => Text(
            l10n.audioDownloadsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Amiri',
                ),
          ),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.audioDownloadsLoadError,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (detail) {
          if (!detail.isStorageSupported) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.audioDownloadsUnavailableMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontFamily: 'Amiri',
                      ),
                ),
              ),
            );
          }

          final surahs = surahsAsync.valueOrNull;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: detail.items.length,
            itemBuilder: (context, index) {
              final item = detail.items[index];
              final label = _resolveSurahLabel(
                l10n: l10n,
                surahs: surahs,
                surahNumber: item.surahNumber,
              );

              return SurahDownloadStatusTile(
                label: label,
                item: _mergeItemState(item, operation),
                operation: operation,
                onDownload: () => _runAction(
                  context,
                  ref,
                  () =>
                      ref.read(audioDownloadsControllerProvider).downloadSurah(
                            reciterIndex: reciterIndex,
                            surahNumber: item.surahNumber,
                          ),
                ),
                onDelete: () => _runAction(
                  context,
                  ref,
                  () => ref.read(audioDownloadsControllerProvider).deleteSurah(
                        reciterIndex: reciterIndex,
                        surahNumber: item.surahNumber,
                      ),
                ),
                onCancel: () => _runAction(
                  context,
                  ref,
                  () => ref
                      .read(audioDownloadsControllerProvider)
                      .cancelActiveDownload(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _resolveSurahLabel({
    required AppLocalizations l10n,
    required List<Surah>? surahs,
    required int surahNumber,
  }) {
    if (surahs != null) {
      for (final surah in surahs) {
        if (surah.number == surahNumber) {
          return surah.nameArabic;
        }
      }
    }

    return '${l10n.audioHubSurah} $surahNumber';
  }

  SurahDownloadItem _mergeItemState(
    SurahDownloadItem item,
    AudioDownloadOperationState operation,
  ) {
    if (operation.reciterIndex != reciterIndex ||
        operation.surahNumber != item.surahNumber) {
      return item;
    }

    switch (operation.status) {
      case AudioDownloadOperationStatus.downloading:
        return SurahDownloadItem(
          surahNumber: item.surahNumber,
          state: SurahDownloadItemState.downloading,
          localBytes: item.localBytes,
        );
      case AudioDownloadOperationStatus.failed:
        return SurahDownloadItem(
          surahNumber: item.surahNumber,
          state: SurahDownloadItemState.failed,
          localBytes: item.localBytes,
        );
      case AudioDownloadOperationStatus.idle:
      case AudioDownloadOperationStatus.completed:
      case AudioDownloadOperationStatus.canceled:
        return item;
    }
  }

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      AppLogger.error(
        'AudioReciterDownloadsScreen._runAction',
        error,
        stackTrace,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.audioDownloadsActionFailed),
        ),
      );
    }
  }
}
