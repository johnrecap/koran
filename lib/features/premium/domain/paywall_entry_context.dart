import 'package:flutter/foundation.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';

enum PaywallEntryKind {
  lockedAyahShareTemplate,
  aiFeaturesQuotaExceeded,
}

@immutable
class PaywallEntryContext {
  const PaywallEntryContext._({
    required this.kind,
    required this.requiredAccessKey,
    this.templateId,
  });

  const PaywallEntryContext.lockedAyahShareTemplate({
    required String templateId,
  }) : this._(
          kind: PaywallEntryKind.lockedAyahShareTemplate,
          requiredAccessKey: PremiumAccessKey.ayahShareCardsPremiumTemplates,
          templateId: templateId,
        );

  const PaywallEntryContext.aiFeaturesQuotaExceeded()
      : this._(
          kind: PaywallEntryKind.aiFeaturesQuotaExceeded,
          requiredAccessKey: PremiumAccessKey.aiFeatures,
        );

  final PaywallEntryKind kind;
  final PremiumAccessKey requiredAccessKey;
  final String? templateId;
}
