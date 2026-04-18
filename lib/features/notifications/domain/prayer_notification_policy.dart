import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/notification_schedule_window_policy.dart';
import 'package:quran_kareem/features/notifications/domain/prayer_notification_sound.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';

abstract final class PrayerNotificationPolicy {
  /// Legacy single-reminder builder (kept for backward-compatibility).
  static ScheduledNotificationDescriptor? buildNextReminder({
    required HomePrayerSnapshot? snapshot,
    required DateTime now,
    required PrayerReminderOffset offset,
    String title = '',
    String body = '',
  }) {
    if (snapshot == null) {
      return null;
    }

    final candidate = snapshot.nextPrayerTime.subtract(offset.leadTime);
    final scheduledAt = NotificationScheduleWindowPolicy.clampIntoSafeFuture(
      candidate: candidate,
      now: now,
    );
    if (!NotificationScheduleWindowPolicy.isWithinRollingWindow(
      scheduledAt: scheduledAt,
      now: now,
    )) {
      return null;
    }

    final isFriday = snapshot.gregorianDate.weekday == DateTime.friday;
    final sound = PrayerNotificationSound.forPrayer(
      snapshot.nextPrayer,
      isFriday: isFriday,
    );

    return ScheduledNotificationDescriptor(
      id: ScheduledNotificationIdPolicy.prayerReminder(snapshot.nextPrayer),
      reminderType: NotificationReminderType.prayer,
      scheduledAt: scheduledAt,
      cadence: ScheduledNotificationCadence.once,
      launchTarget: const NotificationLaunchTarget.prayerDetails(),
      title: title,
      body: body,
      androidRawSoundName: sound.rawResourceName,
    );
  }

  /// Builds reminder notifications for ALL remaining prayers today
  /// plus tomorrow's Fajr.
  ///
  /// Each notification gets a unique ID and its own custom sound.
  /// On Friday, Dhuhr uses the Jummah sound automatically.
  static List<ScheduledNotificationDescriptor> buildRemainderOfDay({
    required HomePrayerSnapshot? snapshot,
    required DateTime now,
    required PrayerReminderOffset offset,
    required String Function(PrayerType) labelResolver,
    String title = '',
    String Function(String prayerLabel)? bodyBuilder,
  }) {
    if (snapshot == null) {
      return const <ScheduledNotificationDescriptor>[];
    }

    final results = <ScheduledNotificationDescriptor>[];
    final today = snapshot.gregorianDate;
    final isFriday = today.weekday == DateTime.friday;

    // 1️⃣ Schedule all remaining prayers for today.
    for (final prayer in snapshot.prayers) {
      final prayerTime = prayer.resolveDateTime(today);
      final reminderTime = prayerTime.subtract(offset.leadTime);

      // Skip prayers whose actual time has already passed.
      if (!prayerTime.isAfter(now)) continue;

      final scheduledAt = NotificationScheduleWindowPolicy.clampIntoSafeFuture(
        candidate: reminderTime,
        now: now,
      );

      if (!NotificationScheduleWindowPolicy.isWithinRollingWindow(
        scheduledAt: scheduledAt,
        now: now,
      )) {
        continue;
      }

      final sound = PrayerNotificationSound.forPrayer(
        prayer.type,
        isFriday: isFriday,
      );

      results.add(ScheduledNotificationDescriptor(
        id: ScheduledNotificationIdPolicy.prayerReminder(prayer.type),
        reminderType: NotificationReminderType.prayer,
        scheduledAt: scheduledAt,
        cadence: ScheduledNotificationCadence.once,
        launchTarget: const NotificationLaunchTarget.prayerDetails(),
        title: title,
        body: bodyBuilder?.call(labelResolver(prayer.type)) ?? '',
        androidRawSoundName: sound.rawResourceName,
      ));
    }

    // 2️⃣ Schedule tomorrow's Fajr automatically.
    _addTomorrowFajr(
      results: results,
      snapshot: snapshot,
      now: now,
      offset: offset,
      title: title,
      labelResolver: labelResolver,
      bodyBuilder: bodyBuilder,
    );

    return results;
  }

  /// Calculates and appends tomorrow's Fajr reminder if within the scheduling
  /// window. Uses today's Fajr time shifted +1 day as approximation.
  static void _addTomorrowFajr({
    required List<ScheduledNotificationDescriptor> results,
    required HomePrayerSnapshot snapshot,
    required DateTime now,
    required PrayerReminderOffset offset,
    required String title,
    required String Function(PrayerType) labelResolver,
    String Function(String prayerLabel)? bodyBuilder,
  }) {
    // Find today's Fajr entry to extract its TimeOfDay.
    final fajrEntry = snapshot.prayers
        .where((entry) => entry.type == PrayerType.fajr)
        .firstOrNull;
    if (fajrEntry == null) return;

    final tomorrow = snapshot.gregorianDate.add(const Duration(days: 1));
    final tomorrowFajrTime = fajrEntry.resolveDateTime(tomorrow);
    final reminderTime = tomorrowFajrTime.subtract(offset.leadTime);

    final scheduledAt = NotificationScheduleWindowPolicy.clampIntoSafeFuture(
      candidate: reminderTime,
      now: now,
    );

    if (!scheduledAt.isAfter(now)) return;
    if (!NotificationScheduleWindowPolicy.isWithinRollingWindow(
      scheduledAt: scheduledAt,
      now: now,
    )) {
      return;
    }

    // Tomorrow's Fajr uses fajr sound (never jummah).
    final sound = PrayerNotificationSound.forPrayer(PrayerType.fajr);

    // Use a distinct ID so it doesn't overwrite today's Fajr reminder
    // (if today's Fajr was already scheduled and hasn't fired yet).
    // We use the adhanAlert ID range for tomorrow's Fajr as a safe slot.
    results.add(ScheduledNotificationDescriptor(
      id: ScheduledNotificationIdPolicy.adhanAlert(PrayerType.fajr),
      reminderType: NotificationReminderType.prayer,
      scheduledAt: scheduledAt,
      cadence: ScheduledNotificationCadence.once,
      launchTarget: const NotificationLaunchTarget.prayerDetails(),
      title: title,
      body: bodyBuilder?.call(labelResolver(PrayerType.fajr)) ?? '',
      androidRawSoundName: sound.rawResourceName,
    ));
  }
}
