import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/widgets/app_error_widget.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_config.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_policy.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/insight_section_content_builder.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/insight_section_shell.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/tafsir_browser_navigation_bar.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/tafsir_browser_source_picker.dart';
import 'package:quran_kareem/features/tafsir/providers/insight_section_providers.dart';
import 'package:quran_kareem/features/tafsir/providers/tafsir_browser_providers.dart';

class TafsirBrowserScreen extends ConsumerWidget {
  const TafsirBrowserScreen({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeArgs = TafsirBrowserRouteArgs(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    final targetAsync = ref.watch(tafsirBrowserTargetProvider(routeArgs));
    final sourceOptionsAsync = ref.watch(tafsirBrowserSourceOptionsProvider);
    final canonicalSurahs =
        ref.watch(tafsirBrowserCanonicalSurahsProvider).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tafsirBrowserTitle),
      ),
      body: targetAsync.when(
        loading: () => Center(
          child: Text(context.l10n.tafsirBrowserLoading),
        ),
        error: (_, __) => Center(
          child: Text(context.l10n.tafsirBrowserLoadError),
        ),
        data: (target) {
          if (target == null) {
            return Center(
              child: Text(context.l10n.tafsirBrowserInvalidVerse),
            );
          }

          final previousTarget = TafsirBrowserPolicy.previousTarget(
            current: target,
            canonicalSurahs: canonicalSurahs,
          );
          final nextTarget = TafsirBrowserPolicy.nextTarget(
            current: target,
            canonicalSurahs: canonicalSurahs,
          );
          final sectionCards = _buildSectionCards(
            context: context,
            ref: ref,
            target: target,
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${target.surahNumber}:${target.ayahNumber}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                sourceOptionsAsync.when(
                  data: (options) => TafsirBrowserSourcePicker(
                    options: options,
                    onChanged: (sourceId) async {
                      await ref.read(tafsirBrowserRepositoryProvider).selectSource(
                            sourceId: sourceId,
                            pageNumber: target.pageNumber,
                          );
                      ref.invalidate(tafsirBrowserSourceOptionsProvider);
                      ref.invalidate(tafsirBrowserContentProvider(target));
                      ref.invalidate(tafsirSectionProvider(target));
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => AppErrorWidget(
                    message: context.l10n.tafsirBrowserLoadError,
                    onRetry: () => ref.invalidate(tafsirBrowserSourceOptionsProvider),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: sectionCards.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => sectionCards[index],
                  ),
                ),
                const SizedBox(height: 16),
                TafsirBrowserNavigationBar(
                  canGoPrevious: previousTarget != null,
                  canGoNext: nextTarget != null,
                  onPrevious: previousTarget == null
                      ? null
                      : () => _replaceTarget(
                            context,
                            previousTarget.surahNumber,
                            previousTarget.ayahNumber,
                          ),
                  onNext: nextTarget == null
                      ? null
                      : () => _replaceTarget(
                            context,
                            nextTarget.surahNumber,
                            nextTarget.ayahNumber,
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSectionCards({
    required BuildContext context,
    required WidgetRef ref,
    required ReaderAyahInsightsTarget target,
  }) {
    final sectionCards = <Widget>[];

    for (final config in insightSectionRegistry) {
      final provider = insightSectionProviderResolver(config.type);
      final sectionAsync = ref.watch(provider(target));

      switch (sectionAsync) {
        case AsyncData(:final value):
          if (value is InsightSectionUnavailable) {
            continue;
          }
          sectionCards.add(
            InsightSectionShell(
              config: config,
              data: value,
              child: buildInsightSectionChild(
                context: context,
                config: config,
                data: value,
                onNavigateToAyah: (surah, ayah) =>
                    _replaceTarget(context, surah, ayah),
              ),
            ),
          );
        case AsyncError(:final error):
          sectionCards.add(
            InsightSectionShell(
              config: config,
              data: InsightSectionError(error),
              child: const SizedBox.shrink(),
            ),
          );
        case AsyncLoading():
          sectionCards.add(
            InsightSectionShell(
              config: config,
              data: const InsightSectionLoaded<Object?>(null),
              child: const _InsightSectionLoadingBody(),
            ),
          );
      }
    }

    return sectionCards;
  }

  void _replaceTarget(
    BuildContext context,
    int surah,
    int ayah,
  ) {
    context.replace('/tafsir/$surah/$ayah');
  }
}

class _InsightSectionLoadingBody extends StatelessWidget {
  const _InsightSectionLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
