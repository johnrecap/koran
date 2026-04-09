import 'dart:convert';

import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';

abstract final class NotificationPayloadCodec {
  static String encode(NotificationLaunchTarget target) {
    return jsonEncode(target.toMap());
  }

  static NotificationLaunchTarget decodeOrFallback(String? payload) {
    if (payload == null || payload.isEmpty) {
      return const NotificationLaunchTarget.library();
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return const NotificationLaunchTarget.library();
      }
      return NotificationLaunchTarget.fromMap(decoded);
    } catch (error, stackTrace) {
      AppLogger.error(
        'NotificationPayloadCodec.decodeOrFallback',
        error,
        stackTrace,
      );
      return const NotificationLaunchTarget.library();
    }
  }
}
