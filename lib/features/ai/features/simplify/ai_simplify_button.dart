import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';

class AiSimplifyButton extends ConsumerWidget {
  const AiSimplifyButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(aiAvailableProvider);
    if (!isAvailable) {
      return const SizedBox.shrink();
    }

    final quotaAsync = ref.watch(aiQuotaExhaustedProvider);
    final isDisabled = quotaAsync.maybeWhen(
      data: (value) => value,
      orElse: () => true,
    );

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FilledButton.icon(
        key: const Key('ai-simplify-button'),
        onPressed: isDisabled ? null : onPressed,
        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
        label: Text(context.l10n.simplifyTafsir),
      ),
    );
  }
}
