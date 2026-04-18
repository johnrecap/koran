import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/notifications/domain/notification_permission_state.dart';
import 'package:quran_kareem/features/notifications/providers/notification_providers.dart';
import 'package:quran_kareem/features/onboarding/domain/permission_flow_policy.dart';

/// A one-time permission request screen shown after onboarding.
///
/// It presents a friendly pre-prompt for each permission (notifications,
/// location) before invoking the system dialog, improving grant rates and
/// user confidence. The user can skip any permission — the app degrades
/// gracefully.
class PermissionRequestScreen extends ConsumerStatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  ConsumerState<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState
    extends ConsumerState<PermissionRequestScreen> {
  bool _notificationDone = false;
  bool _notificationGranted = false;
  bool _locationDone = false;
  bool _locationGranted = false;
  bool _isLoadingNotification = false;
  bool _isLoadingLocation = false;

  Future<void> _requestNotificationPermission() async {
    setState(() => _isLoadingNotification = true);
    try {
      await ref
          .read(notificationPermissionControllerProvider.notifier)
          .requestPermission();
      final state = ref.read(notificationPermissionControllerProvider);
      setState(() {
        _notificationDone = true;
        _notificationGranted = state.isGranted;
        _isLoadingNotification = false;
      });
    } catch (_) {
      setState(() {
        _notificationDone = true;
        _notificationGranted = false;
        _isLoadingNotification = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationDone = true;
          _locationGranted = false;
          _isLoadingLocation = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      setState(() {
        _locationDone = true;
        _locationGranted = permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
        _isLoadingLocation = false;
      });
    } catch (_) {
      setState(() {
        _locationDone = true;
        _locationGranted = false;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _continue() async {
    await PermissionFlowPolicy.markComplete();
    if (!mounted) return;
    context.go('/library');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth > 400 ? 380.0 : screenWidth - 40;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ─── Header ───
                const Icon(
                  Icons.security_rounded,
                  size: 56,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.permissionsTitle,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: cardWidth,
                  child: Text(
                    l10n.permissionsSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ─── Notification Permission Card ───
                _PermissionCard(
                  width: cardWidth,
                  icon: Icons.notifications_active_rounded,
                  title: l10n.permissionsNotificationTitle,
                  description: l10n.permissionsNotificationDesc,
                  isDone: _notificationDone,
                  isGranted: _notificationGranted,
                  isLoading: _isLoadingNotification,
                  isDark: isDark,
                  grantedLabel: l10n.permissionsGranted,
                  deniedLabel: l10n.permissionsDenied,
                  allowLabel: l10n.permissionsAllow,
                  onAllow: _requestNotificationPermission,
                ),

                const SizedBox(height: 16),

                // ─── Location Permission Card ───
                _PermissionCard(
                  width: cardWidth,
                  icon: Icons.location_on_rounded,
                  title: l10n.permissionsLocationTitle,
                  description: l10n.permissionsLocationDesc,
                  isDone: _locationDone,
                  isGranted: _locationGranted,
                  isLoading: _isLoadingLocation,
                  isDark: isDark,
                  grantedLabel: l10n.permissionsGranted,
                  deniedLabel: l10n.permissionsDenied,
                  allowLabel: l10n.permissionsAllow,
                  onAllow: _requestLocationPermission,
                ),

                const SizedBox(height: 40),

                // ─── Continue Button ───
                SizedBox(
                  width: cardWidth,
                  height: 52,
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(l10n.permissionsContinue),
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

/// A single permission request card with icon, description, and action button.
class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.isDone,
    required this.isGranted,
    required this.isLoading,
    required this.isDark,
    required this.grantedLabel,
    required this.deniedLabel,
    required this.allowLabel,
    required this.onAllow,
  });

  final double width;
  final IconData icon;
  final String title;
  final String description;
  final bool isDone;
  final bool isGranted;
  final bool isLoading;
  final bool isDark;
  final String grantedLabel;
  final String deniedLabel;
  final String allowLabel;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDone && isGranted
                  ? AppColors.meccan.withValues(alpha: 0.5)
                  : AppColors.camel.withValues(alpha: isDark ? 0.2 : 0.12),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 14),

              // Title + Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Action
              _buildAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.gold,
        ),
      );
    }

    if (isDone) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isGranted
              ? AppColors.meccan.withValues(alpha: 0.12)
              : AppColors.warmBrown.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          isGranted ? grantedLabel : deniedLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isGranted ? AppColors.meccan : AppColors.warmBrown,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: onAllow,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.gold,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
      ),
      child: Text(
        allowLabel,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
