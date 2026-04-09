import 'package:flutter/material.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';

class TafsirBrowserNavigationBar extends StatelessWidget {
  const TafsirBrowserNavigationBar({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: canGoPrevious ? onPrevious : null,
            child: Text(context.l10n.tafsirBrowserPrevious),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: canGoNext ? onNext : null,
            child: Text(context.l10n.tafsirBrowserNext),
          ),
        ),
      ],
    );
  }
}
