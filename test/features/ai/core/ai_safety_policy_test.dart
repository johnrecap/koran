import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/ai/core/ai_safety_policy.dart';

void main() {
  group('AiSafetyPolicy', () {
    const policy = AiSafetyPolicy();

    test('system prompt includes core safety rules for each feature type', () {
      for (final feature in AiFeatureType.values) {
        final prompt = policy.buildSystemPrompt(feature);

        expect(prompt, contains('لا تصدر فتاوى'));
        expect(prompt, contains('المحتوى القرآني'));
        expect(prompt, contains('3-5 جمل'));
        expect(prompt, contains(_featureSnippet(feature)));
      }
    });

    test('validateResponse rejects fatwa-like content', () {
      expect(
        policy.validateResponse(
            'الحكم الشرعي في هذا الأمر واجب، وهذه فتوى مباشرة.'),
        isFalse,
      );
    });

    test('validateResponse accepts normal tafsir summary', () {
      expect(
        policy.validateResponse(
          'توضح الآية أن الصبر والاستعانة بالله طريق الثبات، مع تذكير المؤمن بالصلاة واليقين.',
        ),
        isTrue,
      );
    });

    test('disclaimer text is non-empty', () {
      expect(policy.disclaimerText.trim(), isNotEmpty);
    });
  });
}

String _featureSnippet(AiFeatureType feature) {
  return switch (feature) {
    AiFeatureType.simplifyTafsir => 'بسّط النص التالي',
    AiFeatureType.semanticSearch => 'ابحث في القرآن',
    AiFeatureType.verseContext => 'اشرح العلاقة',
    AiFeatureType.tadabburQuestions => 'اكتب 3 أسئلة',
    AiFeatureType.juzSummary => 'لخّص الموضوعات',
  };
}
