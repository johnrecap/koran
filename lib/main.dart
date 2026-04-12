import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_library/quran_library.dart';
import 'core/services/data_migration_service.dart';
import 'core/services/error_reporting_service.dart';
import 'core/localization/app_locale_policy.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme_mode_policy.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'data/datasources/local/user_preferences.dart';
import 'features/notifications/data/notification_timezone_service.dart';
import 'features/notifications/data/local_notifications_service.dart';
import 'features/notifications/data/package_local_notifications_service.dart';
import 'features/notifications/domain/notification_launch_target.dart';
import 'features/notifications/domain/notification_payload_codec.dart';
import 'features/notifications/domain/notification_reader_launch_policy.dart';
import 'features/notifications/providers/notification_providers.dart';
import 'features/premium/data/premium_purchases_service.dart';
import 'features/premium/providers/premium_providers.dart';
import 'features/reader/providers/reader_providers.dart';
import 'features/reader/domain/reader_session_intent.dart';
import 'features/settings/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorReporting.install(const NoopErrorReportingService());
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.fatal(
      'FlutterError.onError',
      details.exception,
      details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.fatal(
      'PlatformDispatcher.instance.onError',
      error,
      stackTrace,
    );
    return true;
  };

  await QuranLibrary.init();
  await DataMigrationService().run();
  final preferenceResults = await Future.wait<Object?>([
    UserPreferences.getThemeMode(),
    UserPreferences.getLanguage(),
    UserPreferences.getArabicFontSize(),
    UserPreferences.getReaderMode(),
    UserPreferences.isTajweedEnabled(),
    UserPreferences.isNightReaderAutoEnableEnabled(),
    UserPreferences.getNightReaderStartMinutes(),
    UserPreferences.getNightReaderEndMinutes(),
    UserPreferences.getPreferredNightReaderStyle(),
  ]);
  final initialSettings = AppSettingsState(
    themeMode: AppThemeModePolicy.resolve(
      preferenceResults[0]! as String,
    ),
    locale: AppLocalePolicy.resolve(
      preferenceResults[1]! as String,
    ),
    arabicFontSize: preferenceResults[2]! as double,
    defaultReaderMode: ReaderModePolicy.fromPreference(
      preferenceResults[3]! as String,
    ),
    tajweedEnabled: preferenceResults[4]! as bool,
    nightReaderSettings: NightReaderSettings(
      autoEnable: preferenceResults[5]! as bool,
      startMinutes: preferenceResults[6]! as int,
      endMinutes: preferenceResults[7]! as int,
      preferredStyle: preferenceResults[8]! as ReaderNightStyle,
    ),
  );
  const QuranLibrarySettingsRuntimeSync().sync(initialSettings);
  final notificationTimezoneService = DeviceNotificationTimezoneService();
  final localNotificationsService = PackageLocalNotificationsService(
    timezoneService: notificationTimezoneService,
  );
  final premiumPurchasesService = createDefaultPremiumPurchasesService();
  await Future.wait<void>([
    localNotificationsService.initialize(),
    premiumPurchasesService.initialize(),
  ]);
  final initialNotificationLaunchTarget = await _loadInitialNotificationTarget(
    localNotificationsService,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        appSettingsInitialStateProvider.overrideWithValue(initialSettings),
        notificationTimezoneServiceProvider
            .overrideWithValue(notificationTimezoneService),
        localNotificationsServiceProvider.overrideWithValue(
          localNotificationsService,
        ),
        premiumPurchasesServiceProvider.overrideWithValue(
          premiumPurchasesService,
        ),
        initialNotificationLaunchTargetProvider.overrideWithValue(
          initialNotificationLaunchTarget,
        ),
      ],
      child: const QuranKareemApp(),
    ),
  );
}

Future<NotificationLaunchTarget?> _loadInitialNotificationTarget(
  LocalNotificationsService notificationsService,
) async {
  final payload = await notificationsService.getLaunchPayload();
  if (payload == null || payload.isEmpty) {
    return null;
  }
  return NotificationPayloadCodec.decodeOrFallback(payload);
}

class QuranKareemApp extends ConsumerWidget {
  const QuranKareemApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: appRouter,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => NotificationFeatureBridge(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

class NotificationFeatureBridge extends ConsumerStatefulWidget {
  const NotificationFeatureBridge({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<NotificationFeatureBridge> createState() =>
      _NotificationFeatureBridgeState();
}

class _NotificationFeatureBridgeState
    extends ConsumerState<NotificationFeatureBridge> {
  StreamSubscription<String>? _launchSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(
        ref.read(notificationPermissionControllerProvider.notifier).ready);
    unawaited(
        ref.read(notificationPreferencesControllerProvider.notifier).ready);
    unawaited(ref.read(premiumEntitlementControllerProvider.notifier).ready);
    _launchSubscription =
        ref.read(localNotificationsServiceProvider).launchPayloads.listen(
      (payload) {
        ref.read(pendingNotificationLaunchTargetProvider.notifier).state =
            NotificationPayloadCodec.decodeOrFallback(payload);
      },
    );
  }

  @override
  void dispose() {
    _launchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingTarget = ref.watch(pendingNotificationLaunchTargetProvider);
    if (pendingTarget != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _consumePendingLaunchTarget(pendingTarget);
      });
    }

    return widget.child;
  }

  void _consumePendingLaunchTarget(NotificationLaunchTarget target) {
    if (_isStartupGateActive()) {
      return;
    }

    switch (target.destination) {
      case NotificationLaunchDestination.library:
        context.go('/library');
        break;
      case NotificationLaunchDestination.prayerDetails:
        context.go('/more/prayer-times');
        break;
      case NotificationLaunchDestination.adhkar:
        context.go('/more/adhkar');
        break;
      case NotificationLaunchDestination.reviewQueue:
        context.go('/memorization/reviews');
        break;
      case NotificationLaunchDestination.dailyWirdReader:
        unawaited(_openDailyWirdReader());
        break;
      case NotificationLaunchDestination.fridayKahfReader:
        _openFridayKahfReader();
        break;
    }

    ref.read(pendingNotificationLaunchTargetProvider.notifier).state = null;
  }

  bool _isStartupGateActive() {
    final path = appRouter.routeInformationProvider.value.uri.path;
    return path == '/splash' ||
        path == '/onboarding' ||
        path == '/setup-mushaf';
  }

  Future<void> _openDailyWirdReader() async {
    final lastReadingPosition = await UserPreferences.getLastReadingPosition();
    if (!mounted) {
      return;
    }

    final target = NotificationReaderLaunchPolicy.dailyWirdTarget(
      lastReadingPosition,
    );
    ref.read(readerSessionIntentProvider.notifier).state =
        const ReaderSessionIntent.general();
    ref.read(readerNavigationTargetProvider.notifier).state = target;
    ref.read(currentSurahProvider.notifier).state = target.surahNumber;
    ref.read(quranPageIndexProvider.notifier).state = target.pageNumber;
    context.go('/reader');
  }

  void _openFridayKahfReader() {
    final surah = QuranCtrl.instance.surahs.firstWhere(
      (item) => item.surahNumber == 18,
      orElse: () => QuranCtrl.instance.surahs.first,
    );
    final pageNumber = surah.ayahs.isEmpty ? 293 : surah.ayahs.first.page;
    final target = ReaderEntryTargetPolicy.forSurah(
      surahNumber: 18,
      pageNumber: pageNumber,
    );
    ref.read(readerSessionIntentProvider.notifier).state =
        const ReaderSessionIntent.general();
    ref.read(readerNavigationTargetProvider.notifier).state = target;
    ref.read(currentSurahProvider.notifier).state = target.surahNumber;
    ref.read(quranPageIndexProvider.notifier).state = target.pageNumber;
    context.go('/reader');
  }
}
