import 'hijri_calendar_month.dart';
import 'prayer_day_tracking.dart';
import 'prayer_time_models.dart';

abstract final class PrayerTimesPolicies {
  static List<PrayerTimeSlotView> resolveTodayTimesPanel({
    required List<PrayerTimeEntry> prayers,
    required DateTime now,
    required PrayerDayTracking tracking,
  }) {
    final currentIndex = prayers.indexWhere(
      (prayer) => !prayer.resolveDateTime(now).isBefore(now),
    );

    return List<PrayerTimeSlotView>.generate(prayers.length, (index) {
      final prayer = prayers[index];
      final status = switch (currentIndex) {
        -1 => PrayerTimeSlotStatus.past,
        _ when index < currentIndex => PrayerTimeSlotStatus.past,
        _ when index == currentIndex => PrayerTimeSlotStatus.current,
        _ => PrayerTimeSlotStatus.upcoming,
      };

      return PrayerTimeSlotView(
        entry: prayer,
        status: status,
        isTracked: tracking.isCompleted(prayer.type),
        timeOfDay: prayer.timeOfDay,
      );
    }, growable: false);
  }

  static DailyAdherenceSummary buildDailyAdherence({
    required PrayerDayTracking tracking,
    int totalPrayers = 5,
    int streakDays = 0,
  }) {
    return DailyAdherenceSummary(
      completed: tracking.completedPrayers.length,
      total: totalPrayers,
      streakDays: streakDays,
    );
  }

  static int computeConsecutiveCompleteDays({
    required Map<String, PrayerDayTracking> trackings,
    required DateTime today,
  }) {
    var streak = 0;
    var cursor = DateTime(today.year, today.month, today.day - 1);

    while (true) {
      final tracking = trackings[dateKey(cursor)];
      if (tracking == null || !tracking.isComplete) {
        return streak;
      }
      streak += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
  }

  static List<WeeklyDaySnapshot> buildWeeklyStrip({
    required DateTime today,
    required Map<String, PrayerDayTracking> weekTrackings,
  }) {
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final startOfWeek = normalizedToday.subtract(
      Duration(days: (normalizedToday.weekday + 1) % 7),
    );

    return List<WeeklyDaySnapshot>.generate(7, (index) {
      final date = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      );
      final tracking = weekTrackings[dateKey(date)] ??
          PrayerDayTracking(
            dateKey: dateKey(date),
            completedPrayers: const <PrayerType>{},
          );

      return WeeklyDaySnapshot(
        dateKey: tracking.dateKey,
        date: date,
        completedCount: tracking.completedPrayers.length,
        totalPrayers: PrayerType.values.length,
        isToday: date == normalizedToday,
      );
    }, growable: false);
  }

  static PrayerOccurrence nextPrayer({
    required List<PrayerTimeEntry> prayers,
    required DateTime date,
    required DateTime now,
    PrayerTimesDay? nextDay,
  }) {
    for (final prayer in prayers) {
      final prayerDateTime = prayer.resolveDateTime(date);
      if (!prayerDateTime.isBefore(now)) {
        return PrayerOccurrence(
          type: prayer.type,
          label: prayer.label,
          dateTime: prayerDateTime,
        );
      }
    }

    if (nextDay != null && nextDay.prayers.isNotEmpty) {
      final firstPrayer = nextDay.prayers.first;
      return PrayerOccurrence(
        type: firstPrayer.type,
        label: firstPrayer.label,
        dateTime: firstPrayer.resolveDateTime(nextDay.gregorianDate),
      );
    }

    final firstPrayer = prayers.first;
    final nextDate = DateTime(date.year, date.month, date.day + 1);
    return PrayerOccurrence(
      type: firstPrayer.type,
      label: firstPrayer.label,
      dateTime: firstPrayer.resolveDateTime(nextDate),
    );
  }

  static String formatCountdown(Duration duration) {
    final safeDuration = duration.isNegative ? Duration.zero : duration;
    final hours = safeDuration.inHours.toString().padLeft(2, '0');
    final minutes = (safeDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (safeDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime parseDateKey(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid date key: $value');
    }

    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static PrayerCalendarDayVisualState resolveDayVisualState({
    required DateTime dayDate,
    required DateTime today,
    required PrayerDayTracking tracking,
  }) {
    final normalizedDay = DateTime(dayDate.year, dayDate.month, dayDate.day);
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (normalizedDay == normalizedToday) {
      return PrayerCalendarDayVisualState.today;
    }

    if (tracking.isComplete) {
      return PrayerCalendarDayVisualState.completed;
    }

    if (normalizedDay.isBefore(normalizedToday)) {
      return PrayerCalendarDayVisualState.pastIncomplete;
    }

    return PrayerCalendarDayVisualState.normal;
  }

  static HijriCalendarMonthView buildMonthView({
    required HijriCalendarMonthData month,
    required DateTime today,
    required Map<String, PrayerDayTracking> trackings,
  }) {
    final days = month.days.map((day) {
      final tracking = trackings[day.gregorianDate] ??
          PrayerDayTracking(
            dateKey: day.gregorianDate,
            completedPrayers: const <PrayerType>{},
          );
      return HijriCalendarDayView(
        data: day,
        tracking: tracking,
        visualState: resolveDayVisualState(
          dayDate: parseDateKey(day.gregorianDate),
          today: today,
          tracking: tracking,
        ),
      );
    }).toList(growable: false);

    return HijriCalendarMonthView(
      reference: month.reference,
      days: days,
    );
  }

  static HomePrayerSnapshot buildHomeSnapshot({
    required PrayerLocationSnapshot location,
    required PrayerTimesDay day,
    required DateTime now,
    required String languageCode,
    PrayerTimesDay? nextDay,
    bool isUsingCachedData = false,
    DateTime? cachedFetchedAt,
  }) {
    final occurrence = nextPrayer(
      prayers: day.prayers,
      date: day.gregorianDate,
      now: now,
      nextDay: nextDay,
    );

    return HomePrayerSnapshot(
      locationLabel: location.label,
      gregorianDate: day.gregorianDate,
      hijriDay: day.hijriDay,
      hijriYear: day.hijriYear,
      weekdayLabel: localizedWeekdayLabel(
        date: day.gregorianDate,
        languageCode: languageCode,
      ),
      hijriLabel: localizedHijriLabel(
        dayOfMonth: day.hijriDay,
        year: day.hijriYear,
        reference: day.hijriMonthReference,
        languageCode: languageCode,
      ),
      nextPrayer: occurrence.type,
      nextPrayerTime: occurrence.dateTime,
      hijriMonthReference: day.hijriMonthReference,
      isUsingCachedData: isUsingCachedData,
      cachedFetchedAt: cachedFetchedAt,
      prayers: day.prayers,
    );
  }

  static bool shouldRefreshHomeSnapshot({
    required HomePrayerSnapshot snapshot,
    required DateTime now,
  }) {
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedSnapshotDay = DateTime(
      snapshot.gregorianDate.year,
      snapshot.gregorianDate.month,
      snapshot.gregorianDate.day,
    );

    if (normalizedSnapshotDay != normalizedNow) {
      return true;
    }

    return !snapshot.nextPrayerTime.isAfter(now);
  }

  static String localizedWeekdayLabel({
    required DateTime date,
    required String languageCode,
  }) {
    final weekday = date.weekday;
    if (languageCode == 'ar') {
      return switch (weekday) {
        DateTime.monday => 'الاثنين',
        DateTime.tuesday => 'الثلاثاء',
        DateTime.wednesday => 'الأربعاء',
        DateTime.thursday => 'الخميس',
        DateTime.friday => 'الجمعة',
        DateTime.saturday => 'السبت',
        DateTime.sunday => 'الأحد',
        _ => '',
      };
    }

    return switch (weekday) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      _ => '',
    };
  }

  static String localizedHijriLabel({
    required int dayOfMonth,
    required int year,
    required HijriMonthReference reference,
    required String languageCode,
  }) {
    final monthName = languageCode == 'ar'
        ? reference.monthNameArabic
        : reference.monthNameEnglish;
    final suffix = languageCode == 'ar' ? 'هـ' : 'AH';
    return '$dayOfMonth $monthName $year $suffix';
  }
}
