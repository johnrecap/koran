import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

void main() {
  group('InsightSectionData', () {
    test('supports loaded, unavailable, and error type matching', () {
      final states = <InsightSectionData>[
        const InsightSectionLoaded<String>('tafsir'),
        const InsightSectionUnavailable(),
        InsightSectionError(StateError('boom')),
      ];

      final labels = states.map(_describeState).toList(growable: false);

      expect(labels, ['loaded:tafsir', 'unavailable', 'error:boom']);
    });
  });

  group('Insight section models', () {
    test('parses word meaning entries from a map', () {
      final entry = WordMeaningEntry.fromMap(const {
        'word': 'الرحمن',
        'meaning': 'The Most Merciful',
        'root': 'رحم',
      });

      expect(entry.word, 'الرحمن');
      expect(entry.meaning, 'The Most Merciful');
      expect(entry.root, 'رحم');
    });

    test('parses asbaab entries from a map', () {
      final entry = AsbaabEntry.fromMap(const {
        'text': 'سبب النزول',
        'source': 'الواحدي',
        'narrator': 'ابن عباس',
      });

      expect(entry.text, 'سبب النزول');
      expect(entry.source, 'الواحدي');
      expect(entry.narrator, 'ابن عباس');
    });

    test('parses related ayah entries from a map', () {
      final entry = RelatedAyahEntry.fromMap(const {
        'surah': 3,
        'ayah': 18,
        'tag': 'thematic',
        'snippet': 'شهد الله',
      });

      expect(entry.surahNumber, 3);
      expect(entry.ayahNumber, 18);
      expect(entry.tag, 'thematic');
      expect(entry.snippet, 'شهد الله');
    });
  });
}

String _describeState(InsightSectionData state) {
  return switch (state) {
    InsightSectionLoaded<String>(content: final content) => 'loaded:$content',
    InsightSectionUnavailable() => 'unavailable',
    InsightSectionError(error: final error) => 'error:${error.message}',
    _ => 'unknown',
  };
}

extension on Object {
  String get message {
    if (this case StateError(:final message)) {
      return message;
    }

    return toString();
  }
}
