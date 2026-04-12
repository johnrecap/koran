import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/premium/data/premium_purchases_service.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';
import 'package:quran_kareem/features/premium/domain/premium_entitlement_snapshot.dart';
import 'package:quran_kareem/features/premium/domain/premium_product_descriptor.dart';
import 'package:quran_kareem/features/premium/providers/premium_providers.dart';

void main() {
  test('purchase refreshes entitlement snapshot and unlocks premium access',
      () async {
    final service = _FakePremiumPurchasesService(
      snapshot: const PremiumEntitlementSnapshot.free(),
      product: const PremiumProductDescriptor(
        title: 'Ayah Share Cards Pro',
        subtitle: 'Unlock premium templates',
        packageId: 'ayah_cards_pro_monthly',
      ),
      purchasedSnapshot: const PremiumEntitlementSnapshot.premium(),
    );
    final container = ProviderContainer(
      overrides: [
        premiumPurchasesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(premiumEntitlementControllerProvider.notifier);
    await controller.ready;

    expect(
      container.read(hasPremiumAccessProvider(PremiumAccessKey.ayahShareCardsPremiumTemplates)),
      isFalse,
    );

    await controller.purchasePremium();

    expect(
      container.read(hasPremiumAccessProvider(PremiumAccessKey.ayahShareCardsPremiumTemplates)),
      isTrue,
    );
    expect(
      container.read(hasPremiumAccessProvider(PremiumAccessKey.aiFeatures)),
      isTrue,
    );
  });

  test('unsupported purchases service fails safe and keeps premium access off',
      () async {
    final service = _FakePremiumPurchasesService(
      snapshot: const PremiumEntitlementSnapshot.unavailable(),
      product: null,
    );
    final container = ProviderContainer(
      overrides: [
        premiumPurchasesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(premiumEntitlementControllerProvider.notifier).ready;

    expect(
      container.read(hasPremiumAccessProvider(PremiumAccessKey.ayahShareCardsPremiumTemplates)),
      isFalse,
    );
    expect(
      container.read(premiumEntitlementControllerProvider).billingAvailable,
      isFalse,
    );
  });

  test('restore refreshes entitlement snapshot and unlocks premium access',
      () async {
    final service = _FakePremiumPurchasesService(
      snapshot: const PremiumEntitlementSnapshot.free(),
      product: const PremiumProductDescriptor(
        title: 'Ayah Share Cards Pro',
        subtitle: 'Unlock premium templates',
        packageId: 'ayah_cards_pro_monthly',
      ),
      restoredSnapshot: const PremiumEntitlementSnapshot.premium(),
    );
    final container = ProviderContainer(
      overrides: [
        premiumPurchasesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    final controller =
        container.read(premiumEntitlementControllerProvider.notifier);
    await controller.ready;
    await controller.restorePurchases();

    expect(
      container.read(hasPremiumAccessProvider(
        PremiumAccessKey.ayahShareCardsPremiumTemplates,
      )),
      isTrue,
    );
    expect(
      container.read(hasPremiumAccessProvider(PremiumAccessKey.aiFeatures)),
      isTrue,
    );
  });
}

class _FakePremiumPurchasesService implements PremiumPurchasesService {
  _FakePremiumPurchasesService({
    required this.snapshot,
    required this.product,
    this.purchasedSnapshot,
    this.restoredSnapshot,
  });

  PremiumEntitlementSnapshot snapshot;
  final PremiumProductDescriptor? product;
  final PremiumEntitlementSnapshot? purchasedSnapshot;
  final PremiumEntitlementSnapshot? restoredSnapshot;

  @override
  Future<PremiumProductDescriptor?> loadProductDescriptor() async => product;

  @override
  Future<PremiumEntitlementSnapshot> loadSnapshot() async => snapshot;

  @override
  Future<void> initialize() async {}

  @override
  Future<PremiumEntitlementSnapshot> purchasePremium() async {
    snapshot = purchasedSnapshot ?? snapshot;
    return snapshot;
  }

  @override
  Future<PremiumEntitlementSnapshot> restorePurchases() async {
    snapshot = restoredSnapshot ?? snapshot;
    return snapshot;
  }
}
