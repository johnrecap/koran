import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

import 'package:quran_kareem/features/prayer/data/home_prayer_snapshot_cache_local_data_source.dart';
import 'package:quran_kareem/features/prayer/data/hijri_month_cache_local_data_source.dart';
import 'package:quran_kareem/features/prayer/data/more_prayer_remote_data_source.dart';
import 'package:quran_kareem/features/prayer/data/prayer_month_cache_local_data_source.dart';
import 'package:quran_kareem/features/prayer/data/prayer_location_service.dart';
import 'package:quran_kareem/features/prayer/data/prayer_tracking_local_data_source.dart';
import 'package:quran_kareem/features/prayer/domain/hijri_calendar_month.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_day_tracking.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_times_policies.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

export 'package:quran_kareem/features/prayer/data/more_prayer_remote_data_source.dart';
export 'package:quran_kareem/features/prayer/data/prayer_location_service.dart';
export 'package:quran_kareem/features/prayer/data/prayer_tracking_local_data_source.dart';
export 'package:quran_kareem/features/prayer/data/home_prayer_snapshot_cache_local_data_source.dart';
export 'package:quran_kareem/features/prayer/data/prayer_month_cache_local_data_source.dart';
export 'package:quran_kareem/features/prayer/data/hijri_month_cache_local_data_source.dart';
export 'package:quran_kareem/features/prayer/domain/hijri_calendar_month.dart';
export 'package:quran_kareem/features/prayer/domain/prayer_day_tracking.dart';
export 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
export 'package:quran_kareem/features/prayer/domain/prayer_times_policies.dart';

final prayerHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final prayerLocationServiceProvider = Provider<PrayerLocationService>((ref) {
  return const GeolocatorPrayerLocationService();
});

final morePrayerRemoteDataSourceProvider =
    Provider<MorePrayerRemoteDataSource>((ref) {
  return AlAdhanMorePrayerRemoteDataSource(
    client: ref.watch(prayerHttpClientProvider),
  );
});

final prayerTrackingLocalDataSourceProvider =
    Provider<PrayerTrackingLocalDataSource>((ref) {
  return SharedPreferencesPrayerTrackingLocalDataSource();
});

final homePrayerSnapshotCacheLocalDataSourceProvider =
    Provider<HomePrayerSnapshotCacheLocalDataSource>((ref) {
  return SharedPreferencesHomePrayerSnapshotCacheLocalDataSource();
});

final prayerMonthCacheLocalDataSourceProvider =
    Provider<PrayerMonthCacheLocalDataSource>((ref) {
  return SharedPreferencesPrayerMonthCacheLocalDataSource();
});

final hijriMonthCacheLocalDataSourceProvider =
    Provider<HijriMonthCacheLocalDataSource>((ref) {
  return SharedPreferencesHijriMonthCacheLocalDataSource();
});

typedef PrayerNowResolver = DateTime Function();

final prayerNowProvider = Provider<PrayerNowResolver>((ref) => DateTime.now);

typedef PrayerSnapshotRefreshDelayResolver = Duration? Function({
  required DateTime now,
  required DateTime nextPrayerTime,
});

final homePrayerSnapshotRefreshDelayResolverProvider =
    Provider<PrayerSnapshotRefreshDelayResolver>((ref) {
  return ({
    required DateTime now,
    required DateTime nextPrayerTime,
  }) {
    final delay = nextPrayerTime.difference(now) + const Duration(seconds: 1);
    if (delay.isNegative) {
      return Duration.zero;
    }
    return delay;
  };
});

final homePrayerSnapshotProvider =
    StreamProvider<HomePrayerSnapshot>((ref) async* {
  final languageCode = ref.watch(
    appSettingsControllerProvider
        .select((settings) => settings.locale.languageCode),
  );
  final refreshDelayResolver =
      ref.watch(homePrayerSnapshotRefreshDelayResolverProvider);
  final snapshotCache = ref.watch(homePrayerSnapshotCacheLocalDataSourceProvider);
  final monthCache = ref.watch(prayerMonthCacheLocalDataSourceProvider);
  final remote = ref.watch(morePrayerRemoteDataSourceProvider);
  Timer? refreshTimer;
  ref.onDispose(() {
    refreshTimer?.cancel();
  });

  HomePrayerSnapshot buildSnapshot({
    required PrayerLocationSnapshot location,
    required PrayerTimesDay day,
    PrayerTimesDay? nextDay,
    required bool isUsingCachedData,
    required DateTime? cachedFetchedAt,
  }) {
    return PrayerTimesPolicies.buildHomeSnapshot(
      location: location,
      day: day,
      now: ref.read(prayerNowProvider)(),
      languageCode: languageCode,
      nextDay: nextDay,
      isUsingCachedData: isUsingCachedData,
      cachedFetchedAt: cachedFetchedAt,
    );
  }

  PrayerTimesDay? resolveNextDayFromMonth({
    required PrayerTimesDay day,
    required PrayerTimesMonthData? month,
  }) {
    if (month == null) {
      return null;
    }

    final nextDate = DateTime(
      day.gregorianDate.year,
      day.gregorianDate.month,
      day.gregorianDate.day + 1,
    );
    return month.dayFor(nextDate);
  }

  void scheduleRefresh(HomePrayerSnapshot snapshot) {
    final scheduledAt = DateTime.now();
    final delay = refreshDelayResolver(
      now: scheduledAt,
      nextPrayerTime: snapshot.nextPrayerTime,
    );
    if (delay == null) {
      return;
    }

    refreshTimer?.cancel();
    refreshTimer = Timer(delay, ref.invalidateSelf);
  }

  CachedHomePrayerSnapshotData? cached;
  try {
    cached = await snapshotCache.load();
  } catch (error, stackTrace) {
    AppLogger.error('homePrayerSnapshotProvider.loadCache', error, stackTrace);
    cached = null;
  }
  var yieldedData = false;
  if (cached != null) {
    final cachedSnapshot = buildSnapshot(
      location: cached.location,
      day: cached.day,
      nextDay: null,
      isUsingCachedData: true,
      cachedFetchedAt: cached.fetchedAt,
    );
    yieldedData = true;
    yield cachedSnapshot;
    scheduleRefresh(cachedSnapshot);
  }

  try {
    final locationService = ref.watch(prayerLocationServiceProvider);
    final coordinates = await locationService.resolveCurrentCoordinates();
    final labelFuture = locationService.resolveLocationLabel(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
    );
    final requestNow = ref.read(prayerNowProvider)();
    var resolvedLocation = PrayerLocationSnapshot(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      label: coordinates.fallbackLabel,
    );
    CachedPrayerTimesMonthData? cachedMonth;
    try {
      cachedMonth = await monthCache.load(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        year: requestNow.year,
        month: requestNow.month,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'homePrayerSnapshotProvider.loadMonthCache',
        error,
        stackTrace,
      );
      cachedMonth = null;
    }

    Future<void> persistVisibleData({
      required PrayerLocationSnapshot location,
      required PrayerTimesDay day,
      required DateTime fetchedAt,
      PrayerTimesMonthData? month,
    }) async {
      await snapshotCache.save(
        CachedHomePrayerSnapshotData(
          location: location,
          day: day,
          fetchedAt: fetchedAt,
        ),
      );
      if (month != null) {
        await monthCache.save(
          CachedPrayerTimesMonthData(
            location: location,
            month: month,
            fetchedAt: fetchedAt,
          ),
        );
      }
    }

    PrayerTimesDay? day;
    PrayerTimesDay? nextDay;
    PrayerTimesMonthData? visibleMonth;
    var isUsingCachedData = false;
    DateTime? cachedFetchedAt;

    try {
      final freshMonth = await remote.fetchPrayerTimesMonth(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        year: requestNow.year,
        month: requestNow.month,
      );
      day = freshMonth.dayFor(requestNow);
      if (day != null) {
        visibleMonth = freshMonth;
        nextDay = resolveNextDayFromMonth(
          day: day,
          month: freshMonth,
        );
        final fetchedAt = DateTime.now();
        await persistVisibleData(
          location: resolvedLocation,
          day: day,
          fetchedAt: fetchedAt,
          month: freshMonth,
        );
        final freshSnapshot = buildSnapshot(
          location: resolvedLocation,
          day: day,
          nextDay: nextDay,
          isUsingCachedData: false,
          cachedFetchedAt: null,
        );
        // Only yield the fresh snapshot if it provides new data.
        // When cached data was already yielded and the prayer times
        // are for the same date, skip the redundant yield to prevent
        // unnecessary downstream rebuilds.
        final isSameDayAsCached = cached != null &&
            day.gregorianDate == cached.day.gregorianDate &&
            day.prayers.length == cached.day.prayers.length;
        if (!yieldedData || !isSameDayAsCached) {
          yield freshSnapshot;
          scheduleRefresh(freshSnapshot);
        } else {
          scheduleRefresh(freshSnapshot);
        }
        yieldedData = true;
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'homePrayerSnapshotProvider.fetchMonthSnapshot',
        error,
        stackTrace,
      );
      if (cachedMonth != null) {
        day = cachedMonth.month.dayFor(requestNow);
        if (day != null) {
          visibleMonth = cachedMonth.month;
          nextDay = resolveNextDayFromMonth(
            day: day,
            month: cachedMonth.month,
          );
          isUsingCachedData = true;
          cachedFetchedAt = cachedMonth.fetchedAt;
        }
      }
    }

    if (day == null) {
      day = await remote.fetchPrayerTimesDay(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        date: requestNow,
      );
      nextDay = resolveNextDayFromMonth(
        day: day,
        month: cachedMonth?.month,
      );
    }

    if (!yieldedData || isUsingCachedData) {
      final snapshot = buildSnapshot(
        location: isUsingCachedData && cachedMonth != null
            ? cachedMonth.location
            : resolvedLocation,
        day: day,
        nextDay: nextDay,
        isUsingCachedData: isUsingCachedData,
        cachedFetchedAt: cachedFetchedAt,
      );
      yield snapshot;
      scheduleRefresh(snapshot);
      yieldedData = true;
    }

    final resolvedLabel = await labelFuture;
    final didRelabel =
        resolvedLabel.isNotEmpty && resolvedLabel != resolvedLocation.label;
    if (didRelabel) {
      resolvedLocation = PrayerLocationSnapshot(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        label: resolvedLabel,
      );
    }

    final persistedAt = cachedFetchedAt ?? DateTime.now();
    await persistVisibleData(
      location: resolvedLocation,
      day: day,
      fetchedAt: persistedAt,
      month: visibleMonth,
    );

    if (didRelabel) {
      final relabeledSnapshot = buildSnapshot(
        location: resolvedLocation,
        day: day,
        nextDay: nextDay,
        isUsingCachedData: isUsingCachedData,
        cachedFetchedAt: cachedFetchedAt,
      );
      yield relabeledSnapshot;
      scheduleRefresh(relabeledSnapshot);
    }
    } catch (error, stackTrace) {
      AppLogger.error('homePrayerSnapshotProvider', error, stackTrace);
      if (!yieldedData) {
        rethrow;
      }
  }
});

final hijriMonthDataProvider =
    FutureProvider.family<HijriCalendarMonthData, HijriMonthReference>(
  (ref, reference) async {
    final remote = ref.watch(morePrayerRemoteDataSourceProvider);
    final cache = ref.watch(hijriMonthCacheLocalDataSourceProvider);
    HijriCalendarMonthData? cached;
    try {
      cached = await cache.load(
        hijriYear: reference.year,
        hijriMonth: reference.month,
      );
    } catch (error, stackTrace) {
      AppLogger.error('hijriMonthDataProvider.loadCache', error, stackTrace);
      cached = null;
    }

    try {
      final month = await remote.fetchHijriMonth(
        hijriYear: reference.year,
        hijriMonth: reference.month,
      );
      await cache.save(month);
      return month;
    } catch (error, stackTrace) {
      AppLogger.error('hijriMonthDataProvider.fetchRemote', error, stackTrace);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  },
);

final prayerMonthTrackingsProvider =
    FutureProvider.family<Map<String, PrayerDayTracking>, HijriMonthReference>(
  (ref, reference) async {
    final local = ref.watch(prayerTrackingLocalDataSourceProvider);
    final month = await ref.watch(hijriMonthDataProvider(reference).future);
    return local.loadTrackings(
      month.days.map((day) => day.gregorianDate),
    );
  },
);

final todayPrayerTrackingProvider = FutureProvider<PrayerDayTracking>((
  ref,
) async {
  final now = ref.watch(prayerNowProvider)();
  final dateKey = PrayerTimesPolicies.dateKey(now);
  final trackings = await ref
      .watch(prayerTrackingLocalDataSourceProvider)
      .loadTrackings([dateKey]);
  return trackings[dateKey] ??
      PrayerDayTracking(
        dateKey: dateKey,
        completedPrayers: const <PrayerType>{},
      );
});

final todayPrayerTimesPanelProvider =
    FutureProvider<List<PrayerTimeSlotView>>((ref) async {
  final snapshot = await ref.watch(homePrayerSnapshotProvider.future);
  final tracking = await ref.watch(todayPrayerTrackingProvider.future);
  return PrayerTimesPolicies.resolveTodayTimesPanel(
    prayers: snapshot.prayers,
    now: ref.watch(prayerNowProvider)(),
    tracking: tracking,
  );
});

final prayerAdherenceSummaryProvider =
    FutureProvider<DailyAdherenceSummary>((ref) async {
  final now = ref.watch(prayerNowProvider)();
  final todayTracking = await ref.watch(todayPrayerTrackingProvider.future);
  final history = await ref
      .watch(prayerTrackingLocalDataSourceProvider)
      .getTrackingsForDateRange(
        PrayerTimesPolicies.dateKey(
          DateTime(now.year, now.month, now.day - 3650),
        ),
        PrayerTimesPolicies.dateKey(now),
      );
  final streak = PrayerTimesPolicies.computeConsecutiveCompleteDays(
    trackings: history,
    today: now,
  );
  return PrayerTimesPolicies.buildDailyAdherence(
    tracking: todayTracking,
    totalPrayers: PrayerType.values.length,
    streakDays: streak,
  );
});

final prayerWeeklyStripProvider =
    FutureProvider<List<WeeklyDaySnapshot>>((ref) async {
  final today = ref.watch(prayerNowProvider)();
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final startOfWeek = normalizedToday.subtract(
    Duration(days: (normalizedToday.weekday + 1) % 7),
  );
  final endOfWeek = DateTime(
    startOfWeek.year,
    startOfWeek.month,
    startOfWeek.day + 6,
  );
  final weekTrackings = await ref
      .watch(prayerTrackingLocalDataSourceProvider)
      .getTrackingsForDateRange(
        PrayerTimesPolicies.dateKey(startOfWeek),
        PrayerTimesPolicies.dateKey(endOfWeek),
      );
  return PrayerTimesPolicies.buildWeeklyStrip(
    today: today,
    weekTrackings: weekTrackings,
  );
});

final hijriMonthCalendarViewProvider =
    FutureProvider.family<HijriCalendarMonthView, HijriMonthReference>(
  (ref, reference) async {
    final today = ref.watch(prayerNowProvider)();
    final month = await ref.watch(hijriMonthDataProvider(reference).future);
    final trackings =
        await ref.watch(prayerMonthTrackingsProvider(reference).future);

    return PrayerTimesPolicies.buildMonthView(
      month: month,
      today: today,
      trackings: trackings,
    );
  },
);
