part of '/quran.dart';

class PageMotionDecision {
  const PageMotionDecision({
    required this.showLive,
    required this.showSnapshot,
    required this.shouldCapture,
  });

  final bool showLive;
  final bool showSnapshot;
  final bool shouldCapture;

  static PageMotionDecision resolve({
    required double pagePosition,
    required int pageIndex,
    required bool hasSnapshot,
    required bool isCapturePending,
    double settledEpsilon = 0.01,
    double neighborCaptureRadius = 1.0,
  }) {
    final distanceFromPage = (pagePosition - pageIndex).abs();
    final isSettled =
        (pagePosition - pagePosition.roundToDouble()).abs() < settledEpsilon;
    final isSettledActivePage = isSettled && distanceFromPage < settledEpsilon;
    final showSnapshot = hasSnapshot && !isSettledActivePage;
    final shouldCapture = !hasSnapshot &&
        !isCapturePending &&
        isSettled &&
        distanceFromPage <= neighborCaptureRadius;

    return PageMotionDecision(
      showLive: !showSnapshot,
      showSnapshot: showSnapshot,
      shouldCapture: shouldCapture,
    );
  }
}

class PageMotionSurface extends StatefulWidget {
  const PageMotionSurface({
    super.key,
    required this.pageIndex,
    required this.controller,
    required this.child,
    this.cacheService,
    this.snapshotPixelRatio = 1.5,
    this.neighborCaptureRadius = 1.0,
  });

  final int pageIndex;
  final PreloadPageController controller;
  final Widget child;
  final PageSnapshotCacheService? cacheService;
  final double snapshotPixelRatio;
  final double neighborCaptureRadius;

  @override
  State<PageMotionSurface> createState() => _PageMotionSurfaceState();
}

class _PageMotionSurfaceState extends State<PageMotionSurface> {
  final GlobalKey _captureBoundaryKey = GlobalKey();
  bool _captureQueued = false;
  late double _pagePosition;

  PageSnapshotCacheService get _cache =>
      widget.cacheService ?? PageSnapshotCacheService.instance;

  @override
  void initState() {
    super.initState();
    _pagePosition = _readPagePosition();
    widget.controller.addListener(_handleControllerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant PageMotionSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      _pagePosition = _readPagePosition();
      widget.controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  double _readPagePosition() {
    if (widget.controller.hasClients) {
      final page = widget.controller.page;
      if (page != null) {
        return page;
      }
    }
    return widget.controller.initialPage.toDouble();
  }

  void _handleControllerChange() {
    final nextPagePosition = _readPagePosition();
    if ((nextPagePosition - _pagePosition).abs() < 0.0001) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _pagePosition = nextPagePosition;
    });
  }

  void _scheduleCaptureIfNeeded(PageMotionDecision decision) {
    if (!decision.shouldCapture || _captureQueued) {
      return;
    }

    if (!_cache.markPending(widget.pageIndex)) {
      return;
    }

    _captureQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _captureQueued = false;
      if (!mounted) {
        _cache.clearPending(widget.pageIndex);
        return;
      }

      await _captureSnapshot();

      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _captureSnapshot() async {
    try {
      final renderObject =
          _captureBoundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary || renderObject.debugNeedsPaint) {
        _cache.clearPending(widget.pageIndex);
        return;
      }

      final renderedImage = await renderObject.toImage(
        pixelRatio: widget.snapshotPixelRatio.clamp(1.0, 2.0),
      );
      try {
        final byteData =
            await renderedImage.toByteData(format: ImageByteFormat.png);
        if (byteData == null) {
          _cache.clearPending(widget.pageIndex);
          return;
        }

        _cache.put(widget.pageIndex, byteData.buffer.asUint8List());
      } finally {
        renderedImage.dispose();
      }
    } catch (_) {
      _cache.clearPending(widget.pageIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshotBytes = _cache.get(widget.pageIndex);
    final decision = PageMotionDecision.resolve(
      pagePosition: _pagePosition,
      pageIndex: widget.pageIndex,
      hasSnapshot: snapshotBytes != null,
      isCapturePending: _cache.isPending(widget.pageIndex),
      neighborCaptureRadius: widget.neighborCaptureRadius,
    );

    _scheduleCaptureIfNeeded(decision);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Offstage(
            offstage: !decision.showLive,
            child: RepaintBoundary(
              key: _captureBoundaryKey,
              child: widget.child,
            ),
          ),
        ),
        if (decision.showSnapshot && snapshotBytes != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Image.memory(
                snapshotBytes,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
              ),
            ),
          ),
      ],
    );
  }
}
