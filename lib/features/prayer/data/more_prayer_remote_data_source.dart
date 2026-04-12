import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';

import '../domain/hijri_calendar_month.dart';
import '../domain/prayer_time_models.dart';
import 'package:quran_kareem/features/qibla/domain/qibla_compass_models.dart';
import 'package:quran_kareem/features/qibla/domain/qibla_compass_policies.dart';


class MorePrayerRemoteException implements Exception {
  const MorePrayerRemoteException(this.message);

  final String message;

  @override
  String toString() => 'MorePrayerRemoteException: $message';
}

abstract class MorePrayerRemoteDataSource {
  Future<PrayerTimesDay> fetchPrayerTimesDay({
    required double latitude,
    required double longitude,
    required DateTime date,
  });

  Future<PrayerTimesMonthData> fetchPrayerTimesMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  });

  Future<HijriCalendarMonthData> fetchHijriMonth({
    required int hijriYear,
    required int hijriMonth,
  });

  Future<QiblaDirectionData> fetchQiblaDirection({
    required double latitude,
    required double longitude,
  });
}

class AlAdhanMorePrayerRemoteDataSource implements MorePrayerRemoteDataSource {
  AlAdhanMorePrayerRemoteDataSource({
    required http.Client client,
    this.baseUrl = AppConstants.aladhanApiBaseUrl,
  }) : _client = client;

  final http.Client _client;
  final String baseUrl;

  @override
  Future<PrayerTimesDay> fetchPrayerTimesDay({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    final response = await _client.get(
      Uri.parse('$baseUrl/timings/$formattedDate').replace(
        queryParameters: <String, String>{
          'latitude': '$latitude',
          'longitude': '$longitude',
          'method': '5',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw MorePrayerRemoteException(
        'Unexpected status code: ${response.statusCode}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const MorePrayerRemoteException('Invalid response payload.');
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw const MorePrayerRemoteException('Missing data payload.');
    }

    return _mapPrayerTimesDay(
      data,
      fallbackDate: DateTime(date.year, date.month, date.day),
    );
  }

  @override
  Future<PrayerTimesMonthData> fetchPrayerTimesMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/calendar/$year/$month').replace(
        queryParameters: <String, String>{
          'latitude': '$latitude',
          'longitude': '$longitude',
          'method': '5',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw MorePrayerRemoteException(
        'Unexpected status code: ${response.statusCode}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const MorePrayerRemoteException('Invalid response payload.');
    }

    final data = payload['data'];
    if (data is! List) {
      throw const MorePrayerRemoteException('Missing prayer month data.');
    }

    final days = <PrayerTimesDay>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      days.add(
        _mapPrayerTimesDay(
          item,
          fallbackDate: DateTime(year, month, days.length + 1),
        ),
      );
    }

    return PrayerTimesMonthData(
      gregorianYear: year,
      gregorianMonth: month,
      days: days,
    );
  }

  @override
  Future<HijriCalendarMonthData> fetchHijriMonth({
    required int hijriYear,
    required int hijriMonth,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/hToGCalendar/$hijriMonth/$hijriYear'),
    );

    if (response.statusCode != 200) {
      throw MorePrayerRemoteException(
        'Unexpected status code: ${response.statusCode}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const MorePrayerRemoteException('Invalid response payload.');
    }

    final data = payload['data'];
    if (data is! List) {
      throw const MorePrayerRemoteException('Missing Hijri month data.');
    }

    final monthDays = <HijriCalendarDayData>[];
    HijriMonthReference? reference;
    for (final item in data) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final hijri = item['hijri'] as Map<String, dynamic>?;
      final gregorian = item['gregorian'] as Map<String, dynamic>?;
      if (hijri == null || gregorian == null) {
        continue;
      }

      final monthPayload = hijri['month'] as Map<String, dynamic>?;
      if (monthPayload == null) {
        continue;
      }

      reference ??= HijriMonthReference(
        year: int.tryParse(hijri['year']?.toString() ?? '') ?? hijriYear,
        month: monthPayload['number'] as int? ?? hijriMonth,
        monthNameArabic: monthPayload['ar'] as String? ?? '',
        monthNameEnglish: monthPayload['en'] as String? ?? '',
      );

      final gregorianDate =
          _toIsoDateKey(gregorian['date'] as String? ?? '01-01-1970');
      final weekday = DateTime.parse(gregorianDate).weekday;
      monthDays.add(
        HijriCalendarDayData(
          dayOfMonth: int.tryParse(hijri['day']?.toString() ?? '') ?? 1,
          weekday: weekday,
          gregorianDate: gregorianDate,
        ),
      );
    }

    return HijriCalendarMonthData(
      reference: reference ??
          HijriMonthReference(
            year: hijriYear,
            month: hijriMonth,
            monthNameArabic: '',
            monthNameEnglish: '',
          ),
      days: monthDays,
    );
  }

  @override
  Future<QiblaDirectionData> fetchQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/qibla/$latitude/$longitude'),
    );

    if (response.statusCode != 200) {
      throw MorePrayerRemoteException(
        'Unexpected status code: ${response.statusCode}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const MorePrayerRemoteException('Invalid response payload.');
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw const MorePrayerRemoteException('Missing qibla payload.');
    }

    final direction = (data['direction'] as num?)?.toDouble();
    if (direction == null) {
      throw const MorePrayerRemoteException('Missing qibla direction.');
    }

    return QiblaDirectionData(
      bearingDegrees: direction,
      distanceMeters: QiblaCompassPolicies.distanceToKaabaMeters(
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  PrayerTimeEntry _mapPrayer(
    Map<String, dynamic> timings,
    PrayerType type,
    String key,
  ) {
    final rawValue = timings[key] as String? ?? '00:00';
    final normalized = rawValue.split(' ').first.trim();
    final parts = normalized.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return PrayerTimeEntry(
      type: type,
      label: key,
      timeOfDay: TimeOfDay(hour: hour, minute: minute),
    );
  }

  PrayerTimesDay _mapPrayerTimesDay(
    Map<String, dynamic> data, {
    required DateTime fallbackDate,
  }) {
    final timings = data['timings'] as Map<String, dynamic>?;
    final datePayload = data['date'] as Map<String, dynamic>?;
    final hijri = datePayload?['hijri'] as Map<String, dynamic>?;
    final gregorian = datePayload?['gregorian'] as Map<String, dynamic>?;
    if (timings == null || datePayload == null || hijri == null) {
      throw const MorePrayerRemoteException('Missing timings metadata.');
    }

    final monthPayload = hijri['month'] as Map<String, dynamic>?;
    final hijriDay = hijri['day']?.toString() ?? '1';
    final hijriYear =
        int.tryParse(hijri['year']?.toString() ?? '') ?? fallbackDate.year;
    if (monthPayload == null) {
      throw const MorePrayerRemoteException('Missing Hijri month payload.');
    }

    final reference = HijriMonthReference(
      year: hijriYear,
      month: monthPayload['number'] as int? ?? 1,
      monthNameArabic: monthPayload['ar'] as String? ?? '',
      monthNameEnglish: monthPayload['en'] as String? ?? '',
    );

    final gregorianDate = _parseGregorianDate(
      gregorian?['date'] as String?,
      fallbackDate: fallbackDate,
    );

    return PrayerTimesDay(
      gregorianDate: gregorianDate,
      hijriDay: int.tryParse(hijriDay) ?? 1,
      hijriYear: hijriYear,
      hijriMonthReference: reference,
      prayers: [
        _mapPrayer(timings, PrayerType.fajr, 'Fajr'),
        _mapPrayer(timings, PrayerType.dhuhr, 'Dhuhr'),
        _mapPrayer(timings, PrayerType.asr, 'Asr'),
        _mapPrayer(timings, PrayerType.maghrib, 'Maghrib'),
        _mapPrayer(timings, PrayerType.isha, 'Isha'),
      ],
    );
  }

  String _toIsoDateKey(String ddMmYyyy) {
    final parts = ddMmYyyy.split('-');
    if (parts.length != 3) {
      throw MorePrayerRemoteException('Invalid date key: $ddMmYyyy');
    }
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  DateTime _parseGregorianDate(
    String? rawDate, {
    required DateTime fallbackDate,
  }) {
    if (rawDate == null || rawDate.isEmpty) {
      return DateTime(fallbackDate.year, fallbackDate.month, fallbackDate.day);
    }

    try {
      final isoKey = _toIsoDateKey(rawDate);
      return DateTime.parse(isoKey);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MorePrayerRemoteDataSource._parseGregorianDate',
        error,
        stackTrace,
      );
      return DateTime(fallbackDate.year, fallbackDate.month, fallbackDate.day);
    }
  }
}
