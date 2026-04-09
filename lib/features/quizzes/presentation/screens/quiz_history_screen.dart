import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/widgets/app_error_widget.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_difficulty_badge.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_progress_chart.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

class QuizHistoryScreen extends ConsumerStatefulWidget {
  const QuizHistoryScreen({
    super.key,
    this.initialQuizType = QuizType.verseCompletion,
  });

  final QuizType initialQuizType;

  @override
  ConsumerState<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends ConsumerState<QuizHistoryScreen> {
  late QuizType _selectedType = widget.initialQuizType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(quizHistoryProvider(_selectedType));
    final surahs = ref.watch(surahsProvider).valueOrNull ?? const <Surah>[];

    return Scaffold(
      key: const Key('quiz-history-screen'),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          l10n.quizHistoryTitle,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: historyAsync.when(
        data: (entries) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              _QuizHistoryTypeSelector(
                selectedType: _selectedType,
                onChanged: (quizType) {
                  if (quizType == _selectedType) {
                    return;
                  }

                  setState(() {
                    _selectedType = quizType;
                  });
                },
              ),
              const SizedBox(height: 18),
              QuizProgressChart(entries: entries),
              const SizedBox(height: 18),
              if (entries.isEmpty)
                _QuizHistoryEmptyState(message: l10n.quizHistoryEmpty)
              else
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuizHistoryEntryCard(
                      entry: entry,
                      surahName: _surahNameFor(
                        context: context,
                        surahs: surahs,
                        surahNumber: entry.surahFilter,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => AppErrorWidget(
          message: l10n.errorLoadingData,
          onRetry: () {
            ref.invalidate(quizHistoryProvider(_selectedType));
            ref.invalidate(surahsProvider);
          },
        ),
      ),
    );
  }

  String _surahNameFor({
    required BuildContext context,
    required List<Surah> surahs,
    required int? surahNumber,
  }) {
    if (surahNumber == null) {
      return context.l10n.quizAllQuran;
    }

    for (final surah in surahs) {
      if (surah.number == surahNumber) {
        return Localizations.localeOf(context).languageCode == 'ar'
            ? surah.nameArabic
            : surah.nameEnglish;
      }
    }

    return MaterialLocalizations.of(context).formatDecimal(surahNumber);
  }
}

class _QuizHistoryTypeSelector extends StatelessWidget {
  const _QuizHistoryTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  final QuizType selectedType;
  final ValueChanged<QuizType> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: QuizType.values.map((quizType) {
        final isSelected = quizType == selectedType;

        return ChoiceChip(
          key: Key('quiz-history-type-${quizType.name}'),
          selected: isSelected,
          label: Text(_labelFor(context, quizType)),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textDark : AppColors.textLight),
          ),
          selectedColor: AppColors.gold,
          backgroundColor: isDark ? AppColors.surfaceDarkNav : Colors.white,
          side: BorderSide(
            color: isSelected
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: isDark ? 0.28 : 0.18),
          ),
          onSelected: (_) => onChanged(quizType),
        );
      }).toList(growable: false),
    );
  }

  String _labelFor(BuildContext context, QuizType quizType) {
    return switch (quizType) {
      QuizType.verseCompletion => context.l10n.quizTypeVerseCompletion,
      QuizType.wordMeaning => context.l10n.quizTypeWordMeaning,
      QuizType.verseTopic => context.l10n.quizTypeVerseTopic,
    };
  }
}

class _QuizHistoryEmptyState extends StatelessWidget {
  const _QuizHistoryEmptyState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.24 : 0.14),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textDark : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _QuizHistoryEntryCard extends StatelessWidget {
  const _QuizHistoryEntryCard({
    required this.entry,
    required this.surahName,
  });

  final QuizHistoryEntry entry;
  final String surahName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);
    final percentage = _percentageFor(entry);
    final scoreLabel =
        '${localizations.formatDecimal(entry.score)} / ${localizations.formatDecimal(entry.totalQuestions)}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${localizations.formatDecimal(percentage.round())}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const Spacer(),
                QuizDifficultyBadge(difficulty: entry.difficulty),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _QuizHistoryMetadataBlock(
                    label: context.l10n.quizHistoryDate,
                    value: localizations.formatShortDate(entry.completedAt),
                    valueKey: const Key('quiz-history-entry-date'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuizHistoryMetadataBlock(
                    label: context.l10n.quizHistoryScore,
                    value: scoreLabel,
                    valueKey: const Key('quiz-history-entry-score'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.quizHistoryDifficulty,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: QuizDifficultyBadge(difficulty: entry.difficulty),
            ),
            const SizedBox(height: 10),
            Text(
              '${context.l10n.quizSurahFilter}: $surahName',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _percentageFor(QuizHistoryEntry value) {
    if (value.totalQuestions <= 0) {
      return 0;
    }

    return (value.score / value.totalQuestions) * 100;
  }
}

class _QuizHistoryMetadataBlock extends StatelessWidget {
  const _QuizHistoryMetadataBlock({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          key: valueKey,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
