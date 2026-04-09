import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/prayer_time_models.dart';

abstract class PrayerLocationService {
  Future<PrayerCoordinates> resolveCurrentCoordinates();

  Future<String> resolveLocationLabel({
    required double latitude,
    required double longitude,
  });

  Future<PrayerLocationSnapshot> resolveCurrentLocation();
}

class GeolocatorPrayerLocationService implements PrayerLocationService {
  const GeolocatorPrayerLocationService();

  @override
  Future<PrayerCoordinates> resolveCurrentCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const PrayerFeatureException(
        PrayerFeatureError.locationServicesDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const PrayerFeatureException(PrayerFeatureError.permissionDenied);
    }

    if (permission == LocationPermission.deniedForever) {
      if (!kIsWeb) {
        unawaited(Geolocator.openAppSettings());
      }
      throw const PrayerFeatureException(
        PrayerFeatureError.permissionDeniedForever,
      );
    }

    final position = await Geolocator.getCurrentPosition();
    return PrayerCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Future<String> resolveLocationLabel({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final places = await placemarkFromCoordinates(latitude, longitude);
      if (places.isNotEmpty) {
        final place = places.first;
        final city = place.locality ?? place.subAdministrativeArea;
        final country = place.country;
        final pieces = <String>[
          if (city != null && city.trim().isNotEmpty) city.trim(),
          if (country != null && country.trim().isNotEmpty) country.trim(),
        ];
        if (pieces.isNotEmpty) {
          return pieces.join(', ');
        }
      }
    } on MissingPluginException {
      // Fallback to coordinates on unsupported platforms such as web.
    } on PlatformException {
      // Fallback to coordinates when reverse geocoding is unavailable.
    }

    return PrayerCoordinates(
      latitude: latitude,
      longitude: longitude,
    ).fallbackLabel;
  }

  @override
  Future<PrayerLocationSnapshot> resolveCurrentLocation() async {
    final coordinates = await resolveCurrentCoordinates();
    final label = await resolveLocationLabel(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
    );

    return PrayerLocationSnapshot(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      label: label,
    );
  }
}
