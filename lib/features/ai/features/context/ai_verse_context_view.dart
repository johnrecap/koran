import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/domain/verse_identifier.dart';
import 'package:quran_kareem/features/ai/features/context/verse_context_provider.dart';
import 'package:quran_kareem/features/ai/widgets/ai_disclaimer_banner.dart';
import 'package:quran_kareem/features/ai/widgets/ai_error_view.dart';
import 'package:quran_kareem/features/ai/widgets/ai_loading_shimmer.dart';

class AiVerseContextView extends ConsumerWidget {
  const AiVerseContextView({
    super.key,
    required this.verse,
  });

  final VerseIdentifier verse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(verseContextProvider(verse));

    return contextAsync.when(
      loading: () => AiLoadingShimmer(
        label: context.l10n.loadingContext,
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
          ref.invalidate(verseContextProvider(verse));
        },
      ),
      data: (response) => Container(
        key: const Key('ai-verse-context-view'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark.withValues(alpha: 0.74)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              response.text.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.8,
                  ),
            ),
            const SizedBox(height: 12),
            const AiDisclaimerBanner(),
          ],
        ),
      ),
    );
  }
}
