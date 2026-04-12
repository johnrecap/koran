import 'package:flutter/foundation.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';

@immutable
class PremiumEntitlementSnapshot {
  const PremiumEntitlementSnapshot({
    required this.billingAvailable,
    required Set<PremiumAccessKey> grantedAccesses,
  }) : _grantedAccesses = grantedAccesses;

  const PremiumEntitlementSnapshot.free()
      : billingAvailable = true,
        _grantedAccesses = const <PremiumAccessKey>{};

  const PremiumEntitlementSnapshot.premium()
      : billingAvailable = true,
        _grantedAccesses = const <PremiumAccessKey>{
          PremiumAccessKey.ayahShareCardsPremiumTemplates,
          PremiumAccessKey.aiFeatures,
        };

  const PremiumEntitlementSnapshot.unavailable()
      : billingAvailable = false,
        _grantedAccesses = const <PremiumAccessKey>{};

  final bool billingAvailable;
  final Set<PremiumAccessKey> _grantedAccesses;

  bool hasAccess(PremiumAccessKey accessKey) {
    return _grantedAccesses.contains(accessKey);
  }

  Set<PremiumAccessKey> get grantedAccesses =>
      Set<PremiumAccessKey>.unmodifiable(_grantedAccesses);

  @override
  bool operator ==(Object other) {
    return other is PremiumEntitlementSnapshot &&
        other.billingAvailable == billingAvailable &&
        setEquals(other._grantedAccesses, _grantedAccesses);
  }

  @override
  int get hashCode => Object.hash(
        billingAvailable,
        Object.hashAll(_grantedAccesses),
      );
}
