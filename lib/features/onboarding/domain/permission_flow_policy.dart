import 'package:quran_kareem/data/datasources/local/user_preferences.dart';

/// Policy that determines whether the centralized permission flow should
/// be shown and manages its completion state.
abstract final class PermissionFlowPolicy {
  /// Returns `true` when the permission flow has already been completed
  /// (the user has seen and interacted with the permission screen at least once).
  static Future<bool> isComplete() async {
    return UserPreferences.isPermissionsFlowComplete();
  }

  /// Mark the permission flow as complete so it is not shown again.
  static Future<void> markComplete() async {
    await UserPreferences.setPermissionsFlowComplete(true);
  }

  /// Returns `true` when the permission screen should be displayed.
  /// This is the inverse of [isComplete] — show only on first launch.
  static Future<bool> shouldShowPermissionFlow() async {
    final complete = await isComplete();
    return !complete;
  }
}
