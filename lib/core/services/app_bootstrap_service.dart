import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import '../../data/datasources/local/user_preferences.dart';
import 'data_migration_service.dart';
import '../../features/notifications/data/notification_timezone_service.dart';
import '../../features/notifications/data/local_notifications_service.dart';
import '../../features/notifications/data/package_local_notifications_service.dart';
import '../../features/notifications/domain/notification_launch_target.dart';
import '../../features/notifications/domain/notification_payload_codec.dart';
import '../../features/premium/data/premium_purchases_service.dart';
import '../../features/reader/domain/reader_mode_policy.dart';
import '../../features/reader/domain/reader_night_style.dart';
import '../../features/settings/providers/settings_providers.dart';

/// Manages the deferred app initialization that previously ran in [main()]
/// before [runApp()].
///
/// The lifecycle is:
/// 1. [main()] calls [runApp()] immediately after minimal setup (error handlers
///    + theme/locale for the first frame).
/// 2. The SplashScreen calls [AppBootstrapService.initialize()] which performs
///    the heavy work (QuranLibrary, notifications, premium, etc.).
/// 3. When [initialize()] completes, the SplashScreen navigates to the next
///    route.
class AppBootstrapService {
  AppBootstrapService._();

  static final AppBootstrapService instance = AppBootstrapService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// A notifier that fires when bootstrap completes.
  /// [_PostBootstrapBridge] listens to this to guarantee wiring.
  final bootstrapCompleted = ValueNotifier<bool>(false);

  /// Services initialized during bootstrap.
  /// Accessible after [initialize()] completes.
  late final NotificationTimezoneService notificationTimezoneService;
  late final LocalNotificationsService localNotificationsService;
  late final PremiumPurchasesService premiumPurchasesService;
  late final NotificationLaunchTarget? initialNotificationLaunchTarget;
  late final AppSettingsState fullSettings;

  /// Performs all heavy initialization that was previously in [main()]:
  /// - QuranLibrary.init()
  /// - DataMigration
  /// - Full settings load
  /// - Notifications & Premium init
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // ─── Phase 1: QuranLibrary (heaviest) ───
    await QuranLibrary.init();

    // ─── Phase 1.5: Data migration (must complete before reading settings) ───
    await DataMigrationService().run();

    // ─── Phase 2: Full settings ───
    final preferenceResults = await Future.wait<Object?>([
      UserPreferences.getArabicFontSize(),
      UserPreferences.getReaderMode(),
      UserPreferences.isTajweedEnabled(),
      UserPreferences.isNightReaderAutoEnableEnabled(),
      UserPreferences.getNightReaderStartMinutes(),
      UserPreferences.getNightReaderEndMinutes(),
      UserPreferences.getPreferredNightReaderStyle(),
    ]);

    fullSettings = AppSettingsState(
      themeMode: _cachedThemeMode,
      locale: _cachedLocale,
      arabicFontSize: preferenceResults[0]! as double,
      defaultReaderMode: ReaderModePolicy.fromPreference(
        preferenceResults[1]! as String,
      ),
      tajweedEnabled: preferenceResults[2]! as bool,
      nightReaderSettings: NightReaderSettings(
        autoEnable: preferenceResults[3]! as bool,
        startMinutes: preferenceResults[4]! as int,
        endMinutes: preferenceResults[5]! as int,
        preferredStyle: preferenceResults[6]! as ReaderNightStyle,
      ),
    );

    const QuranLibrarySettingsRuntimeSync().sync(fullSettings);

    // ─── Phase 3: Services (parallel) ───
    notificationTimezoneService = DeviceNotificationTimezoneService();
    localNotificationsService = PackageLocalNotificationsService(
      timezoneService: notificationTimezoneService,
    );
    premiumPurchasesService = createDefaultPremiumPurchasesService();

    await Future.wait<void>([
      localNotificationsService.initialize(),
      premiumPurchasesService.initialize(),
    ]);

    // ─── Phase 4: Check launch notification ───
    initialNotificationLaunchTarget = await _loadInitialNotificationTarget();

    _isInitialized = true;
    bootstrapCompleted.value = true;
  }

  // ─── Cached values from the fast path in main() ───
  ThemeMode _cachedThemeMode = ThemeMode.system;
  Locale _cachedLocale = const Locale('ar');

  /// Called from [main()] to cache the fast-path theme/locale values
  /// so they can be reused in the full settings without re-reading prefs.
  void cacheThemeAndLocale({
    required ThemeMode themeMode,
    required Locale locale,
  }) {
    _cachedThemeMode = themeMode;
    _cachedLocale = locale;
  }

  Future<NotificationLaunchTarget?> _loadInitialNotificationTarget() async {
    final payload = await localNotificationsService.getLaunchPayload();
    if (payload == null || payload.isEmpty) {
      return null;
    }
    return NotificationPayloadCodec.decodeOrFallback(payload);
  }
}
