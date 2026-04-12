import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/prayer/data/prayer_month_cache_local_data_source.dart';
import 'package:quran_kareem/features/prayer/domain/hijri_calendar_month.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('saves and reloads a cached prayer month for the same location key',
      () async {
    final dataSource = SharedPreferencesPrayerMonthCacheLocalDataSource();
    final cached = CachedPrayerTimesMonthData(
      location: const PrayerLocationSnapshot(
        latitude: 30.0444,
        longitude: 31.2357,
        label: 'Cairo, Egypt',
      ),
      month: PrayerTimesMonthData(
        gregorianYear: 2026,
        gregorianMonth: 3,
        days: [
          PrayerTimesDay(
            gregorianDate: DateTime(2026, 3, 25),
            hijriDay: 6,
            hijriYear: 1447,
            hijriMonthReference: const HijriMonthReference(
              year: 1447,
              month: 10,
              monthNameArabic: 'ط´ظˆط§ظ„',
              monthNameEnglish: 'Shawwal',
            ),
            prayers: const [
              PrayerTimeEntry(
                type: PrayerType.fajr,
                label: 'Fajr',
                timeOfDay: TimeOfDay(hour: 4, minute: 26),
              ),
            ],
          ),
        ],
      ),
      fetchedAt: DateTime(2026, 3, 25, 10),
    );

    await dataSource.save(cached);

    final loaded = await dataSource.load(
      latitude: 30.0444,
      longitude: 31.2357,
      year: 2026,
      month: 3,
    );

    expect(loaded, isNotNull);
    expect(loaded!.location.label, 'Cairo, Egypt');
    expect(loaded.month.days.single.gregorianDate, DateTime(2026, 3, 25));
  });

  test('returns null when the stored prayer month cache JSON is malformed',
      () async {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(
      const <String, Object>{
        'prayerMonthCache.v1.2026-03.30.04.31.24': '{bad json',
      },
    );
    final dataSource = SharedPreferencesPrayerMonthCacheLocalDataSource();

    final loaded = await dataSource.load(
      latitude: 30.0444,
      longitude: 31.2357,
      year: 2026,
      month: 3,
    );

    expect(loaded, isNull);
  });
}
