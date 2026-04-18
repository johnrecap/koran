import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/services/app_bootstrap_service.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/premium/data/premium_purchases_service.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';
import 'package:quran_kareem/features/premium/domain/premium_entitlement_snapshot.dart';
import 'package:quran_kareem/features/premium/domain/premium_product_descriptor.dart';

final premiumPurchasesServiceProvider =
    Provider<PremiumPurchasesService>((ref) {
  final bootstrap = AppBootstrapService.instance;
  if (bootstrap.isInitialized) {
    return bootstrap.premiumPurchasesService;
  }
  return createDefaultPremiumPurchasesService();
});

final premiumEntitlementControllerProvider =
    NotifierProvider<PremiumEntitlementController, PremiumEntitlementSnapshot>(
  PremiumEntitlementController.new,
);

final premiumProductDescriptorProvider =
    FutureProvider<PremiumProductDescriptor?>((ref) async {
  await ref.read(premiumEntitlementControllerProvider.notifier).ready;
  return ref.read(premiumPurchasesServiceProvider).loadProductDescriptor();
});

final hasPremiumAccessProvider =
    Provider.family<bool, PremiumAccessKey>((ref, accessKey) {
  final snapshot = ref.watch(premiumEntitlementControllerProvider);
  return snapshot.hasAccess(accessKey);
});

class PremiumEntitlementController
    extends Notifier<PremiumEntitlementSnapshot> {
  late final Future<void> _ready;

  Future<void> get ready => _ready;

  @override
  PremiumEntitlementSnapshot build() {
    _ready = _load();
    return const PremiumEntitlementSnapshot.unavailable();
  }

  Future<void> refresh() async {
    state = await ref.read(premiumPurchasesServiceProvider).loadSnapshot();
  }

  Future<PremiumEntitlementSnapshot> purchasePremium() async {
    final snapshot =
        await ref.read(premiumPurchasesServiceProvider).purchasePremium();
    state = snapshot;
    ref.invalidate(premiumProductDescriptorProvider);
    return snapshot;
  }

  Future<PremiumEntitlementSnapshot> restorePurchases() async {
    final snapshot =
        await ref.read(premiumPurchasesServiceProvider).restorePurchases();
    state = snapshot;
    ref.invalidate(premiumProductDescriptorProvider);
    return snapshot;
  }

  Future<void> _load() async {
    try {
      await ref.read(premiumPurchasesServiceProvider).initialize();
      await refresh();
    } catch (error, stackTrace) {
      AppLogger.error('PremiumEntitlementController._load', error, stackTrace);
      state = const PremiumEntitlementSnapshot.unavailable();
    }
  }
}
