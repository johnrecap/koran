import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/core/utils/id_generator.dart';
import 'package:quran_kareem/core/widgets/app_error_widget.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart' as entity;
import 'package:quran_kareem/features/audio/presentation/widgets/audio_hub_reciter_picker_sheet.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_exit_cleanup_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/jump_to_dialog.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/muallim_playback_controls.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/muallim_word_highlight_bridge.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_note_sheet.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_share_card_sheet.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_translation_sheet.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_mode_selector.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_night_mode_sheet.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_tadabbur_sheet.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/surah_drawer.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/torn_paper_banner.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/translation_mode_view.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_action_menu.dart';
import 'package:quran_kareem/features/reader/providers/manual_bookmarks_provider.dart';
import 'package:quran_kareem/features/reader/providers/muallim_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';
import 'package:quran_library/quran_library.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen>
    with WidgetsBindingObserver {
  static const double _muallimControlsInset = 112.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollPositionSaveDebounce;
  late ProviderContainer _providerContainer;
  int _readingPositionSaveGeneration = 0;
  late final String _readerVisitSessionId;
  late final DateTime _readerVisitStartedAt;
  double? _pendingScrollOffsetRestore;
  bool _savedBannerWasVisible = false;
  bool _showRestoreButton = false;
  bool _didRecordTrackedVisitDuration = false;
  bool _didScheduleExitCleanup = false;
  int? _entryPageNumber;
  bool _didIgnoreInitialPageProgressCommit = false;
  bool _didTrackTrustedKhatmaProgressThisVisit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _readerVisitSessionId = IdGenerator.uniqueId();
    _readerVisitStartedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshReaderNightEvaluation();
    });
    Future<void>(() => _restoreReaderState());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _providerContainer = ProviderScope.containerOf(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollPositionSaveDebounce?.cancel();
    _scheduleExitCleanup();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshReaderNightEvaluation();
    }
  }

  void _scheduleExitCleanup() {
    if (_didScheduleExitCleanup) {
      return;
    }
    _didScheduleExitCleanup = true;

    ReaderExitCleanupPolicy.schedule(
      defer: (callback) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          callback();
        });
      },
      recordTrackedDuration: () => _recordTrackedReadingDuration(
        _providerContainer,
      ),
      applySystemUiReset: () => _applySystemUiMode(isFullscreen: false),
      resetSessionIntent: () {
        _providerContainer.read(readerSessionIntentProvider.notifier).state =
            const ReaderSessionIntent.general();
      },
      resetFullscreen: () {
        _providerContainer.read(readerFullscreenModeProvider.notifier).state =
            false;
      },
      resetNightSessionOverride: () {
        _providerContainer
            .read(readerNightSessionOverrideProvider.notifier)
            .state = null;
      },
    );
  }

  void _refreshReaderNightEvaluation() {
    ref.read(readerNightEvaluationTimeProvider.notifier).state = DateTime.now();
  }

  Future<void> _restoreReaderState() async {
    final restoreState = await ReaderRestorePolicy.load(
      loadModePreference: () async {
        final mode = ref.read(appSettingsControllerProvider).defaultReaderMode;
        return ReaderModePolicy.toPreference(mode);
      },
      loadLastReadingPosition: UserPreferences.getLastReadingPosition,
      currentTarget: ref.read(readerNavigationTargetProvider),
      currentSurah: ref.read(currentSurahProvider),
      currentPage: ref.read(quranPageIndexProvider),
      isMounted: () => mounted,
    );
    if (!mounted || restoreState == null) {
      return;
    }

    ref.read(readerModeProvider.notifier).state = restoreState.mode;
    _entryPageNumber = restoreState.target.pageNumber;
    _didIgnoreInitialPageProgressCommit = false;
    if (restoreState.shouldReplaceTarget) {
      ref.read(readerNavigationTargetProvider.notifier).state =
          restoreState.target;
      ref.read(currentSurahProvider.notifier).state =
          restoreState.target.surahNumber;
      ref.read(quranPageIndexProvider.notifier).state =
          restoreState.target.pageNumber;
    }

    if (restoreState.mode == ReaderMode.page) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          QuranLibrary().jumpToPage(restoreState.target.pageNumber);
        }
      });
    }

    await _recordReaderProgress(
      surahNumber: restoreState.target.surahNumber,
      ayahNumber: restoreState.target.ayahNumber,
      pageNumber: restoreState.target.pageNumber,
      allowKhatmaTracking: false,
    );
  }

  void _applySystemUiMode({required bool isFullscreen}) {
    SystemChrome.setEnabledSystemUIMode(
      ReaderFullscreenSystemUiPolicy.modeFor(isFullscreen: isFullscreen),
    );
  }

  void _enterFullscreenReader() {
    _prepareForFullscreenTransition();
    _applySystemUiMode(isFullscreen: true);
    ref.read(readerFullscreenModeProvider.notifier).state = true;
    if (mounted) {
      setState(() {
        _showRestoreButton = false;
      });
    }
    _restoreAfterFullscreenTransition();
  }

  void _exitFullscreenReader() {
    _prepareForFullscreenTransition();
    _applySystemUiMode(isFullscreen: false);
    ref.read(readerFullscreenModeProvider.notifier).state = false;
    if (mounted) {
      setState(() {
        _showRestoreButton = false;
      });
    }
    _restoreAfterFullscreenTransition();
  }

  void _prepareForFullscreenTransition() {
    final mode = ref.read(readerModeProvider);
    if (mode == ReaderMode.scroll && _scrollController.hasClients) {
      _pendingScrollOffsetRestore = _scrollController.offset;
      _savedBannerWasVisible = ReaderChromePolicy.shouldShowExternalBanner(
        ReaderMode.scroll,
        isFullscreen: ref.read(readerFullscreenModeProvider),
      );
      return;
    }

    _pendingScrollOffsetRestore = null;

    final liveTarget = ReaderLiveTargetPolicy.fromCurrentState(
      target: ref.read(readerNavigationTargetProvider),
      currentSurah: ref.read(currentSurahProvider),
      currentPage: ref.read(quranPageIndexProvider),
    );
    ref.read(readerNavigationTargetProvider.notifier).state = liveTarget;
  }

  void _restoreAfterFullscreenTransition({int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final mode = ref.read(readerModeProvider);
      if (mode == ReaderMode.page) {
        final pageNumber = ref.read(quranPageIndexProvider);
        QuranLibrary().jumpToPage(pageNumber);
        return;
      }

      final pendingOffset = _pendingScrollOffsetRestore;
      if (pendingOffset == null) {
        return;
      }

      if (!_scrollController.hasClients) {
        if (attempt < ReaderScrollRestorePolicy.maxDeferredAttempts) {
          _restoreAfterFullscreenTransition(attempt: attempt + 1);
        }
        return;
      }

      final bannerNowVisible = ReaderChromePolicy.shouldShowExternalBanner(
        ReaderMode.scroll,
        isFullscreen: ref.read(readerFullscreenModeProvider),
      );
      final bannerDelta = (_savedBannerWasVisible == bannerNowVisible)
          ? 0.0
          : bannerNowVisible
              ? ReaderScrollViewportPolicy.leadingBannerOffset
              : -ReaderScrollViewportPolicy.leadingBannerOffset;
      final adjustedOffset = (pendingOffset + bannerDelta).clamp(
        0.0,
        double.infinity,
      );

      final position = _scrollController.position;
      if (ReaderScrollRestorePolicy.shouldDeferRestore(
        savedOffset: adjustedOffset,
        maxScrollExtent: position.maxScrollExtent,
        attempt: attempt,
      )) {
        _restoreAfterFullscreenTransition(attempt: attempt + 1);
        return;
      }

      final clampedOffset = ReaderScrollRestorePolicy.clampOffset(
        savedOffset: adjustedOffset,
        minScrollExtent: position.minScrollExtent,
        maxScrollExtent: position.maxScrollExtent,
      );
      _scrollController.jumpTo(clampedOffset);
      _pendingScrollOffsetRestore = null;
    });
  }

  void _revealRestoreButton() {
    if (!ref.read(readerFullscreenModeProvider)) {
      return;
    }

    if (!_showRestoreButton) {
      setState(() {
        _showRestoreButton = true;
      });
    }
  }

  Future<void> _syncReadingPositionForPage(int pageNumber) async {
    ref.read(quranPageIndexProvider.notifier).state = pageNumber;

    final ayahs = QuranLibrary().getPageAyahsByPageNumber(
      pageNumber: pageNumber,
    );
    if (ayahs.isEmpty) {
      return;
    }

    final firstAyah = ayahs.first;
    final surahNumber = firstAyah.surahNumber;
    if (surahNumber == null) {
      return;
    }

    ref.read(currentSurahProvider.notifier).state = surahNumber;
    ref.read(readerNavigationTargetProvider.notifier).state =
        ReaderNavigationTarget(
      surahNumber: surahNumber,
      ayahNumber: firstAyah.ayahNumber,
      pageNumber: pageNumber,
    );
    if (_shouldIgnoreInitialPageProgressCommit(pageNumber)) {
      return;
    }
    await _recordReaderProgress(
      surahNumber: surahNumber,
      ayahNumber: firstAyah.ayahNumber,
      pageNumber: pageNumber,
    );
  }

  Future<void> _navigateToTarget(ReaderNavigationTarget target) async {
    _invalidatePendingReadingPositionSave();
    ref.read(readerNavigationTargetProvider.notifier).state = target;
    ref.read(currentSurahProvider.notifier).state = target.surahNumber;
    ref.read(quranPageIndexProvider.notifier).state = target.pageNumber;
    await _recordReaderProgress(
      surahNumber: target.surahNumber,
      ayahNumber: target.ayahNumber,
      pageNumber: target.pageNumber,
    );

    final mode = ref.read(readerModeProvider);
    if (mode == ReaderMode.page) {
      QuranLibrary().jumpToPage(target.pageNumber);
    }
  }

  void _handleScrollVisiblePageChanged(int pageNumber) {
    final currentPage = ref.read(quranPageIndexProvider);
    if (currentPage == pageNumber) {
      return;
    }

    ref.read(quranPageIndexProvider.notifier).state = pageNumber;
    final pageAyahs = QuranLibrary().getPageAyahsByPageNumber(
      pageNumber: pageNumber,
    );
    if (pageAyahs.isEmpty) {
      return;
    }

    final firstAyah = pageAyahs.first;
    final surahNumber = firstAyah.surahNumber;
    if (surahNumber == null) {
      return;
    }

    ref.read(currentSurahProvider.notifier).state = surahNumber;

    _scrollPositionSaveDebounce?.cancel();
    final scheduledGeneration = _readingPositionSaveGeneration;
    _scrollPositionSaveDebounce = Timer(
      const Duration(milliseconds: AppConstants.scrollDebounceMs),
      () {
        if (!ReaderPendingSavePolicy.shouldPersist(
          scheduledGeneration: scheduledGeneration,
          currentGeneration: _readingPositionSaveGeneration,
        )) {
          return;
        }

        unawaited(
          _recordReaderProgress(
            surahNumber: surahNumber,
            ayahNumber: firstAyah.ayahNumber,
            pageNumber: pageNumber,
          ),
        );
      },
    );
  }

  void _invalidatePendingReadingPositionSave() {
    _scrollPositionSaveDebounce?.cancel();
    _scrollPositionSaveDebounce = null;
    _readingPositionSaveGeneration = ReaderPendingSavePolicy.invalidate(
      _readingPositionSaveGeneration,
    );
  }

  Future<void> _showReaderStatusMessage(String message) async {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<String?> _resolveVerseActionSurahName(int surahNumber) async {
    try {
      final surahs = await ref.read(surahsProvider.future);
      return ReaderVerseActionPolicy.resolveSurahName(
        surahs: surahs,
        surahNumber: surahNumber,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'ReaderScreen._resolveVerseActionSurahName',
        error,
        stackTrace,
      );
      return null;
    }
  }

  Future<void> _bookmarkVerse(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    final surahName = await _resolveVerseActionSurahName(ayah.surahNumber);
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
    if (surahName == null) {
      await _showReaderStatusMessage(l10n.verseMetadataUnavailable);
      return;
    }

    await ref.read(manualBookmarksProvider.notifier).toggle(
          ayah.surahNumber,
          ayah.ayahNumber,
          surahName,
        );
    await _showReaderStatusMessage(l10n.bookmarkUpdated);
  }

  Future<void> _shareVerse(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    final surahName = await _resolveVerseActionSurahName(ayah.surahNumber);
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
    if (surahName == null) {
      await _showReaderStatusMessage(l10n.verseMetadataUnavailable);
      return;
    }

    try {
      await showReaderAyahShareCardSheet(
        context: context,
        ayah: ayah,
        payload: ReaderVerseActionPolicy.buildShareCardPayload(
          ayah: ayah,
          surahPrefix: l10n.surahPrefix,
          surahName: surahName,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('ReaderScreen._shareVerse', error, stackTrace);
      await _showReaderStatusMessage(l10n.verseShareUnavailable);
    }
  }

  Future<void> _copyVerse(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    final surahName = await _resolveVerseActionSurahName(ayah.surahNumber);
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
    if (surahName == null) {
      await _showReaderStatusMessage(l10n.verseMetadataUnavailable);
      return;
    }

    try {
      await Clipboard.setData(
        ClipboardData(
          text: ReaderVerseActionPolicy.buildCopyText(
            ayah: ayah,
            surahPrefix: l10n.surahPrefix,
            surahName: surahName,
          ),
        ),
      );
      await _showReaderStatusMessage(l10n.verseCopied);
    } catch (error, stackTrace) {
      AppLogger.error('ReaderScreen._copyVerse', error, stackTrace);
      await _showReaderStatusMessage(l10n.verseCopyUnavailable);
    }
  }

  Future<void> _openAyahNoteSheet(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
    try {
      final result = await showReaderAyahNoteSheet(
        context: context,
        ayah: ayah,
      );
      if (!mounted || result == null) {
        return;
      }

      switch (result) {
        case ReaderAyahNoteSheetResult.saved:
          await _showReaderStatusMessage(l10n.verseNoteSaved);
        case ReaderAyahNoteSheetResult.deleted:
          await _showReaderStatusMessage(l10n.verseNoteDeleted);
      }
    } catch (error, stackTrace) {
      AppLogger.error('ReaderScreen._openAyahNoteSheet', error, stackTrace);
      await _showReaderStatusMessage(l10n.verseNoteUnavailable);
    }
  }

  Future<void> _openAyahTranslationSheet(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
    try {
      await showReaderAyahTranslationSheet(
        context: context,
        ayah: ayah,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'ReaderScreen._openAyahTranslationSheet',
        error,
        stackTrace,
      );
      await _showReaderStatusMessage(l10n.verseTranslationUnavailable);
    }
  }

  ReaderAyahInsightsTarget _resolveAyahInsightsTarget(entity.Ayah ayah) {
    return ReaderAyahInsightsPolicy.resolve(
      ayah: ayah,
      canonicalSurahs: QuranCtrl.instance.surahs,
    );
  }

  Future<void> _playAyahAudio(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
    try {
      final target = _resolveAyahInsightsTarget(ayah);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      await ref.read(readerAyahPlaybackLauncherProvider).play(
            context,
            target,
            isDark: isDark,
          );
    } catch (error, stackTrace) {
      AppLogger.error('ReaderScreen._playAyahAudio', error, stackTrace);
      await _showReaderStatusMessage(l10n.verseAudioUnavailable);
    }
  }

  Future<void> _openAyahInsights(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
    try {
      final target = _resolveAyahInsightsTarget(ayah);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      await ref.read(readerAyahInsightsSheetLauncherProvider).show(
            context,
            target,
            isDark: isDark,
          );
    } catch (error, stackTrace) {
      AppLogger.error('ReaderScreen._openAyahInsights', error, stackTrace);
      await _showReaderStatusMessage(l10n.verseInsightsUnavailable);
    }
  }

  Future<void> _openTadabbur(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
    try {
      final lastAyah = await showReaderTadabburSheet(
        context: context,
        entryAyah: ayah,
      );
      if (!mounted || lastAyah == null) {
        return;
      }

      final pageNumber = await QuranDatabase.getPageForAyah(
        lastAyah.surahNumber,
        lastAyah.ayahNumber,
      );
      if (!mounted) {
        return;
      }

      await _navigateToTarget(
        ReaderNavigationTarget(
          surahNumber: lastAyah.surahNumber,
          ayahNumber: lastAyah.ayahNumber,
          pageNumber: pageNumber,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('ReaderScreen._openTadabbur', error, stackTrace);
      await _showReaderStatusMessage(l10n.verseMetadataUnavailable);
    }
  }

  void _showVerseActionMenuForAyah(entity.Ayah ayah) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) => VerseActionMenu(
        ayah: ayah,
        onDismiss: () => Navigator.of(dialogContext).pop(),
        onListen: () => unawaited(_playAyahAudio(dialogContext, ayah)),
        onBookmark: () => unawaited(_bookmarkVerse(dialogContext, ayah)),
        onShare: () => unawaited(_shareVerse(dialogContext, ayah)),
        onCopy: () => unawaited(_copyVerse(dialogContext, ayah)),
        onNote: () => unawaited(_openAyahNoteSheet(dialogContext, ayah)),
        onTadabbur: () => unawaited(_openTadabbur(dialogContext, ayah)),
        onTranslations: () =>
            unawaited(_openAyahTranslationSheet(dialogContext, ayah)),
        onInsights: () => unawaited(_openAyahInsights(dialogContext, ayah)),
        onMuallimStart: () =>
            unawaited(_startMuallimFromAyah(dialogContext, ayah)),
      ),
    );
  }

  Future<void> _setReaderMode(ReaderMode nextMode) async {
    final currentMode = ref.read(readerModeProvider);
    if (nextMode == currentMode) {
      return;
    }

    _invalidatePendingReadingPositionSave();
    ref.read(readerModeProvider.notifier).state = nextMode;
    await ref
        .read(appSettingsControllerProvider.notifier)
        .setDefaultReaderMode(nextMode);

    final liveTarget = ReaderLiveTargetPolicy.fromCurrentState(
      target: ref.read(readerNavigationTargetProvider),
      currentSurah: ref.read(currentSurahProvider),
      currentPage: ref.read(quranPageIndexProvider),
    );
    ref.read(readerNavigationTargetProvider.notifier).state = liveTarget;
    await _recordReaderProgress(
      surahNumber: liveTarget.surahNumber,
      ayahNumber: liveTarget.ayahNumber,
      pageNumber: liveTarget.pageNumber,
    );

    if (nextMode != ReaderMode.page) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        QuranLibrary().jumpToPage(liveTarget.pageNumber);
      }
    });
  }

  void _toggleReaderMode(ReaderMode mode) {
    final nextMode = ReaderQuickTogglePolicy.nextMode(mode);
    unawaited(_setReaderMode(nextMode));
  }

  bool _currentReaderUsesDarkLibrary() {
    final presentation = ref.read(readerNightPresentationProvider);
    final palette = ReaderNightPresentationPolicy.paletteFor(
      presentation: presentation,
      appBrightness: Theme.of(context).brightness,
    );
    return palette.useDarkReaderLibrary;
  }

  Future<void> _toggleMuallimMode() async {
    final notifier = ref.read(muallimStateProvider.notifier);
    final snapshot = ref.read(muallimStateProvider);
    if (snapshot.isEnabled) {
      await notifier.disable();
      return;
    }
    await notifier.enable();
  }

  Future<void> _showMuallimReciterPicker(
    MuallimSnapshot snapshot, {
    required bool isDarkMode,
  }) async {
    final reciters =
        ref.read(muallimAyahAudioServiceProvider).availableReciters;
    if (reciters.isEmpty) {
      return;
    }

    final selectedReciterId = snapshot.currentReciterId.isNotEmpty
        ? snapshot.currentReciterId
        : reciters.first.id;
    final reciterId = await showAudioHubReciterPickerSheet(
      context,
      reciters: reciters,
      selectedReciterId: selectedReciterId,
    );
    if (!mounted || reciterId == null) {
      return;
    }

    await ref.read(muallimStateProvider.notifier).selectReciter(
          reciterId,
          context: context,
          restartPlayback:
              snapshot.playbackState == MuallimPlaybackState.playing ||
                  snapshot.playbackState == MuallimPlaybackState.paused,
          isDarkMode: isDarkMode,
        );
  }

  Future<void> _startMuallimFromAyah(
    BuildContext dialogContext,
    entity.Ayah ayah,
  ) async {
    final l10n = context.l10n;
    if (!mounted || !dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();

    try {
      final ayahUQNumber = ayah.id > 0
          ? ayah.id
          : QuranCtrl.instance.getAyahUQBySurahAndAyah(
              ayah.surahNumber,
              ayah.ayahNumber,
            );
      if (ayahUQNumber == null) {
        await _showReaderStatusMessage(l10n.verseAudioUnavailable);
        return;
      }

      final pageNumber = ayah.page > 0
          ? ayah.page
          : await QuranDatabase.getPageForAyah(
              ayah.surahNumber,
              ayah.ayahNumber,
            );
      if (!mounted) {
        return;
      }

      await ref.read(muallimStateProvider.notifier).startFromAyah(
            MuallimAyahPosition(
              surahNumber: ayah.surahNumber,
              ayahNumber: ayah.ayahNumber,
              ayahUQNumber: ayahUQNumber,
              pageNumber: pageNumber,
            ),
            context: context,
            isDarkMode: _currentReaderUsesDarkLibrary(),
          );
    } catch (error, stackTrace) {
      AppLogger.error('ReaderScreen._startMuallimFromAyah', error, stackTrace);
      await _showReaderStatusMessage(l10n.verseAudioUnavailable);
    }
  }

  Future<void> _showNightReaderModeSheet(
    ReaderNightPresentation currentPresentation,
  ) async {
    final selection = await showReaderNightModeSheet(
      context: context,
      currentPresentation: currentPresentation,
    );
    if (!mounted || selection == null) {
      return;
    }

    await _applyNightReaderSelection(selection);
  }

  Future<void> _applyNightReaderSelection(
    ReaderNightPresentation selection,
  ) async {
    ref.read(readerNightSessionOverrideProvider.notifier).state = selection;

    final settingsController = ref.read(appSettingsControllerProvider.notifier);
    switch (selection) {
      case ReaderNightPresentation.normal:
        return;
      case ReaderNightPresentation.night:
        await settingsController.setPreferredNightStyle(
          ReaderNightStyle.night,
        );
        return;
      case ReaderNightPresentation.amoled:
        await settingsController.setPreferredNightStyle(
          ReaderNightStyle.amoled,
        );
        return;
    }
  }

  Future<void> _recordReaderProgress({
    required int surahNumber,
    required int ayahNumber,
    required int pageNumber,
    bool allowKhatmaTracking = true,
  }) async {
    await ref.read(readerSaveRecorderProvider).record(
          sessionId: _readerVisitSessionId,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          page: pageNumber,
          allowKhatmaTracking: allowKhatmaTracking,
        );

    final sessionIntent = ref.read(readerSessionIntentProvider);
    if (allowKhatmaTracking && sessionIntent.isKhatmaOwned) {
      _didTrackTrustedKhatmaProgressThisVisit = true;
    }
  }

  bool _shouldIgnoreInitialPageProgressCommit(int pageNumber) {
    if (_didIgnoreInitialPageProgressCommit) {
      return false;
    }

    _didIgnoreInitialPageProgressCommit = true;
    return _entryPageNumber == pageNumber;
  }

  Future<void> _recordTrackedReadingDuration(
      ProviderContainer container) async {
    if (_didRecordTrackedVisitDuration) {
      return;
    }
    _didRecordTrackedVisitDuration = true;

    final duration = DateTime.now().difference(_readerVisitStartedAt);
    final trackedMinutes = duration.inMinutes > 0
        ? duration.inMinutes
        : (duration.inSeconds >= 30 ? 1 : 0);
    if (trackedMinutes <= 0) {
      return;
    }

    final sessionIntent = container.read(readerSessionIntentProvider);
    final trackedKhatmaId = sessionIntent.trackedKhatmaId;
    if (trackedKhatmaId == null || !_didTrackTrustedKhatmaProgressThisVisit) {
      return;
    }

    await container.read(khatmasProvider.notifier).addTrackedMinutes(
          khatmaId: trackedKhatmaId,
          minutes: trackedMinutes,
        );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(readerModeProvider);
    final navigationTarget = ref.watch(readerNavigationTargetProvider);
    final muallimSnapshot = ref.watch(muallimStateProvider);
    final nightPresentation = ref.watch(readerNightPresentationProvider);
    final isFullscreenReader = ref.watch(readerFullscreenModeProvider);
    final palette = ReaderNightPresentationPolicy.paletteFor(
      presentation: nightPresentation,
      appBrightness: Theme.of(context).brightness,
    );
    ref.listen<ReaderNavigationTarget?>(
      muallimAutoNavigationTargetProvider,
      (previous, next) {
        if (!mounted || next == null) {
          return;
        }
        if (ref.read(readerNavigationTargetProvider) == next) {
          return;
        }
        unawaited(_navigateToTarget(next));
      },
    );
    final bgColor = palette.backgroundColor;
    final appLanguageCode =
        ReaderAppLanguagePolicy.resolve(Localizations.localeOf(context));
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final baseContentPadding = ReaderViewportInsetPolicy.contentPadding(
      isFullscreen: isFullscreenReader,
      systemTopInset: viewPadding.top,
      systemBottomInset: viewPadding.bottom,
    );
    final contentPadding = baseContentPadding.copyWith(
      bottom: baseContentPadding.bottom +
          (muallimSnapshot.isEnabled ? _muallimControlsInset : 0),
    );

    final readerBody = switch (mode) {
      ReaderMode.scroll => _buildScrollMode(
          palette: palette,
          navigationTarget: navigationTarget,
          isFullscreenReader: isFullscreenReader,
          appLanguageCode: appLanguageCode,
        ),
      ReaderMode.page => _buildPageMode(palette, appLanguageCode),
      ReaderMode.translation => _buildTranslationMode(
          navigationTarget,
          palette,
        ),
    };

    final canPop = context.canPop();

    return MuallimWordHighlightBridge(
      child: PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            context.go('/library');
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: bgColor,
            endDrawer: SurahDrawer(
              palette: palette,
              onSurahSelected: (surah) async {
                await _navigateToTarget(
                  ReaderNavigationTarget(
                    surahNumber: surah.number,
                    ayahNumber: 1,
                    pageNumber: surah.page,
                  ),
                );
              },
            ),
            appBar: isFullscreenReader
                ? null
                : _buildAppBar(
                    mode,
                    palette,
                    nightPresentation,
                    muallimSnapshot,
                  ),
            body: _buildReaderSurface(
              child: readerBody,
              contentPadding: contentPadding,
              isFullscreenReader: isFullscreenReader,
              palette: palette,
              navigationTarget: navigationTarget,
              muallimSnapshot: muallimSnapshot,
            ),
          )),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ReaderMode mode,
    ReaderNightPalette palette,
    ReaderNightPresentation nightPresentation,
    MuallimSnapshot muallimSnapshot,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 12,
      title: ReaderModeSelector(
        currentMode: mode,
        onChanged: (nextMode) => unawaited(_setReaderMode(nextMode)),
      ),
      iconTheme: IconThemeData(
        color: palette.textColor,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.saved_search_rounded),
          tooltip: context.l10n.readerQuickJump,
          onPressed: () async {
            final target = await showDialog<ReaderNavigationTarget>(
              context: context,
              builder: (dialogContext) => const JumpToDialog(),
            );
            if (target != null) {
              await _navigateToTarget(target);
            }
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: palette.textColor),
          onSelected: (value) {
            switch (value) {
              case 'night':
                unawaited(
                  _showNightReaderModeSheet(nightPresentation),
                );
              case 'muallim':
                unawaited(_toggleMuallimMode());
              case 'fullscreen':
                _enterFullscreenReader();
              case 'toggle_mode':
                _toggleReaderMode(mode);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'night',
              child: ListTile(
                leading: Icon(
                  nightPresentation == ReaderNightPresentation.normal
                      ? Icons.nights_stay_outlined
                      : Icons.nights_stay_rounded,
                  color: nightPresentation == ReaderNightPresentation.normal
                      ? null
                      : AppColors.gold,
                ),
                title: Text(context.l10n.readerNightModeSheetTitle),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem<String>(
              value: 'muallim',
              child: ListTile(
                leading: Icon(
                  Icons.record_voice_over_rounded,
                  color: muallimSnapshot.isEnabled ? AppColors.gold : null,
                ),
                title: Text(
                  muallimSnapshot.isEnabled
                      ? context.l10n.mushafMuallimDisable
                      : context.l10n.mushafMuallimEnable,
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem<String>(
              value: 'fullscreen',
              child: ListTile(
                leading: const Icon(Icons.fullscreen_rounded),
                title: Text(context.l10n.enterFullscreen),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (ReaderQuickTogglePolicy.isAvailable(mode))
              PopupMenuItem<String>(
                value: 'toggle_mode',
                child: ListTile(
                  leading: Icon(
                    mode == ReaderMode.page ? Icons.swap_vert : Icons.swipe,
                  ),
                  title: Text(
                    mode == ReaderMode.page
                        ? context.l10n.readerToggleToScroll
                        : context.l10n.readerToggleToPage,
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildReaderSurface({
    required Widget child,
    required EdgeInsets contentPadding,
    required bool isFullscreenReader,
    required ReaderNightPalette palette,
    required ReaderNavigationTarget navigationTarget,
    required MuallimSnapshot muallimSnapshot,
  }) {
    final paddedChild = Padding(
      padding: contentPadding,
      child: child,
    );

    // Always return the same widget-tree shape so that the
    // CustomScrollView inside `child` is updated instead of recreated.
    final overlayColor = palette.fullscreenOverlayColor;
    final iconColor = palette.fullscreenIconColor;

    return Listener(
      behavior: isFullscreenReader
          ? HitTestBehavior.translucent
          : HitTestBehavior.deferToChild,
      onPointerDown: isFullscreenReader ? (_) => _revealRestoreButton() : null,
      child: Stack(
        children: [
          Positioned.fill(child: paddedChild),
          if (muallimSnapshot.isEnabled)
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              child: MuallimPlaybackControls(
                snapshot: muallimSnapshot,
                onPreviousAyah: () => unawaited(
                  ref
                      .read(muallimStateProvider.notifier)
                      .previousAyah(context: context),
                ),
                onPrimaryAction: () => unawaited(
                  ref.read(muallimStateProvider.notifier).togglePlayback(
                        navigationTarget,
                        context: context,
                        isDarkMode: palette.useDarkReaderLibrary,
                      ),
                ),
                onNextAyah: () => unawaited(
                  ref.read(muallimStateProvider.notifier).nextAyah(
                        context: context,
                      ),
                ),
                onStop: () => unawaited(
                  ref.read(muallimStateProvider.notifier).stop(),
                ),
                onSelectReciter: () => unawaited(
                  _showMuallimReciterPicker(
                    muallimSnapshot,
                    isDarkMode: palette.useDarkReaderLibrary,
                  ),
                ),
                onRetry: () => unawaited(
                  ref.read(muallimStateProvider.notifier).togglePlayback(
                        navigationTarget,
                        context: context,
                        isDarkMode: palette.useDarkReaderLibrary,
                      ),
                ),
              ),
            ),
          if (isFullscreenReader)
            PositionedDirectional(
              top: MediaQuery.paddingOf(context).top + 12,
              end: 12,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _showRestoreButton ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_showRestoreButton,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: overlayColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.fullscreen_exit_rounded,
                        color: iconColor,
                      ),
                      tooltip: context.l10n.restoreReaderChrome,
                      onPressed: _exitFullscreenReader,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showVerseActionMenu(
    LongPressStartDetails details,
    AyahModel ayahModel,
  ) {
    final surahNumber = ayahModel.surahNumber;
    if (surahNumber == null) {
      return;
    }

    final entityAyah = entity.Ayah(
      id: ayahModel.ayahUQNumber,
      surahNumber: surahNumber,
      ayahNumber: ayahModel.ayahNumber,
      text: ayahModel.text,
      page: ayahModel.page,
      juz: ayahModel.juz,
      hizb: ayahModel.hizb ?? 0,
    );

    _showVerseActionMenuForAyah(entityAyah);
  }

  Widget _buildPageMode(
    ReaderNightPalette palette,
    String appLanguageCode,
  ) {
    return QuranLibraryScreen(
      parentContext: context,
      withPageView: true,
      pagingPerformanceProfile:
          const QuranPagingPerformanceProfile.fastInteractive(),
      enableWordSelection:
          ReaderInteractionPolicy.shouldEnablePackageWordSelection(
        ReaderMode.page,
      ),
      useDefaultAppBar: false,
      showAyahBookmarkedIcon: true,
      isDark: palette.useDarkReaderLibrary,
      appLanguageCode: appLanguageCode,
      backgroundColor: palette.backgroundColor,
      textColor: palette.textColor,
      onPageChanged: (pageIndex) => _syncReadingPositionForPage(pageIndex + 1),
      ayahSelectedBackgroundColor: palette.selectedAyahBackgroundColor,
      ayahIconColor: palette.accentColor,
      basmalaStyle: BasmalaStyle(
        basmalaColor: palette.textColor.withValues(alpha: 0.8),
      ),
      downloadFontsDialogStyle: _getFontsDialogStyle(palette),
      onAyahLongPress: _showVerseActionMenu,
      isShowTabBar: false,
      isShowAudioSlider: false,
    );
  }

  Widget _buildTranslationMode(
    ReaderNavigationTarget navigationTarget,
    ReaderNightPalette palette,
  ) {
    return TranslationModeView(
      navigationTarget: navigationTarget,
      palette: palette,
      onAyahLongPress: _showVerseActionMenuForAyah,
    );
  }

  Widget _buildScrollMode({
    required ReaderNightPalette palette,
    required ReaderNavigationTarget navigationTarget,
    required bool isFullscreenReader,
    required String appLanguageCode,
  }) {
    final showExternalBanner = ReaderChromePolicy.shouldShowExternalBanner(
      ReaderMode.scroll,
      isFullscreen: isFullscreenReader,
    );

    return CustomScrollView(
      controller: _scrollController,
      cacheExtent: continuousSurahScrollPolicy.scrollCacheExtent,
      physics: const ClampingScrollPhysics(),
      slivers: [
        // Always keep two slivers so ContinuousSurahContent stays at
        // position 1 and Flutter preserves its state across banner changes.
        if (showExternalBanner)
          ref.watch(surahsProvider).when(
                data: (surahs) {
                  final l10n = context.l10n;
                  final surah = surahs.firstWhere(
                    (item) => item.number == navigationTarget.surahNumber,
                    orElse: () => surahs.first,
                  );
                  return TornPaperBanner(
                    title: '${l10n.surahPrefix} ${surah.nameArabic}',
                    palette: palette,
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox()),
                error: (_, __) => SliverToBoxAdapter(
                  child: AppErrorWidget(
                    message: context.l10n.errorLoadingData,
                    onRetry: () => ref.invalidate(surahsProvider),
                  ),
                ),
              )
        else
          const SliverToBoxAdapter(child: SizedBox.shrink()),
        ContinuousSurahContent(
          key: const ValueKey<String>('continuous_surah_scroll'),
          surahNumber: navigationTarget.surahNumber,
          scrollController: _scrollController,
          targetPageNumber: navigationTarget.pageNumber,
          hasLeadingBanner: showExternalBanner,
          parentContext: context,
          enableWordSelection:
              ReaderInteractionPolicy.shouldEnablePackageWordSelection(
            ReaderMode.scroll,
          ),
          isDark: palette.useDarkReaderLibrary,
          appLanguageCode: appLanguageCode,
          textColor: palette.textColor,
          ayahSelectedBackgroundColor: palette.selectedAyahBackgroundColor,
          ayahIconColor: palette.accentColor,
          basmalaStyle: BasmalaStyle(
            basmalaColor: palette.textColor.withValues(alpha: 0.8),
          ),
          onAyahLongPress: _showVerseActionMenu,
          onVisiblePageChanged: _handleScrollVisiblePageChanged,
        ),
      ],
    );
  }

  DownloadFontsDialogStyle _getFontsDialogStyle(ReaderNightPalette palette) {
    final l10n = context.l10n;
    return DownloadFontsDialogStyle(
      headerTitle: l10n.mushafFontsTitle,
      titleColor: palette.textColor,
      notes: l10n.mushafFontsNotes,
      notesColor: palette.mutedTextColor,
      linearProgressBackgroundColor: AppColors.gold.withValues(alpha: 0.3),
      linearProgressColor: AppColors.gold,
      downloadButtonBackgroundColor: AppColors.gold,
      downloadingText: l10n.mushafFontsDownloading,
      backgroundColor: palette.backgroundColor,
    );
  }
}
