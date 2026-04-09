abstract final class NotificationScheduleWindowPolicy {
  static const Duration minimumLeadTime = Duration(minutes: 1);
  static const Duration rollingScheduleWindow = Duration(days: 2);

  static DateTime clampIntoSafeFuture({
    required DateTime candidate,
    required DateTime now,
    Duration minimumLead = minimumLeadTime,
  }) {
    final earliestAllowed = now.add(minimumLead);
    if (candidate.isBefore(earliestAllowed)) {
      return earliestAllowed;
    }
    return candidate;
  }

  static bool isWithinRollingWindow({
    required DateTime scheduledAt,
    required DateTime now,
    Duration window = rollingScheduleWindow,
  }) {
    return !scheduledAt.isAfter(now.add(window));
  }
}
