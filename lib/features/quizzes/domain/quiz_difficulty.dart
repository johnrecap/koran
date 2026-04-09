enum QuizDifficulty { easy, medium, hard }

extension QuizDifficultyX on QuizDifficulty {
  QuizDifficulty harder() {
    return switch (this) {
      QuizDifficulty.easy => QuizDifficulty.medium,
      QuizDifficulty.medium => QuizDifficulty.hard,
      QuizDifficulty.hard => QuizDifficulty.hard,
    };
  }

  QuizDifficulty easier() {
    return switch (this) {
      QuizDifficulty.easy => QuizDifficulty.easy,
      QuizDifficulty.medium => QuizDifficulty.easy,
      QuizDifficulty.hard => QuizDifficulty.medium,
    };
  }
}

abstract final class VerseDifficultyRules {
  static int maxWordCount(QuizDifficulty difficulty) {
    return switch (difficulty) {
      QuizDifficulty.easy => 5,
      QuizDifficulty.medium => 12,
      QuizDifficulty.hard => 999,
    };
  }

  static bool requiresSameSurahDistractors(QuizDifficulty difficulty) {
    return switch (difficulty) {
      QuizDifficulty.easy => false,
      QuizDifficulty.medium || QuizDifficulty.hard => true,
    };
  }
}
