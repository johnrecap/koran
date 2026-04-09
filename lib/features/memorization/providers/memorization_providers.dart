import 'dart:convert';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/memorization/data/debounced_save_scheduler.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_planner_summary.dart';
import 'package:quran_kareem/features/memorization/domain/memorization_hub_summary.dart';
import 'package:quran_kareem/features/reader/providers/manual_bookmarks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Sessions Provider ───

final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, List<ReadingSession>>(
  (ref) => SessionsNotifier(),
);

class SessionsNotifier extends StateNotifier<List<ReadingSession>> {
  SessionsNotifier() : super([]) {
    _ready = _load();
  }

  late final Future<void> _ready;
  final DebouncedSaveScheduler _saveScheduler = DebouncedSaveScheduler();

  Future<void> get ready => _ready;

  Future<void> _load() async {
    final prefs = await UserPreferences.prefs;
    final json = prefs.getString('readingSessions');
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        state = list
            .map((e) => ReadingSession.fromMap(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (e, st) {
        AppLogger.error('ReadingSessionsNotifier._load', e, st);
        state = [];
      }
    }
  }

  Future<void> _save() async {
    final prefs = await UserPreferences.prefs;
    await prefs.setString(
        'readingSessions', jsonEncode(state.map((s) => s.toMap()).toList()));
  }

  Future<void> _scheduleSave() {
    return _saveScheduler.schedule(_save);
  }

  Future<void> addSession(ReadingSession session) async {
    await upsertSession(session);
  }

  Future<void> upsertSession(ReadingSession session) async {
    await _ready;

    final nextState = [
      session,
      for (final existing in state)
        if (existing.id != session.id &&
            (session.khatmaId == null || existing.khatmaId != session.khatmaId))
          existing,
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    state = nextState;
    await _scheduleSave();
  }

  Future<void> removeSession(String id) async {
    await _ready;
    state = state.where((s) => s.id != id).toList();
    await _scheduleSave();
  }

  /// Get only regular sessions (no khatma)
  List<ReadingSession> get regularSessions =>
      state.where((s) => s.khatmaId == null).toList();

  /// Get sessions for a specific khatma
  List<ReadingSession> sessionsForKhatma(String khatmaId) =>
      state.where((s) => s.khatmaId == khatmaId).toList();

  @override
  void dispose() {
    _saveScheduler.dispose();
    super.dispose();
  }
}

typedef MemorizationAyahPageResolver = Future<int> Function(
  int surahNumber,
  int ayahNumber,
);

final memorizationAyahPageResolverProvider =
    Provider<MemorizationAyahPageResolver>((ref) {
  return QuranDatabase.getPageForAyah;
});

typedef MemorizationPageAyahResolver = Future<Ayah?> Function(int pageNumber);

final memorizationPageAyahResolverProvider =
    Provider<MemorizationPageAyahResolver>((ref) {
  return (int pageNumber) async {
    final ayahs = await QuranDatabase.getAyahsByPage(pageNumber);
    if (ayahs.isEmpty) {
      return null;
    }

    return ayahs.first;
  };
});

// ─── Khatma Provider ───

final khatmasProvider = StateNotifierProvider<KhatmasNotifier, List<Khatma>>(
  (ref) => KhatmasNotifier(),
);

class KhatmasNotifier extends StateNotifier<List<Khatma>> {
  KhatmasNotifier() : super([]) {
    _ready = _load();
  }

  late final Future<void> _ready;
  final DebouncedSaveScheduler _saveScheduler = DebouncedSaveScheduler();

  Future<void> get ready => _ready;

  Future<void> _load() async {
    final prefs = await UserPreferences.prefs;
    final json = prefs.getString('khatmas');
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        final loadedKhatmas =
            list.map((e) => Khatma.fromMap(e as Map<String, dynamic>)).toList();
        final loadedSessions =
            KhatmaSessionIntegrityPolicy.loadStoredSessions(prefs);
        final repairedKhatmas = KhatmaSessionIntegrityPolicy.sanitizeAllKhatmas(
          khatmas: loadedKhatmas,
          sessions: loadedSessions,
        );
        state = repairedKhatmas;

        if (!KhatmaSessionIntegrityPolicy.sameKhatmas(
          loadedKhatmas,
          repairedKhatmas,
        )) {
          await prefs.setString(
            'khatmas',
            jsonEncode(repairedKhatmas.map((k) => k.toMap()).toList()),
          );
        }
      } catch (e, st) {
        AppLogger.error('KhatmasNotifier._load', e, st);
        state = [];
      }
    }
  }

  Future<void> _save() async {
    final prefs = await UserPreferences.prefs;
    await prefs.setString(
        'khatmas', jsonEncode(state.map((k) => k.toMap()).toList()));
  }

  Future<void> _scheduleSave() {
    return _saveScheduler.schedule(_save);
  }

  Future<void> addKhatma(Khatma khatma) async {
    await _ready;
    state = [khatma, ...state];
    await _scheduleSave();
  }

  Future<void> updateKhatma(Khatma updated) async {
    await _ready;
    state = state.map((k) => k.id == updated.id ? updated : k).toList();
    await _scheduleSave();
  }

  Future<void> recordPlannerProgress({
    required String khatmaId,
    required int pageNumber,
    required DateTime timestamp,
    required int completedSurahs,
  }) async {
    await _ready;
    final normalizedPage = pageNumber.clamp(1, Khatma.mushafPageCount);
    final dayKey = KhatmaPlannerSummaryPolicy.dayKey(timestamp);

    state = state.map((khatma) {
      if (khatma.id != khatmaId) {
        return khatma;
      }

      final nextFurthestPage = normalizedPage > khatma.furthestPageRead
          ? normalizedPage
          : khatma.furthestPageRead;
      final nextCompletedSurahs = completedSurahs > khatma.completedSurahs
          ? completedSurahs
          : khatma.completedSurahs;
      final nextReadingDayKeys = khatma.readingDayKeys.contains(dayKey)
          ? khatma.readingDayKeys
          : [...khatma.readingDayKeys, dayKey]
        ..sort();

      return khatma.copyWith(
        furthestPageRead: nextFurthestPage,
        completedSurahs: nextCompletedSurahs,
        readingDayKeys: nextReadingDayKeys,
        completedDate: nextFurthestPage >= Khatma.mushafPageCount
            ? (khatma.completedDate ?? timestamp)
            : khatma.completedDate,
      );
    }).toList();

    await _scheduleSave();
  }

  Future<void> addTrackedMinutes({
    required String khatmaId,
    required int minutes,
  }) async {
    await _ready;
    if (minutes <= 0) {
      return;
    }

    state = state.map((khatma) {
      if (khatma.id != khatmaId) {
        return khatma;
      }

      return khatma.copyWith(
        totalReadMinutes: khatma.totalReadMinutes + minutes,
      );
    }).toList();

    await _scheduleSave();
  }

  /// Get active (non-completed) khatmas
  List<Khatma> get activeKhatmas => state.where((k) => !k.isCompleted).toList();

  /// Get completed khatmas
  List<Khatma> get completedKhatmas =>
      state.where((k) => k.isCompleted).toList();

  @override
  void dispose() {
    _saveScheduler.dispose();
    super.dispose();
  }
}

final effectiveKhatmasProvider = Provider<List<Khatma>>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final khatmas = ref.watch(khatmasProvider);

  return [
    for (final khatma in khatmas)
      KhatmaSessionIntegrityPolicy.sanitizeKhatma(
        khatma: khatma,
        sessions: sessions,
      ),
  ];
});

final activeKhatmaProvider = Provider<Khatma?>((ref) {
  final khatmas = ref.watch(effectiveKhatmasProvider);
  for (final khatma in khatmas) {
    if (!khatma.isCompleted) {
      return khatma;
    }
  }
  return null;
});

final khatmaByIdProvider = Provider.family<Khatma?, String>((ref, khatmaId) {
  final khatmas = ref.watch(effectiveKhatmasProvider);
  for (final khatma in khatmas) {
    if (khatma.id == khatmaId) {
      return khatma;
    }
  }
  return null;
});

final khatmaPlannerSummaryProvider =
    Provider.family<KhatmaPlannerSummary?, String>((ref, khatmaId) {
  final khatma = ref.watch(khatmaByIdProvider(khatmaId));
  if (khatma == null) {
    return null;
  }

  final latestSession = KhatmaSessionIntegrityPolicy.latestTrustedSession(
    ref.watch(sessionsProvider),
    khatmaId,
  );

  return KhatmaPlannerSummaryPolicy.build(
    khatma: khatma,
    latestSession: latestSession,
    now: ref.watch(khatmaPlannerNowProvider),
  );
});

final khatmaPlannerNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final memorizationHubSummaryProvider = Provider<MemorizationHubSummary>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final khatmas = ref.watch(effectiveKhatmasProvider);
  final manualBookmarkCount = ref.watch(manualBookmarksProvider).length;

  return MemorizationHubSummaryPolicy.build(
    sessions: sessions,
    khatmas: khatmas,
    manualBookmarkCount: manualBookmarkCount,
  );
});

abstract final class KhatmaSessionIntegrityPolicy {
  static List<ReadingSession> loadStoredSessions(SharedPreferences prefs) {
    final json = prefs.getString('readingSessions');
    if (json == null) {
      return const <ReadingSession>[];
    }

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((item) => ReadingSession.fromMap(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e, st) {
      AppLogger.error('MemorizationData.loadSessions', e, st);
      return const <ReadingSession>[];
    }
  }

  static List<Khatma> sanitizeAllKhatmas({
    required List<Khatma> khatmas,
    required List<ReadingSession> sessions,
  }) {
    return [
      for (final khatma in khatmas)
        sanitizeKhatma(
          khatma: khatma,
          sessions: sessions,
        ),
    ];
  }

  static bool sameKhatmas(List<Khatma> first, List<Khatma> second) {
    if (first.length != second.length) {
      return false;
    }

    final firstJson = jsonEncode(first.map((item) => item.toMap()).toList());
    final secondJson = jsonEncode(second.map((item) => item.toMap()).toList());
    return firstJson == secondJson;
  }

  static ReadingSession? latestTrustedSession(
    List<ReadingSession> sessions,
    String khatmaId,
  ) {
    for (final session in sessions) {
      if (session.khatmaId == khatmaId && session.isTrustedKhatmaAnchor) {
        return session;
      }
    }

    return null;
  }

  static Khatma sanitizeKhatma({
    required Khatma khatma,
    required List<ReadingSession> sessions,
  }) {
    final trustedSession = latestTrustedSession(sessions, khatma.id);
    final hasTrustedReadingEvidence =
        trustedSession != null || khatma.totalReadMinutes > 0;
    final hasPhantomPlannerProgress =
        khatma.furthestPageRead > 0 && !hasTrustedReadingEvidence;

    if (!hasPhantomPlannerProgress) {
      return khatma;
    }

    return khatma.copyWith(
      completedSurahs: 0,
      clearCompletedDate: true,
      furthestPageRead: 0,
      readingDayKeys: const <String>[],
    );
  }
}
