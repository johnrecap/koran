import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/audio/domain/audio_download_models.dart';
import 'package:quran_kareem/features/audio/presentation/widgets/audio_download_summary_card.dart';

class ReciterDownloadSummaryTile extends StatelessWidget {
  const ReciterDownloadSummaryTile({
    super.key,
    required this.reciter,
    required this.operation,
    required this.onTap,
  });

  final AudioDownloadReciterSummary reciter;
  final AudioDownloadOperationState operation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive =
        operation.isActive && operation.reciterIndex == reciter.reciterIndex;
    final l10n = context.l10n;

    return Card(
      color: const Color(0xFF18140C),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.gold.withValues(alpha: 0.12),
          foregroundColor: AppColors.goldGeneral,
          child: Icon(
            reciter.section == AudioDownloadReciterSection.downloaded
                ? Icons.download_done_rounded
                : Icons.download_for_offline_outlined,
          ),
        ),
        title: Text(
          reciter.reciterName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontFamily: 'Amiri',
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              '${reciter.downloadedSurahCount} / 114 ${l10n.audioDownloadsSurahCount}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              '${l10n.audioDownloadsLocalSize}: ${formatDownloadBytes(reciter.totalBytes)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: operation.progress > 0 ? operation.progress : null,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.goldGeneral,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.white70,
        ),
      ),
    );
  }
}
