import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/arabic_digits.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';

class MuallimPlaybackControls extends StatelessWidget {
  const MuallimPlaybackControls({
    super.key,
    required this.snapshot,
    required this.onPreviousAyah,
    required this.onPrimaryAction,
    required this.onNextAyah,
    required this.onStop,
    required this.onSelectReciter,
  });

  final MuallimSnapshot snapshot;
  final VoidCallback onPreviousAyah;
  final VoidCallback onPrimaryAction;
  final VoidCallback onNextAyah;
  final VoidCallback onStop;
  final VoidCallback onSelectReciter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryIcon = snapshot.playbackState == MuallimPlaybackState.playing
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;
    final primaryTooltip = snapshot.playbackState == MuallimPlaybackState.playing
        ? context.l10n.audioHubPause
        : context.l10n.audioHubPlay;
    final reciterLabel = snapshot.currentReciterName.isNotEmpty
        ? snapshot.currentReciterName
        : context.l10n.audioHubSelectReciter;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: isDark ? AppColors.surfaceDarkNav : Colors.white,
          elevation: 10,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.mushafMuallimCurrentAyah,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _buildAyahLabel(context),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Amiri',
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      key: const ValueKey<String>('muallim-reciter'),
                      onPressed: onSelectReciter,
                      icon: const Icon(Icons.mic_rounded),
                      label: Text(reciterLabel),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      key: const ValueKey<String>('muallim-prev'),
                      tooltip: context.l10n.audioHubPrevious,
                      onPressed: onPreviousAyah,
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    FilledButton(
                      key: const ValueKey<String>('muallim-primary'),
                      onPressed: onPrimaryAction,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(18),
                      ),
                      child: Icon(primaryIcon, semanticLabel: primaryTooltip),
                    ),
                    IconButton(
                      key: const ValueKey<String>('muallim-next'),
                      tooltip: context.l10n.audioHubNext,
                      onPressed: onNextAyah,
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                    IconButton(
                      key: const ValueKey<String>('muallim-stop'),
                      tooltip: context.l10n.audioHubStop,
                      onPressed: onStop,
                      icon: const Icon(Icons.stop_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildAyahLabel(BuildContext context) {
    final currentAyah = snapshot.currentAyah;
    if (currentAyah == null) {
      return '--';
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final surah = isArabic
        ? toArabicDigits(currentAyah.surahNumber)
        : currentAyah.surahNumber.toString();
    final ayah = isArabic
        ? toArabicDigits(currentAyah.ayahNumber)
        : currentAyah.ayahNumber.toString();
    return '$surah:$ayah';
  }
}
