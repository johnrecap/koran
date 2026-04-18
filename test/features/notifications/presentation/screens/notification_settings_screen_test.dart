import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/notifications/data/local_notifications_service.dart';
import 'package:quran_kareem/features/notifications/data/notification_preferences_local_data_source.dart';
import 'package:quran_kareem/features/notifications/domain/notification_permission_state.dart';
import 'package:quran_kareem/features/notifications/domain/notification_preferences.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reminder_type.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';
import 'package:quran_kareem/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:quran_kareem/features/notifications/providers/notification_providers.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
      'renders localized families and persists toggles through the controller',
      (tester) async {
    final service = _FakeLocalNotificationsService(
      permissionState: NotificationPermissionState.denied,
      requestedPermissionState: NotificationPermissionState.granted,
    );
    final dataSource = _FakeNotificationPreferencesLocalDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsInitialStateProvider.overrideWithValue(
            const AppSettingsState.defaults(),
          ),
          localNotificationsServiceProvider.overrideWithValue(service),
          notificationPreferencesLocalDataSourceProvider
              .overrideWithValue(dataSource),
          homePrayerSnapshotProvider.overrideWith(
            (ref) => const Stream<HomePrayerSnapshot>.empty(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsWidgets);
    expect(find.text('Daily wird'), findsOneWidget);
    expect(find.text('Prayer reminder'), findsOneWidget);
    expect(
        find.text(
            'Notification permission is still required before this family can be delivered.'),
        findsWidgets);

    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('notification-family-dailyWird')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();

    expect(dataSource.savedStates, isNotEmpty);
    expect(
      service.familySchedules[NotificationReminderType.dailyWird]?.length,
      1,
    );
  });

  testWidgets('shows the prayer reminder offset selector and persists changes',
      (tester) async {
    final service = _FakeLocalNotificationsService(
      permissionState: NotificationPermissionState.granted,
    );
    final dataSource = _FakeNotificationPreferencesLocalDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsInitialStateProvider.overrideWithValue(
            const AppSettingsState.defaults(),
          ),
          localNotificationsServiceProvider.overrideWithValue(service),
          notificationPreferencesLocalDataSourceProvider
              .overrideWithValue(dataSource),
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream<HomePrayerSnapshot>.value(_samplePrayerSnapshot()),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('notification-family-prayer-offset')),
        findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('notification-family-prayer-offset')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification-family-prayer-offset')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('prayer-reminder-offset-thirtyMinBefore')),
    );
    await tester.pumpAndSettle();

    expect(
      dataSource.savedStates.last.prayerReminderOffset,
      PrayerReminderOffset.thirtyMinBefore,
    );
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
      monthNameArabic: 'شوال',
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
