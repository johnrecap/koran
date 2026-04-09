import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/notifications/data/local_notifications_service.dart';
import 'package:quran_kareem/features/notifications/data/notification_preferences_local_data_source.dart';
import 'package:quran_kareem/features/notifications/data/notification_timezone_service.dart';
import 'package:quran_kareem/features/notifications/data/package_local_notifications_service.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_permission_state.dart';
import 'package:quran_kareem/features/notifications/domain/notification_preferences.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/prayer_notification_policy.dart';
import 'package:quran_kareem/features/notifications/domain/recurring_notification_policy.dart';
import 'package:quran_kareem/features/notifications/domain/review_notification_policy.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

final notificationTimezoneServiceProvider =
    Provider<NotificationTimezoneService>((ref) {
  return DeviceNotificationTimezoneService();
});

final localNotificationsServiceProvider = Provider<LocalNotificationsService>((
  ref,
) {
  return PackageLocalNotificationsService(
    timezoneService: ref.watch(notificationTimezoneServiceProvider),
  );
});

final notificationPreferencesLocalDataSourceProvider =
    Provider<NotificationPreferencesLocalDataSource>((ref) {
  return SharedPreferencesNotificationPreferencesLocalDataSource();
});

typedef NotificationNowResolver = DateTime Function();

final notificationNowProvider =
    Provider<NotificationNowResolver>((ref) => DateTime.now);

final initialNotificationLaunchTargetProvider =
    Provider<NotificationLaunchTarget?>((ref) => null);

final pendingNotificationLaunchTargetProvider =
    StateProvider<NotificationLaunchTarget?>((ref) {
  return ref.watch(initialNotificationLaunchTargetProvider);
});

final notificationPermissionControllerProvider = NotifierProvider<
    NotificationPermissionController, NotificationPermissionState>(
  NotificationPermissionController.new,
);

final notificationPreferencesControllerProvider = NotifierProvider<
    NotificationPreferencesController, NotificationPreferences>(
  NotificationPreferencesController.new,
);

class NotificationPermissionController
    extends Notifier<NotificationPermissionState> {
  late final Future<void> _ready;

  Future<void> get ready => _ready;

  @override
  NotificationPermissionState build() {
    _ready = _load();
    return NotificationPermissionState.unknown;
  }

  Future<void> refresh() async {
    state =
        await ref.read(localNotificationsServiceProvider).getPermissionState();
  }

  Future<void> requestPermission() async {
    state =
        await ref.read(localNotificationsServiceProvider).requestPermission();
    if (state.isGranted) {
      await ref
          .read(notificationPreferencesControllerProvider.notifier)
          .resyncAll();
    }
  }

  Future<void> _load() async {
    await refresh();
  }
}

class NotificationPreferencesController
    extends Notifier<NotificationPreferences> {
  late final Future<void> _ready;
  bool _didLoad = false;

  Future<void> get ready => _ready;

  @override
  NotificationPreferences build() {
    ref.listen<AsyncValue<HomePrayerSnapshot>>(
      homePrayerSnapshotProvider,
      (previous, next) {
        if (!_didLoad) {
          return;
        }
        if (_didPrayerSnapshotChange(previous, next)) {
          unawaited(_resyncFamily(NotificationReminderType.prayer));
        }
      },
    );
    ref.listen<List<SpacedReviewItem>>(
      spacedReviewItemsProvider,
      (previous, next) {
        if (!_didLoad) {
          return;
        }
        if (_didReviewItemsChange(previous, next)) {
          unawaited(_resyncFamily(NotificationReminderType.spacedReview));
        }
      },
    );

    _ready = _load();
    return const NotificationPreferences.defaults();
  }

  Future<void> setReminderEnabled(
    NotificationReminderType reminderType,
    bool enabled,
  ) async {
    await _ready;
    final nextState = state.copyWithFamilyEnabled(reminderType, enabled);
    if (nextState == state) {
      await _resyncFamily(reminderType);
      return;
    }

    state = nextState;
    await _persist();
    await _resyncFamily(reminderType);
  }

  Future<void> setDailyReminderTime(
    NotificationReminderType reminderType,
    TimeOfDay time,
  ) async {
    await _ready;
    if (!reminderType.usesCustomTime) {
      return;
    }

    final nextState = state.copyWithFamilyTime(reminderType, time);
    if (nextState == state) {
      await _resyncFamily(reminderType);
      return;
    }

    state = nextState;
    await _persist();
    await _resyncFamily(reminderType);
  }

  Future<void> setPrayerReminderOffset(PrayerReminderOffset offset) async {
    await _ready;
    final nextState = state.copyWithPrayerReminderOffset(offset);
    if (nextState == state) {
      await _resyncFamily(NotificationReminderType.prayer);
      return;
    }

    state = nextState;
    await _persist();
    await _resyncFamily(NotificationReminderType.prayer);
  }

  Future<void> resyncAll() async {
    await _ready;
    await _syncAllFamilies();
  }

  Future<void> _syncAllFamilies() async {
    for (final reminderType in NotificationReminderType.values) {
      await _syncFamily(reminderType);
    }
  }

  Future<void> _load() async {
    state =
        await ref.read(notificationPreferencesLocalDataSourceProvider).load();
    _didLoad = true;
    await _syncAllFamilies();
  }

  Future<void> _persist() async {
    await ref.read(notificationPreferencesLocalDataSourceProvider).save(state);
  }

  Future<void> _resyncFamily(NotificationReminderType reminderType) async {
    await _ready;
    await _syncFamily(reminderType);
  }

  Future<void> _syncFamily(NotificationReminderType reminderType) async {
    final service = ref.read(localNotificationsServiceProvider);
    final permissionState = await service.getPermissionState();
    if (!permissionState.isGranted || !state.isEnabled(reminderType)) {
      await service.cancelFamily(reminderType);
      return;
    }

    final schedules = _buildSchedulesFor(reminderType);
    if (schedules.isEmpty) {
      await service.cancelFamily(reminderType);
      return;
    }

    await service.replaceFamilySchedules(
      reminderType: reminderType,
      schedules: schedules,
    );
  }

  List<ScheduledNotificationDescriptor> _buildSchedulesFor(
    NotificationReminderType reminderType,
  ) {
    final now = ref.read(notificationNowProvider)();
    final l10n = AppLocalizations(
      ref.read(appSettingsControllerProvider).locale,
    );

    return switch (reminderType) {
      NotificationReminderType.dailyWird => _buildDailyWirdSchedule(
          now: now,
          l10n: l10n,
        ),
      NotificationReminderType.prayer => _buildPrayerSchedule(
          now: now,
          l10n: l10n,
        ),
      NotificationReminderType.fridayKahf => _buildFridayKahfSchedule(
          now: now,
          l10n: l10n,
        ),
      NotificationReminderType.spacedReview => _buildReviewSchedule(
          now: now,
          l10n: l10n,
        ),
      NotificationReminderType.adhkar => _buildAdhkarSchedule(
          now: now,
          l10n: l10n,
        ),
    };
  }

  List<ScheduledNotificationDescriptor> _buildDailyWirdSchedule({
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    final localTime = state.dailyWird.time;
    if (localTime == null) {
      return const <ScheduledNotificationDescriptor>[];
    }
    return [
      RecurringNotificationPolicy.nextDaily(
        reminderType: NotificationReminderType.dailyWird,
        localTime: localTime,
        now: now,
        launchTarget: const NotificationLaunchTarget.dailyWirdReader(),
        title: l10n.notificationsReminderDailyWirdTitle,
        body: l10n.notificationsReminderDailyWirdBody,
      ),
    ];
  }

  List<ScheduledNotificationDescriptor> _buildAdhkarSchedule({
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    final localTime = state.adhkar.time;
    if (localTime == null) {
      return const <ScheduledNotificationDescriptor>[];
    }
    return [
      RecurringNotificationPolicy.nextDaily(
        reminderType: NotificationReminderType.adhkar,
        localTime: localTime,
        now: now,
        launchTarget: const NotificationLaunchTarget.adhkar(),
        title: l10n.notificationsReminderAdhkarTitle,
        body: l10n.notificationsReminderAdhkarBody,
      ),
    ];
  }

  List<ScheduledNotificationDescriptor> _buildFridayKahfSchedule({
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    final localTime = state.fridayKahf.time;
    if (localTime == null) {
      return const <ScheduledNotificationDescriptor>[];
    }
    return [
      RecurringNotificationPolicy.nextWeekly(
        reminderType: NotificationReminderType.fridayKahf,
        weekday: DateTime.friday,
        localTime: localTime,
        now: now,
        launchTarget: const NotificationLaunchTarget.fridayKahfReader(),
        title: l10n.notificationsReminderFridayKahfTitle,
        body: l10n.notificationsReminderFridayKahfBody,
      ),
    ];
  }

  List<ScheduledNotificationDescriptor> _buildPrayerSchedule({
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    final snapshot = ref.read(homePrayerSnapshotProvider).valueOrNull;
    final reminder = PrayerNotificationPolicy.buildNextReminder(
      snapshot: snapshot,
      now: now,
      offset: state.prayerReminderOffset,
      title: l10n.notificationsReminderPrayerTitle,
      body: snapshot == null
          ? l10n.notificationsReminderPrayerBodyGeneric
          : l10n.notificationsReminderPrayerBody(
              _prayerLabelFor(snapshot.nextPrayer, l10n),
            ),
    );
    if (reminder == null) {
      return const <ScheduledNotificationDescriptor>[];
    }
    return [reminder];
  }

  List<ScheduledNotificationDescriptor> _buildReviewSchedule({
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    final reminder = ReviewNotificationPolicy.buildNextReminder(
      items: ref.read(spacedReviewItemsProvider),
      now: now,
      title: l10n.notificationsReminderReviewTitle,
      body: l10n.notificationsReminderReviewBody,
    );
    if (reminder == null) {
      return const <ScheduledNotificationDescriptor>[];
    }
    return [reminder];
  }

  String _prayerLabelFor(PrayerType prayerType, AppLocalizations l10n) {
    return switch (prayerType) {
      PrayerType.fajr => l10n.prayerLabelFajr,
      PrayerType.dhuhr => l10n.prayerLabelDhuhr,
      PrayerType.asr => l10n.prayerLabelAsr,
      PrayerType.maghrib => l10n.prayerLabelMaghrib,
      PrayerType.isha => l10n.prayerLabelIsha,
    };
  }

  bool _didPrayerSnapshotChange(
    AsyncValue<HomePrayerSnapshot>? previous,
    AsyncValue<HomePrayerSnapshot> next,
  ) {
    final before = previous?.valueOrNull;
    final after = next.valueOrNull;
    if (before == null || after == null) {
      return before != after;
    }

    return before.nextPrayer != after.nextPrayer ||
        before.nextPrayerTime != after.nextPrayerTime ||
        before.locationLabel != after.locationLabel;
  }

  bool _didReviewItemsChange(
    List<SpacedReviewItem>? previous,
    List<SpacedReviewItem> next,
  ) {
    if (previous == null) {
      return true;
    }
    if (previous.length != next.length) {
      return true;
    }

    for (var index = 0; index < previous.length; index++) {
      final before = previous[index];
      final after = next[index];
      if (before.id != after.id || before.nextReviewAt != after.nextReviewAt) {
        return true;
      }
    }

    return false;
  }
}
