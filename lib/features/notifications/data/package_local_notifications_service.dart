import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quran_kareem/features/notifications/data/local_notifications_service.dart';
import 'package:quran_kareem/features/notifications/data/notification_timezone_service.dart';
import 'package:quran_kareem/features/notifications/domain/notification_payload_codec.dart';
import 'package:quran_kareem/features/notifications/domain/notification_permission_state.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

const String _notificationsChannelId = 'quran_kareem_reminders';
const String _notificationsChannelName = 'Quran Kareem reminders';
const String _notificationsChannelDescription =
    'Daily devotional and memorization reminders';

/// Dedicated channel for prayer notifications with custom sounds.
const String _prayerNotificationsChannelId = 'quran_kareem_prayer_reminders';
const String _prayerNotificationsChannelName = 'تنبيهات الصلاة';
const String _prayerNotificationsChannelDescription =
    'Prayer time reminders with custom adhan sounds';

const String _androidNotificationIcon = '@drawable/ic_stat_quran_notification';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}

class PackageLocalNotificationsService implements LocalNotificationsService {
  PackageLocalNotificationsService({
    FlutterLocalNotificationsPlugin? plugin,
    required NotificationTimezoneService timezoneService,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _timezoneService = timezoneService;

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationTimezoneService _timezoneService;
  final StreamController<String> _launchPayloadsController =
      StreamController<String>.broadcast();
  bool _initialized = false;

  @override
  Stream<String> get launchPayloads => _launchPayloadsController.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _timezoneService.initialize();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(_androidNotificationIcon),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Default reminders channel.
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _notificationsChannelId,
        _notificationsChannelName,
        description: _notificationsChannelDescription,
        importance: Importance.high,
      ),
    );

    // Dedicated prayer notifications channel (supports custom sounds).
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _prayerNotificationsChannelId,
        _prayerNotificationsChannelName,
        description: _prayerNotificationsChannelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  @override
  Future<void> cancelFamily(NotificationReminderType reminderType) async {
    try {
      if (reminderType == NotificationReminderType.prayer) {
        // Cancel ALL per-prayer notification IDs (reminders + adhan alerts).
        for (final id in ScheduledNotificationIdPolicy.allPrayerIds) {
          await _plugin.cancel(id: id);
        }
        // Also cancel the legacy single-ID for backward compatibility.
        await _plugin.cancel(
          id: ScheduledNotificationIdPolicy.family(reminderType),
        );
        return;
      }
      await _plugin.cancel(
        id: ScheduledNotificationIdPolicy.family(reminderType),
      );
    } on MissingPluginException {
      return;
    } on Object {
      return;
    }
  }

  @override
  Future<String?> getLaunchPayload() async {
    NotificationAppLaunchDetails? launchDetails;
    try {
      launchDetails = await _plugin.getNotificationAppLaunchDetails();
    } on MissingPluginException {
      return null;
    } on Object {
      return null;
    }
    if (launchDetails?.didNotificationLaunchApp != true) {
      return null;
    }
    return launchDetails?.notificationResponse?.payload;
  }

  @override
  Future<NotificationPermissionState> getPermissionState() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final areEnabled = await androidPlugin?.areNotificationsEnabled();
        if (areEnabled == null) {
          return NotificationPermissionState.unavailable;
        }
        return areEnabled
            ? NotificationPermissionState.granted
            : NotificationPermissionState.denied;
      }

      if (Platform.isIOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final options = await iosPlugin?.checkPermissions();
        if (options == null) {
          return NotificationPermissionState.unavailable;
        }
        return options.isEnabled
            ? NotificationPermissionState.granted
            : NotificationPermissionState.denied;
      }
    } on MissingPluginException {
      return NotificationPermissionState.unavailable;
    } on Object {
      return NotificationPermissionState.unavailable;
    }

    return NotificationPermissionState.unavailable;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await androidPlugin?.requestNotificationsPermission() ?? false;
        return granted
            ? NotificationPermissionState.granted
            : NotificationPermissionState.denied;
      }

      if (Platform.isIOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
        return granted
            ? NotificationPermissionState.granted
            : NotificationPermissionState.denied;
      }
    } on MissingPluginException {
      return NotificationPermissionState.unavailable;
    } on Object {
      return NotificationPermissionState.unavailable;
    }

    return NotificationPermissionState.unavailable;
  }

  @override
  Future<void> scheduleMultiple(
    List<ScheduledNotificationDescriptor> schedules,
  ) async {
    try {
      for (final schedule in schedules) {
        await _schedule(schedule);
      }
    } on MissingPluginException {
      return;
    } on Object {
      return;
    }
  }

  @override
  Future<void> replaceFamilySchedules({
    required NotificationReminderType reminderType,
    required List<ScheduledNotificationDescriptor> schedules,
  }) async {
    try {
      await cancelFamily(reminderType);
      for (final schedule in schedules) {
        await _schedule(schedule);
      }
    } on MissingPluginException {
      return;
    } on Object {
      return;
    }
  }

  Future<void> _schedule(ScheduledNotificationDescriptor schedule) async {
    final scheduledDate = _timezoneService.resolve(schedule.scheduledAt);

    // Use the prayer channel with custom sound for prayer notifications.
    final bool isPrayerNotification =
        schedule.reminderType == NotificationReminderType.prayer;
    final String channelId =
        isPrayerNotification ? _prayerNotificationsChannelId : _notificationsChannelId;
    final String channelName =
        isPrayerNotification ? _prayerNotificationsChannelName : _notificationsChannelName;
    final String channelDescription = isPrayerNotification
        ? _prayerNotificationsChannelDescription
        : _notificationsChannelDescription;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: _androidNotificationIcon,
        sound: schedule.androidRawSoundName != null
            ? RawResourceAndroidNotificationSound(
                schedule.androidRawSoundName!,
              )
            : null,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: schedule.id,
      title: schedule.title,
      body: schedule.body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: NotificationPayloadCodec.encode(schedule.launchTarget),
      matchDateTimeComponents: _dateTimeComponentsFor(schedule.cadence),
    );
  }

  DateTimeComponents? _dateTimeComponentsFor(
    ScheduledNotificationCadence cadence,
  ) {
    return switch (cadence) {
      ScheduledNotificationCadence.once => null,
      ScheduledNotificationCadence.daily => DateTimeComponents.time,
      ScheduledNotificationCadence.weekly =>
        DateTimeComponents.dayOfWeekAndTime,
    };
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }
    _launchPayloadsController.add(payload);
  }
}
