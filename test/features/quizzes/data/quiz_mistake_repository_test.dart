import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_mistake_repository.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_mistake_models.dart';
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

  group('QuizMistakeRepository', () {
    test('addMistake persists entries and getMistakes retrieves them by quiz type', () async {
      final repository = QuizMistakeRepository();

      await repository.addMistake(
        _mistakeEntry(
          quizType: QuizType.verseCompletion,
          questionKey: 'vc:2:255',
          correctStreak: 0,
        ),
      );
      await repository.addMistake(
        _mistakeEntry(
          quizType: QuizType.wordMeaning,
          questionKey: 'wm:1:1:rahma',
          correctStreak: 1,
        ),
      );

      final verseMistakes = await repository.getMistakes(
        QuizType.verseCompletion,
      );
      final wordMistakes = await repository.getMistakes(
        QuizType.wordMeaning,
      );

      expect(verseMistakes, hasLength(1));
      expect(verseMistakes.single.questionKey, 'vc:2:255');
      expect(wordMistakes, hasLength(1));
      expect(wordMistakes.single.correctStreak, 1);
    });

    test('updateMistake updates the stored correct streak', () async {
      final repository = QuizMistakeRepository();

      await repository.addMistake(
        _mistakeEntry(
          quizType: QuizType.verseCompletion,
          questionKey: 'vc:2:255',
          correctStreak: 0,
        ),
      );

      await repository.updateMistake(
        _mistakeEntry(
          quizType: QuizType.verseCompletion,
          questionKey: 'vc:2:255',
          correctStreak: 1,
        ),
      );

      final mistakes = await repository.getMistakes(QuizType.verseCompletion);

      expect(mistakes, hasLength(1));
      expect(mistakes.single.correctStreak, 1);
    });

    test('removeMistake deletes the requested question key', () async {
      final repository = QuizMistakeRepository();

      await repository.addMistake(
        _mistakeEntry(
          quizType: QuizType.verseCompletion,
          questionKey: 'vc:2:255',
          correctStreak: 0,
        ),
      );
      await repository.addMistake(
        _mistakeEntry(
          quizType: QuizType.verseCompletion,
          questionKey: 'vc:2:256',
          correctStreak: 0,
        ),
      );

      await repository.removeMistake('vc:2:255');

      final mistakes = await repository.getMistakes(QuizType.verseCompletion);

      expect(mistakes, hasLength(1));
      expect(mistakes.single.questionKey, 'vc:2:256');
    });

    test('getMistakeCount returns the current count for a quiz type', () async {
      final repository = QuizMistakeRepository();

      await repository.addMistake(
        _mistakeEntry(
          quizType: QuizType.verseCompletion,
          questionKey: 'vc:2:255',
          correctStreak: 0,
        ),
      );
      await repository.addMistake(
        _mistakeEntry(
          quizType: QuizType.verseCompletion,
          questionKey: 'vc:2:256',
          correctStreak: 0,
        ),
      );
      await repository.addMistake(
        _mistakeEntry(
          quizType: QuizType.wordMeaning,
          questionKey: 'wm:1:1:rahma',
          correctStreak: 0,
        ),
      );

      final count = await repository.getMistakeCount(QuizType.verseCompletion);

      expect(count, 2);
    });

    test('returns empty list when the stored mistake payload is malformed', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'quiz_mistakes_verseCompletion': 'not-json',
      });
      UserPreferences.resetCache();

      final repository = QuizMistakeRepository();
      final mistakes = await repository.getMistakes(QuizType.verseCompletion);

      expect(mistakes, isEmpty);
    });
  });
}

QuizMistakeEntry _mistakeEntry({
  required QuizType quizType,
  required String questionKey,
  required int correctStreak,
}) {
  return QuizMistakeEntry(
    questionKey: questionKey,
    quizType: quizType,
    questionMetadata: <String, dynamic>{
      'surahNumber': 2,
      'ayahNumber': 255,
    },
    correctStreak: correctStreak,
    lastAttemptedAt: DateTime(2026, 4, 6, 10),
  );
}
