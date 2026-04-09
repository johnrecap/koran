import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/more/presentation/widgets/qibla_compass_card.dart';

class QiblaCompassScreen extends ConsumerWidget {
  const QiblaCompassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snapshotAsync = ref.watch(qiblaCompassSnapshotProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        elevation: 0,
        title: Text(
          l10n.qiblaCompassTitle,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: snapshotAsync.when(
        data: (snapshot) {
          final guidance = _guidanceLabel(context, snapshot);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: QiblaCompassCard(
              snapshot: snapshot,
              title: l10n.qiblaCompassTitle,
              distanceLabel: l10n.qiblaCompassDistance,
              distanceValue:
                  QiblaCompassPolicies.formatDistance(snapshot.distanceMeters),
              bearingLabel: l10n.qiblaCompassBearing,
              headingLabel: l10n.qiblaCompassHeading,
              statusLabel: snapshot.isFacingQibla
                  ? l10n.qiblaCompassFacing
                  : l10n.qiblaCompassNotFacing,
              guidanceLabel: guidance,
              showGuidance: guidance.isNotEmpty,
            ),
          );
        },
        loading: () => _QiblaLoadingState(
          message: l10n.qiblaCompassLoading,
        ),
        error: (error, stackTrace) => _QiblaErrorState(
          message: l10n.qiblaCompassError,
          retryLabel: l10n.homeToolsRetry,
          onRetry: () => ref.invalidate(qiblaCompassSnapshotProvider),
        ),
      ),
    );
  }

  String _guidanceLabel(
    BuildContext context,
    QiblaCompassSnapshot snapshot,
  ) {
    final l10n = context.l10n;
    switch (snapshot.calibrationState) {
      case QiblaCalibrationState.unavailable:
        return l10n.qiblaCompassSensorUnavailable;
      case QiblaCalibrationState.calibrating:
        return l10n.qiblaCompassCalibrate;
      case QiblaCalibrationState.ready:
        break;
    }

    if (snapshot.isFacingQibla) {
      return l10n.qiblaCompassNeedleHint;
    }

    final heading = snapshot.headingDegrees;
    if (heading == null) {
      return l10n.qiblaCompassSensorUnavailable;
    }

    final delta = QiblaCompassPolicies.shortestAngleDelta(
      from: heading,
      to: snapshot.qiblaBearingDegrees,
    );
    final turnLabel =
        delta >= 0 ? l10n.qiblaCompassTurnRight : l10n.qiblaCompassTurnLeft;
    return '$turnLabel ${delta.abs().round()}°';
  }
}

class _QiblaLoadingState extends StatelessWidget {
  const _QiblaLoadingState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 34),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkNav : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QiblaErrorState extends StatelessWidget {
  const _QiblaErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkNav : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.explore_off_rounded,
              color: AppColors.gold,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
