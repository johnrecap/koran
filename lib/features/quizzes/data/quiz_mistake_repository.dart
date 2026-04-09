import 'dart:convert';

import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_mistake_models.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizMistakeRepository {
  QuizMistakeRepository({
    Future<SharedPreferences> Function()? prefsLoader,
  }) : _prefsLoader = prefsLoader ?? (() => UserPreferences.prefs);

  final Future<SharedPreferences> Function() _prefsLoader;

  Future<List<QuizMistakeEntry>> getMistakes(QuizType type) async {
    final prefs = await _prefsLoader();
    final raw = prefs.getString(_storageKey(type));
    if (raw == null || raw.isEmpty) {
      return const <QuizMistakeEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <QuizMistakeEntry>[];
      }

      final entries = decoded
          .whereType<Map>()
          .map(
            (item) => QuizMistakeEntry.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);

      return _sortEntries(entries);
    } catch (error, stackTrace) {
      AppLogger.error(
        'QuizMistakeRepository.getMistakes',
        error,
        stackTrace,
      );
      return const <QuizMistakeEntry>[];
    }
  }

  Future<void> saveMistakes(
    QuizType type,
    List<QuizMistakeEntry> entries,
  ) async {
    final prefs = await _prefsLoader();
    if (entries.isEmpty) {
      await prefs.remove(_storageKey(type));
      return;
    }

    await prefs.setString(
      _storageKey(type),
      jsonEncode(
        _sortEntries(entries)
            .map((entry) => entry.toMap())
            .toList(growable: false),
      ),
    );
  }

  Future<void> addMistake(QuizMistakeEntry entry) async {
    final entries = await getMistakes(entry.quizType);
    final nextEntries = <QuizMistakeEntry>[
      for (final current in entries)
        if (current.questionKey != entry.questionKey) current,
      entry,
    ];

    await saveMistakes(entry.quizType, nextEntries);
  }

  Future<void> updateMistake(QuizMistakeEntry entry) async {
    final entries = await getMistakes(entry.quizType);
    final nextEntries = <QuizMistakeEntry>[
      for (final current in entries)
        if (current.questionKey != entry.questionKey) current,
      if (!entry.isGraduated) entry,
    ];

    await saveMistakes(entry.quizType, nextEntries);
  }

  Future<void> removeMistake(String questionKey) async {
    for (final type in QuizType.values) {
      final entries = await getMistakes(type);
      final nextEntries = entries
          .where((entry) => entry.questionKey != questionKey)
          .toList(growable: false);

      if (nextEntries.length != entries.length) {
        await saveMistakes(type, nextEntries);
      }
    }
  }

  Future<int> getMistakeCount(QuizType type) async {
    final entries = await getMistakes(type);
    return entries.length;
  }

  List<QuizMistakeEntry> _sortEntries(List<QuizMistakeEntry> entries) {
    final sorted = List<QuizMistakeEntry>.from(entries);
    sorted.sort(
      (left, right) => right.lastAttemptedAt.compareTo(left.lastAttemptedAt),
    );
    return sorted;
  }

  String _storageKey(QuizType type) => 'quiz_mistakes_${type.name}';
}
