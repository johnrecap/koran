part of '/quran.dart';

class ContinuousSurahScrollPolicy {
  const ContinuousSurahScrollPolicy({
    this.currentPagePrimeRadius = 0,
    this.preloadBehindRadius = 0,
    this.preloadAheadRadius = 1,
    this.scrollCacheExtent = 480.0,
    this.fallbackSectionExtent = 720.0,
  });

  final int currentPagePrimeRadius;
  final int preloadBehindRadius;
  final int preloadAheadRadius;
  final double scrollCacheExtent;
  final double fallbackSectionExtent;

  int get initialWarmRadius => math.max(
        currentPagePrimeRadius,
        math.max(preloadBehindRadius, preloadAheadRadius),
      );

  Set<int> preloadWindow({
    required int anchorIndex,
    required int itemCount,
  }) {
    if (itemCount <= 0) {
      return const <int>{};
    }

    final start = math.max(0, anchorIndex - preloadBehindRadius);
    final end = math.min(itemCount - 1, anchorIndex + preloadAheadRadius);

    return <int>{
      for (int index = start; index <= end; index++)
        if (index != anchorIndex) index,
    };
  }

  double estimateScrollOffset({
    required int targetIndex,
    required Map<int, double> measuredExtents,
    double leadingOffset = 0,
  }) {
    if (targetIndex <= 0) {
      return leadingOffset;
    }

    double runningOffset = leadingOffset;
    double knownExtentTotal = 0;
    int knownExtentCount = 0;

    measuredExtents.forEach((_, extent) {
      knownExtentTotal += extent;
      knownExtentCount++;
    });

    final averageExtent = knownExtentCount == 0
        ? fallbackSectionExtent
        : knownExtentTotal / knownExtentCount;

    for (int index = 0; index < targetIndex; index++) {
      runningOffset += measuredExtents[index] ?? averageExtent;
    }

    return runningOffset;
  }
}
