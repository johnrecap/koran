import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_history_repository.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  tearDown(() {
    UserPreferences.resetCache();
  });

  group('QuizHistoryRepository', () {
    test('addEntry saves entries and getHistory retrieves them by quiz type', () async {
      final repository = QuizHistoryRepository();

      await repository.addEntry(
        _entry(
          quizType: QuizType.verseCompletion,
          score: 8,
          completedAt: DateTime(2026, 4, 6, 10),
        ),
      );
      await repository.addEntry(
        _entry(
          quizType: QuizType.wordMeaning,
          score: 6,
          completedAt: DateTime(2026, 4, 6, 11),
        ),
      );

      final verseHistory = await repository.getHistory(QuizType.verseCompletion);
      final wordHistory = await repository.getHistory(QuizType.wordMeaning);

      expect(verseHistory, hasLength(1));
      expect(verseHistory.single.score, 8);
      expect(verseHistory.single.quizType, QuizType.verseCompletion);

      expect(wordHistory, hasLength(1));
      expect(wordHistory.single.score, 6);
      expect(wordHistory.single.quizType, QuizType.wordMeaning);
    });

    test('prunes history to the latest 50 entries using FIFO removal', () async {
      final repository = QuizHistoryRepository();

      for (var index = 0; index < 55; index += 1) {
        await repository.addEntry(
          _entry(
            quizType: QuizType.verseCompletion,
            score: index,
            completedAt: DateTime(2026, 4, 6, 10, index),
          ),
        );
      }

      final history = await repository.getHistory(QuizType.verseCompletion);

      expect(history, hasLength(50));
      expect(history.first.score, 54);
      expect(history.last.score, 5);
    });

    test('returns empty list when the stored history payload is malformed', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'quiz_history_verseCompletion': 'not-json',
      });
      UserPreferences.resetCache();

      final repository = QuizHistoryRepository();
      final history = await repository.getHistory(QuizType.verseCompletion);

      expect(history, isEmpty);
    });

    test('clearHistory removes all entries for the requested type only', () async {
      final repository = QuizHistoryRepository();

      await repository.addEntry(
        _entry(
          quizType: QuizType.verseCompletion,
          score: 7,
          completedAt: DateTime(2026, 4, 6, 10),
        ),
      );
      await repository.addEntry(
        _entry(
          quizType: QuizType.wordMeaning,
          score: 4,
          completedAt: DateTime(2026, 4, 6, 11),
        ),
      );

      await repository.clearHistory(QuizType.verseCompletion);

      expect(await repository.getHistory(QuizType.verseCompletion), isEmpty);
      expect(await repository.getHistory(QuizType.wordMeaning), hasLength(1));
    });
  });
}

QuizHistoryEntry _entry({
  required QuizType quizType,
  required int score,
  required DateTime completedAt,
}) {
  return QuizHistoryEntry(
    quizType: quizType,
    score: score,
    totalQuestions: 10,
    difficulty: QuizDifficulty.medium,
    surahFilter: 2,
    completedAt: completedAt,
  );
}
