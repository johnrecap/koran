import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';

class ReaderModeSelector extends StatelessWidget {
  const ReaderModeSelector({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  final ReaderMode currentMode;
  final ValueChanged<ReaderMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.camel.withValues(alpha: 0.12);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.gold.withValues(alpha: 0.18);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeButton(
              mode: ReaderMode.scroll,
              currentMode: currentMode,
              tooltip: context.l10n.readerModeScroll,
              icon: Icons.swipe_rounded,
              key: const ValueKey<String>('reader-mode-scroll'),
              onTap: onChanged,
            ),
            _ModeButton(
              mode: ReaderMode.page,
              currentMode: currentMode,
              tooltip: context.l10n.readerModePage,
              icon: Icons.menu_book_rounded,
              key: const ValueKey<String>('reader-mode-page'),
              onTap: onChanged,
            ),
            _ModeButton(
              mode: ReaderMode.translation,
              currentMode: currentMode,
              tooltip: context.l10n.readerModeTranslation,
              icon: Icons.translate_rounded,
              key: const ValueKey<String>('reader-mode-translation'),
              onTap: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    super.key,
    required this.mode,
    required this.currentMode,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final ReaderMode mode;
  final ReaderMode currentMode;
  final String tooltip;
  final IconData icon;
  final ValueChanged<ReaderMode> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == currentMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const selectedColor = AppColors.gold;
    final unselectedColor = isDark ? Colors.white70 : AppColors.textLight;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: isSelected ? null : () => onTap(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? selectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }
}
