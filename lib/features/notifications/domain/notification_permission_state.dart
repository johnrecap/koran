enum NotificationPermissionState {
  unknown,
  granted,
  denied,
  blocked,
  unavailable,
}

extension NotificationPermissionStateX on NotificationPermissionState {
  bool get isGranted => this == NotificationPermissionState.granted;

  bool get canRequestPermission {
    return switch (this) {
      NotificationPermissionState.unknown => true,
      NotificationPermissionState.granted => false,
      NotificationPermissionState.denied => true,
      NotificationPermissionState.blocked => false,
      NotificationPermissionState.unavailable => false,
    };
  }

  bool get isUnavailable =>
      this == NotificationPermissionState.blocked ||
      this == NotificationPermissionState.unavailable;
}
