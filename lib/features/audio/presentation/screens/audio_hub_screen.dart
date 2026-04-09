import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_snapshot.dart';
import 'package:quran_kareem/features/audio/presentation/widgets/audio_hub_reciter_picker_sheet.dart';
import 'package:quran_kareem/features/audio/presentation/widgets/audio_hub_surah_picker_sheet.dart';
import 'package:quran_kareem/features/audio/providers/audio_providers.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

class AudioHubScreen extends ConsumerWidget {
  const AudioHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final playbackAsync = ref.watch(audioHubControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgAudioDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgAudioDark,
        title: Text(
          l10n.audioHubTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontFamily: 'Amiri',
              ),
        ),
        actions: [
          IconButton(
            key: const Key('audio-download-manager-entry'),
            tooltip: l10n.audioDownloadsOpen,
            onPressed: () => context.push('/audio/downloads'),
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: playbackAsync.when(
        loading: () => _AudioHubLoadingState(label: l10n.audioHubLoading),
        error: (error, _) => _AudioHubErrorState(
          message: l10n.audioHubLoadError,
          retryLabel: l10n.audioHubRetry,
          onRetry: () {
            ref.invalidate(audioHubControllerProvider);
          },
        ),
        data: (snapshot) => _AudioHubPlayerBody(snapshot: snapshot),
      ),
    );
  }
}

class _AudioHubPlayerBody extends ConsumerWidget {
  const _AudioHubPlayerBody({
    required this.snapshot,
  });

  final AudioHubPlaybackSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(allSurahsProvider);
    final surah = _resolveSurah(surahsAsync.valueOrNull, snapshot);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, compact ? 12 : 16, 20, 24),
            child: Column(
              children: [
                _AudioHeroCard(
                  snapshot: snapshot,
                  surah: surah,
                  compact: compact,
                ),
                SizedBox(height: compact ? 12 : 20),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _selectReciter(
                          context,
                          ref,
                          selectedReciterId: snapshot.currentReciterId,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.4),
                          ),
                        ),
                        icon: const Icon(Icons.record_voice_over_rounded),
                        label: Text(context.l10n.audioHubSelectReciter),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _selectSurah(
                          context,
                          ref,
                          selectedSurahNumber: snapshot.selectedSurahNumber,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.4),
                          ),
                        ),
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text(context.l10n.audioHubSelectSurah),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 12 : 20),
                _AudioSeekSection(snapshot: snapshot),
                SizedBox(height: compact ? 16 : 24),
                _PlaybackControls(snapshot: snapshot),
              ],
            ),
          ),
        );
      },
    );
  }

  Surah? _resolveSurah(
    List<Surah>? surahs,
    AudioHubPlaybackSnapshot snapshot,
  ) {
    if (surahs == null) {
      return null;
    }

    for (final surah in surahs) {
      if (surah.number == snapshot.selectedSurahNumber) {
        return surah;
      }
    }

    return null;
  }

  Future<void> _selectSurah(
    BuildContext context,
    WidgetRef ref, {
    required int selectedSurahNumber,
  }) async {
    final l10n = context.l10n;

    try {
      final surahs = await ref.read(allSurahsProvider.future);
      if (!context.mounted) {
        return;
      }

      final result = await showAudioHubSurahPickerSheet(
        context,
        surahs: surahs,
        selectedSurahNumber: selectedSurahNumber,
      );
      if (result == null) {
        return;
      }

      await ref
          .read(audioHubControllerProvider.notifier)
          .selectSurah(result, autoPlay: true);
    } catch (error, stackTrace) {
      AppLogger.error('AudioHubScreen._selectSurah', error, stackTrace);
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.audioHubSurahListUnavailable)),
      );
    }
  }

  Future<void> _selectReciter(
    BuildContext context,
    WidgetRef ref, {
    required String selectedReciterId,
  }) async {
    final l10n = context.l10n;
    final reciters =
        ref.read(audioHubPlaybackServiceProvider).availableReciters;
    if (reciters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.audioHubReciterListUnavailable)),
      );
      return;
    }

    try {
      final result = await showAudioHubReciterPickerSheet(
        context,
        reciters: reciters,
        selectedReciterId: selectedReciterId,
      );
      if (result == null) {
        return;
      }

      await ref.read(audioHubControllerProvider.notifier).selectReciter(result);
    } catch (error, stackTrace) {
      AppLogger.error('AudioHubScreen._selectReciter', error, stackTrace);
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.audioHubReciterChangeFailed)),
      );
    }
  }
}

class _AudioHeroCard extends StatelessWidget {
  const _AudioHeroCard({
    required this.snapshot,
    required this.surah,
    required this.compact,
  });

  final AudioHubPlaybackSnapshot snapshot;
  final Surah? surah;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF2C2416),
            Color(0xFF18140C),
          ],
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: compact ? 88 : 104,
            height: compact ? 88 : 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              size: 50,
              color: AppColors.goldGeneral,
            ),
          ),
          SizedBox(height: compact ? 12 : 18),
          Text(
            surah?.nameArabic ??
                '${l10n.audioHubSurah} ${snapshot.selectedSurahNumber}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.audioHubSurah} ${snapshot.selectedSurahNumber}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            l10n.audioHubCurrentReciter,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            snapshot.currentReciterName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          if (surah != null) ...[
            SizedBox(height: compact ? 8 : 10),
            Text(
              '${surah!.ayahCount} ${l10n.audioHubAyahs}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AudioSeekSection extends ConsumerStatefulWidget {
  const _AudioSeekSection({
    required this.snapshot,
  });

  final AudioHubPlaybackSnapshot snapshot;

  @override
  ConsumerState<_AudioSeekSection> createState() => _AudioSeekSectionState();
}

class _AudioSeekSectionState extends ConsumerState<_AudioSeekSection> {
  double? _previewValue;

  @override
  void didUpdateWidget(covariant _AudioSeekSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.snapshot.canSeek) {
      _previewValue = null;
      return;
    }

    final previewValue = _previewValue;
    if (previewValue == null) {
      return;
    }

    if (widget.snapshot.sliderValue.round() == previewValue.round()) {
      _previewValue = null;
      return;
    }

    if (previewValue > widget.snapshot.sliderMax) {
      _previewValue = widget.snapshot.sliderMax;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewValue = _previewValue;
    final sliderValue = previewValue == null
        ? widget.snapshot.sliderValue
        : previewValue.clamp(0.0, widget.snapshot.sliderMax).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.gold,
            inactiveTrackColor: Colors.white12,
            thumbColor: AppColors.goldGeneral,
            overlayColor: AppColors.gold.withValues(alpha: 0.18),
          ),
          child: Slider(
            value: sliderValue,
            max: widget.snapshot.sliderMax,
            onChanged: widget.snapshot.canSeek
                ? (value) {
                    setState(() {
                      _previewValue = value;
                    });
                  }
                : null,
            onChangeEnd: widget.snapshot.canSeek
                ? (value) async {
                    await ref
                        .read(audioHubControllerProvider.notifier)
                        .seek(Duration(milliseconds: value.round()));
                  }
                : null,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(
                Duration(milliseconds: sliderValue.round()),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            Text(
              _formatDuration(widget.snapshot.duration),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _PlaybackControls extends ConsumerWidget {
  const _PlaybackControls({
    required this.snapshot,
  });

  final AudioHubPlaybackSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: IconButton.filledTonal(
            onPressed: snapshot.hasPrevious
                ? () async {
                    await ref
                        .read(audioHubControllerProvider.notifier)
                        .playPreviousSurah();
                  }
                : null,
            tooltip: l10n.audioHubPrevious,
            icon: const Icon(Icons.skip_previous_rounded),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: snapshot.isBuffering
                ? null
                : () async {
                    await ref
                        .read(audioHubControllerProvider.notifier)
                        .togglePlayPause();
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            icon: snapshot.isBuffering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    snapshot.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
            label: Text(
              snapshot.isPlaying ? l10n.audioHubPause : l10n.audioHubPlay,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: IconButton.filledTonal(
            onPressed: snapshot.hasNext
                ? () async {
                    await ref
                        .read(audioHubControllerProvider.notifier)
                        .playNextSurah();
                  }
                : null,
            tooltip: l10n.audioHubNext,
            icon: const Icon(Icons.skip_next_rounded),
          ),
        ),
      ],
    );
  }
}

class _AudioHubLoadingState extends StatelessWidget {
  const _AudioHubLoadingState({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.goldGeneral,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _AudioHubErrorState extends StatelessWidget {
  const _AudioHubErrorState({
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
            const Icon(
              Icons.headset_off_rounded,
              size: 56,
              color: AppColors.gold,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
