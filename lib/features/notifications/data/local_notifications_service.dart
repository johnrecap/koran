import 'package:quran_kareem/features/notifications/domain/notification_permission_state.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

abstract class LocalNotificationsService {
  Stream<String> get launchPayloads => const Stream<String>.empty();

  Future<void> initialize();

  Future<NotificationPermissionState> getPermissionState();

  Future<NotificationPermissionState> requestPermission();

  Future<void> scheduleMultiple(List<ScheduledNotificationDescriptor> schedules);

  Future<void> replaceFamilySchedules({
    required NotificationReminderType reminderType,
    required List<ScheduledNotificationDescriptor> schedules,
  }) async {
    await cancelFamily(reminderType);
    await scheduleMultiple(schedules);
  }

  Future<void> cancelFamily(NotificationReminderType reminderType);

  Future<String?> getLaunchPayload();
}
