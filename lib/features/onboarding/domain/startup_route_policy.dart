enum StartupRouteTarget {
  onboarding('/onboarding'),
  permissions('/permissions'),
  mushafSetup('/setup-mushaf'),
  library('/library');

  const StartupRouteTarget(this.path);

  final String path;
}

abstract final class StartupRoutePolicy {
  static StartupRouteTarget resolve({
    required bool isOnboardingComplete,
    required bool isPermissionsFlowComplete,
    required bool isMushafSetupComplete,
  }) {
    if (!isOnboardingComplete) {
      return StartupRouteTarget.onboarding;
    }

    return resolveAfterOnboarding(
      isPermissionsFlowComplete: isPermissionsFlowComplete,
      isMushafSetupComplete: isMushafSetupComplete,
    );
  }

  static StartupRouteTarget resolveAfterOnboarding({
    required bool isPermissionsFlowComplete,
    required bool isMushafSetupComplete,
  }) {
    if (!isPermissionsFlowComplete) {
      return StartupRouteTarget.permissions;
    }
    return isMushafSetupComplete
        ? StartupRouteTarget.library
        : StartupRouteTarget.mushafSetup;
  }
}
