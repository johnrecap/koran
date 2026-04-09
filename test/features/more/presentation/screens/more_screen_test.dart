import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/presentation/screens/adhkar_categories_screen.dart';
import 'package:quran_kareem/features/more/presentation/screens/more_screen.dart';
import 'package:quran_kareem/features/more/providers/adhkar_providers.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const arabicSettings = AppSettingsState.defaults();

  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('renders the Home Tools prayer hero from loaded data',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream.value(_sampleHomePrayerSnapshot()),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Home Tools'), findsWidgets);
    expect(find.byKey(const Key('home-tools-prayer-hero')), findsOneWidget);
    expect(find.text('Cairo, Egypt'), findsOneWidget);
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('Qibla'), findsOneWidget);
    expect(
        find.byKey(const Key('home-tools-prayer-stale-badge')), findsNothing);
  });

  testWidgets('renders a stale cache badge when the prayer snapshot is cached',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream.value(_sampleCachedHomePrayerSnapshot()),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
        find.byKey(const Key('home-tools-prayer-stale-badge')), findsOneWidget);
    expect(find.text('Saved at 10:00'), findsOneWidget);
  });

  testWidgets(
      'shows retry-only error state and retries the permission flow on tap',
      (tester) async {
    final locationService = _FakePrayerLocationService(
      error: const PrayerFeatureException(
        PrayerFeatureError.permissionDenied,
      ),
    );

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          prayerLocationServiceProvider.overrideWithValue(locationService),
          morePrayerRemoteDataSourceProvider.overrideWithValue(
            _FakeMorePrayerRemoteDataSource(
              day: _samplePrayerTimesDay(),
              month: _sampleHijriMonthData(),
            ),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final retryButton = find.byType(ElevatedButton);
    expect(retryButton, findsOneWidget);
    expect(locationService.resolveCalls, 1);

    await tester.tap(retryButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(locationService.resolveCalls, 2);
  });

  testWidgets('opens prayer times details when the prayer hero is tapped',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream.value(_sampleHomePrayerSnapshot()),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-tools-prayer-hero')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Prayer Times Details Route'), findsOneWidget);
  });

  testWidgets('opens qibla compass screen when the Qibla tool is tapped',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream.value(_sampleHomePrayerSnapshot()),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-tools-qibla-tool')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Qibla Compass Route'), findsOneWidget);
  });

  testWidgets('opens settings screen when the Settings tool is tapped',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream.value(_sampleHomePrayerSnapshot()),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-tools-settings-tool')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Settings Route'), findsOneWidget);
  });

  testWidgets('opens analytics screen when the Analytics tool is tapped',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream.value(_sampleHomePrayerSnapshot()),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-tools-analytics-tool')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Analytics Route'), findsOneWidget);
  });

  testWidgets('opens adhkar screen when the Azkar tool is tapped',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream.value(_sampleHomePrayerSnapshot()),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-tools-azkar-tool')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Digital tasbeeh'), findsOneWidget);
  });

  testWidgets('renders Arabic prayer snapshot labels when locale is Arabic',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        locale: const Locale('ar'),
        overrides: [
          appSettingsInitialStateProvider.overrideWith(
            (ref) => arabicSettings.copyWith(
              locale: const Locale('ar'),
            ),
          ),
          homePrayerSnapshotProvider.overrideWith(
            (ref) => Stream.value(_sampleArabicHomePrayerSnapshot()),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('الأربعاء'), findsOneWidget);
    expect(find.text('6 شوال 1447 هـ'), findsOneWidget);
    expect(find.text('المغرب'), findsOneWidget);
  });
}

Widget _buildHarness({
  required List<Override> overrides,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      adhkarCatalogSourceProvider.overrideWithValue(
        const _FakeAdhkarCatalogSource(_testAdhkarCatalog),
      ),
      adhkarPreferencesLocalDataSourceProvider.overrideWithValue(
        const _FakeAdhkarPreferencesLocalDataSource(
          AdhkarCounterState(
            count: 0,
            target: 33,
          ),
        ),
      ),
      ...overrides,
    ],
    child: MaterialApp.router(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/more',
        routes: [
          GoRoute(
            path: '/more',
            builder: (context, state) => const MoreScreen(),
          ),
          GoRoute(
            path: '/more/prayer-times',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Prayer Times Details Route'),
              ),
            ),
          ),
          GoRoute(
            path: '/more/qibla',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Qibla Compass Route'),
              ),
            ),
          ),
          GoRoute(
            path: '/more/settings',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Settings Route'),
              ),
            ),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Analytics Route'),
              ),
            ),
          ),
          GoRoute(
            path: '/more/adhkar',
            builder: (context, state) => const AdhkarCategoriesScreen(),
          ),
        ],
      ),
    ),
  );
}

const AdhkarCatalog _testAdhkarCatalog = AdhkarCatalog(
  categories: [
    AdhkarCategory(
      id: 'morning',
      groupId: 'dailyCore',
      sourceLabel: 'السنة الصحيحة',
      sourceNote: 'أذكار مختصرة',
      entries: [
        AdhkarEntry(
          id: 'm1',
          arabicText: 'رضيت بالله ربا',
          repetitionCount: 3,
        ),
      ],
    ),
  ],
);

class _FakeAdhkarCatalogSource implements AdhkarCatalogSource {
  const _FakeAdhkarCatalogSource(this.catalog);

  final AdhkarCatalog catalog;

  @override
  Future<AdhkarCatalog> loadCatalog() async {
    return catalog;
  }
}

class _FakeAdhkarPreferencesLocalDataSource
    implements AdhkarPreferencesLocalDataSource {
  const _FakeAdhkarPreferencesLocalDataSource(this.state);

  final AdhkarCounterState state;

  @override
  Future<AdhkarCounterState> loadCounterState() async {
    return state;
  }

  @override
  Future<void> saveCounterState(AdhkarCounterState state) async {}
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
      monthNameArabic: 'شوال',
      monthNameEnglish: 'Shawwal',
    ),
    isUsingCachedData: false,
    cachedFetchedAt: null,
    prayers: _samplePrayerTimesDay().prayers,
  );
}

HomePrayerSnapshot _sampleCachedHomePrayerSnapshot() {
  return HomePrayerSnapshot(
    locationLabel: 'Cached Cairo',
    gregorianDate: DateTime(2026, 3, 25),
    hijriDay: 5,
    hijriYear: 1447,
    weekdayLabel: 'Wednesday',
    hijriLabel: '5 Shawwal 1447 AH',
    nextPrayer: PrayerType.maghrib,
    nextPrayerTime: DateTime(2026, 3, 25, 18, 9),
    hijriMonthReference: const HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'ط´ظˆط§ظ„',
      monthNameEnglish: 'Shawwal',
    ),
    isUsingCachedData: true,
    cachedFetchedAt: DateTime(2026, 3, 25, 10),
    prayers: _samplePrayerTimesDay().prayers,
  );
}

HomePrayerSnapshot _sampleArabicHomePrayerSnapshot() {
  return HomePrayerSnapshot(
    locationLabel: 'القاهرة، مصر',
    gregorianDate: DateTime(2026, 3, 25),
    hijriDay: 6,
    hijriYear: 1447,
    weekdayLabel: 'الأربعاء',
    hijriLabel: '6 شوال 1447 هـ',
    nextPrayer: PrayerType.maghrib,
    nextPrayerTime: DateTime(2026, 3, 25, 18, 9),
    hijriMonthReference: const HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'شوال',
      monthNameEnglish: 'Shawwal',
    ),
    isUsingCachedData: false,
    cachedFetchedAt: null,
    prayers: _samplePrayerTimesDay().prayers,
  );
}

PrayerTimesDay _samplePrayerTimesDay() {
  return PrayerTimesDay(
    gregorianDate: DateTime(2026, 3, 25),
    hijriDay: 6,
    hijriYear: 1447,
    hijriMonthReference: const HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'شوال',
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

HijriCalendarMonthData _sampleHijriMonthData() {
  return const HijriCalendarMonthData(
    reference: HijriMonthReference(
      year: 1447,
      month: 10,
      monthNameArabic: 'شوال',
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
    ],
  );
}

class _FakePrayerLocationService implements PrayerLocationService {
  _FakePrayerLocationService({
    this.error,
  });

  final PrayerFeatureException? error;
  int resolveCalls = 0;

  @override
  Future<PrayerCoordinates> resolveCurrentCoordinates() async {
    resolveCalls += 1;
    if (error != null) {
      throw error!;
    }

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
    final coordinates = await resolveCurrentCoordinates();
    return PrayerLocationSnapshot(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      label: 'Cairo, Egypt',
    );
  }
}

class _FakeMorePrayerRemoteDataSource implements MorePrayerRemoteDataSource {
  _FakeMorePrayerRemoteDataSource({
    required this.day,
    required this.month,
  });

  final PrayerTimesDay day;
  final HijriCalendarMonthData month;

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
    return PrayerTimesMonthData(
      gregorianYear: 2026,
      gregorianMonth: 3,
      days: [
        day,
      ],
    );
  }

  @override
  Future<HijriCalendarMonthData> fetchHijriMonth({
    required int hijriYear,
    required int hijriMonth,
  }) async {
    return month;
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
