import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';

class AiDisclaimerBanner extends StatelessWidget {
  const AiDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const Key('ai-disclaimer-banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.camel.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.aiDisclaimerFull,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
