import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';
import 'package:quran_kareem/features/qibla/domain/qibla_compass_models.dart';
import 'package:quran_kareem/features/qibla/domain/qibla_compass_policies.dart';

void main() {
  test('buildSnapshot marks user as facing qibla within tolerance', () {
    final snapshot = QiblaCompassPolicies.buildSnapshot(
      location: const PrayerLocationSnapshot(
        latitude: 30.0444,
        longitude: 31.2357,
        label: 'Cairo, Egypt',
      ),
      direction: const QiblaDirectionData(
        bearingDegrees: 136.0,
        distanceMeters: 438000,
      ),
      heading: const QiblaHeadingReading(
        headingDegrees: 130.0,
        accuracy: 4.0,
      ),
    );

    expect(snapshot.locationLabel, 'Cairo, Egypt');
    expect(snapshot.relativeNeedleDegrees, closeTo(6.0, 0.001));
    expect(snapshot.isFacingQibla, isTrue);
    expect(snapshot.calibrationState, QiblaCalibrationState.ready);
  });

  test('buildSnapshot reports unavailable calibration when heading is missing',
      () {
    final snapshot = QiblaCompassPolicies.buildSnapshot(
      location: const PrayerLocationSnapshot(
        latitude: 30.0444,
        longitude: 31.2357,
        label: 'Cairo, Egypt',
      ),
      direction: const QiblaDirectionData(
        bearingDegrees: 136.0,
        distanceMeters: 438000,
      ),
      heading: const QiblaHeadingReading(
        headingDegrees: null,
        accuracy: null,
      ),
    );

    expect(snapshot.headingDegrees, isNull);
    expect(snapshot.calibrationState, QiblaCalibrationState.unavailable);
    expect(snapshot.isFacingQibla, isFalse);
  });

  test('formatDistance renders kilometers with one decimal place', () {
    expect(QiblaCompassPolicies.formatDistance(438000), '438.0 km');
    expect(QiblaCompassPolicies.formatDistance(820), '820 m');
  });
}
