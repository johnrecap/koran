import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/notifications/data/notification_timezone_service.dart';
import 'package:quran_kareem/features/notifications/data/package_local_notifications_service.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('cancelFamily cancels all prayer reminder and adhan ids', () async {
    final plugin = _FakeFlutterLocalNotificationsPlugin();
    final service = PackageLocalNotificationsService(
      plugin: plugin,
      timezoneService: _FakeNotificationTimezoneService(),
    );

    await service.cancelFamily(NotificationReminderType.prayer);

    expect(
      plugin.cancelledIds,
      <int>[
        ...ScheduledNotificationIdPolicy.allPrayerIds,
        ScheduledNotificationIdPolicy.family(NotificationReminderType.prayer),
      ],
    );
  });

  test('scheduleMultiple schedules every descriptor in the batch', () async {
    final plugin = _FakeFlutterLocalNotificationsPlugin();
    final service = PackageLocalNotificationsService(
      plugin: plugin,
      timezoneService: _FakeNotificationTimezoneService(),
    );

    await service.scheduleMultiple(<ScheduledNotificationDescriptor>[
      ScheduledNotificationDescriptor(
        id: ScheduledNotificationIdPolicy.prayerReminder(PrayerType.asr),
        reminderType: NotificationReminderType.prayer,
        scheduledAt: DateTime(2026, 3, 30, 15, 19),
        cadence: ScheduledNotificationCadence.once,
        launchTarget: const NotificationLaunchTarget.prayerDetails(),
      ),
      ScheduledNotificationDescriptor(
        id: ScheduledNotificationIdPolicy.prayerReminder(PrayerType.maghrib),
        reminderType: NotificationReminderType.prayer,
        scheduledAt: DateTime(2026, 3, 30, 17, 59),
        cadence: ScheduledNotificationCadence.once,
        launchTarget: const NotificationLaunchTarget.prayerDetails(),
      ),
    ]);

    expect(
      plugin.scheduledNotifications.map((call) => call.id),
      <int>[41022, 41023],
    );
    expect(
      plugin.scheduledNotifications.map((call) => call.scheduledDate),
      <DateTime>[
        DateTime(2026, 3, 30, 15, 19),
        DateTime(2026, 3, 30, 17, 59),
      ],
    );
  });
}

class _FakeNotificationTimezoneService implements NotificationTimezoneService {
  @override
  Future<void> initialize() async {}

  @override
  tz.TZDateTime resolve(DateTime dateTime) {
    return tz.TZDateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }
}

class _FakeFlutterLocalNotificationsPlugin
    implements FlutterLocalNotificationsPlugin {
  final List<int> cancelledIds = <int>[];
  final List<_ScheduledNotificationCall> scheduledNotifications =
      <_ScheduledNotificationCall>[];

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduledNotifications.add(
      _ScheduledNotificationCall(
        id: id,
        scheduledDate: DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          scheduledDate.hour,
          scheduledDate.minute,
          scheduledDate.second,
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _ScheduledNotificationCall {
  const _ScheduledNotificationCall({
    required this.id,
    required this.scheduledDate,
  });

  final int id;
  final DateTime scheduledDate;
}
