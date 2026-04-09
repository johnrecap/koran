import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

enum QuizAnswerChoiceState {
  idle,
  correct,
  incorrect,
  revealed,
}

class QuizAnswerChoice extends StatelessWidget {
  const QuizAnswerChoice({
    super.key,
    required this.choiceIndex,
    required this.label,
    required this.state,
    required this.isLocked,
    this.onTap,
  });

  final int choiceIndex;
  final String label;
  final QuizAnswerChoiceState state;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _paletteFor(
      state: state,
      isDark: isDark,
      isLocked: isLocked,
    );
    final letter = String.fromCharCode(65 + choiceIndex);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isLocked && state == QuizAnswerChoiceState.idle ? 0.78 : 1,
      child: AnimatedContainer(
        key: Key('quiz-answer-choice-$choiceIndex'),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: palette.fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: palette.borderColor,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: palette.borderColor.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isLocked ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: palette.badgeTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.textColor,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    palette.icon,
                    color: palette.iconColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _QuizAnswerChoicePalette _paletteFor({
    required QuizAnswerChoiceState state,
    required bool isDark,
    required bool isLocked,
  }) {
    final baseFill = isDark ? AppColors.surfaceDarkNav : Colors.white;
    final baseBorder = AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.18);
    final baseText = isDark ? AppColors.textDark : AppColors.textLight;

    return switch (state) {
      QuizAnswerChoiceState.idle => _QuizAnswerChoicePalette(
          fillColor: baseFill,
          borderColor: baseBorder,
          textColor: baseText,
          badgeColor: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.surfaceLight,
          badgeTextColor: baseText,
          icon: Icons.radio_button_unchecked_rounded,
          iconColor: isLocked ? AppColors.textMuted : AppColors.gold,
        ),
      QuizAnswerChoiceState.correct => _QuizAnswerChoicePalette(
          fillColor: AppColors.success.withValues(alpha: isDark ? 0.22 : 0.12),
          borderColor: AppColors.success.withValues(alpha: isDark ? 0.78 : 0.52),
          textColor: isDark ? AppColors.textDark : AppColors.textLight,
          badgeColor: AppColors.success,
          badgeTextColor: Colors.white,
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
        ),
      QuizAnswerChoiceState.incorrect => _QuizAnswerChoicePalette(
          fillColor: AppColors.error.withValues(alpha: isDark ? 0.22 : 0.1),
          borderColor: AppColors.error.withValues(alpha: isDark ? 0.82 : 0.54),
          textColor: isDark ? AppColors.textDark : AppColors.textLight,
          badgeColor: AppColors.error,
          badgeTextColor: Colors.white,
          icon: Icons.cancel_rounded,
          iconColor: AppColors.error,
        ),
      QuizAnswerChoiceState.revealed => _QuizAnswerChoicePalette(
          fillColor: AppColors.success.withValues(alpha: isDark ? 0.18 : 0.08),
          borderColor: AppColors.success.withValues(alpha: isDark ? 0.62 : 0.36),
          textColor: isDark ? AppColors.textDark : AppColors.textLight,
          badgeColor: AppColors.success.withValues(alpha: 0.88),
          badgeTextColor: Colors.white,
          icon: Icons.visibility_rounded,
          iconColor: AppColors.success,
        ),
    };
  }
}

class _QuizAnswerChoicePalette {
  const _QuizAnswerChoicePalette({
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconColor,
  });

  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconColor;
}
