import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';
import 'package:quran_kareem/features/premium/domain/premium_feature_matrix.dart';

void main() {
  group('PremiumFeatureMatrix', () {
    test('keeps the first three ayah-share templates free', () {
      expect(
        PremiumFeatureMatrix.freeAyahShareTemplateIds,
        const <String>['photo-1', 'photo-2', 'photo-3'],
      );
      expect(
        PremiumFeatureMatrix.accessForAyahShareTemplate('photo-1'),
        isNull,
      );
      expect(
        PremiumFeatureMatrix.accessForAyahShareTemplate('photo-2'),
        isNull,
      );
      expect(
        PremiumFeatureMatrix.accessForAyahShareTemplate('photo-3'),
        isNull,
      );
    });

    test('requires premium access for photo 4 through photo 10', () {
      expect(
        PremiumFeatureMatrix.premiumAyahShareTemplateIds,
        const <String>[
          'photo-4',
          'photo-5',
          'photo-6',
          'photo-7',
          'photo-8',
          'photo-9',
          'photo-10',
        ],
      );

      for (final templateId in PremiumFeatureMatrix.premiumAyahShareTemplateIds) {
        expect(
          PremiumFeatureMatrix.accessForAyahShareTemplate(templateId),
          PremiumAccessKey.ayahShareCardsPremiumTemplates,
        );
      }
    });
  });
}
