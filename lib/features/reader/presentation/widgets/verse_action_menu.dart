import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/arabic_digits.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';

class VerseActionMenu extends StatelessWidget {
  const VerseActionMenu({
    super.key,
    required this.ayah,
    required this.onDismiss,
    required this.onListen,
    required this.onBookmark,
    required this.onShare,
    required this.onTranslations,
    required this.onCopy,
    required this.onNote,
    required this.onTadabbur,
    required this.onInsights,
    this.onMuallimStart,
  });

  final Ayah ayah;
  final VoidCallback onDismiss;
  final VoidCallback onListen;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onTranslations;
  final VoidCallback onCopy;
  final VoidCallback onNote;
  final VoidCallback onTadabbur;
  final VoidCallback onInsights;
  final VoidCallback? onMuallimStart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkNav : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${l10n.verseActionAyah} ${_formatAyahNumber(context)}',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.92,
                        children: [
                          _ActionButton(
                            key: const ValueKey<String>('verse-action-listen'),
                            icon: Icons.headphones_rounded,
                            label: l10n.verseActionListen,
                            onTap: onListen,
                            isDark: isDark,
                          ),
                          _ActionButton(
                            key:
                                const ValueKey<String>('verse-action-insights'),
                            icon: Icons.auto_stories_rounded,
                            label: l10n.verseActionInsights,
                            onTap: onInsights,
                            isDark: isDark,
                          ),
                          _ActionButton(
                            key:
                                const ValueKey<String>('verse-action-bookmark'),
                            icon: Icons.bookmark_add_rounded,
                            label: l10n.verseActionBookmark,
                            onTap: onBookmark,
                            isDark: isDark,
                          ),
                          _ActionButton(
                            key: const ValueKey<String>('verse-action-share'),
                            icon: Icons.share_rounded,
                            label: l10n.verseActionShare,
                            onTap: onShare,
                            isDark: isDark,
                          ),
                          _ActionButton(
                            key: const ValueKey<String>(
                              'verse-action-translations',
                            ),
                            icon: Icons.translate_rounded,
                            label: l10n.verseActionTranslations,
                            onTap: onTranslations,
                            isDark: isDark,
                          ),
                          _ActionButton(
                            key: const ValueKey<String>('verse-action-copy'),
                            icon: Icons.copy_rounded,
                            label: l10n.verseActionCopy,
                            onTap: onCopy,
                            isDark: isDark,
                          ),
                          _ActionButton(
                            key: const ValueKey<String>('verse-action-note'),
                            icon: Icons.note_alt_rounded,
                            label: l10n.verseActionNote,
                            onTap: onNote,
                            isDark: isDark,
                          ),
                          _ActionButton(
                            key: const ValueKey<String>(
                              'verse-action-tadabbur',
                            ),
                            icon: Icons.self_improvement_rounded,
                            label: l10n.verseActionTadabbur,
                            onTap: onTadabbur,
                            isDark: isDark,
                          ),
                          if (onMuallimStart != null)
                            _ActionButton(
                              key: const ValueKey<String>(
                                'verse-action-muallim',
                              ),
                              icon: Icons.record_voice_over_rounded,
                              label: l10n.mushafMuallimStartFromHere,
                              onTap: onMuallimStart!,
                              isDark: isDark,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAyahNumber(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return toArabicDigits(ayah.ayahNumber);
    }
    return ayah.ayahNumber.toString();
  }

}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.camel.withValues(alpha: 0.08),
            ),
            child: Icon(icon, size: 20, color: AppColors.gold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
