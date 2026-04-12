import 'dart:math' as math;

import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

import 'qibla_compass_models.dart';

class QiblaCompassPolicies {
  QiblaCompassPolicies._();

  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;
  static const double facingToleranceDegrees = 10;
  static const double calibrationAccuracyThreshold = 20;

  static QiblaCompassSnapshot buildSnapshot({
    required PrayerLocationSnapshot location,
    required QiblaDirectionData direction,
    required QiblaHeadingReading heading,
  }) {
    final calibrationState = _resolveCalibrationState(heading);
    final relativeNeedleDegrees = heading.headingDegrees == null
        ? 0.0
        : clockwiseDelta(
            from: heading.headingDegrees!,
            to: direction.bearingDegrees,
          );
    final absoluteDelta = heading.headingDegrees == null
        ? 180.0
        : shortestAngleDelta(
            from: heading.headingDegrees!,
            to: direction.bearingDegrees,
          ).abs();

    return QiblaCompassSnapshot(
      locationLabel: location.label,
      qiblaBearingDegrees: normalizeDegrees(direction.bearingDegrees),
      distanceMeters: direction.distanceMeters,
      headingDegrees: heading.headingDegrees == null
          ? null
          : normalizeDegrees(heading.headingDegrees!),
      relativeNeedleDegrees: relativeNeedleDegrees,
      isFacingQibla: calibrationState == QiblaCalibrationState.ready &&
          absoluteDelta <= facingToleranceDegrees,
      calibrationState: calibrationState,
    );
  }

  static String formatDistance(double distanceMeters) {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.round()} m';
  }

  static double normalizeDegrees(double degrees) {
    final value = degrees % 360;
    return value < 0 ? value + 360 : value;
  }

  static double clockwiseDelta({
    required double from,
    required double to,
  }) {
    return normalizeDegrees(to - from);
  }

  static double shortestAngleDelta({
    required double from,
    required double to,
  }) {
    final delta = clockwiseDelta(from: from, to: to);
    return delta > 180 ? delta - 360 : delta;
  }

  static double distanceToKaabaMeters({
    required double latitude,
    required double longitude,
  }) {
    const earthRadiusMeters = 6371000.0;
    final startLatitude = _degreesToRadians(latitude);
    final endLatitude = _degreesToRadians(kaabaLatitude);
    final deltaLatitude = _degreesToRadians(kaabaLatitude - latitude);
    final deltaLongitude = _degreesToRadians(kaabaLongitude - longitude);

    final a = math.sin(deltaLatitude / 2) * math.sin(deltaLatitude / 2) +
        math.cos(startLatitude) *
            math.cos(endLatitude) *
            math.sin(deltaLongitude / 2) *
            math.sin(deltaLongitude / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static QiblaCalibrationState _resolveCalibrationState(
    QiblaHeadingReading heading,
  ) {
    if (heading.headingDegrees == null) {
      return QiblaCalibrationState.unavailable;
    }
    if (heading.accuracy != null &&
        heading.accuracy! > calibrationAccuracyThreshold) {
      return QiblaCalibrationState.calibrating;
    }
    return QiblaCalibrationState.ready;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
