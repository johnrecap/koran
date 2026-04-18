import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_muezzin.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_playback_mode.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/notifications/data/notification_preferences_local_data_source.dart';
import 'package:quran_kareem/features/notifications/domain/notification_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('saves and restores notification preferences from shared preferences',
      () async {
    final dataSource =
        SharedPreferencesNotificationPreferencesLocalDataSource();
    const preferences = NotificationPreferences(
      dailyWird: NotificationReminderPreference(
        enabled: true,
        time: TimeOfDay(hour: 8, minute: 45),
      ),
      prayer: NotificationReminderPreference(enabled: true),
      prayerReminderOffset: PrayerReminderOffset.thirtyMinBefore,
      adhanPlaybackMode: AdhanPlaybackMode.fullAdhan,
      selectedMuezzin: AdhanMuezzin.mansourAlZahrani,
      fridayKahf: NotificationReminderPreference(
        enabled: true,
        time: TimeOfDay(hour: 9, minute: 30),
      ),
      spacedReview: NotificationReminderPreference(enabled: true),
      adhkar: NotificationReminderPreference(
        enabled: true,
        time: TimeOfDay(hour: 18, minute: 15),
      ),
    );

    await dataSource.save(preferences);
    final restored = await dataSource.load();

    expect(restored, preferences);
  });

  test('falls back to the default prayer reminder offset when it is missing',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'notificationPreferences':
          '{"dailyWird":{"enabled":false,"hour":8,"minute":0},"prayer":{"enabled":true},"fridayKahf":{"enabled":false,"hour":9,"minute":0},"spacedReview":{"enabled":false},"adhkar":{"enabled":false,"hour":18,"minute":0}}',
    });
    UserPreferences.resetCache();

    final dataSource =
        SharedPreferencesNotificationPreferencesLocalDataSource();
    final restored = await dataSource.load();

    expect(
      restored.prayerReminderOffset,
      PrayerReminderOffset.fifteenMinBefore,
    );
    expect(
      restored.adhanPlaybackMode,
      AdhanPlaybackMode.notificationOnly,
    );
    expect(
      restored.selectedMuezzin,
      AdhanMuezzin.misharyAlafasy,
    );
  });

  test('falls back to defaults when stored payload is malformed', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'notificationPreferences': 'not-json',
    });
    UserPreferences.resetCache();

    final dataSource =
        SharedPreferencesNotificationPreferencesLocalDataSource();
    final restored = await dataSource.load();

    expect(restored, const NotificationPreferences.defaults());
  });
}
