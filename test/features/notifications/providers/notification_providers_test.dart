import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/notifications/data/local_notifications_service.dart';
import 'package:quran_kareem/features/notifications/data/notification_preferences_local_data_source.dart';
import 'package:quran_kareem/features/notifications/domain/notification_permission_state.dart';
import 'package:quran_kareem/features/notifications/domain/notification_preferences.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';
import 'package:quran_kareem/features/notifications/providers/notification_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('loads permission state from the service and updates it after a request',
      () async {
    final service = _FakeLocalNotificationsService(
      permissionState: NotificationPermissionState.denied,
      requestedPermissionState: NotificationPermissionState.granted,
    );
    final container = ProviderContainer(
      overrides: [
        localNotificationsServiceProvider.overrideWithValue(service),
        homePrayerSnapshotProvider.overrideWith(
          (ref) => const Stream<HomePrayerSnapshot>.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller =
        container.read(notificationPermissionControllerProvider.notifier);
    await controller.ready;

    expect(
      container.read(notificationPermissionControllerProvider),
      NotificationPermissionState.denied,
    );

    await controller.requestPermission();

    expect(
      container.read(notificationPermissionControllerProvider),
      NotificationPermissionState.granted,
    );
  });

  test(
      'persists family settings and replaces only the affected family schedules without duplicates',
      () async {
    final service = _FakeLocalNotificationsService(
      permissionState: NotificationPermissionState.granted,
    );
    final dataSource = _FakeNotificationPreferencesLocalDataSource();
    final container = ProviderContainer(
      overrides: [
        localNotificationsServiceProvider.overrideWithValue(service),
        notificationPreferencesLocalDataSourceProvider
            .overrideWithValue(dataSource),
        homePrayerSnapshotProvider.overrideWith(
          (ref) => const Stream<HomePrayerSnapshot>.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller =
        container.read(notificationPreferencesControllerProvider.notifier);
    await controller.ready;

    await controller.setReminderEnabled(
      NotificationReminderType.dailyWird,
      true,
    );
    await controller.setDailyReminderTime(
      NotificationReminderType.dailyWird,
      const TimeOfDay(hour: 8, minute: 45),
    );
    await controller.setReminderEnabled(
      NotificationReminderType.dailyWird,
      true,
    );

    final state = container.read(notificationPreferencesControllerProvider);
    expect(state.dailyWird.enabled, isTrue);
    expect(state.dailyWird.time, const TimeOfDay(hour: 8, minute: 45));
    expect(dataSource.savedStates, isNotEmpty);
    expect(
      service.replacedFamilyCalls
          .where((family) => family == NotificationReminderType.dailyWird)
          .length,
      greaterThanOrEqualTo(1),
    );
    expect(
      service.familySchedules[NotificationReminderType.dailyWird]?.length,
      1,
    );
  });

  test('setPrayerReminderOffset persists state and reschedules prayer reminders',
      () async {
    final service = _FakeLocalNotificationsService(
      permissionState: NotificationPermissionState.granted,
    );
    final dataSource = _FakeNotificationPreferencesLocalDataSource();
    final container = ProviderContainer(
      overrides: [
        localNotificationsServiceProvider.overrideWithValue(service),
        notificationPreferencesLocalDataSourceProvider
            .overrideWithValue(dataSource),
        notificationNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 30, 17, 30),
        ),
        homePrayerSnapshotProvider.overrideWith(
          (ref) => Stream<HomePrayerSnapshot>.value(_samplePrayerSnapshot()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller =
        container.read(notificationPreferencesControllerProvider.notifier);
    await controller.ready;
    await controller.setReminderEnabled(
      NotificationReminderType.prayer,
      true,
    );
    await controller.setPrayerReminderOffset(
      PrayerReminderOffset.thirtyMinBefore,
    );

    final state = container.read(notificationPreferencesControllerProvider);
    final schedule =
        service.familySchedules[NotificationReminderType.prayer]?.single;

    expect(state.prayerReminderOffset, PrayerReminderOffset.thirtyMinBefore);
    expect(
      dataSource.savedStates.last.prayerReminderOffset,
      PrayerReminderOffset.thirtyMinBefore,
    );
    expect(schedule, isNotNull);
    expect(schedule!.scheduledAt, DateTime(2026, 3, 30, 17, 39));
  });
}

HomePrayerSnapshot _samplePrayerSnapshot() {
  return HomePrayerSnapshot(
    locationLabel: 'Cairo',
    gregorianDate: DateTime(2026, 3, 30),
    hijriDay: 12,
    hijriYear: 1447,
    weekdayLabel: 'Monday',
    hijriLabel: '12 Shawwal 1447 AH',
    nextPrayer: PrayerType.maghrib,
    nextPrayerTime: DateTime(2026, 3, 30, 18, 9),
    hijriMonthReference: const HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'ط´ظˆط§ظ„',
      monthNameEnglish: 'Shawwal',
    ),
    isUsingCachedData: false,
    cachedFetchedAt: null,
    prayers: const [
      PrayerTimeEntry(
        type: PrayerType.fajr,
        label: 'Fajr',
        timeOfDay: TimeOfDay(hour: 4, minute: 26),
      ),
      PrayerTimeEntry(
        type: PrayerType.dhuhr,
        label: 'Dhuhr',
        timeOfDay: TimeOfDay(hour: 12, minute: 1),
      ),
      PrayerTimeEntry(
        type: PrayerType.asr,
        label: 'Asr',
        timeOfDay: TimeOfDay(hour: 15, minute: 29),
      ),
      PrayerTimeEntry(
        type: PrayerType.maghrib,
        label: 'Maghrib',
        timeOfDay: TimeOfDay(hour: 18, minute: 9),
      ),
      PrayerTimeEntry(
        type: PrayerType.isha,
        label: 'Isha',
        timeOfDay: TimeOfDay(hour: 19, minute: 27),
      ),
    ],
  );
}

class _FakeNotificationPreferencesLocalDataSource
    implements NotificationPreferencesLocalDataSource {
  NotificationPreferences _state = const NotificationPreferences.defaults();
  final List<NotificationPreferences> savedStates = <NotificationPreferences>[];

  @override
  Future<NotificationPreferences> load() async {
    return _state;
  }

  @override
  Future<void> save(NotificationPreferences preferences) async {
    _state = preferences;
    savedStates.add(preferences);
  }
}

class _FakeLocalNotificationsService implements LocalNotificationsService {
  _FakeLocalNotificationsService({
    required this.permissionState,
    this.requestedPermissionState,
  });

  @override
  Stream<String> get launchPayloads => const Stream<String>.empty();

  NotificationPermissionState permissionState;
  final NotificationPermissionState? requestedPermissionState;
  final List<NotificationReminderType> replacedFamilyCalls =
      <NotificationReminderType>[];
  final Map<NotificationReminderType, List<ScheduledNotificationDescriptor>>
      familySchedules =
      <NotificationReminderType, List<ScheduledNotificationDescriptor>>{};

  @override
  Future<void> cancelFamily(NotificationReminderType reminderType) async {
    familySchedules.remove(reminderType);
  }

  @override
  Future<String?> getLaunchPayload() async => null;

  @override
  Future<NotificationPermissionState> getPermissionState() async {
    return permissionState;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermissionState> requestPermission() async {
    if (requestedPermissionState != null) {
      permissionState = requestedPermissionState!;
    }
    return permissionState;
  }

  @override
  Future<void> replaceFamilySchedules({
    required NotificationReminderType reminderType,
    required List<ScheduledNotificationDescriptor> schedules,
  }) async {
    replacedFamilyCalls.add(reminderType);
    familySchedules[reminderType] = schedules;
  }
}
