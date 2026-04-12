import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/features/simplify/tafsir_simplify_provider.dart';
import 'package:quran_kareem/features/ai/widgets/ai_disclaimer_banner.dart';
import 'package:quran_kareem/features/ai/widgets/ai_error_view.dart';
import 'package:quran_kareem/features/ai/widgets/ai_loading_shimmer.dart';
import 'package:quran_kareem/features/ai/widgets/ai_quota_indicator.dart';

class AiSimplifiedView extends ConsumerWidget {
  const AiSimplifiedView({
    super.key,
    required this.request,
    this.onRetry,
  });

  final TafsirSimplifyRequest request;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_normalizedLength(request.tafsirText) < 50) {
      return _InfoCard(
        text: context.l10n.tafsirAlreadyShort,
      );
    }

    final responseAsync = ref.watch(tafsirSimplifyProvider(request));
    return responseAsync.when(
      loading: () => AiLoadingShimmer(
        label: context.l10n.simplifying,
      ),
      error: (error, _) => AiErrorView(
        exception: error is AiServiceException
            ? error
            : AiProviderException(
                message: error.toString(),
                provider: 'unknown',
                originalError: error,
              ),
        onRetry: () {
          ref.invalidate(tafsirSimplifyProvider(request));
          onRetry?.call();
        },
      ),
      data: (response) => Container(
        key: const Key('ai-simplified-view'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark.withValues(alpha: 0.74)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.simplifiedSummary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              response.text.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.8,
                  ),
            ),
            const SizedBox(height: 14),
            const AiQuotaIndicator(),
            const SizedBox(height: 12),
            const AiDisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  int _normalizedLength(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim().length;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ai-simplified-info-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.camel.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
      ),
    );
  }
}
