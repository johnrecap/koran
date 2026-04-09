import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('QuranPagingPerformanceProfile', () {
    test('fastInteractive uses bounded warmup values for page flips', () {
      const profile = QuranPagingPerformanceProfile.fastInteractive();

      expect(profile.pageViewPreloadCount, 1);
      expect(profile.interactiveFontLoadRadius, 1);
      expect(profile.interactiveQpcPrewarmRadius, 1);
      expect(profile.enableIdleFullPrebuild, isFalse);
      expect(profile.idleFullPrebuildDelay, Duration.zero);
    });

    test('default profile preserves the existing aggressive behavior', () {
      const profile = QuranPagingPerformanceProfile.standard();

      expect(profile.pageViewPreloadCount, 2);
      expect(profile.interactiveFontLoadRadius, 10);
      expect(profile.interactiveQpcPrewarmRadius, 2);
      expect(profile.enableIdleFullPrebuild, isTrue);
      expect(profile.idleFullPrebuildDelay, const Duration(seconds: 2));
    });
  });
}
