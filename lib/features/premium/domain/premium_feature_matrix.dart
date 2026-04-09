import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';

abstract final class PremiumFeatureMatrix {
  static const freeAyahShareTemplateIds = <String>[
    'photo-1',
    'photo-2',
    'photo-3',
  ];

  static const premiumAyahShareTemplateIds = <String>[
    'photo-4',
    'photo-5',
    'photo-6',
    'photo-7',
    'photo-8',
    'photo-9',
    'photo-10',
  ];

  static PremiumAccessKey? accessForAyahShareTemplate(String templateId) {
    if (premiumAyahShareTemplateIds.contains(templateId)) {
      return PremiumAccessKey.ayahShareCardsPremiumTemplates;
    }
    return null;
  }
}
