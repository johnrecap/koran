import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({
    super.key,
    required this.question,
    this.showFullVerseAction = false,
    this.isFullVerseVisible = false,
    this.onToggleFullVerse,
  });

  final QuizQuestion question;
  final bool showFullVerseAction;
  final bool isFullVerseVisible;
  final VoidCallback? onToggleFullVerse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);
    final referenceLabel =
        '${l10n.surahPrefix} ${localizations.formatDecimal(question.surahNumber)} - '
        '${l10n.verseActionAyah} ${localizations.formatDecimal(question.ayahNumber)}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.2 : 0.16),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _titleFor(context, question),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDark : AppColors.gold,
              ),
            ),
            const SizedBox(height: 10),
            Directionality(
              key: const Key('quiz-question-view-prompt-directionality'),
              textDirection: TextDirection.rtl,
              child: Text(
                question.prompt,
                key: const Key('quiz-question-view-prompt'),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: question is WordMeaningQuestion ? 34 : 28,
                  height: 1.65,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              referenceLabel,
              key: const Key('quiz-question-view-reference'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (question is VerseCompletionQuestion && showFullVerseAction) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                key: const Key('quiz-question-view-full-verse-toggle'),
                onPressed: onToggleFullVerse,
                icon: Icon(
                  isFullVerseVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                label: Text(l10n.quizShowFullVerse),
              ),
            ],
            if (question is VerseCompletionQuestion && isFullVerseVisible) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    (question as VerseCompletionQuestion).fullVerse,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 24,
                      height: 1.7,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _titleFor(BuildContext context, QuizQuestion question) {
  final l10n = context.l10n;

  return switch (question) {
    VerseCompletionQuestion() => l10n.quizCompleteThe,
    WordMeaningQuestion() => l10n.quizWhatMeans,
    VerseTopicQuestion() => l10n.quizWhichTopic,
  };
}
