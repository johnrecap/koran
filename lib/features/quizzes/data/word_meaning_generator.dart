import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/quizzes/domain/question_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/tafsir/data/word_meaning_data_source.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

class WordMeaningGenerator implements QuestionGenerator {
  WordMeaningGenerator({
    AssetBundle? bundle,
    this.directoryPath = 'assets/data/word_meanings',
    List<int>? availableSurahNumbers,
    WordMeaningDataSource? dataSource,
  })  : bundle = bundle ?? rootBundle,
        availableSurahNumbers =
            availableSurahNumbers ?? const <int>[1, 2, 112],
        _dataSource = dataSource ??
            LocalWordMeaningDataSource(
              bundle: bundle,
              directoryPath: directoryPath,
            );

  final AssetBundle bundle;
  final String directoryPath;
  final List<int> availableSurahNumbers;
  final WordMeaningDataSource _dataSource;

  @override
  Future<List<QuizQuestion>> generate({
    required int count,
    required QuizDifficulty difficulty,
    int? surahFilter,
  }) async {
    try {
      final allCandidates = await _loadCandidates();
      if (_uniqueMeaningCount(allCandidates) < 4) {
        return const <QuizQuestion>[];
      }

      final questionCandidates = surahFilter == null
          ? allCandidates
          : allCandidates
              .where((candidate) => candidate.surahNumber == surahFilter)
              .toList(growable: false);

      final questions = <QuizQuestion>[];
      final usedWords = <String>{};

      for (final candidate in questionCandidates) {
        if (questions.length >= count) {
          break;
        }

        if (!usedWords.add('${candidate.surahNumber}:${candidate.entry.word}')) {
          continue;
        }

        final distractors = _pickDistractors(
          candidate: candidate,
          pool: allCandidates,
          difficulty: difficulty,
        );
        if (distractors.length < 3) {
          continue;
        }

        final correctIndex = questions.length % 4;
        final choices = <String>[...distractors.take(3)];
        choices.insert(correctIndex, candidate.entry.meaning);

        questions.add(
          WordMeaningQuestion(
            prompt: candidate.entry.word,
            choices: choices,
            correctIndex: correctIndex,
            surahNumber: candidate.surahNumber,
            ayahNumber: candidate.ayahNumber,
            difficulty: difficulty,
            word: candidate.entry.word,
          ),
        );
      }

      return questions;
    } catch (error, stackTrace) {
      AppLogger.error(
        'WordMeaningGenerator.generate',
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
    final questions = await generate(
      count: 1,
      difficulty: QuizDifficulty.medium,
      surahFilter: surahFilter,
    );
    return questions.isNotEmpty;
  }

  Future<List<_WordMeaningCandidate>> _loadCandidates() async {
    final candidates = <_WordMeaningCandidate>[];
    for (final surahNumber in availableSurahNumbers) {
      final ayahNumbers = await _loadAyahNumbersForSurah(surahNumber);
      for (final ayahNumber in ayahNumbers) {
        final section = await _dataSource.fetchForAyah(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        );

        if (section case InsightSectionLoaded<List<WordMeaningEntry>>(:final content)) {
          for (final entry in content) {
            candidates.add(
              _WordMeaningCandidate(
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                entry: entry,
              ),
            );
          }
        }
      }
    }

    return candidates;
  }

  Future<List<int>> _loadAyahNumbersForSurah(int surahNumber) async {
    final assetPath = '$directoryPath/$surahNumber.json';
    try {
      final raw = await bundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const <int>[];
      }

      final ayahs = decoded['ayahs'];
      if (ayahs is! Map<String, dynamic>) {
        return const <int>[];
      }

      return ayahs.keys
          .map(int.tryParse)
          .whereType<int>()
          .toList(growable: false);
    } catch (_) {
      return const <int>[];
    }
  }

  List<String> _pickDistractors({
    required _WordMeaningCandidate candidate,
    required List<_WordMeaningCandidate> pool,
    required QuizDifficulty difficulty,
  }) {
    final rankedCandidates = pool
        .where((other) => other.entry.meaning != candidate.entry.meaning)
        .toList(growable: false);

    rankedCandidates.sort((left, right) {
      final leftScore = _similarityScore(candidate.entry, left.entry);
      final rightScore = _similarityScore(candidate.entry, right.entry);

      return switch (difficulty) {
        QuizDifficulty.easy => leftScore.compareTo(rightScore),
        QuizDifficulty.medium =>
          (leftScore - 2).abs().compareTo((rightScore - 2).abs()),
        QuizDifficulty.hard => rightScore.compareTo(leftScore),
      };
    });

    final meanings = <String>[];
    final seenMeanings = <String>{candidate.entry.meaning};
    for (final distractor in rankedCandidates) {
      if (seenMeanings.add(distractor.entry.meaning)) {
        meanings.add(distractor.entry.meaning);
      }
      if (meanings.length == 3) {
        break;
      }
    }

    return meanings;
  }

  int _uniqueMeaningCount(List<_WordMeaningCandidate> candidates) {
    return candidates.map((candidate) => candidate.entry.meaning).toSet().length;
  }

  int _similarityScore(WordMeaningEntry base, WordMeaningEntry other) {
    var score = 0;

    if (base.root != null && base.root == other.root) {
      score += 4;
    }
    if (_startsWithSameLetter(base.meaning, other.meaning)) {
      score += 2;
    }
    if (_startsWithSameLetter(base.word, other.word)) {
      score += 1;
    }
    if ((base.meaning.length - other.meaning.length).abs() <= 2) {
      score += 1;
    }

    return score;
  }

  bool _startsWithSameLetter(String left, String right) {
    if (left.isEmpty || right.isEmpty) {
      return false;
    }

    return left[0].toLowerCase() == right[0].toLowerCase();
  }
}

class _WordMeaningCandidate {
  const _WordMeaningCandidate({
    required this.surahNumber,
    required this.ayahNumber,
    required this.entry,
  });

  final int surahNumber;
  final int ayahNumber;
  final WordMeaningEntry entry;
}
