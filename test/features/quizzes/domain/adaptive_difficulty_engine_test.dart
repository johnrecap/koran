import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/quizzes/domain/adaptive_difficulty_engine.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';

void main() {
  group('AdaptiveDifficultyEngine', () {
    test('starts at the provided base difficulty', () {
      final engine = AdaptiveDifficultyEngine(QuizDifficulty.medium);

      expect(engine.currentDifficulty, QuizDifficulty.medium);
    });

    test('bumps up one level after three consecutive correct answers', () {
      final engine = AdaptiveDifficultyEngine(QuizDifficulty.medium);

      engine.recordAnswer(true);
      engine.recordAnswer(true);
      engine.recordAnswer(true);

      expect(engine.currentDifficulty, QuizDifficulty.hard);
    });

    test('drops one level after two consecutive wrong answers', () {
      final engine = AdaptiveDifficultyEngine(QuizDifficulty.hard);

      engine.recordAnswer(false);
      engine.recordAnswer(false);

      expect(engine.currentDifficulty, QuizDifficulty.medium);
    });

    test('caps at hard and floors at easy', () {
      final hardEngine = AdaptiveDifficultyEngine(QuizDifficulty.hard);

      hardEngine.recordAnswer(true);
      hardEngine.recordAnswer(true);
      hardEngine.recordAnswer(true);

      expect(hardEngine.currentDifficulty, QuizDifficulty.hard);

      final easyEngine = AdaptiveDifficultyEngine(QuizDifficulty.easy);

      easyEngine.recordAnswer(false);
      easyEngine.recordAnswer(false);

      expect(easyEngine.currentDifficulty, QuizDifficulty.easy);
    });

    test('mixed answers reset the opposite streak', () {
      final engine = AdaptiveDifficultyEngine(QuizDifficulty.medium);

      engine.recordAnswer(true);
      engine.recordAnswer(true);
      engine.recordAnswer(false);
      engine.recordAnswer(true);
      engine.recordAnswer(true);

      expect(
        engine.currentDifficulty,
        QuizDifficulty.medium,
      );

      engine.recordAnswer(true);

      expect(engine.currentDifficulty, QuizDifficulty.hard);
    });
  });
}
