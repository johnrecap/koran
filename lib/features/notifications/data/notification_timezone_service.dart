import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationTimezoneService {
  Future<void> initialize();

  tz.TZDateTime resolve(DateTime dateTime);
}

class DeviceNotificationTimezoneService implements NotificationTimezoneService {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (error, stackTrace) {
      AppLogger.error(
        'DeviceNotificationTimezoneService.initialize',
        error,
        stackTrace,
      );
      tz.setLocalLocation(tz.UTC);
    }
    _initialized = true;
  }

  @override
  tz.TZDateTime resolve(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
