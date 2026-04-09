import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/quizzes/data/verse_completion_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

void main() {
  group('VerseCompletionGenerator', () {
    test('generates the requested count and respects easy word-count rules', () async {
      final generator = VerseCompletionGenerator(
        surahLoader: () async => _surahs,
        ayahLoader: (surahNumber) async => _ayahsBySurah[surahNumber] ?? const [],
      );

      final questions = await generator.generate(
        count: 2,
        difficulty: QuizDifficulty.easy,
      );

      expect(questions, hasLength(2));
      expect(questions, everyElement(isA<VerseCompletionQuestion>()));

      for (final question in questions.cast<VerseCompletionQuestion>()) {
        expect(_wordCount(question.fullVerse), lessThanOrEqualTo(5));
        expect(question.choices.toSet(), hasLength(4));
        expect(
          question.choices.where((choice) => choice == question.correctChoice),
          hasLength(1),
        );
      }
    });

    test('uses medium-length verses when medium difficulty is requested', () async {
      final generator = VerseCompletionGenerator(
        surahLoader: () async => _surahs,
        ayahLoader: (surahNumber) async => _ayahsBySurah[surahNumber] ?? const [],
      );

      final questions = await generator.generate(
        count: 2,
        difficulty: QuizDifficulty.medium,
      );

      expect(questions, hasLength(2));

      for (final question in questions.cast<VerseCompletionQuestion>()) {
        expect(_wordCount(question.fullVerse), greaterThan(5));
        expect(_wordCount(question.fullVerse), lessThanOrEqualTo(12));
      }
    });

    test('restricts generated question verses to the requested surah', () async {
      final generator = VerseCompletionGenerator(
        surahLoader: () async => _surahs,
        ayahLoader: (surahNumber) async => _ayahsBySurah[surahNumber] ?? const [],
      );

      final questions = await generator.generate(
        count: 2,
        difficulty: QuizDifficulty.medium,
        surahFilter: 2,
      );

      expect(questions, hasLength(2));
      expect(
        questions.map((question) => question.surahNumber).toSet(),
        <int>{2},
      );
    });

    test('returns empty when there is not enough data to build unique choices', () async {
      final generator = VerseCompletionGenerator(
        surahLoader: () async => const [
          Surah(
            number: 1,
            nameArabic: 'A',
            nameEnglish: 'A',
            nameTransliteration: 'A',
            ayahCount: 1,
            revelationType: 'Meccan',
            page: 1,
          ),
        ],
        ayahLoader: (surahNumber) async => const [
          Ayah(
            id: 1,
            surahNumber: 1,
            ayahNumber: 1,
            text: 'one two three four five six seven',
            page: 1,
            juz: 1,
            hizb: 1,
          ),
        ],
      );

      final questions = await generator.generate(
        count: 1,
        difficulty: QuizDifficulty.medium,
      );

      expect(questions, isEmpty);
    });

    test('isAvailable returns false when the source is empty', () async {
      final generator = VerseCompletionGenerator(
        surahLoader: () async => const [],
        ayahLoader: (_) async => const [],
      );

      final isAvailable = await generator.isAvailable();

      expect(isAvailable, isFalse);
    });
  });
}

const List<Surah> _surahs = <Surah>[
  Surah(
    number: 1,
    nameArabic: 'One',
    nameEnglish: 'One',
    nameTransliteration: 'One',
    ayahCount: 4,
    revelationType: 'Meccan',
    page: 1,
  ),
  Surah(
    number: 2,
    nameArabic: 'Two',
    nameEnglish: 'Two',
    nameTransliteration: 'Two',
    ayahCount: 8,
    revelationType: 'Medinan',
    page: 2,
  ),
  Surah(
    number: 3,
    nameArabic: 'Three',
    nameEnglish: 'Three',
    nameTransliteration: 'Three',
    ayahCount: 4,
    revelationType: 'Medinan',
    page: 3,
  ),
];

final Map<int, List<Ayah>> _ayahsBySurah = <int, List<Ayah>>{
  1: <Ayah>[
    _ayah(1, 1, 'alpha beta gamma delta'),
    _ayah(1, 2, 'north south east west'),
    _ayah(1, 3, 'spring summer autumn winter'),
    _ayah(1, 4, 'mountain river valley desert'),
  ],
  2: <Ayah>[
    _ayah(2, 1, 'mercy guides every seeking heart tonight'),
    _ayah(2, 2, 'wisdom grows through patient prayer each dawn'),
    _ayah(2, 3, 'truth shines for souls who listen with care'),
    _ayah(2, 4, 'light returns when hope is held with trust'),
    _ayah(2, 5, 'steady hearts remember mercy during every fearful night'),
    _ayah(2, 6, 'gentle rain revives the earth and every silent garden'),
    _ayah(2, 7, 'faithful servants answer the call with humble voices'),
    _ayah(2, 8, 'clear signs appear for those who reflect with patience'),
  ],
  3: <Ayah>[
    _ayah(3, 1, 'ocean breeze calms hearts'),
    _ayah(3, 2, 'lantern lights guide homes'),
    _ayah(3, 3, 'morning birds sing softly'),
    _ayah(3, 4, 'quiet clouds shade hills'),
  ],
};

Ayah _ayah(int surahNumber, int ayahNumber, String text) {
  return Ayah(
    id: (surahNumber * 100) + ayahNumber,
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    text: text,
    page: 1,
    juz: 1,
    hizb: 1,
  );
}

int _wordCount(String text) {
  return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
}
