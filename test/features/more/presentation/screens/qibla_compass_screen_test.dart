import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/presentation/screens/qibla_compass_screen.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';

void main() {
  testWidgets('shows retry state when qibla loading fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qiblaCompassSnapshotProvider.overrideWith(
            (ref) => Stream.error(
              const PrayerFeatureException(
                PrayerFeatureError.permissionDenied,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: QiblaCompassScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows guidance state when heading is unavailable',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qiblaCompassSnapshotProvider.overrideWith(
            (ref) => Stream.value(
              const QiblaCompassSnapshot(
                locationLabel: 'Cairo, Egypt',
                qiblaBearingDegrees: 136.0,
                distanceMeters: 438000,
                headingDegrees: null,
                relativeNeedleDegrees: 0,
                isFacingQibla: false,
                calibrationState: QiblaCalibrationState.unavailable,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: QiblaCompassScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('qibla-guidance-state')), findsOneWidget);
  });
}
