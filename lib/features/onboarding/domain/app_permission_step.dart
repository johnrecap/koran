import 'package:flutter/material.dart';

/// Types of permissions the app may request during the first-launch flow.
enum AppPermissionType {
  notifications,
  location,
}

/// Status of a single permission step.
enum AppPermissionStepStatus {
  /// Not yet requested.
  pending,

  /// Granted by the user.
  granted,

  /// Denied by the user.
  denied,

  /// Permanently blocked — user must go to system settings.
  blocked,
}

/// A single permission step displayed in the permission request screen.
class AppPermissionStep {
  const AppPermissionStep({
    required this.type,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    this.status = AppPermissionStepStatus.pending,
  });

  final AppPermissionType type;

  /// Localization key for the title (resolved via AppLocalizations).
  final String titleKey;

  /// Localization key for the description.
  final String descriptionKey;

  final IconData icon;

  final AppPermissionStepStatus status;

  AppPermissionStep copyWith({AppPermissionStepStatus? status}) {
    return AppPermissionStep(
      type: type,
      titleKey: titleKey,
      descriptionKey: descriptionKey,
      icon: icon,
      status: status ?? this.status,
    );
  }
}
