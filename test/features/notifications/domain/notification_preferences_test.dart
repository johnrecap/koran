import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_muezzin.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_playback_mode.dart';
import 'package:quran_kareem/features/notifications/domain/notification_preferences.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

void main() {
  test('serializes and restores adhan settings with notification preferences',
      () {
    const preferences = NotificationPreferences(
      dailyWird: NotificationReminderPreference(
        enabled: true,
        time: TimeOfDay(hour: 8, minute: 45),
      ),
      prayer: NotificationReminderPreference(enabled: true),
      prayerReminderOffset: PrayerReminderOffset.tenMinBefore,
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

    final restored = NotificationPreferences.fromMap(preferences.toMap());

    expect(restored, preferences);
  });

  test('falls back to safe adhan defaults when persisted names are missing',
      () {
    final restored = NotificationPreferences.fromMap(<String, dynamic>{
      'dailyWird': <String, dynamic>{
        'enabled': false,
        'hour': 8,
        'minute': 0,
      },
      'prayer': <String, dynamic>{'enabled': true},
      'prayerReminderOffset': 'fifteenMinBefore',
      'fridayKahf': <String, dynamic>{
        'enabled': false,
        'hour': 9,
        'minute': 0,
      },
      'spacedReview': <String, dynamic>{'enabled': false},
      'adhkar': <String, dynamic>{
        'enabled': false,
        'hour': 18,
        'minute': 0,
      },
      'adhanPlaybackMode': 'missing',
      'selectedMuezzin': 'missing',
    });

    expect(
      restored.adhanPlaybackMode,
      AdhanPlaybackMode.notificationOnly,
    );
    expect(
      restored.selectedMuezzin,
      AdhanMuezzin.misharyAlafasy,
    );
  });

  test('copies adhan settings without mutating reminder families', () {
    const preferences = NotificationPreferences.defaults();

    final updated = preferences
        .copyWithAdhanPlaybackMode(AdhanPlaybackMode.takbeerOnly)
        .copyWithSelectedMuezzin(AdhanMuezzin.ahmedAlNafis);

    expect(updated.adhanPlaybackMode, AdhanPlaybackMode.takbeerOnly);
    expect(updated.selectedMuezzin, AdhanMuezzin.ahmedAlNafis);
    expect(updated.dailyWird, preferences.dailyWird);
    expect(updated.prayer, preferences.prayer);
    expect(updated.fridayKahf, preferences.fridayKahf);
    expect(updated.spacedReview, preferences.spacedReview);
    expect(updated.adhkar, preferences.adhkar);
  });
}
