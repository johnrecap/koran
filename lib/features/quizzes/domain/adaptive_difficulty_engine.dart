import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';

class AdaptiveDifficultyEngine {
  AdaptiveDifficultyEngine(QuizDifficulty baseDifficulty)
    : _currentDifficulty = baseDifficulty;

  QuizDifficulty _currentDifficulty;
  int _consecutiveCorrect = 0;
  int _consecutiveWrong = 0;

  QuizDifficulty get currentDifficulty => _currentDifficulty;

  void recordAnswer(bool isCorrect) {
    if (isCorrect) {
      _consecutiveCorrect += 1;
      _consecutiveWrong = 0;

      if (_consecutiveCorrect >= 3) {
        _currentDifficulty = _currentDifficulty.harder();
        _consecutiveCorrect = 0;
      }

      return;
    }

    _consecutiveWrong += 1;
    _consecutiveCorrect = 0;

    if (_consecutiveWrong >= 2) {
      _currentDifficulty = _currentDifficulty.easier();
      _consecutiveWrong = 0;
    }
  }
}
