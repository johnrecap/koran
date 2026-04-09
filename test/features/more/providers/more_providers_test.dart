import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const englishSettings = AppSettingsState.defaults();
  const arabicSettings = AppSettingsState.defaults();

  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test(
      'homePrayerSnapshotProvider loads the next prayer using current location',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        appSettingsInitialStateProvider.overrideWith(
          (ref) => englishSettings.copyWith(
            locale: const Locale('en'),
          ),
        ),
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          _FakeMorePrayerRemoteDataSource(
            day: _samplePrayerTimesDay(),
            prayerMonth: _samplePrayerTimesMonthData(),
            hijriMonth: _sampleHijriMonthData(),
            qiblaDirection: const QiblaDirectionData(
              bearingDegrees: 136.0,
              distanceMeters: 438000,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(homePrayerSnapshotProvider.future);

    expect(snapshot.locationLabel, '30.04, 31.24');
    expect(snapshot.nextPrayer, PrayerType.maghrib);
    expect(snapshot.nextPrayerTime, DateTime(2026, 3, 25, 18, 9));
  });

  test(
      'homePrayerSnapshotProvider localizes weekday and Hijri labels in Arabic',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        appSettingsInitialStateProvider.overrideWith(
          (ref) => arabicSettings.copyWith(
            locale: const Locale('ar'),
          ),
        ),
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          _FakeMorePrayerRemoteDataSource(
            day: _samplePrayerTimesDay(),
            prayerMonth: _samplePrayerTimesMonthData(),
            hijriMonth: _sampleHijriMonthData(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(homePrayerSnapshotProvider.future);

    expect(snapshot.weekdayLabel, 'الأربعاء');
    expect(snapshot.hijriLabel, '6 ط´ظˆط§ظ„ 1447 هـ');
  });

  test('homePrayerSnapshotProvider yields cached data before remote refresh',
      () async {
    final remote = _DeferredMorePrayerRemoteDataSource(
      prayerMonth: _samplePrayerTimesMonthData(),
      hijriMonth: _sampleHijriMonthData(),
      qiblaDirection: const QiblaDirectionData(
        bearingDegrees: 136.0,
        distanceMeters: 438000,
      ),
    );
    final cache = _FakeHomePrayerSnapshotCacheLocalDataSource(
      value: CachedHomePrayerSnapshotData(
        location: const PrayerLocationSnapshot(
          latitude: 30.0444,
          longitude: 31.2357,
          label: 'Cached Cairo',
        ),
        day: PrayerTimesDay(
          gregorianDate: DateTime(2026, 3, 25),
          hijriDay: 5,
          hijriYear: 1447,
          hijriMonthReference: const HijriMonthReference(
            year: 1447,
            month: 10,
            monthNameArabic: 'ط´ظˆط§ظ„',
            monthNameEnglish: 'Shawwal',
          ),
          prayers: _samplePrayerTimesDay().prayers,
        ),
        fetchedAt: DateTime(2026, 3, 25, 10),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        appSettingsInitialStateProvider.overrideWith(
          (ref) => englishSettings.copyWith(
            locale: const Locale('en'),
          ),
        ),
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(remote),
        homePrayerSnapshotCacheLocalDataSourceProvider.overrideWithValue(cache),
      ],
    );
    addTearDown(container.dispose);

    final emitted = <HomePrayerSnapshot>[];
    final subscription = container.listen(
      homePrayerSnapshotProvider,
      (_, next) {
        next.whenData(emitted.add);
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    expect(emitted, isNotEmpty);
    expect(emitted.first.locationLabel, 'Cached Cairo');
    expect(emitted.first.hijriLabel, '5 Shawwal 1447 AH');
    expect(emitted.first.isUsingCachedData, isTrue);
    expect(emitted.first.cachedFetchedAt, DateTime(2026, 3, 25, 10));

    remote.complete(
      day: _samplePrayerTimesDay(),
      month: _samplePrayerTimesMonthData(),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(emitted.last.locationLabel, 'Cairo, Egypt');
    expect(emitted.last.hijriLabel, '6 Shawwal 1447 AH');
    expect(emitted.last.isUsingCachedData, isFalse);
    expect(emitted.last.cachedFetchedAt, isNull);
    expect(cache.saved, isNotNull);
    expect(cache.saved!.location.label, 'Cairo, Egypt');
  });

  test(
      'homePrayerSnapshotProvider ignores cache load corruption and recovers remotely',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        appSettingsInitialStateProvider.overrideWith(
          (ref) => englishSettings.copyWith(
            locale: const Locale('en'),
          ),
        ),
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          _FakeMorePrayerRemoteDataSource(
            day: _samplePrayerTimesDay(),
            prayerMonth: _samplePrayerTimesMonthData(),
            hijriMonth: _sampleHijriMonthData(),
          ),
        ),
        homePrayerSnapshotCacheLocalDataSourceProvider.overrideWithValue(
          _ThrowingHomePrayerSnapshotCacheLocalDataSource(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(homePrayerSnapshotProvider.future);

    expect(snapshot.locationLabel, '30.04, 31.24');
    expect(snapshot.isUsingCachedData, isFalse);
    expect(snapshot.nextPrayer, PrayerType.maghrib);
  });

  test(
      'homePrayerSnapshotProvider refreshes next prayer after the scheduled boundary',
      () async {
    var currentNow = DateTime(2026, 3, 25, 18, 8);
    var refreshSchedules = 0;
    final remote = _FakeMorePrayerRemoteDataSource(
      day: _samplePrayerTimesDay(),
      prayerMonth: _samplePrayerTimesMonthData(),
      hijriMonth: _sampleHijriMonthData(),
    );

    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith((ref) => () => currentNow),
        homePrayerSnapshotRefreshDelayResolverProvider.overrideWith(
          (ref) => ({
            required DateTime now,
            required DateTime nextPrayerTime,
          }) {
            refreshSchedules += 1;
            if (refreshSchedules == 1) {
              return const Duration(milliseconds: 20);
            }
            return null;
          },
        ),
        appSettingsInitialStateProvider.overrideWith(
          (ref) => englishSettings.copyWith(
            locale: const Locale('en'),
          ),
        ),
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    final emitted = <HomePrayerSnapshot>[];
    final subscription = container.listen(
      homePrayerSnapshotProvider,
      (_, next) {
        next.whenData(emitted.add);
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    expect(emitted, isNotEmpty);
    expect(emitted.last.nextPrayer, PrayerType.maghrib);

    currentNow = DateTime(2026, 3, 25, 18, 10);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await Future<void>.delayed(Duration.zero);

    expect(emitted.last.nextPrayer, PrayerType.isha);
  });

  test(
      'homePrayerSnapshotProvider saves fetched prayer month data for offline reuse',
      () async {
    final monthCache = _FakePrayerMonthCacheLocalDataSource();
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        appSettingsInitialStateProvider.overrideWith(
          (ref) => englishSettings.copyWith(
            locale: const Locale('en'),
          ),
        ),
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          _FakeMorePrayerRemoteDataSource(
            day: _samplePrayerTimesDay(),
            prayerMonth: _samplePrayerTimesMonthData(),
            hijriMonth: _sampleHijriMonthData(),
          ),
        ),
        prayerMonthCacheLocalDataSourceProvider.overrideWithValue(monthCache),
      ],
    );
    addTearDown(container.dispose);

    await container.read(homePrayerSnapshotProvider.future);

    expect(monthCache.saved, isNotNull);
    expect(monthCache.saved!.month.days.length, 2);
    expect(monthCache.saved!.month.gregorianMonth, 3);
  });

  test(
      'homePrayerSnapshotProvider falls back to cached prayer month when remote fetch fails',
      () async {
    final monthCache = _FakePrayerMonthCacheLocalDataSource(
      value: CachedPrayerTimesMonthData(
        location: const PrayerLocationSnapshot(
          latitude: 30.0444,
          longitude: 31.2357,
          label: 'Cached Cairo',
        ),
        month: _samplePrayerTimesMonthData(),
        fetchedAt: DateTime(2026, 3, 25, 10),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 26, 10),
        ),
        appSettingsInitialStateProvider.overrideWith(
          (ref) => englishSettings.copyWith(
            locale: const Locale('en'),
          ),
        ),
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          const _ThrowingMorePrayerRemoteDataSource(),
        ),
        prayerMonthCacheLocalDataSourceProvider.overrideWithValue(monthCache),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(homePrayerSnapshotProvider.future);

    expect(snapshot.locationLabel, 'Cached Cairo');
    expect(snapshot.isUsingCachedData, isTrue);
    expect(snapshot.cachedFetchedAt, DateTime(2026, 3, 25, 10));
    expect(snapshot.nextPrayer, PrayerType.dhuhr);
    expect(snapshot.nextPrayerTime, DateTime(2026, 3, 26, 12, 2));
  });

  test(
      'homePrayerSnapshotProvider rolls the next prayer into the next cached day after isha',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 23),
        ),
        appSettingsInitialStateProvider.overrideWith(
          (ref) => englishSettings.copyWith(
            locale: const Locale('en'),
          ),
        ),
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          _FakeMorePrayerRemoteDataSource(
            day: _samplePrayerTimesDay(),
            prayerMonth: _samplePrayerTimesMonthData(),
            hijriMonth: _sampleHijriMonthData(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(homePrayerSnapshotProvider.future);

    expect(snapshot.nextPrayer, PrayerType.fajr);
    expect(snapshot.nextPrayerTime, DateTime(2026, 3, 26, 4, 24));
  });

  test(
      'hijriMonthCalendarViewProvider merges stored tracking into day visual states',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          _FakeMorePrayerRemoteDataSource(
            day: _samplePrayerTimesDay(),
            prayerMonth: _samplePrayerTimesMonthData(),
            hijriMonth: _sampleHijriMonthData(),
            qiblaDirection: const QiblaDirectionData(
              bearingDegrees: 136.0,
              distanceMeters: 438000,
            ),
          ),
        ),
        prayerTrackingLocalDataSourceProvider.overrideWithValue(
          _FakePrayerTrackingLocalDataSource(
            values: const {
              '2026-03-24': PrayerDayTracking(
                dateKey: '2026-03-24',
                completedPrayers: {PrayerType.fajr},
              ),
              '2026-03-25': PrayerDayTracking(
                dateKey: '2026-03-25',
                completedPrayers: {PrayerType.fajr, PrayerType.dhuhr},
              ),
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final monthView = await container.read(
      hijriMonthCalendarViewProvider(
        const HijriMonthReference(
          year: 1447,
          month: 10,
          monthNameArabic: 'ط´ظˆط§ظ„',
          monthNameEnglish: 'Shawwal',
        ),
      ).future,
    );

    expect(
      monthView.days
          .firstWhere((day) => day.gregorianDateKey == '2026-03-24')
          .visualState,
      PrayerCalendarDayVisualState.pastIncomplete,
    );
    expect(
      monthView.days
          .firstWhere((day) => day.gregorianDateKey == '2026-03-25')
          .visualState,
      PrayerCalendarDayVisualState.today,
    );
  });

  test('todayPrayerTrackingProvider loads the current day tracking', () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        prayerTrackingLocalDataSourceProvider.overrideWithValue(
          _FakePrayerTrackingLocalDataSource(
            values: const {
              '2026-03-25': PrayerDayTracking(
                dateKey: '2026-03-25',
                completedPrayers: {PrayerType.fajr, PrayerType.dhuhr},
              ),
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tracking = await container.read(todayPrayerTrackingProvider.future);

    expect(tracking.dateKey, '2026-03-25');
    expect(tracking.completedPrayers, {
      PrayerType.fajr,
      PrayerType.dhuhr,
    });
  });

  test(
      'todayPrayerTimesPanelProvider derives slot status from snapshot and tracking',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 14),
        ),
        prayerTrackingLocalDataSourceProvider.overrideWithValue(
          _FakePrayerTrackingLocalDataSource(
            values: const {
              '2026-03-25': PrayerDayTracking(
                dateKey: '2026-03-25',
                completedPrayers: {PrayerType.fajr, PrayerType.dhuhr},
              ),
            },
          ),
        ),
        homePrayerSnapshotProvider.overrideWith(
          (ref) => Stream<HomePrayerSnapshot>.value(_sampleHomePrayerSnapshot()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final rows = await container.read(todayPrayerTimesPanelProvider.future);

    expect(rows, hasLength(5));
    expect(rows[0].status, PrayerTimeSlotStatus.past);
    expect(rows[2].status, PrayerTimeSlotStatus.current);
    expect(rows[3].status, PrayerTimeSlotStatus.upcoming);
    expect(rows[0].isTracked, isTrue);
  });

  test(
      'prayerAdherenceSummaryProvider combines today completion with prior streak',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        prayerTrackingLocalDataSourceProvider.overrideWithValue(
          _FakePrayerTrackingLocalDataSource(
            values: const {
              '2026-03-25': PrayerDayTracking(
                dateKey: '2026-03-25',
                completedPrayers: {
                  PrayerType.fajr,
                  PrayerType.dhuhr,
                  PrayerType.asr,
                },
              ),
              '2026-03-24': PrayerDayTracking(
                dateKey: '2026-03-24',
                completedPrayers: {
                  PrayerType.fajr,
                  PrayerType.dhuhr,
                  PrayerType.asr,
                  PrayerType.maghrib,
                  PrayerType.isha,
                },
              ),
              '2026-03-23': PrayerDayTracking(
                dateKey: '2026-03-23',
                completedPrayers: {
                  PrayerType.fajr,
                  PrayerType.dhuhr,
                  PrayerType.asr,
                  PrayerType.maghrib,
                  PrayerType.isha,
                },
              ),
              '2026-03-22': PrayerDayTracking(
                dateKey: '2026-03-22',
                completedPrayers: {PrayerType.fajr},
              ),
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final summary = await container.read(prayerAdherenceSummaryProvider.future);

    expect(summary.completed, 3);
    expect(summary.total, 5);
    expect(summary.streakDays, 2);
  });

  test('prayerWeeklyStripProvider returns the active Saturday to Friday week',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        prayerTrackingLocalDataSourceProvider.overrideWithValue(
          _FakePrayerTrackingLocalDataSource(
            values: const {
              '2026-03-21': PrayerDayTracking(
                dateKey: '2026-03-21',
                completedPrayers: {PrayerType.fajr},
              ),
              '2026-03-25': PrayerDayTracking(
                dateKey: '2026-03-25',
                completedPrayers: {
                  PrayerType.fajr,
                  PrayerType.dhuhr,
                  PrayerType.asr,
                },
              ),
              '2026-03-27': PrayerDayTracking(
                dateKey: '2026-03-27',
                completedPrayers: {
                  PrayerType.fajr,
                  PrayerType.dhuhr,
                  PrayerType.asr,
                  PrayerType.maghrib,
                  PrayerType.isha,
                },
              ),
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final week = await container.read(prayerWeeklyStripProvider.future);

    expect(week, hasLength(7));
    expect(week.first.dateKey, '2026-03-21');
    expect(week[4].dateKey, '2026-03-25');
    expect(week[4].isToday, isTrue);
    expect(week.last.dateKey, '2026-03-27');
    expect(week.last.completedCount, 5);
  });

  test(
      'prayer tracking refresh does not refetch the remote Hijri month payload',
      () async {
    final remote = _CountingMonthMorePrayerRemoteDataSource(
      day: _samplePrayerTimesDay(),
      prayerMonth: _samplePrayerTimesMonthData(),
      hijriMonth: _sampleHijriMonthData(),
    );
    final local = _CountingPrayerTrackingLocalDataSource(
      values: const {
        '2026-03-25': PrayerDayTracking(
          dateKey: '2026-03-25',
          completedPrayers: {PrayerType.fajr},
        ),
      },
    );
    const reference = HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'ط·آ´ط¸ث†ط·آ§ط¸â€‍',
      monthNameEnglish: 'Shawwal',
    );

    final container = ProviderContainer(
      overrides: [
        prayerNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 25, 17),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(remote),
        prayerTrackingLocalDataSourceProvider.overrideWithValue(local),
      ],
    );
    addTearDown(container.dispose);

    await container.read(hijriMonthCalendarViewProvider(reference).future);
    expect(remote.fetchHijriMonthCalls, 1);
    expect(local.loadTrackingsCalls, 1);

    container.invalidate(prayerMonthTrackingsProvider(reference));
    await container.read(hijriMonthCalendarViewProvider(reference).future);

    expect(remote.fetchHijriMonthCalls, 1);
    expect(local.loadTrackingsCalls, 2);
  });

  test(
      'hijriMonthDataProvider falls back to cached month data when the remote call fails',
      () async {
    const reference = HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'ط´ظˆط§ظ„',
      monthNameEnglish: 'Shawwal',
    );
    final cache = _FakeHijriMonthCacheLocalDataSource(
      value: _sampleHijriMonthData(),
    );
    final container = ProviderContainer(
      overrides: [
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          const _ThrowingMorePrayerRemoteDataSource(),
        ),
        hijriMonthCacheLocalDataSourceProvider.overrideWithValue(cache),
      ],
    );
    addTearDown(container.dispose);

    final month = await container.read(hijriMonthDataProvider(reference).future);

    expect(month.reference.monthNameEnglish, 'Shawwal');
    expect(month.days.length, 3);
  });

  test(
      'qiblaCompassSnapshotProvider combines location, bearing, distance, and heading',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          _FakeMorePrayerRemoteDataSource(
            day: _samplePrayerTimesDay(),
            prayerMonth: _samplePrayerTimesMonthData(),
            hijriMonth: _sampleHijriMonthData(),
            qiblaDirection: const QiblaDirectionData(
              bearingDegrees: 136.0,
              distanceMeters: 438000,
            ),
          ),
        ),
        qiblaHeadingServiceProvider.overrideWithValue(
          const _FakeQiblaHeadingService(
            values: [
              QiblaHeadingReading(
                headingDegrees: 130.0,
                accuracy: 4.0,
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final emitted = <QiblaCompassSnapshot>[];
    final subscription = container.listen(
      qiblaCompassSnapshotProvider,
      (_, next) {
        next.whenData(emitted.add);
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(emitted, isNotEmpty);
    final snapshot = emitted.last;

    expect(
      snapshot.locationLabel,
      anyOf('Cairo, Egypt', '30.04, 31.24'),
    );
    expect(snapshot.qiblaBearingDegrees, 136.0);
    expect(snapshot.distanceMeters, 438000);
    expect(snapshot.isFacingQibla, isTrue);
  });

  test(
      'qiblaCompassSnapshotProvider emits an initial fallback snapshot before heading events',
      () async {
    final container = ProviderContainer(
      overrides: [
        prayerLocationServiceProvider.overrideWithValue(
          const _FakePrayerLocationService(),
        ),
        morePrayerRemoteDataSourceProvider.overrideWithValue(
          _FakeMorePrayerRemoteDataSource(
            day: _samplePrayerTimesDay(),
            prayerMonth: _samplePrayerTimesMonthData(),
            hijriMonth: _sampleHijriMonthData(),
            qiblaDirection: const QiblaDirectionData(
              bearingDegrees: 136.0,
              distanceMeters: 438000,
            ),
          ),
        ),
        qiblaHeadingServiceProvider.overrideWithValue(
          const _NeverEmittingQiblaHeadingService(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container
        .read(qiblaCompassSnapshotProvider.future)
        .timeout(const Duration(seconds: 1));

    expect(snapshot.locationLabel, '30.04, 31.24');
    expect(snapshot.headingDegrees, isNull);
    expect(snapshot.calibrationState, QiblaCalibrationState.unavailable);
  });
}

PrayerTimesDay _samplePrayerTimesDay() {
  return PrayerTimesDay(
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

HomePrayerSnapshot _sampleHomePrayerSnapshot() {
  return HomePrayerSnapshot(
    locationLabel: 'Cairo, Egypt',
    gregorianDate: DateTime(2026, 3, 25),
    hijriDay: 6,
    hijriYear: 1447,
    weekdayLabel: 'Wednesday',
    hijriLabel: '6 Shawwal 1447 AH',
    nextPrayer: PrayerType.maghrib,
    nextPrayerTime: DateTime(2026, 3, 25, 18, 9),
    hijriMonthReference: const HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'ط´ظˆط§ظ„',
      monthNameEnglish: 'Shawwal',
    ),
    isUsingCachedData: false,
    cachedFetchedAt: null,
    prayers: _samplePrayerTimesDay().prayers,
  );
}

PrayerTimesMonthData _samplePrayerTimesMonthData() {
  return PrayerTimesMonthData(
    gregorianYear: 2026,
    gregorianMonth: 3,
    days: [
      _samplePrayerTimesDay(),
      PrayerTimesDay(
        gregorianDate: DateTime(2026, 3, 26),
        hijriDay: 7,
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
            timeOfDay: TimeOfDay(hour: 4, minute: 24),
          ),
          PrayerTimeEntry(
            type: PrayerType.dhuhr,
            label: 'Dhuhr',
            timeOfDay: TimeOfDay(hour: 12, minute: 2),
          ),
          PrayerTimeEntry(
            type: PrayerType.asr,
            label: 'Asr',
            timeOfDay: TimeOfDay(hour: 15, minute: 30),
          ),
          PrayerTimeEntry(
            type: PrayerType.maghrib,
            label: 'Maghrib',
            timeOfDay: TimeOfDay(hour: 18, minute: 10),
          ),
          PrayerTimeEntry(
            type: PrayerType.isha,
            label: 'Isha',
            timeOfDay: TimeOfDay(hour: 19, minute: 28),
          ),
        ],
      ),
    ],
  );
}

HijriCalendarMonthData _sampleHijriMonthData() {
  return const HijriCalendarMonthData(
    reference: HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'ط´ظˆط§ظ„',
      monthNameEnglish: 'Shawwal',
    ),
    days: [
      HijriCalendarDayData(
        dayOfMonth: 5,
        weekday: DateTime.tuesday,
        gregorianDate: '2026-03-24',
      ),
      HijriCalendarDayData(
        dayOfMonth: 6,
        weekday: DateTime.wednesday,
        gregorianDate: '2026-03-25',
      ),
      HijriCalendarDayData(
        dayOfMonth: 7,
        weekday: DateTime.thursday,
        gregorianDate: '2026-03-26',
      ),
    ],
  );
}

class _FakePrayerLocationService implements PrayerLocationService {
  const _FakePrayerLocationService();

  @override
  Future<PrayerCoordinates> resolveCurrentCoordinates() async {
    return const PrayerCoordinates(
      latitude: 30.0444,
      longitude: 31.2357,
    );
  }

  @override
  Future<String> resolveLocationLabel({
    required double latitude,
    required double longitude,
  }) async {
    return 'Cairo, Egypt';
  }

  @override
  Future<PrayerLocationSnapshot> resolveCurrentLocation() async {
    return const PrayerLocationSnapshot(
      latitude: 30.0444,
      longitude: 31.2357,
      label: 'Cairo, Egypt',
    );
  }
}

class _FakeMorePrayerRemoteDataSource implements MorePrayerRemoteDataSource {
  _FakeMorePrayerRemoteDataSource({
    required this.day,
    required this.prayerMonth,
    required this.hijriMonth,
    this.qiblaDirection = const QiblaDirectionData(
      bearingDegrees: 136.0,
      distanceMeters: 438000,
    ),
  });

  final PrayerTimesDay day;
  final PrayerTimesMonthData prayerMonth;
  final HijriCalendarMonthData hijriMonth;
  final QiblaDirectionData qiblaDirection;

  @override
  Future<PrayerTimesDay> fetchPrayerTimesDay({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    return day;
  }

  @override
  Future<PrayerTimesMonthData> fetchPrayerTimesMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    return prayerMonth;
  }

  @override
  Future<HijriCalendarMonthData> fetchHijriMonth({
    required int hijriYear,
    required int hijriMonth,
  }) async {
    return this.hijriMonth;
  }

  @override
  Future<QiblaDirectionData> fetchQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    return qiblaDirection;
  }
}

class _CountingMonthMorePrayerRemoteDataSource
    extends _FakeMorePrayerRemoteDataSource {
  _CountingMonthMorePrayerRemoteDataSource({
    required super.day,
    required super.prayerMonth,
    required super.hijriMonth,
  });

  int fetchHijriMonthCalls = 0;

  @override
  Future<HijriCalendarMonthData> fetchHijriMonth({
    required int hijriYear,
    required int hijriMonth,
  }) async {
    fetchHijriMonthCalls += 1;
    return super.fetchHijriMonth(
      hijriYear: hijriYear,
      hijriMonth: hijriMonth,
    );
  }
}

class _DeferredMorePrayerRemoteDataSource
    implements MorePrayerRemoteDataSource {
  _DeferredMorePrayerRemoteDataSource({
    required this.prayerMonth,
    required this.hijriMonth,
    required this.qiblaDirection,
  });

  final PrayerTimesMonthData prayerMonth;
  final HijriCalendarMonthData hijriMonth;
  final QiblaDirectionData qiblaDirection;
  final Completer<PrayerTimesDay> _dayCompleter = Completer<PrayerTimesDay>();
  final Completer<PrayerTimesMonthData> _monthCompleter =
      Completer<PrayerTimesMonthData>();

  void complete({
    required PrayerTimesDay day,
    required PrayerTimesMonthData month,
  }) {
    if (!_dayCompleter.isCompleted) {
      _dayCompleter.complete(day);
    }
    if (!_monthCompleter.isCompleted) {
      _monthCompleter.complete(month);
    }
  }

  @override
  Future<PrayerTimesDay> fetchPrayerTimesDay({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    return _dayCompleter.future;
  }

  @override
  Future<PrayerTimesMonthData> fetchPrayerTimesMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) {
    return _monthCompleter.future;
  }

  @override
  Future<HijriCalendarMonthData> fetchHijriMonth({
    required int hijriYear,
    required int hijriMonth,
  }) async {
    return this.hijriMonth;
  }

  @override
  Future<QiblaDirectionData> fetchQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    return qiblaDirection;
  }
}

class _FakeHomePrayerSnapshotCacheLocalDataSource
    implements HomePrayerSnapshotCacheLocalDataSource {
  _FakeHomePrayerSnapshotCacheLocalDataSource({
    this.value,
  });

  final CachedHomePrayerSnapshotData? value;
  CachedHomePrayerSnapshotData? saved;

  @override
  Future<CachedHomePrayerSnapshotData?> load() async {
    return value;
  }

  @override
  Future<void> save(CachedHomePrayerSnapshotData snapshot) async {
    saved = snapshot;
  }
}

class _FakePrayerMonthCacheLocalDataSource
    implements PrayerMonthCacheLocalDataSource {
  _FakePrayerMonthCacheLocalDataSource({
    this.value,
  });

  final CachedPrayerTimesMonthData? value;
  CachedPrayerTimesMonthData? saved;

  @override
  Future<CachedPrayerTimesMonthData?> load({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    return value;
  }

  @override
  Future<void> save(CachedPrayerTimesMonthData monthData) async {
    saved = monthData;
  }
}

class _FakeHijriMonthCacheLocalDataSource
    implements HijriMonthCacheLocalDataSource {
  _FakeHijriMonthCacheLocalDataSource({
    this.value,
  });

  final HijriCalendarMonthData? value;

  @override
  Future<HijriCalendarMonthData?> load({
    required int hijriYear,
    required int hijriMonth,
  }) async {
    return value;
  }

  @override
  Future<void> save(HijriCalendarMonthData month) async {}
}

class _ThrowingHomePrayerSnapshotCacheLocalDataSource
    implements HomePrayerSnapshotCacheLocalDataSource {
  @override
  Future<CachedHomePrayerSnapshotData?> load() async {
    throw const FormatException('bad cache payload');
  }

  @override
  Future<void> save(CachedHomePrayerSnapshotData snapshot) async {}
}

class _ThrowingMorePrayerRemoteDataSource implements MorePrayerRemoteDataSource {
  const _ThrowingMorePrayerRemoteDataSource();

  @override
  Future<PrayerTimesDay> fetchPrayerTimesDay({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    throw const MorePrayerRemoteException('offline');
  }

  @override
  Future<PrayerTimesMonthData> fetchPrayerTimesMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    throw const MorePrayerRemoteException('offline');
  }

  @override
  Future<HijriCalendarMonthData> fetchHijriMonth({
    required int hijriYear,
    required int hijriMonth,
  }) async {
    throw const MorePrayerRemoteException('offline');
  }

  @override
  Future<QiblaDirectionData> fetchQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    return const QiblaDirectionData(
      bearingDegrees: 136.0,
      distanceMeters: 438000,
    );
  }
}

class _FakePrayerTrackingLocalDataSource
    implements PrayerTrackingLocalDataSource {
  _FakePrayerTrackingLocalDataSource({
    required this.values,
  });

  final Map<String, PrayerDayTracking> values;

  @override
  Future<Map<String, PrayerDayTracking>> loadTrackings(
    Iterable<String> dateKeys,
  ) async {
    return {
      for (final key in dateKeys)
        if (values.containsKey(key)) key: values[key]!,
    };
  }

  @override
  Future<Map<String, PrayerDayTracking>> getTrackingsForDateRange(
    String startKey,
    String endKey,
  ) async {
    final start = PrayerTimesPolicies.parseDateKey(startKey);
    final end = PrayerTimesPolicies.parseDateKey(endKey);
    final requestedKeys = <String>[];
    var cursor = DateTime(start.year, start.month, start.day);
    while (!cursor.isAfter(end)) {
      requestedKeys.add(PrayerTimesPolicies.dateKey(cursor));
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return loadTrackings(requestedKeys);
  }

  @override
  Future<void> setPrayerCompleted({
    required String dateKey,
    required PrayerType prayer,
    required bool completed,
  }) async {}
}

class _CountingPrayerTrackingLocalDataSource
    extends _FakePrayerTrackingLocalDataSource {
  _CountingPrayerTrackingLocalDataSource({
    required super.values,
  });

  int loadTrackingsCalls = 0;

  @override
  Future<Map<String, PrayerDayTracking>> loadTrackings(
    Iterable<String> dateKeys,
  ) async {
    loadTrackingsCalls += 1;
    return super.loadTrackings(dateKeys);
  }

  @override
  Future<Map<String, PrayerDayTracking>> getTrackingsForDateRange(
    String startKey,
    String endKey,
  ) async {
    loadTrackingsCalls += 1;
    return super.getTrackingsForDateRange(startKey, endKey);
  }
}

class _FakeQiblaHeadingService implements QiblaHeadingService {
  const _FakeQiblaHeadingService({
    required this.values,
  });

  final List<QiblaHeadingReading> values;

  @override
  Stream<QiblaHeadingReading> watchHeading() async* {
    for (final value in values) {
      yield value;
    }
  }
}

class _NeverEmittingQiblaHeadingService implements QiblaHeadingService {
  const _NeverEmittingQiblaHeadingService();

  @override
  Stream<QiblaHeadingReading> watchHeading() => const Stream.empty();
}
