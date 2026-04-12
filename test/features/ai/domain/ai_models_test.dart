import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/ai/domain/ai_response.dart';
import 'package:quran_kareem/features/ai/domain/ai_search_result.dart';
import 'package:quran_kareem/features/ai/domain/verse_identifier.dart';

void main() {
  group('AiResponse', () {
    test('fromRaw populates fields correctly', () {
      final before = DateTime.now();

      final response = AiResponse.fromRaw(
        'Simplified tafsir',
        'gemini',
        482,
      );

      expect(response.text, 'Simplified tafsir');
      expect(response.providerName, 'gemini');
      expect(response.latencyMs, 482);
      expect(response.inputTokens, isNull);
      expect(response.outputTokens, isNull);
      expect(
        response.timestamp.isAfter(before) ||
            response.timestamp.isAtSameMomentAs(before),
        isTrue,
      );
    });

    test('isEmpty returns true for blank text', () {
      final response = AiResponse(
        text: '   ',
        latencyMs: 12,
        providerName: 'groq',
        timestamp: DateTime(2026, 4, 11),
      );

      expect(response.isEmpty, isTrue);
    });
  });

  group('AiSearchResult', () {
    test('fromJson parses known fields correctly', () {
      final result = AiSearchResult.fromJson(<String, dynamic>{
        'surah': 2,
        'ayah': 255,
        'verse_text': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
        'context': 'Verse about tawhid.',
        'relevance_score': 0.91,
      });

      expect(result.surah, 2);
      expect(result.ayah, 255);
      expect(result.verseTextAr, 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ');
      expect(result.contextNote, 'Verse about tawhid.');
      expect(result.relevanceScore, 0.91);
    });

    test('parseResults extracts structured json arrays', () {
      final results = AiSearchResult.parseResults(
        '''
        [
          {
            "surah": 2,
            "ayah": 153,
            "verse_text": "يَا أَيُّهَا الَّذِينَ آمَنُوا",
            "context": "Calls believers to seek help through patience and prayer."
          },
          {
            "surah": 39,
            "ayah": 10,
            "verse_text": "إِنَّمَا يُوَفَّى الصَّابِرُونَ",
            "context": "Highlights the reward of patience."
          }
        ]
        ''',
      );

      expect(results, hasLength(2));
      expect(results.first.surah, 2);
      expect(results.last.ayah, 10);
    });

    test('parseResults falls back to regex extraction on malformed json', () {
      final results = AiSearchResult.parseResults(
        '''
        1) surah: 12, ayah: 87, verse_text: "ولا تيأسوا من روح الله", context: "Encourages hope."
        2) surah: 94, ayah: 6, verse_text: "إن مع العسر يسرا", context: "Relief follows hardship."
        ''',
      );

      expect(results, hasLength(2));
      expect(results.first.surah, 12);
      expect(results.last.ayah, 6);
    });
  });

  group('VerseIdentifier', () {
    test('supports value equality and stable formatting', () {
      const left = VerseIdentifier(surah: 18, ayah: 10);
      const right = VerseIdentifier(surah: 18, ayah: 10);
      const other = VerseIdentifier(surah: 18, ayah: 11);

      expect(left, right);
      expect(left.hashCode, right.hashCode);
      expect(left, isNot(other));
      expect(left.toString(), '18:10');
    });
  });
}
