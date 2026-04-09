import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/quizzes/data/word_meaning_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

import '../../tafsir/data/fake_asset_bundle.dart';

void main() {
  group('WordMeaningGenerator', () {
    test('generates questions from mock word meanings without duplicate choices', () async {
      final generator = WordMeaningGenerator(
        bundle: FakeAssetBundle(values: _richWordMeaningAssets),
        availableSurahNumbers: const <int>[1, 2],
      );

      final questions = await generator.generate(
        count: 3,
        difficulty: QuizDifficulty.medium,
      );

      expect(questions, hasLength(3));
      expect(questions, everyElement(isA<WordMeaningQuestion>()));

      for (final question in questions.cast<WordMeaningQuestion>()) {
        expect(question.choices.toSet(), hasLength(4));
        expect(
          question.choices.where((choice) => choice == question.correctChoice),
          hasLength(1),
        );
      }
    });

    test('restricts generated questions to the requested surah file', () async {
      final generator = WordMeaningGenerator(
        bundle: FakeAssetBundle(values: _richWordMeaningAssets),
        availableSurahNumbers: const <int>[1, 2],
      );

      final questions = await generator.generate(
        count: 2,
        difficulty: QuizDifficulty.easy,
        surahFilter: 2,
      );

      expect(questions, hasLength(2));
      expect(
        questions.map((question) => question.surahNumber).toSet(),
        <int>{2},
      );
    });

    test('returns empty when fewer than four unique entries are available', () async {
      final generator = WordMeaningGenerator(
        bundle: FakeAssetBundle(values: _smallWordMeaningAssets),
        availableSurahNumbers: const <int>[112],
      );

      final questions = await generator.generate(
        count: 1,
        difficulty: QuizDifficulty.easy,
      );

      expect(questions, isEmpty);
    });

    test('isAvailable reports false when the dataset cannot produce a question', () async {
      final generator = WordMeaningGenerator(
        bundle: FakeAssetBundle(values: _smallWordMeaningAssets),
        availableSurahNumbers: const <int>[112],
      );

      final isAvailable = await generator.isAvailable();

      expect(isAvailable, isFalse);
    });
  });
}

const Map<String, String> _richWordMeaningAssets = <String, String>{
  'assets/data/word_meanings/1.json': '''
{
  "ayahs": {
    "1": [{"word": "rahma", "meaning": "mercy", "root": "rhm"}],
    "2": [{"word": "nar", "meaning": "fire", "root": "nwr"}],
    "3": [{"word": "ard", "meaning": "earth", "root": "ard"}]
  }
}
''',
  'assets/data/word_meanings/2.json': '''
{
  "ayahs": {
    "1": [{"word": "sama", "meaning": "sky", "root": "smw"}],
    "2": [{"word": "bahr", "meaning": "sea", "root": "bhr"}],
    "3": [{"word": "nur", "meaning": "light", "root": "nwr"}]
  }
}
''',
};

const Map<String, String> _smallWordMeaningAssets = <String, String>{
  'assets/data/word_meanings/112.json': '''
{
  "ayahs": {
    "1": [{"word": "ahad", "meaning": "one", "root": "ahd"}],
    "2": [{"word": "samad", "meaning": "eternal", "root": "smd"}],
    "3": [{"word": "walad", "meaning": "child", "root": "wld"}]
  }
}
''',
};
