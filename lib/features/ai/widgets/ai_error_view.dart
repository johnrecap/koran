import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/premium/domain/paywall_entry_context.dart';
import 'package:quran_kareem/features/premium/presentation/widgets/premium_paywall_sheet.dart';

class AiErrorView extends ConsumerWidget {
  const AiErrorView({
    super.key,
    required this.exception,
    this.onRetry,
  });

  final AiServiceException exception;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = _presentationFor(context.l10n, exception);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canRetry = presentation.canRetry && onRetry != null;
    final showUpgrade = exception is AiQuotaExceededException;

    return Container(
      key: const Key('ai-error-view'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: presentation.color.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            presentation.icon,
            color: presentation.color,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            presentation.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          if (canRetry) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              key: const Key('ai-error-retry'),
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: presentation.color,
                side: BorderSide(
                    color: presentation.color.withValues(alpha: 0.4)),
              ),
              child: Text(context.l10n.aiRetry),
            ),
          ],
          if (showUpgrade) ...[
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('ai-error-upgrade'),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const PremiumPaywallSheet(
                    contextInfo: PaywallEntryContext.aiFeaturesQuotaExceeded(),
                    autoCloseOnUnlock: true,
                  ),
                );
              },
              child: Text(context.l10n.upgradeForUnlimitedAi),
            ),
          ],
        ],
      ),
    );
  }

  _AiErrorPresentation _presentationFor(
    AppLocalizations l10n,
    AiServiceException error,
  ) {
    if (error is AiOfflineException) {
      return _AiErrorPresentation(
        message: l10n.aiOffline,
        icon: Icons.wifi_off_rounded,
        color: AppColors.warmBrown,
      );
    }
    if (error is AiTimeoutException) {
      return _AiErrorPresentation(
        message: l10n.aiTimeout,
        icon: Icons.hourglass_bottom_rounded,
        color: AppColors.gold,
        canRetry: true,
      );
    }
    if (error is AiQuotaExceededException) {
      return _AiErrorPresentation(
        message: l10n.aiQuotaExhausted,
        icon: Icons.block_rounded,
        color: AppColors.error,
      );
    }
    if (error is AiSafetyException) {
      return _AiErrorPresentation(
        message: l10n.aiSafetyBlocked,
        icon: Icons.shield_outlined,
        color: AppColors.warmBrown,
      );
    }
    if (error is AiProviderException && _isNetworkError(error)) {
      return _AiErrorPresentation(
        message: l10n.aiOffline,
        icon: Icons.wifi_off_rounded,
        color: AppColors.warmBrown,
      );
    }

    return _AiErrorPresentation(
      message: l10n.aiProviderError,
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
      canRetry: true,
    );
  }

  bool _isNetworkError(AiProviderException error) {
    final originalError = error.originalError;
    if (originalError is SocketException || originalError is HttpException) {
      return true;
    }

    final combined = '${error.message} ${error.originalError ?? ''}'
        .toLowerCase();
    return combined.contains('failed host lookup') ||
        combined.contains('socketexception') ||
        combined.contains('connection refused') ||
        combined.contains('connection reset') ||
        combined.contains('network is unreachable');
  }
}

class _AiErrorPresentation {
  const _AiErrorPresentation({
    required this.message,
    required this.icon,
    required this.color,
    this.canRetry = false,
  });

  final String message;
  final IconData icon;
  final Color color;
  final bool canRetry;
}
