import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_snapshot.dart';

class AudioMiniPlayer extends StatelessWidget {
  const AudioMiniPlayer({
    super.key,
    required this.snapshot,
    required this.onOpen,
    required this.onTogglePlayPause,
    required this.onStop,
  });

  final AudioHubPlaybackSnapshot snapshot;
  final VoidCallback onOpen;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.bgAudioDark.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onOpen,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.l10n.audioHubSurah} ${snapshot.selectedSurahNumber}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        snapshot.currentReciterName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: snapshot.isBuffering ? null : onTogglePlayPause,
              tooltip: snapshot.isPlaying
                  ? context.l10n.audioHubPause
                  : context.l10n.audioHubPlay,
              color: Colors.white,
              icon: snapshot.isBuffering
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      snapshot.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
            ),
            IconButton(
              onPressed: onStop,
              tooltip: context.l10n.audioHubStop,
              color: Colors.white70,
              icon: const Icon(Icons.close_rounded),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
