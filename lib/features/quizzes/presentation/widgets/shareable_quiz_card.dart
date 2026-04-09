import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';

class ShareableQuizCard extends StatelessWidget {
  const ShareableQuizCard({
    super.key,
    required this.question,
    required this.answer,
    required this.surahName,
  });

  final QuizQuestion question;
  final QuizAnswer answer;
  final String surahName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final localizations = MaterialLocalizations.of(context);
    final referenceLabel =
        '${l10n.surahPrefix} $surahName • ${l10n.verseActionAyah} '
        '${localizations.formatDecimal(question.ayahNumber)}';

    return Container(
      key: const Key('quiz-shareable-card-surface'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.30 : 0.18),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            bottom: 8,
            end: 8,
            child: Opacity(
              opacity: isDark ? 0.08 : 0.05,
              child: Text(
                l10n.appTitle,
                key: const Key('quiz-shareable-card-watermark'),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  key: const Key('quiz-shareable-card-branding'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: isDark ? 0.16 : 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        size: 18,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.appTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _titleFor(context, question),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textDark : AppColors.gold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: isDark ? 0.20 : 0.14),
                  ),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    question.prompt,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: question is WordMeaningQuestion ? 34 : 28,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              for (var index = 0; index < question.choices.length; index += 1) ...[
                _ShareableChoiceRow(
                  index: index,
                  choice: question.choices[index],
                  state: _choiceStateFor(index),
                ),
                if (index < question.choices.length - 1)
                  const SizedBox(height: 10),
              ],
              const SizedBox(height: 18),
              Text(
                referenceLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _ShareableChoiceState _choiceStateFor(int index) {
    if (index == question.correctIndex) {
      return _ShareableChoiceState.correct;
    }
    if (index == answer.selectedIndex && !answer.isCorrect) {
      return _ShareableChoiceState.incorrect;
    }
    return _ShareableChoiceState.neutral;
  }
}

class _ShareableChoiceRow extends StatelessWidget {
  const _ShareableChoiceRow({
    required this.index,
    required this.choice,
    required this.state,
  });

  final int index;
  final String choice;
  final _ShareableChoiceState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = switch (state) {
      _ShareableChoiceState.correct => AppColors.success,
      _ShareableChoiceState.incorrect => AppColors.error,
      _ShareableChoiceState.neutral => AppColors.gold,
    };
    final backgroundColor = switch (state) {
      _ShareableChoiceState.correct =>
        AppColors.success.withValues(alpha: isDark ? 0.24 : 0.12),
      _ShareableChoiceState.incorrect =>
        AppColors.error.withValues(alpha: isDark ? 0.24 : 0.12),
      _ShareableChoiceState.neutral =>
        isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
    };

    return Container(
      key: Key('quiz-shareable-card-choice-$index-panel'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tone.withValues(alpha: isDark ? 0.52 : 0.26),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tone.withValues(alpha: isDark ? 0.24 : 0.14),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: tone,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Directionality(
              textDirection: _containsArabic(choice)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Text(
                choice,
                style: TextStyle(
                  fontFamily: _containsArabic(choice) ? 'Amiri' : null,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ShareableChoiceState {
  neutral,
  correct,
  incorrect,
}

String _titleFor(BuildContext context, QuizQuestion question) {
  final l10n = context.l10n;

  return switch (question) {
    VerseCompletionQuestion() => l10n.quizCompleteThe,
    WordMeaningQuestion() => l10n.quizWhatMeans,
    VerseTopicQuestion() => l10n.quizWhichTopic,
  };
}

bool _containsArabic(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}
