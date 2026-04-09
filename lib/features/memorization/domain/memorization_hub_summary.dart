import 'package:quran_kareem/features/memorization/data/reading_session.dart';

class MemorizationHubSummary {
  const MemorizationHubSummary({
    required this.activeKhatma,
    required this.activeKhatmaSession,
    required this.recentRegularSessions,
    required this.activeKhatmas,
    required this.completedKhatmas,
    required this.manualBookmarkCount,
  });

  final Khatma? activeKhatma;
  final ReadingSession? activeKhatmaSession;
  final List<ReadingSession> recentRegularSessions;
  final List<Khatma> activeKhatmas;
  final List<Khatma> completedKhatmas;
  final int manualBookmarkCount;

  bool get hasActiveKhatma => activeKhatma != null;
  int get activeKhatmaCount => activeKhatmas.length;
  int get recentSessionCount => recentRegularSessions.length;
}

abstract final class MemorizationHubSummaryPolicy {
  static MemorizationHubSummary build({
    required List<ReadingSession> sessions,
    required List<Khatma> khatmas,
    required int manualBookmarkCount,
  }) {
    final sortedSessions = [...sessions]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final activeKhatmas = khatmas.where((item) => !item.isCompleted).toList();
    final completedKhatmas = khatmas.where((item) => item.isCompleted).toList();
    final activeKhatma = activeKhatmas.isEmpty ? null : activeKhatmas.first;
    final khatmaSessions = activeKhatma == null
        ? const <ReadingSession>[]
        : sortedSessions
            .where(
              (session) =>
                  session.khatmaId == activeKhatma.id &&
                  session.isTrustedKhatmaAnchor,
            )
            .toList();

    return MemorizationHubSummary(
      activeKhatma: activeKhatma,
      activeKhatmaSession:
          khatmaSessions.isEmpty ? null : khatmaSessions.first,
      recentRegularSessions:
          sortedSessions.where((session) => session.khatmaId == null).toList(),
      activeKhatmas: activeKhatmas,
      completedKhatmas: completedKhatmas,
      manualBookmarkCount: manualBookmarkCount,
    );
  }
}
