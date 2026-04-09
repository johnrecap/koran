import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/quizzes/domain/question_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

typedef QuizSurahLoader = Future<List<Surah>> Function();
typedef QuizAyahLoader = Future<List<Ayah>> Function(int surahNumber);

class VerseCompletionGenerator implements QuestionGenerator {
  VerseCompletionGenerator({
    QuizSurahLoader? surahLoader,
    QuizAyahLoader? ayahLoader,
  })  : _surahLoader = surahLoader ?? QuranDatabase.getSurahs,
        _ayahLoader = ayahLoader ?? QuranDatabase.getAyahsBySurah;

  final QuizSurahLoader _surahLoader;
  final QuizAyahLoader _ayahLoader;

  @override
  Future<List<QuizQuestion>> generate({
    required int count,
    required QuizDifficulty difficulty,
    int? surahFilter,
  }) async {
    try {
      final ayahsBySurah = await _loadAyahsBySurah();
      final allEligibleAyahs = ayahsBySurah.values
          .expand((ayahs) => ayahs)
          .where((ayah) => _matchesDifficulty(ayah, difficulty))
          .toList(growable: false);

      if (allEligibleAyahs.length < 4) {
        return const <QuizQuestion>[];
      }

      final questionCandidates = (surahFilter == null
              ? allEligibleAyahs
              : (ayahsBySurah[surahFilter] ?? const <Ayah>[]))
          .where((ayah) => _matchesDifficulty(ayah, difficulty))
          .toList(growable: false);

      final eligibleBySurah = <int, List<Ayah>>{
        for (final entry in ayahsBySurah.entries)
          entry.key: entry.value
              .where((ayah) => _matchesDifficulty(ayah, difficulty))
              .toList(growable: false),
      };

      final questions = <QuizQuestion>[];
      for (final ayah in questionCandidates) {
        if (questions.length >= count) {
          break;
        }

        final question = _buildQuestion(
          ayah: ayah,
          allEligibleAyahs: allEligibleAyahs,
          eligibleBySurah: eligibleBySurah,
          difficulty: difficulty,
          questionOffset: questions.length,
        );
        if (question != null) {
          questions.add(question);
        }
      }

      return questions;
    } catch (error, stackTrace) {
      AppLogger.error(
        'VerseCompletionGenerator.generate',
        error,
        stackTrace,
      );
      return const <QuizQuestion>[];
    }
  }

  @override
  Future<bool> isAvailable({
    int? surahFilter,
  }) async {
    for (final difficulty in QuizDifficulty.values) {
      final questions = await generate(
        count: 1,
        difficulty: difficulty,
        surahFilter: surahFilter,
      );
      if (questions.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  Future<Map<int, List<Ayah>>> _loadAyahsBySurah() async {
    final surahs = await _surahLoader();
    final ayahs = await Future.wait(
      surahs.map((surah) async {
        final loadedAyahs = await _ayahLoader(surah.number);
        return MapEntry(surah.number, loadedAyahs);
      }),
    );

    return <int, List<Ayah>>{for (final entry in ayahs) entry.key: entry.value};
  }

  VerseCompletionQuestion? _buildQuestion({
    required Ayah ayah,
    required List<Ayah> allEligibleAyahs,
    required Map<int, List<Ayah>> eligibleBySurah,
    required QuizDifficulty difficulty,
    required int questionOffset,
  }) {
    final split = _splitVerse(ayah.text);
    if (split == null) {
      return null;
    }

    final distractorPool =
        VerseDifficultyRules.requiresSameSurahDistractors(difficulty)
            ? (eligibleBySurah[ayah.surahNumber] ?? const <Ayah>[])
                .where((candidate) => candidate.ayahNumber != ayah.ayahNumber)
                .toList(growable: false)
            : allEligibleAyahs
                .where((candidate) => candidate.surahNumber != ayah.surahNumber)
                .toList(growable: false);

    final distractors = <String>[];
    final seenChoices = <String>{split.answer};

    for (final candidate in distractorPool) {
      final candidateSplit = _splitVerse(candidate.text);
      if (candidateSplit == null) {
        continue;
      }

      if (seenChoices.add(candidateSplit.answer)) {
        distractors.add(candidateSplit.answer);
      }

      if (distractors.length == 3) {
        break;
      }
    }

    if (distractors.length < 3) {
      return null;
    }

    final correctIndex = questionOffset % 4;
    final choices = <String>[...distractors];
    choices.insert(correctIndex, split.answer);

    return VerseCompletionQuestion(
      prompt: split.prompt,
      choices: choices,
      correctIndex: correctIndex,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      difficulty: difficulty,
      fullVerse: _normalizeText(ayah.text),
    );
  }
}

_VerseSplit? _splitVerse(String verseText) {
  final words = _splitWords(verseText);
  if (words.length < 2) {
    return null;
  }

  final splitIndex = words.length <= 3 ? 1 : words.length ~/ 2;
  final prompt = words.take(splitIndex).join(' ').trim();
  final answer = words.skip(splitIndex).join(' ').trim();

  if (prompt.isEmpty || answer.isEmpty) {
    return null;
  }

  return _VerseSplit(prompt: prompt, answer: answer);
}

bool _matchesDifficulty(Ayah ayah, QuizDifficulty difficulty) {
  final wordCount = _splitWords(ayah.text).length;

  return switch (difficulty) {
    QuizDifficulty.easy =>
      wordCount >= 2 && wordCount <= VerseDifficultyRules.maxWordCount(difficulty),
    QuizDifficulty.medium =>
      wordCount > VerseDifficultyRules.maxWordCount(QuizDifficulty.easy) &&
      wordCount <= VerseDifficultyRules.maxWordCount(difficulty),
    QuizDifficulty.hard =>
      wordCount > VerseDifficultyRules.maxWordCount(QuizDifficulty.medium),
  };
}

List<String> _splitWords(String text) {
  return _normalizeText(text)
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
}

String _normalizeText(String text) {
  return text.trim().replaceAll(RegExp(r'\s+'), ' ');
}

class _VerseSplit {
  const _VerseSplit({
    required this.prompt,
    required this.answer,
  });

  final String prompt;
  final String answer;
}
