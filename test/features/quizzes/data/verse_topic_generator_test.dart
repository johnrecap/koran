import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/library/data/library_topic_local_data_source.dart';
import 'package:quran_kareem/features/library/domain/library_topic.dart';
import 'package:quran_kareem/features/quizzes/data/verse_topic_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

void main() {
  group('VerseTopicGenerator', () {
    test('generates questions with distractors from distinct categories', () async {
      final generator = VerseTopicGenerator(
        topicCatalogSource: const _FakeTopicCatalogSource(_topics),
        ayahResolver: _FakeTopicAyahResolver(_resolvedAyahs),
      );

      final questions = await generator.generate(
        count: 2,
        difficulty: QuizDifficulty.medium,
      );

      expect(questions, hasLength(2));
      expect(questions, everyElement(isA<VerseTopicQuestion>()));

      for (final question in questions.cast<VerseTopicQuestion>()) {
        final correctTopic = _topicByTitle(question.correctChoice);
        final distractorCategories = question.choices
            .where((choice) => choice != question.correctChoice)
            .map((choice) => _topicByTitle(choice).category)
            .toSet();

        expect(question.choices.toSet(), hasLength(4));
        expect(distractorCategories, hasLength(3));
        expect(distractorCategories.contains(correctTopic.category), isFalse);
      }
    });

    test('restricts generated question verses to the requested surah', () async {
      final generator = VerseTopicGenerator(
        topicCatalogSource: const _FakeTopicCatalogSource(_topics),
        ayahResolver: _FakeTopicAyahResolver(_resolvedAyahs),
      );

      final questions = await generator.generate(
        count: 1,
        difficulty: QuizDifficulty.easy,
        surahFilter: 2,
      );

      expect(questions, hasLength(1));
      expect(questions.single.surahNumber, 2);
    });

    test('returns empty when fewer than four usable topics are available', () async {
      final generator = VerseTopicGenerator(
        topicCatalogSource: _FakeTopicCatalogSource(_topics.take(3).toList()),
        ayahResolver: _FakeTopicAyahResolver(_resolvedAyahs),
      );

      final questions = await generator.generate(
        count: 1,
        difficulty: QuizDifficulty.medium,
      );

      expect(questions, isEmpty);
    });

    test('isAvailable reports false when the catalog cannot form a question', () async {
      final generator = VerseTopicGenerator(
        topicCatalogSource: _FakeTopicCatalogSource(_topics.take(3).toList()),
        ayahResolver: _FakeTopicAyahResolver(_resolvedAyahs),
      );

      final isAvailable = await generator.isAvailable();

      expect(isAvailable, isFalse);
    });
  });
}

const List<LibraryTopic> _topics = <LibraryTopic>[
  LibraryTopic(
    id: 'stories',
    titleArabic: 'Stories',
    titleEnglish: 'Stories',
    descriptionArabic: 'Stories',
    descriptionEnglish: 'Stories',
    category: LibraryTopicCategory.stories,
    iconKey: 'book',
    references: <LibraryTopicReference>[
      LibraryTopicReference(surahNumber: 1, ayahNumber: 1),
    ],
  ),
  LibraryTopic(
    id: 'laws',
    titleArabic: 'Laws',
    titleEnglish: 'Laws',
    descriptionArabic: 'Laws',
    descriptionEnglish: 'Laws',
    category: LibraryTopicCategory.laws,
    iconKey: 'gavel',
    references: <LibraryTopicReference>[
      LibraryTopicReference(surahNumber: 2, ayahNumber: 1),
    ],
  ),
  LibraryTopic(
    id: 'afterlife',
    titleArabic: 'Afterlife',
    titleEnglish: 'Afterlife',
    descriptionArabic: 'Afterlife',
    descriptionEnglish: 'Afterlife',
    category: LibraryTopicCategory.afterlife,
    iconKey: 'hourglass',
    references: <LibraryTopicReference>[
      LibraryTopicReference(surahNumber: 3, ayahNumber: 1),
    ],
  ),
  LibraryTopic(
    id: 'foundations',
    titleArabic: 'Foundations',
    titleEnglish: 'Foundations',
    descriptionArabic: 'Foundations',
    descriptionEnglish: 'Foundations',
    category: LibraryTopicCategory.all,
    iconKey: 'menu_book',
    references: <LibraryTopicReference>[
      LibraryTopicReference(surahNumber: 2, ayahNumber: 2),
    ],
  ),
  LibraryTopic(
    id: 'ethics',
    titleArabic: 'Ethics',
    titleEnglish: 'Ethics',
    descriptionArabic: 'Ethics',
    descriptionEnglish: 'Ethics',
    category: LibraryTopicCategory.stories,
    iconKey: 'balance',
    references: <LibraryTopicReference>[
      LibraryTopicReference(surahNumber: 1, ayahNumber: 2),
    ],
  ),
];

final Map<String, List<LibraryTopicReferenceResult>> _resolvedAyahs =
    <String, List<LibraryTopicReferenceResult>>{
  'stories': <LibraryTopicReferenceResult>[
    _resolvedReference(1, 1, 'narrative verse about patience and rescue'),
  ],
  'laws': <LibraryTopicReferenceResult>[
    _resolvedReference(2, 1, 'lawful guidance for community obligations'),
  ],
  'afterlife': <LibraryTopicReferenceResult>[
    _resolvedReference(3, 1, 'afterlife reminder about return and judgment'),
  ],
  'foundations': <LibraryTopicReferenceResult>[
    _resolvedReference(2, 2, 'foundational verse about faith and devotion'),
  ],
  'ethics': <LibraryTopicReferenceResult>[
    _resolvedReference(1, 2, 'ethical teaching about honesty and trust'),
  ],
};

LibraryTopic _topicByTitle(String title) {
  return _topics.firstWhere(
    (topic) => topic.titleEnglish == title || topic.titleArabic == title,
  );
}

LibraryTopicReferenceResult _resolvedReference(
  int surahNumber,
  int ayahNumber,
  String text,
) {
  return LibraryTopicReferenceResult(
    ayah: Ayah(
      id: (surahNumber * 100) + ayahNumber,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      text: text,
      page: 1,
      juz: 1,
      hizb: 1,
    ),
    surahName: 'Surah $surahNumber',
  );
}

class _FakeTopicCatalogSource implements LibraryTopicCatalogSource {
  const _FakeTopicCatalogSource(this.topics);

  final List<LibraryTopic> topics;

  @override
  Future<List<LibraryTopic>> loadTopics() async => topics;
}

class _FakeTopicAyahResolver implements LibraryTopicAyahResolver {
  const _FakeTopicAyahResolver(this.resolvedAyahs);

  final Map<String, List<LibraryTopicReferenceResult>> resolvedAyahs;

  @override
  Future<List<LibraryTopicReferenceResult>> resolveTopic(
    LibraryTopic topic,
  ) async {
    return resolvedAyahs[topic.id] ?? const [];
  }
}
