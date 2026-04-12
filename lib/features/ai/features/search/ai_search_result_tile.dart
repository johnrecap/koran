import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/ai/domain/ai_search_result.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

class AiSearchResultTile extends ConsumerWidget {
  const AiSearchResultTile({
    super.key,
    required this.result,
  });

  final AiSearchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(allSurahsProvider);

    return surahsAsync.when(
      data: (surahs) {
        final surahName = _resolveSurahName(surahs, result.surah);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            key: Key('ai-search-result-tile-${result.surah}-${result.ayah}'),
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openReader(context, ref),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        surahName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${context.l10n.libraryAyahLabel} ${result.ayah}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.verseTextAr,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.9,
                          fontFamily: 'Amiri',
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.contextNote,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _resolveSurahName(List<Surah> surahs, int surahNumber) {
    for (final surah in surahs) {
      if (surah.number == surahNumber) {
        return surah.nameEnglish;
      }
    }

    return surahNumber.toString();
  }

  Future<void> _openReader(BuildContext context, WidgetRef ref) async {
    final page = await ref.read(aiSearchPageResolverProvider)(
          result.surah,
          result.ayah,
        );
    ref.read(readerSessionIntentProvider.notifier).state =
        const ReaderSessionIntent.general();
    ref.read(currentSurahProvider.notifier).state = result.surah;
    ref.read(quranPageIndexProvider.notifier).state = page;
    ref.read(readerNavigationTargetProvider.notifier).state =
        ReaderNavigationTarget(
      surahNumber: result.surah,
      ayahNumber: result.ayah,
      pageNumber: page,
    );

    if (context.mounted) {
      context.go('/reader');
    }
  }
}
