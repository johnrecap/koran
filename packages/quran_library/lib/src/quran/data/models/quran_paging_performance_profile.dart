part of '/quran.dart';

/// Configures how aggressively page mode prepares nearby pages during flips.
class QuranPagingPerformanceProfile {
  const QuranPagingPerformanceProfile({
    this.pageViewPreloadCount = 2,
    this.interactiveFontLoadRadius = 10,
    this.interactiveQpcPrewarmRadius = 2,
    this.enableIdleFullPrebuild = true,
    this.idleFullPrebuildDelay = const Duration(seconds: 2),
  })  : assert(pageViewPreloadCount >= 0),
        assert(interactiveFontLoadRadius >= 0),
        assert(interactiveQpcPrewarmRadius >= 0);

  const QuranPagingPerformanceProfile.standard()
      : this(
          pageViewPreloadCount: 2,
          interactiveFontLoadRadius: 10,
          interactiveQpcPrewarmRadius: 2,
          enableIdleFullPrebuild: true,
          idleFullPrebuildDelay: const Duration(seconds: 2),
        );

  const QuranPagingPerformanceProfile.fastInteractive()
      : this(
          pageViewPreloadCount: 1,
          interactiveFontLoadRadius: 1,
          interactiveQpcPrewarmRadius: 1,
          enableIdleFullPrebuild: false,
          idleFullPrebuildDelay: Duration.zero,
        );

  final int pageViewPreloadCount;
  final int interactiveFontLoadRadius;
  final int interactiveQpcPrewarmRadius;
  final bool enableIdleFullPrebuild;
  final Duration idleFullPrebuildDelay;
}
