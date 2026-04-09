import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';

class QuizDifficultyBadge extends StatelessWidget {
  const QuizDifficultyBadge({
    super.key,
    required this.difficulty,
  });

  final QuizDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colorFor(difficulty);
    final label = switch (difficulty) {
      QuizDifficulty.easy => context.l10n.quizDifficultyEasy,
      QuizDifficulty.medium => context.l10n.quizDifficultyMedium,
      QuizDifficulty.hard => context.l10n.quizDifficultyHard,
    };

    return Container(
      key: Key('quiz-difficulty-badge-${difficulty.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.24 : 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.62 : 0.34),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textDark : color,
        ),
      ),
    );
  }

  Color _colorFor(QuizDifficulty value) {
    return switch (value) {
      QuizDifficulty.easy => AppColors.success,
      QuizDifficulty.medium => const Color(0xFFE67E22),
      QuizDifficulty.hard => AppColors.error,
    };
  }
}
