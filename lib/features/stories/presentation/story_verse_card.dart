import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/stories/domain/story_verse.dart';

class StoryVerseCard extends ConsumerWidget {
  const StoryVerseCard({
    super.key,
    required this.verse,
    this.onTap,
  });

  final StoryVerse verse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final referenceText = ref.watch(surahsProvider).maybeWhen(
          data: (surahs) => _buildReferenceText(
            context: context,
            localizations: localizations,
            surahs: surahs,
            locale: locale,
          ),
          orElse: () => _buildReferenceText(
            context: context,
            localizations: localizations,
            surahs: const <Surah>[],
            locale: locale,
          ),
        );

    return Tooltip(
      message: context.l10n.storiesOpenInReader,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key(
            'story-verse-card-${verse.surah}-${verse.ayahStart}-${verse.ayahEnd}',
          ),
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDarkNav : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: isDark ? 0.45 : 0.38),
                width: 1.5,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    verse.textAr,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 23,
                      height: 1.8,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    referenceText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                  if (verse.contextAr.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      verse.contextAr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildReferenceText({
    required BuildContext context,
    required MaterialLocalizations localizations,
    required List<Surah> surahs,
    required Locale locale,
  }) {
    final surahName = _resolveSurahName(
      surahs: surahs,
      locale: locale,
      localizations: localizations,
    );
    final ayahLabel = verse.isRange
        ? '${localizations.formatDecimal(verse.ayahStart)}-'
            '${localizations.formatDecimal(verse.ayahEnd)}'
        : localizations.formatDecimal(verse.ayahStart);

    return '${context.l10n.surahPrefix} $surahName: $ayahLabel';
  }

  String _resolveSurahName({
    required List<Surah> surahs,
    required Locale locale,
    required MaterialLocalizations localizations,
  }) {
    for (final surah in surahs) {
      if (surah.number != verse.surah) {
        continue;
      }

      if (locale.languageCode == 'en') {
        if (surah.nameEnglish.trim().isNotEmpty) {
          return surah.nameEnglish;
        }
        if (surah.nameTransliteration.trim().isNotEmpty) {
          return surah.nameTransliteration;
        }
      }

      if (surah.nameArabic.trim().isNotEmpty) {
        return surah.nameArabic;
      }
    }

    return localizations.formatDecimal(verse.surah);
  }
}
