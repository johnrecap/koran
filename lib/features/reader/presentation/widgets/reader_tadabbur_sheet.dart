import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_payload.dart';
import 'package:quran_kareem/features/reader/domain/reader_tadabbur_navigation_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_tadabbur_session_state.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_share_card_sheet.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_tadabbur_providers.dart';

typedef ReaderTadabburShareRequested = Future<void> Function({
  required Ayah ayah,
  required AyahShareCardPayload payload,
});

Future<Ayah?> showReaderTadabburSheet({
  required BuildContext context,
  required Ayah entryAyah,
  ReaderTadabburShareRequested? onShareRequested,
}) {
  return showModalBottomSheet<Ayah>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => ReaderTadabburSheet(
      entryAyah: entryAyah,
      onShareRequested: onShareRequested,
      onClose: (ayah) => Navigator.of(sheetContext).pop(ayah),
    ),
  );
}

class ReaderTadabburSheet extends ConsumerStatefulWidget {
  const ReaderTadabburSheet({
    super.key,
    required this.entryAyah,
    required this.onClose,
    this.onShareRequested,
  });

  final Ayah entryAyah;
  final ValueChanged<Ayah> onClose;
  final ReaderTadabburShareRequested? onShareRequested;

  @override
  ConsumerState<ReaderTadabburSheet> createState() =>
      _ReaderTadabburSheetState();
}

class _ReaderTadabburSheetState extends ConsumerState<ReaderTadabburSheet> {
  late final TextEditingController _reflectionController;
  late final ReaderTadabburSessionController _sessionController;
  String _currentAyahKey = '';

  @override
  void initState() {
    super.initState();
    _reflectionController = TextEditingController();
    _sessionController = ref.read(
      readerTadabburSessionControllerProvider(widget.entryAyah).notifier,
    );
  }

  @override
  void dispose() {
    unawaited(_sessionController.flushPendingReflection());
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(
      readerTadabburSessionControllerProvider(widget.entryAyah),
    );
    final surahsAsync = ref.watch(surahsProvider);

    _syncReflectionController(state);

    final previousReference = surahsAsync.maybeWhen(
      data: (surahs) => ReaderTadabburNavigationPolicy.previousAyah(
        surahs: surahs,
        surahNumber: state.currentAyah.surahNumber,
        ayahNumber: state.currentAyah.ayahNumber,
      ),
      orElse: () => null,
    );
    final nextReference = surahsAsync.maybeWhen(
      data: (surahs) => ReaderTadabburNavigationPolicy.nextAyah(
        surahs: surahs,
        surahNumber: state.currentAyah.surahNumber,
        ayahNumber: state.currentAyah.ayahNumber,
      ),
      orElse: () => null,
    );
    final referenceText = surahsAsync.maybeWhen(
      data: (surahs) => _referenceTextFor(
        context: context,
        surahs: surahs,
        ayah: state.currentAyah,
      ),
      orElse: () =>
          '[${state.currentAyah.surahNumber}:${state.currentAyah.ayahNumber}]',
    );
    final hasReflection = state.draftReflection.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.verseActionTadabbur,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      IconButton(
                        key: const ValueKey<String>('reader-tadabbur-close'),
                        onPressed: () async {
                          await _sessionController.flushPendingReflection();
                          if (!mounted) {
                            return;
                          }
                          widget.onClose(
                            ref
                                .read(
                                  readerTadabburSessionControllerProvider(
                                    widget.entryAyah,
                                  ),
                                )
                                .currentAyah,
                          );
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.currentAyah.text,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          height: 1.8,
                          fontFamily: 'Amiri',
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    referenceText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.72),
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey<String>(
                        'reader-tadabbur-reflection-field'),
                    controller: _reflectionController,
                    maxLines: 6,
                    minLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.verseNoteHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _sessionController.updateReflection,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const ValueKey<String>(
                              'reader-tadabbur-previous'),
                          onPressed: previousReference == null
                              ? null
                              : () => _sessionController.goToPrevious(),
                          child: Text(l10n.tafsirBrowserPrevious),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          key: const ValueKey<String>('reader-tadabbur-next'),
                          onPressed: nextReference == null
                              ? null
                              : () => _sessionController.goToNext(),
                          child: Text(l10n.tafsirBrowserNext),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const ValueKey<String>('reader-tadabbur-timer'),
                          onPressed: _sessionController.startTimer,
                          child: Text(
                            state.isTimerRunning
                                ? l10n.audioHubPause
                                : l10n.audioHubPlay,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          key: const ValueKey<String>('reader-tadabbur-share'),
                          onPressed: !hasReflection
                              ? null
                              : () => _handleShare(
                                    currentAyah: state.currentAyah,
                                    reflection: state.draftReflection.trim(),
                                  ),
                          child: Text(l10n.verseActionShare),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleShare({
    required Ayah currentAyah,
    required String reflection,
  }) async {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final surahs = await ref.read(surahsProvider.future);
    if (!mounted) {
      return;
    }

    final payload = ReaderVerseActionPolicy.buildShareCardPayload(
      ayah: currentAyah,
      surahPrefix: l10n.surahPrefix,
      surahName: _localizedSurahName(
        languageCode: languageCode,
        surahs: surahs,
        surahNumber: currentAyah.surahNumber,
      ),
    ).copyWith(
      supportingText: reflection,
    );

    final onShareRequested = widget.onShareRequested;
    if (onShareRequested != null) {
      await onShareRequested(
        ayah: currentAyah,
        payload: payload,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await showReaderAyahShareCardSheet(
      context: context,
      ayah: currentAyah,
      payload: payload,
      allowTranslationToggle: false,
    );
  }

  String _referenceTextFor({
    required BuildContext context,
    required List<Surah> surahs,
    required Ayah ayah,
  }) {
    final surahName = _localizedSurahName(
      languageCode: Localizations.localeOf(context).languageCode,
      surahs: surahs,
      surahNumber: ayah.surahNumber,
    );
    return '[${context.l10n.surahPrefix} $surahName]';
  }

  String _localizedSurahName({
    required String languageCode,
    required List<Surah> surahs,
    required int surahNumber,
  }) {
    final surah = surahs.firstWhere(
      (candidate) => candidate.number == surahNumber,
      orElse: () => Surah(
        number: surahNumber,
        nameArabic: '$surahNumber',
        nameEnglish: '$surahNumber',
        nameTransliteration: '$surahNumber',
        ayahCount: 0,
        revelationType: 'Meccan',
        page: 1,
      ),
    );
    if (languageCode == 'en') {
      return surah.nameEnglish;
    }
    return surah.nameArabic;
  }

  void _syncReflectionController(ReaderTadabburSessionState state) {
    final ayahKey =
        '${state.currentAyah.surahNumber}:${state.currentAyah.ayahNumber}';
    if (_currentAyahKey == ayahKey &&
        _reflectionController.text == state.draftReflection) {
      return;
    }

    _currentAyahKey = ayahKey;
    _reflectionController.value = TextEditingValue(
      text: state.draftReflection,
      selection: TextSelection.collapsed(offset: state.draftReflection.length),
    );
  }
}
