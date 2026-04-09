abstract final class ReaderNightSchedulePolicy {
  static const _minutesPerDay = 24 * 60;

  static bool isValidWindow({
    required int startMinutes,
    required int endMinutes,
  }) {
    return _isValidMinuteOfDay(startMinutes) &&
        _isValidMinuteOfDay(endMinutes) &&
        startMinutes != endMinutes;
  }

  static bool isWithinWindow({
    required int startMinutes,
    required int endMinutes,
    required DateTime nowLocal,
  }) {
    if (!isValidWindow(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    )) {
      return false;
    }

    final currentMinutes = (nowLocal.hour * 60) + nowLocal.minute;
    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }

    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }

  static bool _isValidMinuteOfDay(int minutes) {
    return minutes >= 0 && minutes < _minutesPerDay;
  }
}
