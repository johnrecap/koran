import 'prayer_day_tracking.dart';

enum PrayerCalendarDayVisualState {
  normal,
  today,
  pastIncomplete,
  completed,
}

class HijriMonthReference {
  const HijriMonthReference({
    required this.year,
    required this.month,
    required this.monthNameArabic,
    required this.monthNameEnglish,
  });

  final int year;
  final int month;
  final String monthNameArabic;
  final String monthNameEnglish;

  Map<String, dynamic> toMap() => {
        'year': year,
        'month': month,
        'monthNameArabic': monthNameArabic,
        'monthNameEnglish': monthNameEnglish,
      };

  factory HijriMonthReference.fromMap(Map<String, dynamic> map) {
    return HijriMonthReference(
      year: map['year'] as int? ?? 0,
      month: map['month'] as int? ?? 1,
      monthNameArabic: map['monthNameArabic'] as String? ?? '',
      monthNameEnglish: map['monthNameEnglish'] as String? ?? '',
    );
  }
}

class HijriCalendarDayData {
  const HijriCalendarDayData({
    required this.dayOfMonth,
    required this.weekday,
    required this.gregorianDate,
  });

  final int dayOfMonth;
  final int weekday;
  final String gregorianDate;

  Map<String, dynamic> toMap() => {
        'dayOfMonth': dayOfMonth,
        'weekday': weekday,
        'gregorianDate': gregorianDate,
      };

  factory HijriCalendarDayData.fromMap(Map<String, dynamic> map) {
    return HijriCalendarDayData(
      dayOfMonth: map['dayOfMonth'] as int? ?? 1,
      weekday: map['weekday'] as int? ?? 1,
      gregorianDate: map['gregorianDate'] as String? ?? '1970-01-01',
    );
  }
}

class HijriCalendarMonthData {
  const HijriCalendarMonthData({
    required this.reference,
    required this.days,
  });

  final HijriMonthReference reference;
  final List<HijriCalendarDayData> days;

  Map<String, dynamic> toMap() => {
        'reference': reference.toMap(),
        'days': days.map((day) => day.toMap()).toList(),
      };

  factory HijriCalendarMonthData.fromMap(Map<String, dynamic> map) {
    return HijriCalendarMonthData(
      reference: HijriMonthReference.fromMap(
        map['reference'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      days: ((map['days'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>())
          .map(HijriCalendarDayData.fromMap)
          .toList(growable: false),
    );
  }
}

class HijriCalendarDayView {
  const HijriCalendarDayView({
    required this.data,
    required this.tracking,
    required this.visualState,
  });

  final HijriCalendarDayData data;
  final PrayerDayTracking tracking;
  final PrayerCalendarDayVisualState visualState;

  int get dayOfMonth => data.dayOfMonth;

  String get gregorianDateKey => data.gregorianDate;
}

class HijriCalendarMonthView {
  const HijriCalendarMonthView({
    required this.reference,
    required this.days,
  });

  final HijriMonthReference reference;
  final List<HijriCalendarDayView> days;
}
