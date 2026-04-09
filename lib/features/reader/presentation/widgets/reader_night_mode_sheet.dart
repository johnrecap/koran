import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';

Future<ReaderNightPresentation?> showReaderNightModeSheet({
  required BuildContext context,
  required ReaderNightPresentation currentPresentation,
}) {
  return showModalBottomSheet<ReaderNightPresentation>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return ReaderNightModeSheet(
        currentPresentation: currentPresentation,
        onSelected: (presentation) {
          Navigator.of(sheetContext).pop(presentation);
        },
      );
    },
  );
}

class ReaderNightModeSheet extends StatelessWidget {
  const ReaderNightModeSheet({
    super.key,
    required this.currentPresentation,
    required this.onSelected,
  });

  final ReaderNightPresentation currentPresentation;
  final ValueChanged<ReaderNightPresentation> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textDark : AppColors.textLight;
    final subtitleColor = isDark ? Colors.white70 : AppColors.textMuted;
    final cardColor = isDark ? AppColors.surfaceDarkNav : Colors.white;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.readerNightModeSheetTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                _ReaderNightModeOption(
                  optionKey: const ValueKey<String>('reader-night-mode-normal'),
                  label: l10n.readerNightModeNormal,
                  description: l10n.readerNightModeNormalDescription,
                  selected:
                      currentPresentation == ReaderNightPresentation.normal,
                  subtitleColor: subtitleColor,
                  onTap: () => onSelected(ReaderNightPresentation.normal),
                ),
                _ReaderNightModeOption(
                  optionKey: const ValueKey<String>('reader-night-mode-night'),
                  label: l10n.readerNightModeNight,
                  description: l10n.readerNightModeNightDescription,
                  selected: currentPresentation == ReaderNightPresentation.night,
                  subtitleColor: subtitleColor,
                  onTap: () => onSelected(ReaderNightPresentation.night),
                ),
                _ReaderNightModeOption(
                  optionKey: const ValueKey<String>('reader-night-mode-amoled'),
                  label: l10n.readerNightModeAmoled,
                  description: l10n.readerNightModeAmoledDescription,
                  selected:
                      currentPresentation == ReaderNightPresentation.amoled,
                  subtitleColor: subtitleColor,
                  onTap: () => onSelected(ReaderNightPresentation.amoled),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReaderNightModeOption extends StatelessWidget {
  const _ReaderNightModeOption({
    required this.optionKey,
    required this.label,
    required this.description,
    required this.selected,
    required this.subtitleColor,
    required this.onTap,
  });

  final Key optionKey;
  final String label;
  final String description;
  final bool selected;
  final Color subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: optionKey,
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? AppColors.gold
                    : AppColors.gold.withValues(alpha: 0.16),
              ),
              color: selected
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: subtitleColor,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected
                        ? AppColors.gold
                        : subtitleColor.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
