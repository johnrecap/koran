import 'package:flutter/foundation.dart';
import 'package:quran_kareem/features/premium/data/revenuecat_purchases_service.dart';
import 'package:quran_kareem/features/premium/data/unsupported_premium_purchases_service.dart';
import 'package:quran_kareem/features/premium/domain/premium_billing_config.dart';
import 'package:quran_kareem/features/premium/domain/premium_entitlement_snapshot.dart';
import 'package:quran_kareem/features/premium/domain/premium_product_descriptor.dart';

abstract interface class PremiumPurchasesService {
  Future<void> initialize();
  Future<PremiumEntitlementSnapshot> loadSnapshot();
  Future<PremiumProductDescriptor?> loadProductDescriptor();
  Future<PremiumEntitlementSnapshot> purchasePremium();
  Future<PremiumEntitlementSnapshot> restorePurchases();
}

PremiumPurchasesService createDefaultPremiumPurchasesService() {
  if (kIsWeb) {
    return const UnsupportedPremiumPurchasesService();
  }

  final sdkKey = switch (defaultTargetPlatform) {
    TargetPlatform.android => PremiumBillingConfig.androidPublicSdkKey,
    TargetPlatform.iOS => PremiumBillingConfig.iosPublicSdkKey,
    _ => '',
  };
  if (sdkKey.isEmpty) {
    return const UnsupportedPremiumPurchasesService();
  }

  return RevenueCatPremiumPurchasesService(publicSdkKey: sdkKey);
}
