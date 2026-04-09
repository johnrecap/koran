import 'package:flutter/material.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_kareem/features/audio/presentation/widgets/audio_download_summary_card.dart';

class SurahDownloadStatusTile extends StatelessWidget {
  const SurahDownloadStatusTile({
    super.key,
    required this.label,
    required this.item,
    required this.operation,
    required this.onDownload,
    required this.onDelete,
    required this.onCancel,
  });

  final String label;
  final SurahDownloadItem item;
  final AudioDownloadOperationState operation;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      color: const Color(0xFF18140C),
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontFamily: 'Amiri',
              ),
        ),
        subtitle: Text(
          '${_statusLabel(l10n, item.state)} • ${formatDownloadBytes(item.localBytes)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        trailing: _buildTrailing(context),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final l10n = context.l10n;
    switch (item.state) {
      case SurahDownloadItemState.downloaded:
        return TextButton(
          onPressed: onDelete,
          child: Text(l10n.audioDownloadsDelete),
        );
      case SurahDownloadItemState.available:
        return TextButton(
          onPressed: onDownload,
          child: Text(l10n.audioDownloadsDownload),
        );
      case SurahDownloadItemState.failed:
        return TextButton(
          onPressed: onDownload,
          child: Text(l10n.audioDownloadsRetry),
        );
      case SurahDownloadItemState.downloading:
        return SizedBox(
          width: 112,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LinearProgressIndicator(
                value: operation.progress > 0 ? operation.progress : null,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onCancel,
                child: Text(l10n.audioDownloadsCancel),
              ),
            ],
          ),
        );
    }
  }

  String _statusLabel(AppLocalizations l10n, SurahDownloadItemState state) {
    switch (state) {
      case SurahDownloadItemState.available:
        return l10n.audioDownloadsStatusAvailable;
      case SurahDownloadItemState.downloaded:
        return l10n.audioDownloadsStatusDownloaded;
      case SurahDownloadItemState.downloading:
        return l10n.audioDownloadsStatusDownloading;
      case SurahDownloadItemState.failed:
        return l10n.audioDownloadsStatusFailed;
    }
  }
}
