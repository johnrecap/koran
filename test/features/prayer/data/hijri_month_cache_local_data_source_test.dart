import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/prayer/data/hijri_month_cache_local_data_source.dart';
import 'package:quran_kareem/features/prayer/domain/hijri_calendar_month.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('saves and reloads a cached Hijri month payload', () async {
    final dataSource = SharedPreferencesHijriMonthCacheLocalDataSource();
    const month = HijriCalendarMonthData(
      reference: HijriMonthReference(
        year: 1447,
        month: 10,
        monthNameArabic: 'ط´ظˆط§ظ„',
        monthNameEnglish: 'Shawwal',
      ),
      days: [
        HijriCalendarDayData(
          dayOfMonth: 6,
          weekday: DateTime.wednesday,
          gregorianDate: '2026-03-25',
        ),
      ],
    );

    await dataSource.save(month);

    final loaded = await dataSource.load(
      hijriYear: 1447,
      hijriMonth: 10,
    );

    expect(loaded, isNotNull);
    expect(loaded!.reference.monthNameEnglish, 'Shawwal');
    expect(loaded.days.single.gregorianDate, '2026-03-25');
  });

  test('returns null when the stored Hijri month cache payload is malformed',
      () async {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(
      const <String, Object>{
        'hijriMonthCache.v1.1447-10': '{bad json',
      },
    );
    final dataSource = SharedPreferencesHijriMonthCacheLocalDataSource();

    final loaded = await dataSource.load(
      hijriYear: 1447,
      hijriMonth: 10,
    );

    expect(loaded, isNull);
  });
}
