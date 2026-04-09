import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/onboarding/domain/startup_route_policy.dart';

void main() {
  group('StartupRoutePolicy', () {
    test('routes users with incomplete onboarding to onboarding first', () {
      expect(
        StartupRoutePolicy.resolve(
          isOnboardingComplete: false,
          isMushafSetupComplete: false,
        ),
        StartupRouteTarget.onboarding,
      );
    });

    test('routes users with finished onboarding and incomplete setup to bridge',
        () {
      expect(
        StartupRoutePolicy.resolve(
          isOnboardingComplete: true,
          isMushafSetupComplete: false,
        ),
        StartupRouteTarget.mushafSetup,
      );
    });

    test('routes fully prepared users to the surah library', () {
      expect(
        StartupRoutePolicy.resolve(
          isOnboardingComplete: true,
          isMushafSetupComplete: true,
        ),
        StartupRouteTarget.library,
      );
    });

    test('routes onboarding exit to loading bridge while setup is incomplete',
        () {
      expect(
        StartupRoutePolicy.resolveAfterOnboarding(
          isMushafSetupComplete: false,
        ),
        StartupRouteTarget.mushafSetup,
      );
    });

    test('routes onboarding exit directly to the library when setup finished',
        () {
      expect(
        StartupRoutePolicy.resolveAfterOnboarding(
          isMushafSetupComplete: true,
        ),
        StartupRouteTarget.library,
      );
    });
  });
}
