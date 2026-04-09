import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/library/data/library_topic_local_data_source.dart';
import 'package:quran_kareem/features/library/domain/library_topic.dart';
import 'package:quran_kareem/features/quizzes/domain/question_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

class VerseTopicGenerator implements QuestionGenerator {
  VerseTopicGenerator({
    LibraryTopicCatalogSource? topicCatalogSource,
    LibraryTopicAyahResolver? ayahResolver,
  })  : _topicCatalogSource =
            topicCatalogSource ?? AssetLibraryTopicCatalogSource(),
        _ayahResolver = ayahResolver ?? const QuranDatabaseLibraryTopicAyahResolver();

  final LibraryTopicCatalogSource _topicCatalogSource;
  final LibraryTopicAyahResolver _ayahResolver;

  @override
  Future<List<QuizQuestion>> generate({
    required int count,
    required QuizDifficulty difficulty,
    int? surahFilter,
  }) async {
    try {
      final allCandidates = await _loadCandidates();
      if (allCandidates.length < 4) {
        return const <QuizQuestion>[];
      }

      final questionCandidates = surahFilter == null
          ? allCandidates
          : allCandidates
              .where(
                (candidate) => candidate.reference.ayah.surahNumber == surahFilter,
              )
              .toList(growable: false);

      final questions = <QuizQuestion>[];
      for (final candidate in questionCandidates) {
        if (questions.length >= count) {
          break;
        }

        final distractors = _pickDistractors(
          correct: candidate,
          pool: allCandidates,
        );
        if (distractors.length < 3) {
          continue;
        }

        final correctChoice = _topicLabel(candidate.topic);
        final choices = distractors.map((candidate) => _topicLabel(candidate.topic)).toList();
        final correctIndex = questions.length % 4;
        choices.insert(correctIndex, correctChoice);

        questions.add(
          VerseTopicQuestion(
            prompt: _snippet(candidate.reference.ayah.text),
            choices: choices,
            correctIndex: correctIndex,
            surahNumber: candidate.reference.ayah.surahNumber,
            ayahNumber: candidate.reference.ayah.ayahNumber,
            difficulty: difficulty,
            topicId: candidate.topic.id,
          ),
        );
      }

      return questions;
    } catch (error, stackTrace) {
      AppLogger.error(
        'VerseTopicGenerator.generate',
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

  Future<List<_TopicQuestionCandidate>> _loadCandidates() async {
    final topics = await _topicCatalogSource.loadTopics();
    final candidates = <_TopicQuestionCandidate>[];

    for (final topic in topics) {
      final resolvedReferences = await _ayahResolver.resolveTopic(topic);
      final matchingReference = _firstOrNull(resolvedReferences);

      if (matchingReference == null) {
        continue;
      }

      candidates.add(
        _TopicQuestionCandidate(
          topic: topic,
          reference: matchingReference,
        ),
      );
    }

    return candidates;
  }

  List<_TopicQuestionCandidate> _pickDistractors({
    required _TopicQuestionCandidate correct,
    required List<_TopicQuestionCandidate> pool,
  }) {
    final distractors = <_TopicQuestionCandidate>[];
    final usedCategories = <LibraryTopicCategory>{};
    final usedLabels = <String>{_topicLabel(correct.topic)};

    final preferred = pool
        .where(
          (candidate) =>
              candidate.topic.id != correct.topic.id &&
              candidate.topic.category != correct.topic.category,
        )
        .toList(growable: false);

    for (final candidate in preferred) {
      final label = _topicLabel(candidate.topic);
      if (!usedLabels.add(label)) {
        continue;
      }
      if (!usedCategories.add(candidate.topic.category)) {
        continue;
      }

      distractors.add(candidate);
      if (distractors.length == 3) {
        return distractors;
      }
    }

    return const <_TopicQuestionCandidate>[];
  }
}

String _topicLabel(LibraryTopic topic) {
  return topic.titleEnglish.trim().isNotEmpty
      ? topic.titleEnglish.trim()
      : topic.titleArabic.trim();
}

String _snippet(String text) {
  final words = text
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.length <= 8) {
    return words.join(' ');
  }

  return '${words.take(8).join(' ')}...';
}

class _TopicQuestionCandidate {
  const _TopicQuestionCandidate({
    required this.topic,
    required this.reference,
  });

  final LibraryTopic topic;
  final LibraryTopicReferenceResult reference;
}

T? _firstOrNull<T>(Iterable<T> values) {
  for (final value in values) {
    return value;
  }

  return null;
}
