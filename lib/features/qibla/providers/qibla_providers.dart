import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/prayer/providers/prayer_providers.dart';
import 'package:quran_kareem/features/qibla/data/qibla_heading_service.dart';
import 'package:quran_kareem/features/qibla/domain/qibla_compass_models.dart';
import 'package:quran_kareem/features/qibla/domain/qibla_compass_policies.dart';

export 'package:quran_kareem/features/qibla/data/qibla_heading_service.dart';
export 'package:quran_kareem/features/qibla/domain/qibla_compass_models.dart';
export 'package:quran_kareem/features/qibla/domain/qibla_compass_policies.dart';

final qiblaHeadingServiceProvider = Provider<QiblaHeadingService>((ref) {
  return const FlutterCompassQiblaHeadingService();
});

final qiblaCompassSnapshotProvider =
    StreamProvider.autoDispose<QiblaCompassSnapshot>((ref) {
  final locationService = ref.watch(prayerLocationServiceProvider);
  final remote = ref.watch(morePrayerRemoteDataSourceProvider);
  final headingService = ref.watch(qiblaHeadingServiceProvider);
  final controller = StreamController<QiblaCompassSnapshot>();
  var disposed = false;

  ref.onDispose(() {
    disposed = true;
    unawaited(controller.close());
  });

  Future<void> load() async {
    try {
      final coordinates = await locationService.resolveCurrentCoordinates();
      if (disposed) {
        return;
      }

      final labelFuture = locationService.resolveLocationLabel(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );
      final direction = await remote.fetchQiblaDirection(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );
      if (disposed) {
        return;
      }

      var location = PrayerLocationSnapshot(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        label: coordinates.fallbackLabel,
      );
      var heading = const QiblaHeadingReading(
        headingDegrees: null,
        accuracy: null,
      );

      void emitSnapshot() {
        if (disposed || controller.isClosed) {
          return;
        }

        controller.add(
          QiblaCompassPolicies.buildSnapshot(
            location: location,
            direction: direction,
            heading: heading,
          ),
        );
      }

      emitSnapshot();

      unawaited(
        Future<void>(() async {
          try {
            final resolvedLabel = await labelFuture;
            if (disposed ||
                controller.isClosed ||
                resolvedLabel.isEmpty ||
                resolvedLabel == location.label) {
              return;
            }

            location = PrayerLocationSnapshot(
              latitude: coordinates.latitude,
              longitude: coordinates.longitude,
              label: resolvedLabel,
            );
            emitSnapshot();
          } catch (error, stackTrace) {
            AppLogger.error(
              'qiblaCompassStreamProvider.resolveLocationLabel',
              error,
              stackTrace,
            );
            // Keep the fallback coordinates label when reverse geocoding fails.
          }
        }),
      );

      await for (final nextHeading in headingService.watchHeading()) {
        if (disposed || controller.isClosed) {
          break;
        }

        heading = nextHeading;
        emitSnapshot();
      }
    } catch (error, stackTrace) {
      if (!disposed && !controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }
  }

  unawaited(load());
  return controller.stream;
});
