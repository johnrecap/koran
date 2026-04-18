import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/onboarding/domain/startup_route_policy.dart';

void main() {
  group('StartupRoutePolicy', () {
    test('routes users with incomplete onboarding to onboarding first', () {
      expect(
        StartupRoutePolicy.resolve(
          isOnboardingComplete: false,
          isPermissionsFlowComplete: false,
          isMushafSetupComplete: false,
        ),
        StartupRouteTarget.onboarding,
      );
    });

    test('routes users after onboarding to permissions when not completed', () {
      expect(
        StartupRoutePolicy.resolve(
          isOnboardingComplete: true,
          isPermissionsFlowComplete: false,
          isMushafSetupComplete: false,
        ),
        StartupRouteTarget.permissions,
      );
    });

    test(
        'routes users with finished permissions and incomplete setup to bridge',
        () {
      expect(
        StartupRoutePolicy.resolve(
          isOnboardingComplete: true,
          isPermissionsFlowComplete: true,
          isMushafSetupComplete: false,
        ),
        StartupRouteTarget.mushafSetup,
      );
    });

    test('routes fully prepared users to the surah library', () {
      expect(
        StartupRoutePolicy.resolve(
          isOnboardingComplete: true,
          isPermissionsFlowComplete: true,
          isMushafSetupComplete: true,
        ),
        StartupRouteTarget.library,
      );
    });

    test('routes onboarding exit to permissions when not yet completed', () {
      expect(
        StartupRoutePolicy.resolveAfterOnboarding(
          isPermissionsFlowComplete: false,
          isMushafSetupComplete: false,
        ),
        StartupRouteTarget.permissions,
      );
    });

    test(
        'routes onboarding exit to loading bridge when permissions done but setup incomplete',
        () {
      expect(
        StartupRoutePolicy.resolveAfterOnboarding(
          isPermissionsFlowComplete: true,
          isMushafSetupComplete: false,
        ),
        StartupRouteTarget.mushafSetup,
      );
    });

    test('routes onboarding exit directly to the library when all finished',
        () {
      expect(
        StartupRoutePolicy.resolveAfterOnboarding(
          isPermissionsFlowComplete: true,
          isMushafSetupComplete: true,
        ),
        StartupRouteTarget.library,
      );
    });
  });
}
