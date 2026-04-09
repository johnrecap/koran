import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/data/prayer_tracking_local_data_source.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const storageKey = 'prayerTracking.v1';

  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('stores and reloads manual prayer completion by Gregorian date key',
      () async {
    final dataSource = SharedPreferencesPrayerTrackingLocalDataSource();

    await dataSource.setPrayerCompleted(
      dateKey: '2026-03-25',
      prayer: PrayerType.fajr,
      completed: true,
    );
    await dataSource.setPrayerCompleted(
      dateKey: '2026-03-25',
      prayer: PrayerType.isha,
      completed: true,
    );

    final values = await dataSource.loadTrackings(
      const ['2026-03-25'],
    );

    expect(values['2026-03-25']?.completedPrayers, {
      PrayerType.fajr,
      PrayerType.isha,
    });
  });

  test('removes a prayer from the stored day when unchecked', () async {
    final dataSource = SharedPreferencesPrayerTrackingLocalDataSource();

    await dataSource.setPrayerCompleted(
      dateKey: '2026-03-25',
      prayer: PrayerType.maghrib,
      completed: true,
    );
    await dataSource.setPrayerCompleted(
      dateKey: '2026-03-25',
      prayer: PrayerType.maghrib,
      completed: false,
    );

    final values = await dataSource.loadTrackings(
      const ['2026-03-25'],
    );

    expect(values['2026-03-25']?.completedPrayers, isEmpty);
  });

  test('returns empty tracking when stored JSON is malformed', () async {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(
      const <String, Object>{
        storageKey: '{bad json',
      },
    );
    final dataSource = SharedPreferencesPrayerTrackingLocalDataSource();

    final values = await dataSource.loadTrackings(
      const ['2026-03-25'],
    );

    expect(values['2026-03-25']?.completedPrayers, isEmpty);
  });

  test('rewrites a valid payload when updating malformed stored tracking',
      () async {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(
      const <String, Object>{
        storageKey: '{bad json',
      },
    );
    final dataSource = SharedPreferencesPrayerTrackingLocalDataSource();

    await dataSource.setPrayerCompleted(
      dateKey: '2026-03-25',
      prayer: PrayerType.asr,
      completed: true,
    );

    final values = await dataSource.loadTrackings(
      const ['2026-03-25'],
    );

    expect(values['2026-03-25']?.completedPrayers, {PrayerType.asr});
  });

  test('loads a contiguous date range with missing days defaulted to empty',
      () async {
    final dataSource = SharedPreferencesPrayerTrackingLocalDataSource();

    await dataSource.setPrayerCompleted(
      dateKey: '2026-03-24',
      prayer: PrayerType.fajr,
      completed: true,
    );
    await dataSource.setPrayerCompleted(
      dateKey: '2026-03-26',
      prayer: PrayerType.isha,
      completed: true,
    );

    final values = await dataSource.getTrackingsForDateRange(
      '2026-03-24',
      '2026-03-26',
    );

    expect(values.keys, ['2026-03-24', '2026-03-25', '2026-03-26']);
    expect(values['2026-03-24']?.completedPrayers, {PrayerType.fajr});
    expect(values['2026-03-25']?.completedPrayers, isEmpty);
    expect(values['2026-03-26']?.completedPrayers, {PrayerType.isha});
  });
}
