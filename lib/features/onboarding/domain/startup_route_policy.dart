enum StartupRouteTarget {
  onboarding('/onboarding'),
  mushafSetup('/setup-mushaf'),
  library('/library');

  const StartupRouteTarget(this.path);

  final String path;
}

abstract final class StartupRoutePolicy {
  static StartupRouteTarget resolve({
    required bool isOnboardingComplete,
    required bool isMushafSetupComplete,
  }) {
    if (!isOnboardingComplete) {
      return StartupRouteTarget.onboarding;
    }

    return resolveAfterOnboarding(
      isMushafSetupComplete: isMushafSetupComplete,
    );
  }

  static StartupRouteTarget resolveAfterOnboarding({
    required bool isMushafSetupComplete,
  }) {
    return isMushafSetupComplete
        ? StartupRouteTarget.library
        : StartupRouteTarget.mushafSetup;
  }
}
