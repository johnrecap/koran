import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/notifications/domain/scheduled_notification_descriptor.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

void main() {
  test('assigns stable unique ids per prayer reminder and adhan alert', () {
    expect(ScheduledNotificationIdPolicy.prayerReminder(PrayerType.fajr), 41020);
    expect(
      ScheduledNotificationIdPolicy.prayerReminder(PrayerType.dhuhr),
      41021,
    );
    expect(ScheduledNotificationIdPolicy.prayerReminder(PrayerType.asr), 41022);
    expect(
      ScheduledNotificationIdPolicy.prayerReminder(PrayerType.maghrib),
      41023,
    );
    expect(ScheduledNotificationIdPolicy.prayerReminder(PrayerType.isha), 41024);

    expect(ScheduledNotificationIdPolicy.adhanAlert(PrayerType.fajr), 41030);
    expect(ScheduledNotificationIdPolicy.adhanAlert(PrayerType.dhuhr), 41031);
    expect(ScheduledNotificationIdPolicy.adhanAlert(PrayerType.asr), 41032);
    expect(
      ScheduledNotificationIdPolicy.adhanAlert(PrayerType.maghrib),
      41033,
    );
    expect(ScheduledNotificationIdPolicy.adhanAlert(PrayerType.isha), 41034);

    expect(
      ScheduledNotificationIdPolicy.allPrayerIds,
      <int>[
        41020,
        41021,
        41022,
        41023,
        41024,
        41030,
        41031,
        41032,
        41033,
        41034,
      ],
    );
  });
}
