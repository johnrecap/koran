import 'package:flutter/material.dart';

import 'hijri_calendar_month.dart';

enum PrayerType {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

enum PrayerReminderOffset {
  atAdhan(Duration.zero),
  fiveMinBefore(Duration(minutes: 5)),
  tenMinBefore(Duration(minutes: 10)),
  fifteenMinBefore(Duration(minutes: 15)),
  thirtyMinBefore(Duration(minutes: 30));

  const PrayerReminderOffset(this.leadTime);

  final Duration leadTime;

  static PrayerReminderOffset fromName(String? name) {
    return PrayerReminderOffset.values.firstWhere(
      (value) => value.name == name,
      orElse: () => PrayerReminderOffset.fifteenMinBefore,
    );
  }
}

enum PrayerTimeSlotStatus {
  past,
  current,
  upcoming,
}

class PrayerTimeSlotView {
  const PrayerTimeSlotView({
    required this.entry,
    required this.status,
    required this.isTracked,
    required this.timeOfDay,
  });

  final PrayerTimeEntry entry;
  final PrayerTimeSlotStatus status;
  final bool isTracked;
  final TimeOfDay timeOfDay;
}

class DailyAdherenceSummary {
  const DailyAdherenceSummary({
    required this.completed,
    required this.total,
    required this.streakDays,
  });

  final int completed;
  final int total;
  final int streakDays;
}

class WeeklyDaySnapshot {
  const WeeklyDaySnapshot({
    required this.dateKey,
    required this.date,
    required this.completedCount,
    required this.totalPrayers,
    required this.isToday,
  });

  final String dateKey;
  final DateTime date;
  final int completedCount;
  final int totalPrayers;
  final bool isToday;
}

enum PrayerFeatureError {
  permissionDenied,
  permissionDeniedForever,
  locationServicesDisabled,
  locationUnavailable,
  remoteFetchFailed,
}

class PrayerFeatureException implements Exception {
  const PrayerFeatureException(this.error, [this.message]);

  final PrayerFeatureError error;
  final String? message;

  @override
  String toString() => 'PrayerFeatureException($error, $message)';
}

class PrayerLocationSnapshot {
  const PrayerLocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'label': label,
      };

  factory PrayerLocationSnapshot.fromMap(Map<String, dynamic> map) {
    return PrayerLocationSnapshot(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      label: map['label'] as String? ?? '',
    );
  }
}

class PrayerCoordinates {
  const PrayerCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  String get fallbackLabel =>
      '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
}

class PrayerTimeEntry {
  const PrayerTimeEntry({
    required this.type,
    required this.label,
    required this.timeOfDay,
  });

  final PrayerType type;
  final String label;
  final TimeOfDay timeOfDay;

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'label': label,
        'hour': timeOfDay.hour,
        'minute': timeOfDay.minute,
      };

  factory PrayerTimeEntry.fromMap(Map<String, dynamic> map) {
    return PrayerTimeEntry(
      type: PrayerType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => PrayerType.fajr,
      ),
      label: map['label'] as String? ?? '',
      timeOfDay: TimeOfDay(
        hour: map['hour'] as int? ?? 0,
        minute: map['minute'] as int? ?? 0,
      ),
    );
  }

  DateTime resolveDateTime(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}

class PrayerOccurrence {
  const PrayerOccurrence({
    required this.type,
    required this.label,
    required this.dateTime,
  });

  final PrayerType type;
  final String label;
  final DateTime dateTime;
}

class PrayerTimesDay {
  const PrayerTimesDay({
    required this.gregorianDate,
    required this.hijriDay,
    required this.hijriYear,
    required this.hijriMonthReference,
    required this.prayers,
  });

  final DateTime gregorianDate;
  final int hijriDay;
  final int hijriYear;
  final HijriMonthReference hijriMonthReference;
  final List<PrayerTimeEntry> prayers;

  Map<String, dynamic> toMap() => {
        'gregorianDate': gregorianDate.toIso8601String(),
        'hijriDay': hijriDay,
        'hijriYear': hijriYear,
        'hijriMonthReference': hijriMonthReference.toMap(),
        'prayers': prayers.map((entry) => entry.toMap()).toList(),
      };

  factory PrayerTimesDay.fromMap(Map<String, dynamic> map) {
    return PrayerTimesDay(
      gregorianDate: DateTime.parse(
        map['gregorianDate'] as String? ?? DateTime(1970).toIso8601String(),
      ),
      hijriDay: map['hijriDay'] as int? ?? 1,
      hijriYear: map['hijriYear'] as int? ?? 0,
      hijriMonthReference: HijriMonthReference.fromMap(
        map['hijriMonthReference'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      prayers: ((map['prayers'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>())
          .map(PrayerTimeEntry.fromMap)
          .toList(growable: false),
    );
  }
}

class PrayerTimesMonthData {
  const PrayerTimesMonthData({
    required this.gregorianYear,
    required this.gregorianMonth,
    required this.days,
  });

  final int gregorianYear;
  final int gregorianMonth;
  final List<PrayerTimesDay> days;

  PrayerTimesDay? dayFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    for (final day in days) {
      final candidate = DateTime(
        day.gregorianDate.year,
        day.gregorianDate.month,
        day.gregorianDate.day,
      );
      if (candidate == normalized) {
        return day;
      }
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        'gregorianYear': gregorianYear,
        'gregorianMonth': gregorianMonth,
        'days': days.map((day) => day.toMap()).toList(),
      };

  factory PrayerTimesMonthData.fromMap(Map<String, dynamic> map) {
    return PrayerTimesMonthData(
      gregorianYear: map['gregorianYear'] as int? ?? 0,
      gregorianMonth: map['gregorianMonth'] as int? ?? 1,
      days: ((map['days'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>())
          .map(PrayerTimesDay.fromMap)
          .toList(growable: false),
    );
  }
}

class HomePrayerSnapshot {
  const HomePrayerSnapshot({
    required this.locationLabel,
    required this.gregorianDate,
    required this.hijriDay,
    required this.hijriYear,
    required this.weekdayLabel,
    required this.hijriLabel,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.hijriMonthReference,
    required this.isUsingCachedData,
    required this.cachedFetchedAt,
    required this.prayers,
  });

  final String locationLabel;
  final DateTime gregorianDate;
  final int hijriDay;
  final int hijriYear;
  final String weekdayLabel;
  final String hijriLabel;
  final PrayerType nextPrayer;
  final DateTime nextPrayerTime;
  final HijriMonthReference hijriMonthReference;
  final bool isUsingCachedData;
  final DateTime? cachedFetchedAt;
  final List<PrayerTimeEntry> prayers;
}

class CachedHomePrayerSnapshotData {
  const CachedHomePrayerSnapshotData({
    required this.location,
    required this.day,
    required this.fetchedAt,
  });

  final PrayerLocationSnapshot location;
  final PrayerTimesDay day;
  final DateTime fetchedAt;

  Map<String, dynamic> toMap() => {
        'location': location.toMap(),
        'day': day.toMap(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory CachedHomePrayerSnapshotData.fromMap(Map<String, dynamic> map) {
    return CachedHomePrayerSnapshotData(
      location: PrayerLocationSnapshot.fromMap(
        map['location'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      day: PrayerTimesDay.fromMap(
        map['day'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      fetchedAt: DateTime.parse(
        map['fetchedAt'] as String? ?? DateTime(1970).toIso8601String(),
      ),
    );
  }
}

class CachedPrayerTimesMonthData {
  const CachedPrayerTimesMonthData({
    required this.location,
    required this.month,
    required this.fetchedAt,
  });

  final PrayerLocationSnapshot location;
  final PrayerTimesMonthData month;
  final DateTime fetchedAt;

  Map<String, dynamic> toMap() => {
        'location': location.toMap(),
        'month': month.toMap(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory CachedPrayerTimesMonthData.fromMap(Map<String, dynamic> map) {
    return CachedPrayerTimesMonthData(
      location: PrayerLocationSnapshot.fromMap(
        map['location'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      month: PrayerTimesMonthData.fromMap(
        map['month'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      fetchedAt: DateTime.parse(
        map['fetchedAt'] as String? ?? DateTime(1970).toIso8601String(),
      ),
    );
  }
}
