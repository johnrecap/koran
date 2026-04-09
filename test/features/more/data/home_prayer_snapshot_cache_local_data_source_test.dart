import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/data/home_prayer_snapshot_cache_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const storageKey = 'homePrayerSnapshotCache.v1';

  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('returns null when the stored home prayer cache JSON is malformed',
      () async {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(
      const <String, Object>{
        storageKey: '{bad json',
      },
    );
    final dataSource =
        SharedPreferencesHomePrayerSnapshotCacheLocalDataSource();

    final cached = await dataSource.load();

    expect(cached, isNull);
  });

  test('returns null when the stored home prayer cache payload is invalid',
      () async {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(
      const <String, Object>{
        storageKey: '{"location":{},"day":{},"fetchedAt":"not-a-real-date"}',
      },
    );
    final dataSource =
        SharedPreferencesHomePrayerSnapshotCacheLocalDataSource();

    final cached = await dataSource.load();

    expect(cached, isNull);
  });
}
