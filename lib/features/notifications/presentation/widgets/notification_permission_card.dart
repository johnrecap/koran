import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

class NotificationPermissionCard extends StatelessWidget {
  const NotificationPermissionCard({
    super.key,
    required this.title,
    required this.message,
    required this.ctaLabel,
    required this.showAction,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String ctaLabel;
  final bool showAction;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF23352A),
                  Color(0xFF18271F),
                ]
              : const [
                  Color(0xFFF6F1DA),
                  Color(0xFFF2E8BF),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.26),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                height: 1.5,
                color: isDark ? Colors.white70 : AppColors.textMuted,
              ),
            ),
            if (showAction) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onPressed,
                child: Text(ctaLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
