import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';

class AiQuotaIndicator extends ConsumerWidget {
  const AiQuotaIndicator({
    super.key,
    this.totalQuota = 20,
  });

  final int totalQuota;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingAsync = ref.watch(aiQuotaRemainingProvider);

    return remainingAsync.when(
      data: (remaining) {
        final colors = _colorsFor(remaining);
        return Container(
          key: const Key('ai-quota-indicator'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            context.l10n.aiQuotaRemainingFormat(
              remaining.toString(),
              totalQuota.toString(),
            ),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  _QuotaColors _colorsFor(int remaining) {
    if (remaining < 5) {
      return _QuotaColors(
        foreground: AppColors.error,
        background: AppColors.error.withValues(alpha: 0.14),
      );
    }
    if (remaining <= 10) {
      return _QuotaColors(
        foreground: AppColors.gold,
        background: AppColors.gold.withValues(alpha: 0.14),
      );
    }
    return _QuotaColors(
      foreground: AppColors.success,
      background: AppColors.success.withValues(alpha: 0.14),
    );
  }
}

class _QuotaColors {
  const _QuotaColors({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
