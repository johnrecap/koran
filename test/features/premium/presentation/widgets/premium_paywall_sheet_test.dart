import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/premium/data/premium_purchases_service.dart';
import 'package:quran_kareem/features/premium/domain/paywall_entry_context.dart';
import 'package:quran_kareem/features/premium/domain/premium_entitlement_snapshot.dart';
import 'package:quran_kareem/features/premium/domain/premium_product_descriptor.dart';
import 'package:quran_kareem/features/premium/presentation/widgets/premium_paywall_sheet.dart';
import 'package:quran_kareem/features/premium/providers/premium_providers.dart';

void main() {
  testWidgets('shows the live premium product and triggers purchase and restore',
      (tester) async {
    final service = _RecordingPremiumPurchasesService();

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          premiumPurchasesServiceProvider.overrideWithValue(service),
        ],
        child: const PremiumPaywallSheet(
          contextInfo: PaywallEntryContext.lockedAyahShareTemplate(
            templateId: 'photo-7',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ayah Share Cards Pro'), findsOneWidget);
    expect(find.text('Unlock premium templates'), findsOneWidget);

    await tester.tap(find.byKey(const Key('premium-paywall-purchase')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('premium-paywall-restore')));
    await tester.pumpAndSettle();

    expect(service.purchaseCallCount, 1);
    expect(service.restoreCallCount, 1);
  });
}

Widget _buildHarness({
  required Widget child,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    ),
  );
}

class _RecordingPremiumPurchasesService implements PremiumPurchasesService {
  int purchaseCallCount = 0;
  int restoreCallCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<PremiumProductDescriptor?> loadProductDescriptor() async {
    return const PremiumProductDescriptor(
      title: 'Ayah Share Cards Pro',
      subtitle: 'Unlock premium templates',
      packageId: 'ayah_cards_pro_monthly',
    );
  }

  @override
  Future<PremiumEntitlementSnapshot> loadSnapshot() async {
    return const PremiumEntitlementSnapshot.free();
  }

  @override
  Future<PremiumEntitlementSnapshot> purchasePremium() async {
    purchaseCallCount += 1;
    return const PremiumEntitlementSnapshot.premium();
  }

  @override
  Future<PremiumEntitlementSnapshot> restorePurchases() async {
    restoreCallCount += 1;
    return const PremiumEntitlementSnapshot.premium();
  }
}
