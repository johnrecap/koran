import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_difficulty_badge.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_question_view.dart';

class QuizResultItem extends StatefulWidget {
  const QuizResultItem({
    super.key,
    required this.question,
    required this.answer,
    this.onExportTap,
  });

  final QuizQuestion question;
  final QuizAnswer answer;
  final VoidCallback? onExportTap;

  @override
  State<QuizResultItem> createState() => _QuizResultItemState();
}

class _QuizResultItemState extends State<QuizResultItem> {
  bool _isFullVerseVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = widget.question;
    final answer = widget.answer;
    final selectedAnswer = question.choices[answer.selectedIndex];

    return Container(
      key: Key(
        'quiz-result-item-${question.surahNumber}-${question.ayahNumber}',
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.16),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: answer.isCorrect
                      ? AppColors.success.withValues(alpha: isDark ? 0.22 : 0.12)
                      : AppColors.error.withValues(alpha: isDark ? 0.22 : 0.12),
                ),
                child: Icon(
                  answer.isCorrect
                      ? Icons.check_rounded
                      : Icons.priority_high_rounded,
                  color: answer.isCorrect ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: QuizDifficultyBadge(
                    difficulty: answer.difficulty,
                  ),
                ),
              ),
              if (widget.onExportTap != null)
                IconButton(
                  key: const Key('quiz-result-item-export-action'),
                  onPressed: widget.onExportTap,
                  icon: const Icon(Icons.ios_share_rounded),
                  tooltip: context.l10n.quizResultCardShareAction,
                ),
            ],
          ),
          const SizedBox(height: 14),
          QuizQuestionView(
            question: question,
            showFullVerseAction: question is VerseCompletionQuestion,
            isFullVerseVisible: _isFullVerseVisible,
            onToggleFullVerse: question is VerseCompletionQuestion
                ? () {
                    setState(() {
                      _isFullVerseVisible = !_isFullVerseVisible;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 14),
          _QuizResultAnswerPanel(
            panelKey: const Key('quiz-result-item-user-answer-panel'),
            title: context.l10n.quizReviewYourAnswer,
            value: selectedAnswer,
            isPositive: answer.isCorrect,
          ),
          if (!answer.isCorrect) ...[
            const SizedBox(height: 10),
            _QuizResultAnswerPanel(
              panelKey: const Key('quiz-result-item-correct-answer-panel'),
              title: context.l10n.quizReviewCorrectAnswer,
              value: question.correctChoice,
              isPositive: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizResultAnswerPanel extends StatelessWidget {
  const _QuizResultAnswerPanel({
    required this.panelKey,
    required this.title,
    required this.value,
    required this.isPositive,
  });

  final Key panelKey;
  final String title;
  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = isPositive ? AppColors.success : AppColors.error;

    return Container(
      key: panelKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: isDark ? 0.22 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tone.withValues(alpha: isDark ? 0.72 : 0.42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : tone,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
