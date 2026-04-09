part of '/quran.dart';

const QuranPagingPerformanceProfile continuousSurahScrollPerformanceProfile =
    QuranPagingPerformanceProfile(
  pageViewPreloadCount: 0,
  interactiveFontLoadRadius: 1,
  interactiveQpcPrewarmRadius: 1,
  enableIdleFullPrebuild: false,
  idleFullPrebuildDelay: Duration.zero,
);

const ContinuousSurahScrollPolicy continuousSurahScrollPolicy =
    ContinuousSurahScrollPolicy(
  currentPagePrimeRadius: 0,
  preloadBehindRadius: 0,
  preloadAheadRadius: 1,
  scrollCacheExtent: 480.0,
);

/// Quran QCF content for a single surah rendered as one continuous vertical flow.
///
/// This keeps the original QCF page glyph layout while removing visible page
/// chrome so the surah reads as one connected scroll.
class ContinuousSurahContent extends StatefulWidget {
  const ContinuousSurahContent({
    super.key,
    required this.surahNumber,
    required this.parentContext,
    this.scrollController,
    this.targetPageNumber,
    this.hasLeadingBanner = false,
    this.ayahIconColor,
    this.ayahSelectedBackgroundColor,
    this.ayahSelectedFontColor,
    this.basmalaStyle,
    this.bookmarkList = const [],
    this.bookmarksColor,
    this.circularProgressWidget,
    this.isDark = false,
    this.appLanguageCode,
    this.onAyahLongPress,
    this.showAyahBookmarkedIcon = true,
    this.textColor,
    this.ayahBookmarked = const [],
    this.isAyahBookmarked,
    this.enableWordSelection = true,
    this.onVisiblePageChanged,
  });

  final int surahNumber;
  final BuildContext parentContext;
  final ScrollController? scrollController;
  final int? targetPageNumber;
  final bool hasLeadingBanner;
  final Color? ayahIconColor;
  final Color? ayahSelectedBackgroundColor;
  final Color? ayahSelectedFontColor;
  final BasmalaStyle? basmalaStyle;
  final List bookmarkList;
  final Color? bookmarksColor;
  final Widget? circularProgressWidget;
  final bool isDark;
  final String? appLanguageCode;
  final void Function(LongPressStartDetails details, AyahModel ayah)?
      onAyahLongPress;
  final bool showAyahBookmarkedIcon;
  final Color? textColor;
  final List<int> ayahBookmarked;
  final bool Function(AyahModel ayah)? isAyahBookmarked;
  final bool enableWordSelection;
  final ValueChanged<int>? onVisiblePageChanged;

  @override
  State<ContinuousSurahContent> createState() => _ContinuousSurahContentState();
}

class _ContinuousSurahContentState extends State<ContinuousSurahContent> {
  static const double _leadingBannerOffset = 204.0;

  final SurahCtrl _surahCtrl = SurahCtrl.instance;
  final QuranCtrl _quranCtrl = QuranCtrl.instance;
  final ContinuousSurahScrollPolicy _scrollPolicy = continuousSurahScrollPolicy;
  final Map<int, GlobalKey> _pageKeys = <int, GlobalKey>{};
  final Map<int, double> _sectionExtents = <int, double>{};
  final Set<int> _warmedSectionIndexes = <int>{};

  int? _lastScrolledTargetPageNumber;
  int? _lastReportedVisiblePageNumber;

  @override
  void initState() {
    super.initState();
    _attachScrollListener();
    _loadSurah();
  }

  @override
  void dispose() {
    _detachScrollListener(widget.scrollController);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ContinuousSurahContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _detachScrollListener(oldWidget.scrollController);
      _attachScrollListener();
    }
    if (oldWidget.surahNumber != widget.surahNumber) {
      _lastScrolledTargetPageNumber = null;
      _lastReportedVisiblePageNumber = null;
      _loadSurah();
      return;
    }

    if (oldWidget.targetPageNumber != widget.targetPageNumber) {
      _scheduleScrollToTargetPage();
    }
  }

  Future<void> _loadSurah() async {
    await _surahCtrl.loadSurah(widget.surahNumber);

    if (!mounted || _surahCtrl.surahPages.isEmpty) {
      return;
    }

    _pageKeys.clear();
    _sectionExtents.clear();
    _warmedSectionIndexes.clear();
    final firstPageNumber = _surahCtrl.surahPages.first.pageNumber;
    _quranCtrl.state.currentPageNumber.value = firstPageNumber;
    _reportVisiblePage(widget.targetPageNumber ?? firstPageNumber);

    Future(() async {
      await QuranFontsService.ensurePagesLoaded(
        firstPageNumber,
        radius: _scrollPolicy.initialWarmRadius,
      );
      await _quranCtrl.prewarmQpcV4Pages(
        firstPageNumber - 1,
        neighborRadius: _scrollPolicy.initialWarmRadius,
      );
      if (mounted) {
        setState(() {});
      }
    });

    _scheduleScrollToTargetPage();
  }

  void _warmVisibleWindowAround(int anchorIndex) {
    if (_surahCtrl.surahPages.isEmpty ||
        !_warmedSectionIndexes.add(anchorIndex)) {
      return;
    }

    final sectionIndexes = _scrollPolicy.preloadWindow(
      anchorIndex: anchorIndex,
      itemCount: _surahCtrl.surahPages.length,
    );

    Future(() async {
      for (final sectionIndex in sectionIndexes) {
        final pageNumber = _surahCtrl.surahPages[sectionIndex].pageNumber;
        await QuranFontsService.ensurePagesLoaded(
          pageNumber,
          radius: _scrollPolicy.currentPagePrimeRadius,
        );
        await _quranCtrl.prewarmQpcV4Pages(
          pageNumber - 1,
          neighborRadius: _scrollPolicy.currentPagePrimeRadius,
        );
      }
    });
  }

  void _recordSectionExtent(int sectionIndex, double extent) {
    if (extent <= 0) {
      return;
    }
    _sectionExtents[sectionIndex] = extent;
  }

  void _attachScrollListener() {
    widget.scrollController?.addListener(_handleScrollPositionChange);
  }

  void _detachScrollListener(ScrollController? controller) {
    controller?.removeListener(_handleScrollPositionChange);
  }

  void _handleScrollPositionChange() {
    _maybeReportVisiblePage();
  }

  void _reportVisiblePage(int pageNumber) {
    if (pageNumber == _lastReportedVisiblePageNumber) {
      return;
    }

    _lastReportedVisiblePageNumber = pageNumber;
    widget.onVisiblePageChanged?.call(pageNumber);
  }

  void _maybeReportVisiblePage() {
    final visiblePageNumber = _estimateVisiblePageNumber();
    if (visiblePageNumber == null) {
      return;
    }

    _reportVisiblePage(visiblePageNumber);
  }

  int? _estimateVisiblePageNumber() {
    if (_surahCtrl.surahPages.isEmpty) {
      return widget.targetPageNumber;
    }

    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) {
      return widget.targetPageNumber ?? _surahCtrl.surahPages.first.pageNumber;
    }

    final leadingOffset =
        widget.hasLeadingBanner ? _leadingBannerOffset : 0.0;
    final probeOffset = math.max(
      0.0,
      controller.offset + (controller.position.viewportDimension * 0.25),
    );
    final contentOffset = math.max(0.0, probeOffset - leadingOffset);
    final averageExtent = _averageSectionExtent();

    double runningOffset = 0.0;
    for (int index = 0; index < _surahCtrl.surahPages.length; index++) {
      final extent = _sectionExtents[index] ?? averageExtent;
      final nextOffset = runningOffset + extent;
      if (contentOffset < nextOffset) {
        return _surahCtrl.surahPages[index].pageNumber;
      }
      runningOffset = nextOffset;
    }

    return _surahCtrl.surahPages.last.pageNumber;
  }

  double _averageSectionExtent() {
    if (_sectionExtents.isEmpty) {
      return _scrollPolicy.fallbackSectionExtent;
    }

    double total = 0.0;
    for (final extent in _sectionExtents.values) {
      total += extent;
    }

    return total / _sectionExtents.length;
  }

  void _scheduleScrollToTargetPage({int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final targetPageNumber = widget.targetPageNumber;
      if (targetPageNumber == null ||
          targetPageNumber == _lastScrolledTargetPageNumber) {
        return;
      }

      final targetIndex = _surahCtrl.surahPages.indexWhere(
        (page) => page.pageNumber == targetPageNumber,
      );
      if (targetIndex == -1) {
        return;
      }

      final targetContext = _pageKeys[targetPageNumber]?.currentContext;
      if (targetContext != null) {
        _lastScrolledTargetPageNumber = targetPageNumber;
        _reportVisiblePage(targetPageNumber);
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
        );
        return;
      }

      final controller = widget.scrollController;
      if (controller == null || !controller.hasClients || attempt >= 4) {
        return;
      }

      final estimatedOffset = _scrollPolicy.estimateScrollOffset(
        targetIndex: targetIndex,
        measuredExtents: _sectionExtents,
        leadingOffset: widget.hasLeadingBanner ? _leadingBannerOffset : 0.0,
      );
      final position = controller.position;
      final clampedOffset = estimatedOffset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      controller.jumpTo(clampedOffset.toDouble());
      _scheduleScrollToTargetPage(attempt: attempt + 1);
    });
  }

  GlobalKey _pageKeyFor(int realPageNumber) {
    return _pageKeys.putIfAbsent(realPageNumber, GlobalKey.new);
  }

  @override
  Widget build(BuildContext context) {
    AudioCtrl.instance;
    WordInfoCtrl.instance.isWordSelectionEnabled = widget.enableWordSelection;

    final String deviceLocale = Localizations.localeOf(context).languageCode;
    final String languageCode = widget.appLanguageCode ?? deviceLocale;

    return ScaleKitBuilder(
      designWidth: 375,
      designHeight: 812,
      designType: DeviceType.mobile,
      child: QuranLibraryTheme(
        snackBarStyle:
            SnackBarStyle.defaults(isDark: widget.isDark, context: context),
        ayahLongClickStyle:
            AyahMenuStyle.defaults(isDark: widget.isDark, context: context),
        indexTabStyle:
            IndexTabStyle.defaults(isDark: widget.isDark, context: context),
        topBarStyle:
            QuranTopBarStyle.defaults(isDark: widget.isDark, context: context),
        tajweedMenuStyle:
            TajweedMenuStyle.defaults(isDark: widget.isDark, context: context),
        searchTabStyle:
            SearchTabStyle.defaults(isDark: widget.isDark, context: context),
        surahInfoStyle:
            SurahInfoStyle.defaults(isDark: widget.isDark, context: context),
        tafsirStyle:
            TafsirStyle.defaults(isDark: widget.isDark, context: context),
        bookmarksTabStyle:
            BookmarksTabStyle.defaults(isDark: widget.isDark, context: context),
        topBottomQuranStyle: TopBottomQuranStyle.defaults(
          isDark: widget.isDark,
          context: context,
        ),
        ayahDownloadManagerStyle: AyahDownloadManagerStyle.defaults(
          isDark: widget.isDark,
          context: context,
        ),
        child: GetBuilder<SurahCtrl>(
          init: _surahCtrl,
          builder: (surahCtrl) {
            if (surahCtrl.isLoading.value) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: widget.circularProgressWidget ??
                        const CircularProgressIndicator.adaptive(),
                  ),
                ),
              );
            }

            if (surahCtrl.surahPages.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'ظ„ط§ طھظˆط¬ط¯ ط¢ظٹط§طھ ظ„ظ„ط³ظˆط±ط© ط§ظ„ظ…ط­ط¯ط¯ط©',
                      style: TextStyle(
                        color: AppColors.getTextColor(widget.isDark),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }

            _scheduleScrollToTargetPage();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SliverPadding(
                padding: const EdgeInsets.only(bottom: 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, pageIndex) => _ContinuousSurahPageSection(
                      key: _pageKeyFor(
                        surahCtrl.surahPages[pageIndex].pageNumber,
                      ),
                      userContext: widget.parentContext,
                      surahPage: surahCtrl.surahPages[pageIndex],
                      globalPageIndex:
                          surahCtrl.surahPages[pageIndex].pageNumber - 1,
                      pageIndex: pageIndex,
                      surahNumber: widget.surahNumber,
                      isDark: widget.isDark,
                      languageCode: languageCode,
                      circularProgressWidget: widget.circularProgressWidget,
                      bookmarkList: widget.bookmarkList,
                      bookmarksColor: widget.bookmarksColor,
                      textColor: widget.textColor,
                      ayahSelectedFontColor: widget.ayahSelectedFontColor,
                      ayahSelectedBackgroundColor:
                          widget.ayahSelectedBackgroundColor,
                      ayahIconColor: widget.ayahIconColor,
                      showAyahBookmarkedIcon: widget.showAyahBookmarkedIcon,
                      ayahBookmarked: widget.ayahBookmarked,
                      isAyahBookmarked: widget.isAyahBookmarked,
                      onAyahLongPress: widget.onAyahLongPress,
                      basmalaStyle: widget.basmalaStyle,
                      pagingPerformanceProfile:
                          continuousSurahScrollPerformanceProfile,
                      scrollPolicy: _scrollPolicy,
                      onSectionVisible: _warmVisibleWindowAround,
                      onExtentResolved: _recordSectionExtent,
                    ),
                    childCount: surahCtrl.surahPages.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ContinuousSurahPageSection extends StatefulWidget {
  const _ContinuousSurahPageSection({
    super.key,
    required this.userContext,
    required this.surahPage,
    required this.globalPageIndex,
    required this.pageIndex,
    required this.surahNumber,
    required this.isDark,
    required this.languageCode,
    this.circularProgressWidget,
    this.bookmarkList,
    this.bookmarksColor,
    this.textColor,
    this.ayahSelectedFontColor,
    this.ayahSelectedBackgroundColor,
    this.ayahIconColor,
    this.showAyahBookmarkedIcon = true,
    this.ayahBookmarked = const [],
    this.isAyahBookmarked,
    this.onAyahLongPress,
    this.basmalaStyle,
    required this.pagingPerformanceProfile,
    required this.scrollPolicy,
    required this.onSectionVisible,
    required this.onExtentResolved,
  });

  final BuildContext userContext;
  final QuranPageModel surahPage;
  final int globalPageIndex;
  final int pageIndex;
  final int surahNumber;
  final bool isDark;
  final String languageCode;
  final Widget? circularProgressWidget;
  final List? bookmarkList;
  final Color? bookmarksColor;
  final Color? textColor;
  final Color? ayahSelectedFontColor;
  final Color? ayahSelectedBackgroundColor;
  final Color? ayahIconColor;
  final bool showAyahBookmarkedIcon;
  final List<int> ayahBookmarked;
  final bool Function(AyahModel ayah)? isAyahBookmarked;
  final void Function(LongPressStartDetails details, AyahModel ayah)?
      onAyahLongPress;
  final BasmalaStyle? basmalaStyle;
  final QuranPagingPerformanceProfile pagingPerformanceProfile;
  final ContinuousSurahScrollPolicy scrollPolicy;
  final ValueChanged<int> onSectionVisible;
  final void Function(int sectionIndex, double extent) onExtentResolved;

  @override
  State<_ContinuousSurahPageSection> createState() =>
      _ContinuousSurahPageSectionState();
}

class _ContinuousSurahPageSectionState
    extends State<_ContinuousSurahPageSection> {
  bool _requestedCurrentPage = false;
  double? _lastReportedExtent;

  @override
  void initState() {
    super.initState();
    _primeSection();
  }

  @override
  void didUpdateWidget(covariant _ContinuousSurahPageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.globalPageIndex != widget.globalPageIndex) {
      _requestedCurrentPage = false;
      _lastReportedExtent = null;
      _primeSection();
    }
  }

  void _primeSection() {
    widget.onSectionVisible(widget.pageIndex);

    if (_requestedCurrentPage) {
      return;
    }

    _requestedCurrentPage = true;
    final realPageNumber = widget.globalPageIndex + 1;
    Future(() async {
      await QuranFontsService.ensurePagesLoaded(
        realPageNumber,
        radius: widget.scrollPolicy.currentPagePrimeRadius,
      );
      await QuranCtrl.instance.prewarmQpcV4Pages(
        realPageNumber - 1,
        neighborRadius: widget.scrollPolicy.currentPagePrimeRadius,
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _reportExtentAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final extent = context.size?.height;
      if (extent == null || extent <= 0 || extent == _lastReportedExtent) {
        return;
      }

      _lastReportedExtent = extent;
      widget.onExtentResolved(widget.pageIndex, extent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int realPageNumber = widget.globalPageIndex + 1;

    if (!QuranFontsService.isPageReady(realPageNumber)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: widget.circularProgressWidget ??
              const CircularProgressIndicator.adaptive(),
        ),
      );
    }

    final bool showStandaloneBasmala = widget.pageIndex == 0 &&
        widget.surahNumber != 1 &&
        widget.surahNumber != 9;

    _reportExtentAfterLayout();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UiHelper.currentOrientation(16.0, 64.0, widget.userContext),
      ),
      child: RepaintBoundary(
        key: ValueKey(
          'continuous_surah_page_${widget.surahNumber}_${widget.pageIndex}',
        ),
        child: GetBuilder<SurahCtrl>(
          id: '_continuous_surah_page_$realPageNumber',
          builder: (_) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showStandaloneBasmala)
                  BasmallahWidget(
                    surahNumber: widget.surahNumber,
                    basmalaStyle: BasmalaStyle(
                      basmalaColor: AppColors.getTextColor(widget.isDark),
                      basmalaFontSize: 22.0.sp.clamp(22, 50),
                      verticalPadding: 0.0,
                    ).merge(widget.basmalaStyle),
                  ),
                GetBuilder<BookmarksCtrl>(
                  id: 'bookmarks',
                  builder: (bookmarksCtrl) {
                    return PageBuild(
                      pageIndex: widget.globalPageIndex,
                      surahNumber: widget.surahNumber,
                      surahFilterNumber: widget.surahNumber,
                      bannerStyle: null,
                      isDark: widget.isDark,
                      surahNameStyle: null,
                      onSurahBannerPress: null,
                      basmalaStyle: widget.basmalaStyle,
                      textColor:
                          widget.ayahSelectedFontColor ?? widget.textColor,
                      bookmarks: bookmarksCtrl.bookmarks,
                      onAyahLongPress: widget.onAyahLongPress,
                      bookmarkList: widget.bookmarkList,
                      ayahIconColor: widget.ayahIconColor,
                      showAyahBookmarkedIcon: widget.showAyahBookmarkedIcon,
                      bookmarksAyahs: bookmarksCtrl.bookmarksAyahs,
                      bookmarksColor: widget.bookmarksColor,
                      ayahSelectedBackgroundColor:
                          widget.ayahSelectedBackgroundColor,
                      isFontsLocal: false,
                      fontsName: '',
                      ayahBookmarked: widget.ayahBookmarked,
                      isAyahBookmarked: widget.isAyahBookmarked,
                      context: context,
                      quranCtrl: QuranCtrl.instance,
                      pagingPerformanceProfile: widget.pagingPerformanceProfile,
                      normalizeBaqarahOpeningLayout: true,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
