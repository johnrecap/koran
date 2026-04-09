import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';

enum QuizType { verseCompletion, wordMeaning, verseTopic }

class QuizSessionConfig {
  const QuizSessionConfig({
    required this.quizType,
    this.questionCount = 10,
    this.surahFilter,
    this.difficulty = QuizDifficulty.medium,
    this.adaptiveDifficulty = true,
  }) : assert(questionCount > 0);

  final QuizType quizType;
  final int questionCount;
  final int? surahFilter;
  final QuizDifficulty difficulty;
  final bool adaptiveDifficulty;
}

sealed class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    required this.surahNumber,
    required this.ayahNumber,
    required this.difficulty,
  }) : assert(choices.length >= 2),
       assert(correctIndex >= 0),
       assert(correctIndex < choices.length);

  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final int surahNumber;
  final int ayahNumber;
  final QuizDifficulty difficulty;

  String get correctChoice => choices[correctIndex];
}

class VerseCompletionQuestion extends QuizQuestion {
  const VerseCompletionQuestion({
    required super.prompt,
    required super.choices,
    required super.correctIndex,
    required super.surahNumber,
    required super.ayahNumber,
    required super.difficulty,
    required this.fullVerse,
  });

  final String fullVerse;
}

class WordMeaningQuestion extends QuizQuestion {
  const WordMeaningQuestion({
    required super.prompt,
    required super.choices,
    required super.correctIndex,
    required super.surahNumber,
    required super.ayahNumber,
    required super.difficulty,
    required this.word,
  });

  final String word;
}

class VerseTopicQuestion extends QuizQuestion {
  const VerseTopicQuestion({
    required super.prompt,
    required super.choices,
    required super.correctIndex,
    required super.surahNumber,
    required super.ayahNumber,
    required super.difficulty,
    required this.topicId,
  });

  final String topicId;
}

class QuizAnswer {
  const QuizAnswer({
    required this.questionIndex,
    required this.selectedIndex,
    required this.isCorrect,
    required this.difficulty,
  });

  final int questionIndex;
  final int selectedIndex;
  final bool isCorrect;
  final QuizDifficulty difficulty;
}

class QuizResult {
  const QuizResult({
    required this.config,
    required this.questions,
    required this.answers,
    required this.completedAt,
  }) : assert(answers.length <= questions.length);

  final QuizSessionConfig config;
  final List<QuizQuestion> questions;
  final List<QuizAnswer> answers;
  final DateTime completedAt;

  int get score => answers.where((answer) => answer.isCorrect).length;
  int get totalQuestions => questions.length;
  double get percentage {
    if (totalQuestions == 0) {
      return 0;
    }

    return (score / totalQuestions) * 100;
  }
}

class QuizHistoryEntry {
  const QuizHistoryEntry({
    required this.quizType,
    required this.score,
    required this.totalQuestions,
    required this.difficulty,
    required this.surahFilter,
    required this.completedAt,
  });

  final QuizType quizType;
  final int score;
  final int totalQuestions;
  final QuizDifficulty difficulty;
  final int? surahFilter;
  final DateTime completedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'quizType': quizType.name,
    'score': score,
    'totalQuestions': totalQuestions,
    'difficulty': difficulty.name,
    'surahFilter': surahFilter,
    'completedAt': completedAt.toIso8601String(),
  };

  factory QuizHistoryEntry.fromMap(Map<String, dynamic> map) {
    return QuizHistoryEntry(
      quizType: _quizTypeFromName(map['quizType'] as String?) ??
          QuizType.verseCompletion,
      score: (map['score'] as num?)?.toInt() ?? 0,
      totalQuestions:
          (map['totalQuestions'] as num?)?.toInt() ??
              (map['total'] as num?)?.toInt() ??
              0,
      difficulty: _quizDifficultyFromName(map['difficulty'] as String?) ??
          QuizDifficulty.medium,
      surahFilter: (map['surahFilter'] as num?)?.toInt(),
      completedAt: map['completedAt'] == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(map['completedAt'] as String),
    );
  }
}

QuizType? _quizTypeFromName(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  for (final quizType in QuizType.values) {
    if (quizType.name == value) {
      return quizType;
    }
  }

  return null;
}

QuizDifficulty? _quizDifficultyFromName(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  for (final difficulty in QuizDifficulty.values) {
    if (difficulty.name == value) {
      return difficulty;
    }
  }

  return null;
}
