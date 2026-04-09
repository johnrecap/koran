import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('ContinuousSurahScrollPolicy', () {
    test(
        'continuous scroll defaults split current-page prime from forward preload',
        () {
      expect(continuousSurahScrollPolicy.currentPagePrimeRadius, 0);
      expect(continuousSurahScrollPolicy.preloadBehindRadius, 0);
      expect(continuousSurahScrollPolicy.preloadAheadRadius, 1);
      expect(continuousSurahScrollPolicy.scrollCacheExtent, 480);
    });

    test('preload window biases ahead and excludes the current section', () {
      const policy = ContinuousSurahScrollPolicy(
        preloadBehindRadius: 0,
        preloadAheadRadius: 1,
      );

      expect(
        policy.preloadWindow(anchorIndex: 0, itemCount: 4),
        {1},
      );
      expect(
        policy.preloadWindow(anchorIndex: 2, itemCount: 4),
        {3},
      );
      expect(
        policy.preloadWindow(anchorIndex: 3, itemCount: 4),
        <int>{},
      );
    });

    test('estimates offset from measured extents and fallback average', () {
      const policy = ContinuousSurahScrollPolicy(fallbackSectionExtent: 500);

      final offset = policy.estimateScrollOffset(
        targetIndex: 3,
        measuredExtents: {
          0: 600,
          2: 900,
        },
        leadingOffset: 100,
      );

      expect(offset, 2350);
    });
  });
}
