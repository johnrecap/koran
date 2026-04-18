import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_library/quran_library.dart';
import 'core/services/app_bootstrap_service.dart';
import 'core/services/error_reporting_service.dart';
import 'core/localization/app_locale_policy.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme_mode_policy.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'data/datasources/local/user_preferences.dart';
import 'features/notifications/domain/notification_launch_target.dart';
import 'features/notifications/domain/notification_payload_codec.dart';
import 'features/notifications/domain/notification_reader_launch_policy.dart';
import 'features/notifications/providers/notification_providers.dart';
import 'features/premium/providers/premium_providers.dart';
import 'features/prayer/providers/prayer_providers.dart';
import 'features/reader/providers/reader_providers.dart';
import 'features/reader/domain/reader_session_intent.dart';
import 'features/settings/providers/settings_providers.dart';

Future<void> main() async {
  // ─── Critical path: preserve the native splash ───
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ─── Error handlers (lightweight, synchronous) ───
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

  // ─── Fast-path: only read theme + locale for the first frame ───
  final quickPrefs = await Future.wait<Object?>([
    UserPreferences.getThemeMode(),
    UserPreferences.getLanguage(),
  ]);

  final themeMode = AppThemeModePolicy.resolve(quickPrefs[0]! as String);
  final locale = AppLocalePolicy.resolve(quickPrefs[1]! as String);

  // Cache so the full settings load doesn't re-read these
  AppBootstrapService.instance.cacheThemeAndLocale(
    themeMode: themeMode,
    locale: locale,
  );

  final minimalSettings = AppSettingsState(
    themeMode: themeMode,
    locale: locale,
    // Safe defaults — will be replaced in SplashScreen after full init
    arabicFontSize: 28.0,
    defaultReaderMode: ReaderMode.page,
    tajweedEnabled: true,
    nightReaderSettings: const NightReaderSettings(
      autoEnable: false,
      startMinutes: 1200,
      endMinutes: 360,
      preferredStyle: ReaderNightStyle.night,
    ),
  );

  // ─── Orientation + status bar (synchronous) ───
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

  // ─── Launch immediately — SplashScreen does heavy init ───
  runApp(
    ProviderScope(
      overrides: [
        appSettingsInitialStateProvider.overrideWithValue(minimalSettings),
      ],
      child: const QuranKareemApp(),
    ),
  );
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
      builder: (context, child) => _PostBootstrapBridge(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// A bridge widget that sets up notification listeners **only after**
/// [AppBootstrapService] is initialized (i.e. after the SplashScreen
/// completes its bootstrap).
///
/// Before bootstrap, it simply renders its child without wiring up
/// any service-dependent listeners.
class _PostBootstrapBridge extends ConsumerStatefulWidget {
  const _PostBootstrapBridge({required this.child});
  final Widget child;

  @override
  ConsumerState<_PostBootstrapBridge> createState() =>
      _PostBootstrapBridgeState();
}

class _PostBootstrapBridgeState extends ConsumerState<_PostBootstrapBridge>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _launchSubscription;
  bool _isWired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listen for bootstrap completion to guarantee wiring fires,
    // regardless of whether any watched providers changed.
    AppBootstrapService.instance.bootstrapCompleted.addListener(
      _onBootstrapCompleted,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isWired) {
      unawaited(
        resyncNotificationsOnAppResume(
          refreshPermission: () {
            return ref
                .read(notificationPermissionControllerProvider.notifier)
                .refresh();
          },
          resyncAll: () {
            return ref
                .read(notificationPreferencesControllerProvider.notifier)
                .resyncAll();
          },
          invalidatePrayerSnapshot: () {
            ref.invalidate(homePrayerSnapshotProvider);
          },
        ),
      );
    }
  }

  void _onBootstrapCompleted() {
    if (mounted && !_isWired && AppBootstrapService.instance.isInitialized) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wire up once bootstrap is complete
    if (!_isWired && AppBootstrapService.instance.isInitialized) {
      _isWired = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _wireNotificationListeners();
      });
    }

    final pendingTarget = ref.watch(pendingNotificationLaunchTargetProvider);
    if (pendingTarget != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _consumePendingLaunchTarget(pendingTarget);
      });
    }

    return widget.child;
  }

  void _wireNotificationListeners() {
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
    WidgetsBinding.instance.removeObserver(this);
    AppBootstrapService.instance.bootstrapCompleted.removeListener(
      _onBootstrapCompleted,
    );
    _launchSubscription?.cancel();
    super.dispose();
  }

  void _consumePendingLaunchTarget(NotificationLaunchTarget target) {
    if (_isStartupGateActive()) return;

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
    if (!mounted) return;

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
