import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_template.dart';

void main() {
  group('AyahShareCardTemplateCatalog', () {
    test('exposes 10 placeholder templates with positive layout metadata', () {
      const templates = AyahShareCardTemplateCatalog.defaults;

      expect(templates.length, 10);
      expect(templates.map((template) => template.id).toSet().length,
          templates.length);
      expect(
        templates.map((template) => template.assetPath),
        List<String>.generate(
          10,
          (index) => 'assets/images/photo ${index + 1}.png',
        ),
      );
      expect(
        templates.every(
          (template) =>
              template.assetPath.startsWith('assets/images/') &&
              template.aspectRatio > 0 &&
              template.ayahSlot.maxLines > 0 &&
              template.referenceSlot.maxLines > 0,
        ),
        isTrue,
      );

      expect(
        templates.take(3).every((template) => template.isPremium == false),
        isTrue,
      );
      expect(
        templates
            .skip(3)
            .every((template) => template.requiredAccessKey ==
                PremiumAccessKey.ayahShareCardsPremiumTemplates),
        isTrue,
      );
    });
  });
}
