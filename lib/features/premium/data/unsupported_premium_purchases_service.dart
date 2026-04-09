import 'package:quran_kareem/features/premium/data/premium_purchases_service.dart';
import 'package:quran_kareem/features/premium/domain/premium_entitlement_snapshot.dart';
import 'package:quran_kareem/features/premium/domain/premium_product_descriptor.dart';

class UnsupportedPremiumPurchasesService implements PremiumPurchasesService {
  const UnsupportedPremiumPurchasesService();

  @override
  Future<void> initialize() async {}

  @override
  Future<PremiumProductDescriptor?> loadProductDescriptor() async => null;

  @override
  Future<PremiumEntitlementSnapshot> loadSnapshot() async {
    return const PremiumEntitlementSnapshot.unavailable();
  }

  @override
  Future<PremiumEntitlementSnapshot> purchasePremium() async {
    return const PremiumEntitlementSnapshot.unavailable();
  }

  @override
  Future<PremiumEntitlementSnapshot> restorePurchases() async {
    return const PremiumEntitlementSnapshot.unavailable();
  }
}
