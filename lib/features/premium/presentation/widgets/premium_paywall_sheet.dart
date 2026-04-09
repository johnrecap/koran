import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/premium/domain/paywall_entry_context.dart';
import 'package:quran_kareem/features/premium/domain/premium_entitlement_snapshot.dart';
import 'package:quran_kareem/features/premium/providers/premium_providers.dart';

class PremiumPaywallSheet extends ConsumerStatefulWidget {
  const PremiumPaywallSheet({
    super.key,
    required this.contextInfo,
    this.autoCloseOnUnlock = false,
  });

  final PaywallEntryContext contextInfo;
  final bool autoCloseOnUnlock;

  @override
  ConsumerState<PremiumPaywallSheet> createState() => _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends ConsumerState<PremiumPaywallSheet> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final snapshot = ref.watch(premiumEntitlementControllerProvider);
    final productAsync = ref.watch(premiumProductDescriptorProvider);
    final product = productAsync.valueOrNull;
    final title = product?.title ?? l10n.premiumAyahShareCardsTitle;
    final subtitle =
        product?.subtitle ?? l10n.premiumAyahShareCardsSubtitle;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.72),
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  _contextualBody(l10n),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!snapshot.billingAvailable) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.premiumBillingUnavailable,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('premium-paywall-purchase'),
                  onPressed: _isBusy || !snapshot.billingAvailable
                      ? null
                      : _handlePurchase,
                  child: Text(
                    _isBusy
                        ? l10n.premiumPaywallWorking
                        : l10n.premiumPaywallPurchaseAction,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('premium-paywall-restore'),
                  onPressed: _isBusy || !snapshot.billingAvailable
                      ? null
                      : _handleRestore,
                  child: Text(l10n.premiumPaywallRestoreAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _contextualBody(AppLocalizations l10n) {
    return switch (widget.contextInfo.kind) {
      PaywallEntryKind.lockedAyahShareTemplate =>
        l10n.premiumAyahShareCardsLockedTemplateBody,
    };
  }

  Future<void> _handlePurchase() async {
    if (_isBusy) {
      return;
    }
    setState(() {
      _isBusy = true;
    });
    final snapshot = await ref
        .read(premiumEntitlementControllerProvider.notifier)
        .purchasePremium();
    if (!mounted) {
      return;
    }
    setState(() {
      _isBusy = false;
    });
    _maybeClose(snapshot);
  }

  Future<void> _handleRestore() async {
    if (_isBusy) {
      return;
    }
    setState(() {
      _isBusy = true;
    });
    final snapshot = await ref
        .read(premiumEntitlementControllerProvider.notifier)
        .restorePurchases();
    if (!mounted) {
      return;
    }
    setState(() {
      _isBusy = false;
    });
    _maybeClose(snapshot);
  }

  void _maybeClose(PremiumEntitlementSnapshot snapshot) {
    if (!widget.autoCloseOnUnlock) {
      return;
    }
    if (snapshot.hasAccess(widget.contextInfo.requiredAccessKey)) {
      Navigator.of(context).pop(true);
    }
  }
}
