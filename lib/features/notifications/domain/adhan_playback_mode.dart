enum AdhanPlaybackMode {
  notificationOnly,
  fullAdhan,
  takbeerOnly;

  static AdhanPlaybackMode fromName(String? name) {
    return AdhanPlaybackMode.values.firstWhere(
      (value) => value.name == name,
      orElse: () => AdhanPlaybackMode.notificationOnly,
    );
  }
}
