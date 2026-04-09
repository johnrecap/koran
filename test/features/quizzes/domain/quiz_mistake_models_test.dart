import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_mistake_models.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

void main() {
  group('QuizMistakeEntry', () {
    test('recordCorrect increments the correct streak', () {
      final entry = _seedEntry();

      entry.recordCorrect();

      expect(entry.correctStreak, 1);
    });

    test('recordIncorrect resets the correct streak to zero', () {
      final entry = _seedEntry(correctStreak: 1);

      entry.recordIncorrect();

      expect(entry.correctStreak, 0);
    });

    test('isGraduated becomes true when correct streak reaches two', () {
      final entry = _seedEntry(correctStreak: 1);

      entry.recordCorrect();

      expect(entry.isGraduated, isTrue);
    });

    test('round-trips through map serialization', () {
      final entry = _seedEntry(correctStreak: 1);

      final decoded = QuizMistakeEntry.fromMap(entry.toMap());

      expect(decoded.questionKey, 'vc:2:255');
      expect(decoded.quizType, QuizType.verseCompletion);
      expect(decoded.questionMetadata, {'surahNumber': 2, 'ayahNumber': 255});
      expect(decoded.correctStreak, 1);
      expect(decoded.lastAttemptedAt, DateTime(2026, 4, 6, 10));
    });
  });
}

QuizMistakeEntry _seedEntry({
  int correctStreak = 0,
}) {
  return QuizMistakeEntry(
    questionKey: 'vc:2:255',
    quizType: QuizType.verseCompletion,
    questionMetadata: <String, dynamic>{
      'surahNumber': 2,
      'ayahNumber': 255,
    },
    correctStreak: correctStreak,
    lastAttemptedAt: DateTime(2026, 4, 6, 10),
  );
}
