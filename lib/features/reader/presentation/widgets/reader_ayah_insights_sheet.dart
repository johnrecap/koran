import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/domain/verse_identifier.dart';
import 'package:quran_kareem/features/ai/features/context/ai_verse_context_view.dart';
import 'package:quran_kareem/features/ai/features/tadabbur/ai_tadabbur_view.dart';
import 'package:quran_kareem/features/ai/features/simplify/ai_simplified_view.dart';
import 'package:quran_kareem/features/ai/features/simplify/ai_simplify_button.dart';
import 'package:quran_kareem/features/ai/features/simplify/tafsir_simplify_provider.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:quran_kareem/features/audio/data/audio_hub_playback_service.dart';
import 'package:quran_kareem/features/reader/domain/ayah_reader_sync_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_kareem/features/tafsir/providers/insight_section_providers.dart';
import 'package:quran_library/quran_library.dart';

class PackageReaderAyahPlaybackLauncher implements ReaderAyahPlaybackLauncher {
  const PackageReaderAyahPlaybackLauncher({
    this.audioHubPlaybackService,
  });

  /// Optional hub service reference to stop any active surah session
  /// before starting ayah playback, preventing audio conflicts.
  final AudioHubPlaybackService? audioHubPlaybackService;

  @override
  Future<void> play(
    BuildContext context,
    ReaderAyahInsightsTarget target, {
    required bool isDark,
  }) async {
    // 1. Stop any active surah playback session to avoid audio conflicts
    final hub = audioHubPlaybackService;
    if (hub != null && hub.hasActiveSession) {
      await hub.stop();
    }

    // 2. Sync ayah reader index to match the user's selected surah reciter
    AyahReaderSyncPolicy.syncFromCurrentSurahReader();

    // 3. Play the ayah (guard context after async gap)
    if (!context.mounted) return;
    return AudioCtrl.instance.playAyah(
      context,
      target.ayahUQNumber,
      playSingleAyah: true,
      isDarkMode: isDark,
    );
  }
}

class PackageReaderAyahInsightsSheetLauncher
    implements ReaderAyahInsightsSheetLauncher {
  const PackageReaderAyahInsightsSheetLauncher();

  @override
  Future<void> show(
    BuildContext context,
    ReaderAyahInsightsTarget target, {
    required bool isDark,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ReaderAyahInsightsSheet(
        target: target,
        isDark: isDark,
      ),
    );
  }
}

class ReaderAyahInsightsSheet extends ConsumerWidget {
  const ReaderAyahInsightsSheet({
    super.key,
    required this.target,
    required this.isDark,
    this.quickViewBuilder,
    this.legacyQuickViewBuilder,
  });

  final ReaderAyahInsightsTarget target;
  final bool isDark;
  final WidgetBuilder? quickViewBuilder;
  final WidgetBuilder? legacyQuickViewBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: quickViewBuilder?.call(context) ??
                _ReaderAyahInsightsQuickView(
                  target: target,
                  isDark: isDark,
                  legacyQuickViewBuilder: legacyQuickViewBuilder,
                ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    if (navigator.canPop()) {
                      navigator.pop();
                    }
                    GoRouter.of(context)
                        .push('/tafsir/${target.surahNumber}/${target.ayahNumber}');
                  },
                  child: Text(context.l10n.tafsirBrowserOpenFull),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderAyahInsightsQuickView extends ConsumerWidget {
  const _ReaderAyahInsightsQuickView({
    required this.target,
    required this.isDark,
    required this.legacyQuickViewBuilder,
  });

  final ReaderAyahInsightsTarget target;
  final bool isDark;
  final WidgetBuilder? legacyQuickViewBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tafsirAsync = ref.watch(tafsirSectionProvider(target));

    return tafsirAsync.when(
      loading: () => const _ReaderAyahInsightsLoadingView(),
      error: (_, __) => _buildLegacyQuickView(context),
      data: (data) {
        if (data is InsightSectionLoaded &&
            data.content is TafsirBrowserLoadedContent) {
          return _ReaderAyahInsightsCompactView(
            target: target,
            tafsirContent: data.content as TafsirBrowserLoadedContent,
          );
        }

        return _buildLegacyQuickView(context);
      },
    );
  }

  Widget _buildLegacyQuickView(BuildContext context) {
    return legacyQuickViewBuilder?.call(context) ??
        ShowTafseer(
          context: context,
          ayahUQNumber: target.ayahUQNumber,
          ayahNumber: target.ayahNumber,
          pageIndex: target.pageIndex,
          isDark: isDark,
        );
  }
}

class _ReaderAyahInsightsCompactView extends ConsumerStatefulWidget {
  const _ReaderAyahInsightsCompactView({
    required this.target,
    required this.tafsirContent,
  });

  final ReaderAyahInsightsTarget target;
  final TafsirBrowserLoadedContent tafsirContent;

  @override
  ConsumerState<_ReaderAyahInsightsCompactView> createState() =>
      _ReaderAyahInsightsCompactViewState();
}

class _ReaderAyahInsightsCompactViewState
    extends ConsumerState<_ReaderAyahInsightsCompactView> {
  bool _showSimplified = false;
  bool _showVerseContext = false;
  bool _showTadabbur = false;

  @override
  Widget build(BuildContext context) {
    final target = widget.target;
    final tafsirContent = widget.tafsirContent;
    final wordMeaningsAsync = ref.watch(wordMeaningSectionProvider(target));
    final wordPreviewEntries = _resolveWordMeaningPreviewEntries(wordMeaningsAsync);
    final previewText = _buildTafsirPreview(tafsirContent.bodyText);
    final colorScheme = Theme.of(context).colorScheme;
    final aiAvailable = ref.watch(aiAvailableProvider);
    final normalizedTafsir =
        tafsirContent.bodyText.replaceAll(RegExp(r'\s+'), ' ').trim();
    final request = TafsirSimplifyRequest(
      surah: target.surahNumber,
      ayah: target.ayahNumber,
      tafsirText: normalizedTafsir,
    );
    final verse = VerseIdentifier(
      surah: target.surahNumber,
      ayah: target.ayahNumber,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _CompactInsightSection(
                title: context.l10n.insightSectionTafsir,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      previewText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.7,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    if (normalizedTafsir.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      AiSimplifyButton(
                        onPressed: () {
                          setState(() {
                            _showSimplified = true;
                          });
                        },
                      ),
                    ],
                    if (_showSimplified) ...[
                      const SizedBox(height: 12),
                      AiSimplifiedView(request: request),
                    ],
                  ],
                ),
              ),
              if (wordPreviewEntries.isNotEmpty) ...[
                const SizedBox(height: 18),
                _CompactInsightSection(
                  title: context.l10n.insightSectionWordMeaning,
                  child: SizedBox(
                    height: 40,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var index = 0; index < wordPreviewEntries.length; index++) ...[
                            if (index > 0) const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                '${wordPreviewEntries[index].word} · '
                                '${wordPreviewEntries[index].meaning}',
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (aiAvailable) ...[
                const SizedBox(height: 18),
                _CompactInsightSection(
                  title: context.l10n.contextAndConnection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showVerseContext = true;
                          });
                        },
                        child: Text(context.l10n.verseContext),
                      ),
                      if (_showVerseContext) ...[
                        const SizedBox(height: 12),
                        AiVerseContextView(verse: verse),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _CompactInsightSection(
                  title: context.l10n.reflectionQuestions,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showTadabbur = true;
                          });
                        },
                        child: Text(context.l10n.tadabburQuestions),
                      ),
                      if (_showTadabbur) ...[
                        const SizedBox(height: 12),
                        AiTadabburView(verse: verse),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactInsightSection extends StatelessWidget {
  const _CompactInsightSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ReaderAyahInsightsLoadingView extends StatelessWidget {
  const _ReaderAyahInsightsLoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

List<WordMeaningEntry> _resolveWordMeaningPreviewEntries(
  AsyncValue<InsightSectionData> wordMeaningsAsync,
) {
  final data = wordMeaningsAsync.asData?.value;
  if (data is! InsightSectionLoaded<List<WordMeaningEntry>>) {
    return const <WordMeaningEntry>[];
  }

  return data.content.take(5).toList(growable: false);
}

String _buildTafsirPreview(String bodyText) {
  final normalized = bodyText.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= 200) {
    return normalized;
  }

  return '${normalized.substring(0, 200)}...';
}
