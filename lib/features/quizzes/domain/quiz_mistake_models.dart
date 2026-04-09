import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

class QuizMistakeEntry {
  QuizMistakeEntry({
    required this.questionKey,
    required this.quizType,
    required Map<String, dynamic> questionMetadata,
    this.correctStreak = 0,
    required this.lastAttemptedAt,
  }) : questionMetadata = Map<String, dynamic>.from(questionMetadata);

  final String questionKey;
  final QuizType quizType;
  final Map<String, dynamic> questionMetadata;
  int correctStreak;
  DateTime lastAttemptedAt;

  bool get isGraduated => correctStreak >= 2;

  void recordCorrect({DateTime? attemptedAt}) {
    correctStreak += 1;
    if (attemptedAt != null) {
      lastAttemptedAt = attemptedAt;
    }
  }

  void recordIncorrect({DateTime? attemptedAt}) {
    correctStreak = 0;
    if (attemptedAt != null) {
      lastAttemptedAt = attemptedAt;
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'questionKey': questionKey,
    'quizType': quizType.name,
    'questionMetadata': questionMetadata,
    'correctStreak': correctStreak,
    'lastAttemptedAt': lastAttemptedAt.toIso8601String(),
  };

  factory QuizMistakeEntry.fromMap(Map<String, dynamic> map) {
    final rawMetadata = map['questionMetadata'];
    final metadata = rawMetadata is Map
        ? Map<String, dynamic>.from(rawMetadata)
        : <String, dynamic>{};

    return QuizMistakeEntry(
      questionKey: map['questionKey'] as String? ?? '',
      quizType: _parseQuizType(map['quizType'] as String?),
      questionMetadata: metadata,
      correctStreak: (map['correctStreak'] as num?)?.toInt() ?? 0,
      lastAttemptedAt: map['lastAttemptedAt'] == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(map['lastAttemptedAt'] as String),
    );
  }
}

QuizType _parseQuizType(String? value) {
  for (final quizType in QuizType.values) {
    if (quizType.name == value) {
      return quizType;
    }
  }

  return QuizType.verseCompletion;
}
