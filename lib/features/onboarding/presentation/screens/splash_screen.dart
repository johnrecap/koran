import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/services/app_bootstrap_service.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/notifications/providers/notification_providers.dart';
import 'package:quran_kareem/features/onboarding/domain/startup_route_policy.dart';
import 'package:quran_kareem/features/premium/providers/premium_providers.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleUp = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Remove native splash → show our animated one
    FlutterNativeSplash.remove();
    _controller.forward();

    // Heavy init runs in parallel with the animation
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    final stopwatch = Stopwatch()..start();

    try {
      // QuranLibrary, services, full settings, data migration — all managed
      // by AppBootstrapService in the correct dependency order
      await AppBootstrapService.instance.initialize();

      if (!mounted) return;

      // ─── Wire initialized services into the provider graph ───
      final bootstrap = AppBootstrapService.instance;

      // Atomic settings replacement — no re-persistence, one rebuild
      ref.read(appSettingsControllerProvider.notifier)
          .replaceState(bootstrap.fullSettings);

      // Force service providers to rebuild with bootstrap instances
      ref.invalidate(localNotificationsServiceProvider);
      ref.invalidate(notificationTimezoneServiceProvider);
      ref.invalidate(premiumPurchasesServiceProvider);

      // If there was a notification that launched the app, inject it
      if (bootstrap.initialNotificationLaunchTarget != null) {
        ref.read(pendingNotificationLaunchTargetProvider.notifier).state =
            bootstrap.initialNotificationLaunchTarget;
      }
    } catch (error, stack) {
      AppLogger.fatal('SplashScreen._initializeAndNavigate', error, stack);
      // Even on failure, try to navigate (graceful degradation)
    }

    stopwatch.stop();
    AppLogger.info(
      'SplashScreen',
      'Bootstrap completed in ${stopwatch.elapsedMilliseconds}ms',
    );

    if (!mounted) return;

    // ─── Ensure minimum display time for the animation ───
    final elapsed = stopwatch.elapsedMilliseconds;
    const minDisplayMs = 1200;
    if (elapsed < minDisplayMs) {
      await Future<void>.delayed(
        Duration(milliseconds: minDisplayMs - elapsed),
      );
    }

    if (!mounted) return;

    // ─── Navigate to the appropriate route ───
    final isOnboardingComplete = await UserPreferences.isOnboardingComplete();
    final isPermissionsFlowComplete =
        await UserPreferences.isPermissionsFlowComplete();
    final isMushafSetupComplete = await UserPreferences.isMushafSetupComplete();
    final nextRoute = StartupRoutePolicy.resolve(
      isOnboardingComplete: isOnboardingComplete,
      isPermissionsFlowComplete: isPermissionsFlowComplete,
      isMushafSetupComplete: isMushafSetupComplete,
    );

    if (mounted) {
      context.go(nextRoute.path);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              Color(0xFF0F2218),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleUp,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldReader.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldReader.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 56,
                          color: AppColors.goldReader,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.splashTitle,
                  style: const TextStyle(
                    fontSize: 36,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.splashSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Amiri',
                    color: AppColors.goldReader.withValues(alpha: 0.8),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.goldReader.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
