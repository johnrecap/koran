import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

void main() {
  group('QuizSessionConfig', () {
    test('uses the expected defaults', () {
      const config = QuizSessionConfig(quizType: QuizType.verseCompletion);

      expect(config.questionCount, 10);
      expect(config.surahFilter, isNull);
      expect(config.difficulty, QuizDifficulty.medium);
      expect(config.adaptiveDifficulty, isTrue);
    });
  });

  group('QuizQuestion', () {
    test('supports subtype pattern matching', () {
      final questions = <QuizQuestion>[
        VerseCompletionQuestion(
          prompt: 'prompt',
          choices: const ['a', 'b', 'c', 'd'],
          correctIndex: 0,
          surahNumber: 1,
          ayahNumber: 1,
          difficulty: QuizDifficulty.easy,
          fullVerse: 'full verse',
        ),
        WordMeaningQuestion(
          prompt: 'meaning?',
          choices: const ['mercy', 'fire', 'earth', 'sky'],
          correctIndex: 0,
          surahNumber: 2,
          ayahNumber: 255,
          difficulty: QuizDifficulty.medium,
          word: 'رحمة',
        ),
        VerseTopicQuestion(
          prompt: 'topic?',
          choices: const ['faith', 'prayer', 'charity', 'fasting'],
          correctIndex: 1,
          surahNumber: 67,
          ayahNumber: 3,
          difficulty: QuizDifficulty.hard,
          topicId: 'topic-faith',
        ),
      ];

      final matchedTypes = questions.map(_matchQuestionType).toList();

      expect(
        matchedTypes,
        const <String>['verseCompletion', 'wordMeaning', 'verseTopic'],
      );
    });
  });

  group('QuizResult', () {
    test('derives score, totalQuestions, and percentage for a full score', () {
      final result = QuizResult(
        config: const QuizSessionConfig(quizType: QuizType.verseCompletion),
        questions: [_sampleQuestion()],
        answers: const [
          QuizAnswer(
            questionIndex: 0,
            selectedIndex: 0,
            isCorrect: true,
            difficulty: QuizDifficulty.easy,
          ),
        ],
        completedAt: DateTime(2026, 4, 6, 12),
      );

      expect(result.score, 1);
      expect(result.totalQuestions, 1);
      expect(result.percentage, 100);
    });

    test('derives score, totalQuestions, and percentage for a partial score', () {
      final result = QuizResult(
        config: const QuizSessionConfig(quizType: QuizType.wordMeaning),
        questions: [_sampleQuestion(), _sampleQuestion()],
        answers: const [
          QuizAnswer(
            questionIndex: 0,
            selectedIndex: 0,
            isCorrect: true,
            difficulty: QuizDifficulty.medium,
          ),
          QuizAnswer(
            questionIndex: 1,
            selectedIndex: 2,
            isCorrect: false,
            difficulty: QuizDifficulty.medium,
          ),
        ],
        completedAt: DateTime(2026, 4, 6, 12),
      );

      expect(result.score, 1);
      expect(result.totalQuestions, 2);
      expect(result.percentage, 50);
    });

    test('derives score, totalQuestions, and percentage for zero correct', () {
      final result = QuizResult(
        config: const QuizSessionConfig(quizType: QuizType.verseTopic),
        questions: [_sampleQuestion(), _sampleQuestion()],
        answers: const [
          QuizAnswer(
            questionIndex: 0,
            selectedIndex: 3,
            isCorrect: false,
            difficulty: QuizDifficulty.hard,
          ),
          QuizAnswer(
            questionIndex: 1,
            selectedIndex: 2,
            isCorrect: false,
            difficulty: QuizDifficulty.hard,
          ),
        ],
        completedAt: DateTime(2026, 4, 6, 12),
      );

      expect(result.score, 0);
      expect(result.totalQuestions, 2);
      expect(result.percentage, 0);
    });
  });

  group('QuizHistoryEntry', () {
    test('round-trips through map serialization', () {
      final entry = QuizHistoryEntry(
        quizType: QuizType.wordMeaning,
        score: 7,
        totalQuestions: 10,
        difficulty: QuizDifficulty.hard,
        surahFilter: 2,
        completedAt: DateTime(2026, 4, 6, 18, 30),
      );

      final decoded = QuizHistoryEntry.fromMap(entry.toMap());

      expect(decoded.quizType, QuizType.wordMeaning);
      expect(decoded.score, 7);
      expect(decoded.totalQuestions, 10);
      expect(decoded.difficulty, QuizDifficulty.hard);
      expect(decoded.surahFilter, 2);
      expect(decoded.completedAt, DateTime(2026, 4, 6, 18, 30));
    });

    test('handles missing fields gracefully', () {
      final decoded = QuizHistoryEntry.fromMap(<String, dynamic>{
        'quizType': 'verseCompletion',
        'score': 3,
      });

      expect(decoded.quizType, QuizType.verseCompletion);
      expect(decoded.score, 3);
      expect(decoded.totalQuestions, 0);
      expect(decoded.difficulty, QuizDifficulty.medium);
      expect(decoded.surahFilter, isNull);
      expect(
        decoded.completedAt,
        DateTime.fromMillisecondsSinceEpoch(0),
      );
    });
  });
}

String _matchQuestionType(QuizQuestion question) {
  return switch (question) {
    VerseCompletionQuestion() => 'verseCompletion',
    WordMeaningQuestion() => 'wordMeaning',
    VerseTopicQuestion() => 'verseTopic',
  };
}

QuizQuestion _sampleQuestion() {
  return VerseCompletionQuestion(
    prompt: 'prompt',
    choices: const ['a', 'b', 'c', 'd'],
    correctIndex: 0,
    surahNumber: 1,
    ayahNumber: 1,
    difficulty: QuizDifficulty.easy,
    fullVerse: 'full verse',
  );
}
