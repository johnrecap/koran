import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

class QuizTypeCard extends StatelessWidget {
  const QuizTypeCard({
    super.key,
    required this.quizType,
    required this.isAvailable,
    required this.mistakeCount,
    this.onPressed,
  });

  final QuizType quizType;
  final bool isAvailable;
  final int mistakeCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _accentColorFor(quizType);
    final effectiveOnPressed = isAvailable ? onPressed : null;

    return AnimatedOpacity(
      opacity: isAvailable ? 1 : 0.68,
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: Key('quiz-type-card-${quizType.name}'),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkNav : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: iconColor.withValues(alpha: isDark ? 0.24 : 0.18),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _iconFor(quizType),
                      color: iconColor,
                    ),
                  ),
                  if (mistakeCount > 0) ...[
                    const Spacer(),
                    Tooltip(
                      message:
                          '${context.l10n.quizMistakesBadge}: '
                          '${context.l10n.quizMistakesReviewCount(
                            MaterialLocalizations.of(context).formatDecimal(
                              mistakeCount,
                            ),
                          )}',
                      child: Container(
                        key: Key('quiz-type-card-mistakes-${quizType.name}'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(
                            alpha: isDark ? 0.18 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.l10n.quizMistakesReviewCount(
                            MaterialLocalizations.of(context).formatDecimal(
                              mistakeCount,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDark : AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _titleFor(context, quizType),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _descriptionFor(context, quizType),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: Key('quiz-type-card-button-${quizType.name}'),
                  onPressed: effectiveOnPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: iconColor,
                    disabledBackgroundColor: iconColor.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    isAvailable
                        ? context.l10n.quizStart
                        : context.l10n.quizUnavailable,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _titleFor(BuildContext context, QuizType quizType) {
  return switch (quizType) {
    QuizType.verseCompletion => context.l10n.quizTypeVerseCompletion,
    QuizType.wordMeaning => context.l10n.quizTypeWordMeaning,
    QuizType.verseTopic => context.l10n.quizTypeVerseTopic,
  };
}

String _descriptionFor(BuildContext context, QuizType quizType) {
  return switch (quizType) {
    QuizType.verseCompletion => context.l10n.quizTypeVerseCompletionDesc,
    QuizType.wordMeaning => context.l10n.quizTypeWordMeaningDesc,
    QuizType.verseTopic => context.l10n.quizTypeVerseTopicDesc,
  };
}

IconData _iconFor(QuizType quizType) {
  return switch (quizType) {
    QuizType.verseCompletion => Icons.auto_stories_rounded,
    QuizType.wordMeaning => Icons.translate_rounded,
    QuizType.verseTopic => Icons.insights_rounded,
  };
}

Color _accentColorFor(QuizType quizType) {
  return switch (quizType) {
    QuizType.verseCompletion => AppColors.gold,
    QuizType.wordMeaning => AppColors.meccan,
    QuizType.verseTopic => AppColors.warmBrown,
  };
}
