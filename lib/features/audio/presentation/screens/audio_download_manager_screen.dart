import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/audio/providers/audio_download_providers.dart';
import 'package:quran_kareem/features/audio/presentation/widgets/audio_download_summary_card.dart';
import 'package:quran_kareem/features/audio/presentation/widgets/reciter_download_summary_tile.dart';

class AudioDownloadManagerScreen extends ConsumerWidget {
  const AudioDownloadManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(audioDownloadManagerSummaryProvider);
    final operation = ref.watch(audioDownloadOperationProvider).valueOrNull ??
        ref.read(audioDownloadsServiceProvider).currentOperation;

    return Scaffold(
      backgroundColor: AppColors.bgAudioDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgAudioDark,
        title: Text(
          l10n.audioDownloadsTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontFamily: 'Amiri',
              ),
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => _AudioDownloadsErrorState(
          message: l10n.audioDownloadsLoadError,
          retryLabel: l10n.audioDownloadsRetry,
          onRetry: () => ref.read(audioDownloadsControllerProvider).refresh(),
        ),
        data: (summary) {
          if (!summary.isStorageSupported) {
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              AudioDownloadSummaryCard(
                summary: summary,
                operation: operation,
              ),
              const SizedBox(height: 24),
              _SectionTitle(label: l10n.audioDownloadsDownloadedSection),
              const SizedBox(height: 12),
              if (summary.downloadedReciters.isEmpty)
                _EmptySectionCard(
                    label: l10n.audioDownloadsNoDownloadedReciters)
              else
                ...summary.downloadedReciters.map(
                  (reciter) => ReciterDownloadSummaryTile(
                    reciter: reciter,
                    operation: operation,
                    onTap: () => context
                        .push('/audio/downloads/${reciter.reciterIndex}'),
                  ),
                ),
              const SizedBox(height: 24),
              _SectionTitle(label: l10n.audioDownloadsAvailableSection),
              const SizedBox(height: 12),
              if (summary.availableReciters.isEmpty)
                _EmptySectionCard(label: l10n.audioDownloadsNoAvailableReciters)
              else
                ...summary.availableReciters.map(
                  (reciter) => ReciterDownloadSummaryTile(
                    reciter: reciter,
                    operation: operation,
                    onTap: () => context
                        .push('/audio/downloads/${reciter.reciterIndex}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF18140C),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
        ),
      ),
    );
  }
}

class _AudioDownloadsErrorState extends StatelessWidget {
  const _AudioDownloadsErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
