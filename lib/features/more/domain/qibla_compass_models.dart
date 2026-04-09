enum QiblaCalibrationState {
  ready,
  calibrating,
  unavailable,
}

class QiblaDirectionData {
  const QiblaDirectionData({
    required this.bearingDegrees,
    required this.distanceMeters,
  });

  final double bearingDegrees;
  final double distanceMeters;
}

class QiblaHeadingReading {
  const QiblaHeadingReading({
    required this.headingDegrees,
    required this.accuracy,
  });

  final double? headingDegrees;
  final double? accuracy;
}

class QiblaCompassSnapshot {
  const QiblaCompassSnapshot({
    required this.locationLabel,
    required this.qiblaBearingDegrees,
    required this.distanceMeters,
    required this.headingDegrees,
    required this.relativeNeedleDegrees,
    required this.isFacingQibla,
    required this.calibrationState,
  });

  final String locationLabel;
  final double qiblaBearingDegrees;
  final double distanceMeters;
  final double? headingDegrees;
  final double relativeNeedleDegrees;
  final bool isFacingQibla;
  final QiblaCalibrationState calibrationState;
}
