import 'dart:convert';

import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/notifications/domain/notification_preferences.dart';

abstract class NotificationPreferencesLocalDataSource {
  Future<NotificationPreferences> load();

  Future<void> save(NotificationPreferences preferences);
}

class SharedPreferencesNotificationPreferencesLocalDataSource
    implements NotificationPreferencesLocalDataSource {
  static const String _storageKey = 'notificationPreferences';

  @override
  Future<NotificationPreferences> load() async {
    final prefs = await UserPreferences.prefs;
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const NotificationPreferences.defaults();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const NotificationPreferences.defaults();
      }
      return NotificationPreferences.fromMap(decoded);
    } catch (error, stackTrace) {
      AppLogger.error(
        'SharedPreferencesNotificationPreferencesLocalDataSource.load',
        error,
        stackTrace,
      );
      return const NotificationPreferences.defaults();
    }
  }

  @override
  Future<void> save(NotificationPreferences preferences) async {
    final prefs = await UserPreferences.prefs;
    await prefs.setString(_storageKey, jsonEncode(preferences.toMap()));
  }
}
