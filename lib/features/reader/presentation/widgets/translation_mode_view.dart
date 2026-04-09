import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/translated_ayah_tile.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

class TranslationModeView extends ConsumerStatefulWidget {
  const TranslationModeView({
    super.key,
    required this.navigationTarget,
    this.palette,
    this.onAyahLongPress,
  });

  final ReaderNavigationTarget navigationTarget;
  final ReaderNightPalette? palette;
  final ValueChanged<Ayah>? onAyahLongPress;

  @override
  ConsumerState<TranslationModeView> createState() =>
      _TranslationModeViewState();
}

class _TranslationModeViewState extends ConsumerState<TranslationModeView> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = <int, GlobalKey>{};
  String? _lastAnchoredToken;
  String? _lastApproximateScrollToken;

  @override
  void initState() {
    super.initState();
    _scheduleAnchorToTarget(totalAyahs: 0);
  }

  @override
  void didUpdateWidget(covariant TranslationModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationTarget != widget.navigationTarget) {
      _scheduleAnchorToTarget(totalAyahs: 0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleAnchorToTarget({
    String? token,
    required int totalAyahs,
  }) {
    if (token != null && token == _lastAnchoredToken) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final targetContext =
          _ayahKeys[widget.navigationTarget.ayahNumber]?.currentContext;
      if (targetContext == null) {
        if (token != null &&
            token != _lastApproximateScrollToken &&
            _scrollController.hasClients) {
          final position = _scrollController.position;
          final maxIndex = totalAyahs > 1 ? totalAyahs - 1 : 1;
          final targetIndex =
              (widget.navigationTarget.ayahNumber - 1).clamp(0, maxIndex);
          final fraction = maxIndex == 0 ? 0.0 : targetIndex / maxIndex;
          final approximateOffset = position.minScrollExtent +
              ((position.maxScrollExtent - position.minScrollExtent) *
                  fraction);

          _lastApproximateScrollToken = token;
          _scrollController.jumpTo(approximateOffset);
          _scheduleAnchorToTarget(
            token: token,
            totalAyahs: totalAyahs,
          );
        }
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.12,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
      if (token != null) {
        _lastAnchoredToken = token;
      }
    });
  }

  void _retryCurrentSurah() {
    ref.invalidate(surahAyahsProvider(widget.navigationTarget.surahNumber));
    ref.invalidate(
        surahTranslationsProvider(widget.navigationTarget.surahNumber));
  }

  GlobalKey _keyForAyah(int ayahNumber) {
    return _ayahKeys.putIfAbsent(
      ayahNumber,
      () => GlobalKey(
        debugLabel:
            'translation-${widget.navigationTarget.surahNumber}-$ayahNumber',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPalette = widget.palette ??
        ReaderNightPresentationPolicy.paletteFor(
          presentation: ReaderNightPresentation.normal,
          appBrightness: Theme.of(context).brightness,
        );
    final arabicFontSize = ref.watch(quranFontSizeProvider);
    final ayahsAsync = ref.watch(
      surahAyahsProvider(widget.navigationTarget.surahNumber),
    );
    final translationsAsync = ref.watch(
      surahTranslationsProvider(widget.navigationTarget.surahNumber),
    );

    if (ayahsAsync.isLoading || translationsAsync.isLoading) {
      return _TranslationStateMessage(
        label: context.l10n.translationModeLoading,
        color: resolvedPalette.textColor,
      );
    }

    final ayahError = ayahsAsync.asError;
    final translationError = translationsAsync.asError;
    if (ayahError != null || translationError != null) {
      return _TranslationErrorState(
        onRetry: _retryCurrentSurah,
        color: resolvedPalette.textColor,
      );
    }

    final ayahs = ayahsAsync.asData?.value ?? const <Ayah>[];
    final translations =
        translationsAsync.asData?.value ?? const <int, AyahTranslation>{};
    if (ayahs.isEmpty) {
      return _TranslationStateMessage(
        label: context.l10n.translationModeEmpty,
        color: resolvedPalette.textColor,
      );
    }

    _scheduleAnchorToTarget(
      token:
          '${widget.navigationTarget.surahNumber}:${widget.navigationTarget.ayahNumber}:${ayahs.length}',
      totalAyahs: ayahs.length,
    );

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: ayahs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final ayah = ayahs[index];
        return TranslatedAyahTile(
          key: _keyForAyah(ayah.ayahNumber),
          ayah: ayah,
          translation: translations[ayah.ayahNumber],
          arabicFontSize: arabicFontSize,
          translationFallbackText: context.l10n.translationVerseFallback,
          palette: resolvedPalette,
          isTarget: ayah.ayahNumber == widget.navigationTarget.ayahNumber,
          onLongPress: widget.onAyahLongPress == null
              ? null
              : () => widget.onAyahLongPress!(ayah),
        );
      },
    );
  }
}

class _TranslationStateMessage extends StatelessWidget {
  const _TranslationStateMessage({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
        ),
      ),
    );
  }
}

class _TranslationErrorState extends StatelessWidget {
  const _TranslationErrorState({
    required this.onRetry,
    required this.color,
  });

  final VoidCallback onRetry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.translationModeError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                  ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(context.l10n.translationModeRetry),
            ),
          ],
        ),
      ),
    );
  }
}
