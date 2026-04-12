import 'package:flutter/services.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:quran_kareem/features/premium/data/premium_purchases_service.dart';
import 'package:quran_kareem/features/premium/domain/premium_access_key.dart';
import 'package:quran_kareem/features/premium/domain/premium_billing_config.dart';
import 'package:quran_kareem/features/premium/domain/premium_entitlement_snapshot.dart';
import 'package:quran_kareem/features/premium/domain/premium_product_descriptor.dart';

class RevenueCatPremiumPurchasesService implements PremiumPurchasesService {
  const RevenueCatPremiumPurchasesService({
    required this.publicSdkKey,
  });

  static bool _didConfigure = false;

  final String publicSdkKey;

  @override
  Future<void> initialize() async {
    if (publicSdkKey.isEmpty || _didConfigure) {
      return;
    }
    await Purchases.configure(PurchasesConfiguration(publicSdkKey));
    _didConfigure = true;
  }

  @override
  Future<PremiumProductDescriptor?> loadProductDescriptor() async {
    try {
      final package = await _loadPackage();
      if (package == null) {
        return null;
      }
      return PremiumProductDescriptor(
        title: package.storeProduct.title,
        subtitle: package.storeProduct.description,
        packageId: package.identifier,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'RevenueCatPremiumPurchasesService.loadProductDescriptor',
        error,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Future<PremiumEntitlementSnapshot> loadSnapshot() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _snapshotFromCustomerInfo(customerInfo);
    } catch (error, stackTrace) {
      AppLogger.error(
        'RevenueCatPremiumPurchasesService.loadSnapshot',
        error,
        stackTrace,
      );
      return const PremiumEntitlementSnapshot.unavailable();
    }
  }

  @override
  Future<PremiumEntitlementSnapshot> purchasePremium() async {
    try {
      final package = await _loadPackage();
      if (package == null) {
        return const PremiumEntitlementSnapshot.unavailable();
      }
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      return _snapshotFromCustomerInfo(purchaseResult.customerInfo);
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error(
        'RevenueCatPremiumPurchasesService.purchasePremium.platform',
        error,
        stackTrace,
      );
      return loadSnapshot();
    } catch (error, stackTrace) {
      AppLogger.error(
        'RevenueCatPremiumPurchasesService.purchasePremium',
        error,
        stackTrace,
      );
      return loadSnapshot();
    }
  }

  @override
  Future<PremiumEntitlementSnapshot> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _snapshotFromCustomerInfo(customerInfo);
    } catch (error, stackTrace) {
      AppLogger.error(
        'RevenueCatPremiumPurchasesService.restorePurchases',
        error,
        stackTrace,
      );
      return loadSnapshot();
    }
  }

  Future<Package?> _loadPackage() async {
    final offerings = await Purchases.getOfferings();
    final offering =
        offerings.all[PremiumBillingConfig.offeringId] ?? offerings.current;
    if (offering == null) {
      return null;
    }

    for (final package in offering.availablePackages) {
      if (package.identifier == PremiumBillingConfig.packageId ||
          package.storeProduct.identifier == PremiumBillingConfig.productId) {
        return package;
      }
    }

    return offering.availablePackages.isEmpty
        ? null
        : offering.availablePackages.first;
  }

  PremiumEntitlementSnapshot _snapshotFromCustomerInfo(CustomerInfo info) {
    final isUnlocked = info.entitlements.active.containsKey(
      PremiumBillingConfig.entitlementId,
    );
    if (!isUnlocked) {
      return const PremiumEntitlementSnapshot.free();
    }

    return const PremiumEntitlementSnapshot(
      billingAvailable: true,
      grantedAccesses: <PremiumAccessKey>{
        PremiumAccessKey.ayahShareCardsPremiumTemplates,
        PremiumAccessKey.aiFeatures,
      },
    );
  }
}
