import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

/// Right-side drawer showing all 114 Surahs for quick navigation.
class SurahDrawer extends ConsumerWidget {
  final void Function(Surah surah)? onSurahSelected;
  final ReaderNightPalette? palette;

  const SurahDrawer({
    super.key,
    this.onSurahSelected,
    this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedPalette = palette ??
        ReaderNightPresentationPolicy.paletteFor(
          presentation: ReaderNightPresentation.normal,
          appBrightness: Theme.of(context).brightness,
        );
    final surahsAsync = ref.watch(surahsProvider);
    final currentSurah = ref.watch(currentSurahProvider);
    final l10n = context.l10n;

    return Drawer(
      backgroundColor: resolvedPalette.drawerBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: resolvedPalette.drawerHeaderColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 36,
                    color: AppColors.gold,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.readerSurahList,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: resolvedPalette.drawerHeaderTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '114 ${l10n.readerSurahCountLabel}',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: resolvedPalette.drawerHeaderSubtitleColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Surah List ───
            Expanded(
              child: surahsAsync.when(
                data: (surahs) => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: surahs.length,
                  itemBuilder: (context, index) {
                    final surah = surahs[index];
                    final isActive = surah.number == currentSurah;

                    return _SurahDrawerTile(
                      surah: surah,
                      isActive: isActive,
                      palette: resolvedPalette,
                      countLabel: l10n.readerSurahCountLabel,
                      onTap: () {
                        ref.read(currentSurahProvider.notifier).state =
                            surah.number;
                        Navigator.of(context).pop();
                        onSurahSelected?.call(surah);
                      },
                    );
                  },
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.gold,
                    strokeWidth: 2,
                  ),
                ),
                error: (_, __) => Center(
                  child: Text(
                    l10n.readerSurahLoadError,
                    style: TextStyle(color: resolvedPalette.textColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahDrawerTile extends StatelessWidget {
  final Surah surah;
  final bool isActive;
  final ReaderNightPalette palette;
  final String countLabel;
  final VoidCallback onTap;

  const _SurahDrawerTile({
    required this.surah,
    required this.isActive,
    required this.palette,
    required this.countLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.gold.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.gold
                : palette.drawerTileBadgeColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${surah.number}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : palette.textColor,
              ),
            ),
          ),
        ),
        title: Text(
          surah.nameArabic,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.gold : palette.textColor,
          ),
        ),
        subtitle: Text(
          '${surah.nameEnglish} • ${surah.ayahCount} $countLabel',
          style: TextStyle(
            fontSize: 11,
            color: palette.mutedTextColor,
          ),
        ),
        trailing: isActive
            ? const Icon(Icons.arrow_back_ios_rounded,
                size: 14, color: AppColors.gold)
            : null,
        onTap: onTap,
      ),
    );
  }
}
