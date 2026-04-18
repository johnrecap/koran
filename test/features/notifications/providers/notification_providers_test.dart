import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/notifications/data/adhan_audio_cache_service.dart';
import 'package:quran_kareem/features/notifications/data/local_notifications_service.dart';
import 'package:quran_kareem/features/notifications/data/notification_preferences_local_data_source.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_muezzin.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_playback_mode.dart';
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

  test('builds a stable adhan audio cache service provider instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final first = container.read(adhanAudioCacheServiceProvider);
    final second = container.read(adhanAudioCacheServiceProvider);

    expect(first, isA<AdhanAudioCacheService>());
    expect(identical(first, second), isTrue);
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

  test(
      'setPrayerReminderOffset persists state and reschedules prayer reminders',
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
    final schedules = service.familySchedules[NotificationReminderType.prayer];

    expect(state.prayerReminderOffset, PrayerReminderOffset.thirtyMinBefore);
    expect(
      dataSource.savedStates.last.prayerReminderOffset,
      PrayerReminderOffset.thirtyMinBefore,
    );
    expect(schedules, isNotNull);
    expect(schedules, hasLength(3));
    expect(
      schedules!.map((schedule) => schedule.id),
      <int>[41023, 41024, 41030],
    );
    expect(
      schedules.map((schedule) => schedule.scheduledAt),
      <DateTime>[
        DateTime(2026, 3, 30, 17, 39),
        DateTime(2026, 3, 30, 18, 57),
        DateTime(2026, 3, 31, 3, 56),
      ],
    );
  });

  test(
      'setAdhan playback preferences persists state and reschedules prayer reminders',
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
    await controller.setAdhanPlaybackMode(AdhanPlaybackMode.fullAdhan);
    await controller.setSelectedMuezzin(AdhanMuezzin.mansourAlZahrani);

    final state = container.read(notificationPreferencesControllerProvider);

    expect(state.adhanPlaybackMode, AdhanPlaybackMode.fullAdhan);
    expect(state.selectedMuezzin, AdhanMuezzin.mansourAlZahrani);
    expect(
      dataSource.savedStates.last.adhanPlaybackMode,
      AdhanPlaybackMode.fullAdhan,
    );
    expect(
      dataSource.savedStates.last.selectedMuezzin,
      AdhanMuezzin.mansourAlZahrani,
    );
    expect(
      service.replacedFamilyCalls
          .where((family) => family == NotificationReminderType.prayer)
          .length,
      greaterThanOrEqualTo(3),
    );
  });

  test(
      'resyncNotificationsOnAppResume refreshes permissions, reschedules enabled reminders, and invalidates the prayer snapshot',
      () async {
    final service = _FakeLocalNotificationsService(
      permissionState: NotificationPermissionState.granted,
    );
    final dataSource = _FakeNotificationPreferencesLocalDataSource(
      initialState:
          const NotificationPreferences.defaults().copyWithFamilyEnabled(
        NotificationReminderType.prayer,
        true,
      ),
    );
    var homeSnapshotBuilds = 0;
    final container = ProviderContainer(
      overrides: [
        localNotificationsServiceProvider.overrideWithValue(service),
        notificationPreferencesLocalDataSourceProvider
            .overrideWithValue(dataSource),
        notificationNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 30, 17, 30),
        ),
        homePrayerSnapshotProvider.overrideWith((ref) {
          homeSnapshotBuilds += 1;
          return Stream<HomePrayerSnapshot>.value(_samplePrayerSnapshot());
        }),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      homePrayerSnapshotProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container
        .read(notificationPermissionControllerProvider.notifier)
        .ready;
    await container
        .read(notificationPreferencesControllerProvider.notifier)
        .ready;
    await container.read(homePrayerSnapshotProvider.future);

    final baselinePermissionReads = service.permissionStateReads;
    final baselineReplacedCalls = service.replacedFamilyCalls.length;
    expect(homeSnapshotBuilds, 1);

    await resyncNotificationsOnAppResume(
      refreshPermission: () {
        return container
            .read(notificationPermissionControllerProvider.notifier)
            .refresh();
      },
      resyncAll: () {
        return container
            .read(notificationPreferencesControllerProvider.notifier)
            .resyncAll();
      },
      invalidatePrayerSnapshot: () {
        container.invalidate(homePrayerSnapshotProvider);
      },
    );
    await container.read(homePrayerSnapshotProvider.future);

    expect(service.permissionStateReads, greaterThan(baselinePermissionReads));
    expect(
      service.replacedFamilyCalls.length,
      greaterThan(baselineReplacedCalls),
    );
    expect(homeSnapshotBuilds, 2);
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
  _FakeNotificationPreferencesLocalDataSource({
    NotificationPreferences initialState =
        const NotificationPreferences.defaults(),
  }) : _state = initialState;

  NotificationPreferences _state;
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
  int permissionStateReads = 0;
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
    permissionStateReads += 1;
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

  @override
  Future<void> scheduleMultiple(
    List<ScheduledNotificationDescriptor> schedules,
  ) async {
    if (schedules.isEmpty) {
      return;
    }
    familySchedules[schedules.first.reminderType] = schedules;
  }
}
