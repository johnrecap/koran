import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_difficulty_badge.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

final quizConfigSurahAvailabilityProvider =
    FutureProvider.family<Map<int, bool>, QuizType>((ref, quizType) async {
  final surahs = await ref.watch(surahsProvider.future);
  final generator = ref.watch(quizQuestionGeneratorProvider(quizType));
  final results = await Future.wait(
    surahs.map((surah) async {
      return MapEntry(
        surah.number,
        await generator.isAvailable(surahFilter: surah.number),
      );
    }),
  );

  return <int, bool>{
    for (final result in results) result.key: result.value,
  };
});

Future<QuizSessionConfig?> showQuizSessionConfigSheet({
  required BuildContext context,
  required QuizType quizType,
  Future<void> Function(QuizSessionConfig config)? onBegin,
}) {
  return showModalBottomSheet<QuizSessionConfig>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return QuizSessionConfigSheet(
        quizType: quizType,
        onBegin: (config) async {
          if (onBegin != null) {
            await onBegin(config);
          }
          if (sheetContext.mounted) {
            Navigator.of(sheetContext).pop(config);
          }
        },
      );
    },
  );
}

class QuizSessionConfigSheet extends ConsumerStatefulWidget {
  const QuizSessionConfigSheet({
    super.key,
    required this.quizType,
    this.onBegin,
  });

  final QuizType quizType;
  final Future<void> Function(QuizSessionConfig config)? onBegin;

  @override
  ConsumerState<QuizSessionConfigSheet> createState() =>
      _QuizSessionConfigSheetState();
}

class _QuizSessionConfigSheetState
    extends ConsumerState<QuizSessionConfigSheet> {
  int _questionCount = 10;
  int? _selectedSurahNumber;
  QuizDifficulty _difficulty = QuizDifficulty.medium;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahsAsync = ref.watch(surahsProvider);
    final surahAvailabilityAsync = ref.watch(
      quizConfigSurahAvailabilityProvider(widget.quizType),
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkNav : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.quizConfigTitle,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _quizTypeTitle(context, widget.quizType),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel(label: l10n.quizQuestionCount),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _OptionChip(
                      chipKey: const Key('quiz-config-count-5'),
                      label: '5',
                      selected: _questionCount == 5,
                      onSelected: () {
                        setState(() {
                          _questionCount = 5;
                        });
                      },
                    ),
                    _OptionChip(
                      chipKey: const Key('quiz-config-count-10'),
                      label: '10',
                      selected: _questionCount == 10,
                      onSelected: () {
                        setState(() {
                          _questionCount = 10;
                        });
                      },
                    ),
                    _OptionChip(
                      chipKey: const Key('quiz-config-count-20'),
                      label: '20',
                      selected: _questionCount == 20,
                      onSelected: () {
                        setState(() {
                          _questionCount = 20;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionLabel(label: l10n.quizSurahFilter),
                const SizedBox(height: 10),
                surahsAsync.when(
                  data: (surahs) => DropdownButtonFormField<int?>(
                    key: const Key('quiz-config-surah-field'),
                    initialValue: _effectiveSelectedSurah(
                      surahAvailabilityAsync,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(l10n.quizAllQuran),
                      ),
                      ...surahs.map((surah) {
                        final isSurahAvailable =
                            surahAvailabilityAsync.valueOrNull?[surah.number] ??
                                true;
                        return DropdownMenuItem<int?>(
                          value: surah.number,
                          enabled: isSurahAvailable,
                          child: Text(
                            _surahLabel(context, surah, isSurahAvailable),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSurahNumber = value;
                      });
                    },
                  ),
                  loading: () => _LoadingSurface(
                    message: l10n.librarySurahsLoading,
                  ),
                  error: (_, __) => _LoadingSurface(
                    message: l10n.readerSurahLoadError,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SectionLabel(label: l10n.quizDifficultyLabel),
                    ),
                    QuizDifficultyBadge(difficulty: _difficulty),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _OptionChip(
                      chipKey: const Key('quiz-config-difficulty-easy'),
                      label: l10n.quizDifficultyEasy,
                      selected: _difficulty == QuizDifficulty.easy,
                      onSelected: () {
                        setState(() {
                          _difficulty = QuizDifficulty.easy;
                        });
                      },
                    ),
                    _OptionChip(
                      chipKey: const Key('quiz-config-difficulty-medium'),
                      label: l10n.quizDifficultyMedium,
                      selected: _difficulty == QuizDifficulty.medium,
                      onSelected: () {
                        setState(() {
                          _difficulty = QuizDifficulty.medium;
                        });
                      },
                    ),
                    _OptionChip(
                      chipKey: const Key('quiz-config-difficulty-hard'),
                      label: l10n.quizDifficultyHard,
                      selected: _difficulty == QuizDifficulty.hard,
                      onSelected: () {
                        setState(() {
                          _difficulty = QuizDifficulty.hard;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('quiz-config-begin'),
                    onPressed: _isSubmitting ? null : _handleBegin,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      l10n.quizBegin,
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
      ),
    );
  }

  int? _effectiveSelectedSurah(
    AsyncValue<Map<int, bool>> surahAvailabilityAsync,
  ) {
    final selectedSurahNumber = _selectedSurahNumber;
    if (selectedSurahNumber == null) {
      return null;
    }

    final availability = surahAvailabilityAsync.valueOrNull;
    if (availability != null && availability[selectedSurahNumber] == false) {
      return null;
    }

    return selectedSurahNumber;
  }

  Future<void> _handleBegin() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final config = QuizSessionConfig(
      quizType: widget.quizType,
      questionCount: _questionCount,
      surahFilter: _selectedSurahNumber,
      difficulty: _difficulty,
    );

    try {
      final onBegin = widget.onBegin;
      if (onBegin != null) {
        await onBegin(config);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

String _quizTypeTitle(BuildContext context, QuizType quizType) {
  return switch (quizType) {
    QuizType.verseCompletion => context.l10n.quizTypeVerseCompletion,
    QuizType.wordMeaning => context.l10n.quizTypeWordMeaning,
    QuizType.verseTopic => context.l10n.quizTypeVerseTopic,
  };
}

String _surahLabel(
  BuildContext context,
  Surah surah,
  bool isSurahAvailable,
) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final surahName = languageCode == 'en' ? surah.nameEnglish : surah.nameArabic;
  final baseLabel = '${context.l10n.surahPrefix} $surahName';
  if (isSurahAvailable) {
    return baseLabel;
  }

  return '$baseLabel • ${context.l10n.quizUnavailable}';
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final Key chipKey;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      key: chipKey,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: AppColors.gold.withValues(alpha: 0.2),
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : AppColors.surfaceLight,
      labelStyle: TextStyle(
        color: selected ? (isDark ? AppColors.textDark : AppColors.gold) : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

class _LoadingSurface extends StatelessWidget {
  const _LoadingSurface({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
