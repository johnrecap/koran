import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';

import '../domain/qibla_compass_models.dart';

abstract class QiblaHeadingService {
  Stream<QiblaHeadingReading> watchHeading();
}

class FlutterCompassQiblaHeadingService implements QiblaHeadingService {
  const FlutterCompassQiblaHeadingService();

  @override
  Stream<QiblaHeadingReading> watchHeading() async* {
    if (kIsWeb) {
      yield const QiblaHeadingReading(
        headingDegrees: null,
        accuracy: null,
      );
      return;
    }

    final events = FlutterCompass.events;
    if (events == null) {
      yield const QiblaHeadingReading(
        headingDegrees: null,
        accuracy: null,
      );
      return;
    }

    try {
      await for (final event in events) {
        yield QiblaHeadingReading(
          headingDegrees: event.heading,
          accuracy: event.accuracy,
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'FlutterCompassQiblaHeadingService.watchHeading',
        error,
        stackTrace,
      );
      yield const QiblaHeadingReading(
        headingDegrees: null,
        accuracy: null,
      );
    }
  }
}
