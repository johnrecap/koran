import 'dart:convert';

import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizHistoryRepository {
  QuizHistoryRepository({
    Future<SharedPreferences> Function()? prefsLoader,
    this.maxEntries = 50,
  }) : _prefsLoader = prefsLoader ?? (() => UserPreferences.prefs);

  final Future<SharedPreferences> Function() _prefsLoader;
  final int maxEntries;

  Future<List<QuizHistoryEntry>> getHistory(QuizType type) async {
    final prefs = await _prefsLoader();
    final raw = prefs.getString(_storageKey(type));
    if (raw == null || raw.isEmpty) {
      return const <QuizHistoryEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <QuizHistoryEntry>[];
      }

      final entries = decoded
          .whereType<Map>()
          .map(
            (item) => QuizHistoryEntry.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);

      return _sortEntries(entries);
    } catch (error, stackTrace) {
      AppLogger.error(
        'QuizHistoryRepository.getHistory',
        error,
        stackTrace,
      );
      return const <QuizHistoryEntry>[];
    }
  }

  Future<void> addEntry(QuizHistoryEntry entry) async {
    final entries = await getHistory(entry.quizType);
    final nextEntries = <QuizHistoryEntry>[...entries, entry];
    final sortedEntries = _sortEntries(nextEntries);
    final prunedEntries = sortedEntries.length <= maxEntries
        ? sortedEntries
        : sortedEntries.take(maxEntries).toList(growable: false);

    await _saveHistory(entry.quizType, prunedEntries);
  }

  Future<void> clearHistory(QuizType type) async {
    final prefs = await _prefsLoader();
    await prefs.remove(_storageKey(type));
  }

  Future<void> _saveHistory(
    QuizType type,
    List<QuizHistoryEntry> entries,
  ) async {
    final prefs = await _prefsLoader();
    if (entries.isEmpty) {
      await prefs.remove(_storageKey(type));
      return;
    }

    await prefs.setString(
      _storageKey(type),
      jsonEncode(entries.map((entry) => entry.toMap()).toList(growable: false)),
    );
  }

  List<QuizHistoryEntry> _sortEntries(List<QuizHistoryEntry> entries) {
    final sorted = List<QuizHistoryEntry>.from(entries);
    sorted.sort((left, right) => right.completedAt.compareTo(left.completedAt));
    return sorted;
  }

  String _storageKey(QuizType type) => 'quiz_history_${type.name}';
}
