import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/core/widgets/app_error_widget.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_mistake_models.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_difficulty_badge.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_result_item.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/shareable_quiz_card.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';
import 'package:quran_kareem/features/quizzes/utils/quiz_card_image_exporter.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  QuizResultScreen({
    super.key,
    this.result,
    this.onTryAgain,
    this.onBackToHub,
    QuizCardImageExporter? imageExporter,
    this.surahNameResolver,
  }) : imageExporter = imageExporter ?? QuizCardImageExporter();

  final QuizResult? result;
  final Future<void> Function(BuildContext context, QuizSessionConfig config)?
      onTryAgain;
  final VoidCallback? onBackToHub;
  final QuizCardImageExporter imageExporter;
  final Future<String> Function(int surahNumber)? surahNameResolver;

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  final GlobalKey _shareableCardBoundaryKey = GlobalKey();
  String? _scheduledPersistenceToken;
  String? _persistedToken;
  bool _isRetrying = false;
  bool _isExportingCard = false;
  QuizQuestion? _exportQuestion;
  QuizAnswer? _exportAnswer;
  String? _exportSurahName;

  @override
  Widget build(BuildContext context) {
    final result = widget.result ?? ref.watch(quizResultProvider);
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (result != null) {
      _schedulePersistence(result);
    }

    if (result == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        appBar: AppBar(),
        body: AppErrorWidget(
          message: l10n.errorLoadingData,
        ),
      );
    }

    final localizations = MaterialLocalizations.of(context);
    final performanceTier = _tierFor(result);
    final reviews = _buildReviews(result);

    return Scaffold(
      key: const Key('quiz-result-screen'),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          l10n.quizResultTitle,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                _QuizResultSummaryCard(
                  result: result,
                  performanceTier: performanceTier,
                  scoreLabel:
                      '${localizations.formatDecimal(result.score)} / ${localizations.formatDecimal(result.totalQuestions)}',
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.quizResultReviewTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 12),
                for (final review in reviews)
                  QuizResultItem(
                    question: review.question,
                    answer: review.answer,
                    onExportTap: _isExportingCard
                        ? null
                        : () {
                            unawaited(
                              _handleReviewExport(
                                quizType: result.config.quizType,
                                question: review.question,
                                answer: review.answer,
                              ),
                            );
                          },
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _isRetrying
                      ? null
                      : () {
                          _handleTryAgain(result);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    l10n.quizTryAgain,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    final onBackToHub = widget.onBackToHub;
                    if (onBackToHub != null) {
                      onBackToHub();
                      return;
                    }

                    Navigator.of(context).maybePop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? AppColors.textDark : AppColors.textLight,
                    side: BorderSide(
                      color: AppColors.gold
                          .withValues(alpha: isDark ? 0.48 : 0.28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    l10n.quizBackToHub,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (_exportQuestion != null &&
                _exportAnswer != null &&
                _exportSurahName != null)
              PositionedDirectional(
                start: -10000,
                top: 0,
                child: IgnorePointer(
                  child: Theme(
                    data: Theme.of(context),
                    child: Material(
                      color: Colors.transparent,
                      child: RepaintBoundary(
                        key: _shareableCardBoundaryKey,
                        child: SizedBox(
                          width: 380,
                          child: ShareableQuizCard(
                            question: _exportQuestion!,
                            answer: _exportAnswer!,
                            surahName: _exportSurahName!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _schedulePersistence(QuizResult result) {
    final token = _tokenFor(result);
    if (_persistedToken == token || _scheduledPersistenceToken == token) {
      return;
    }

    _scheduledPersistenceToken = token;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_persistResult(result));
    });
  }

  Future<void> _persistResult(QuizResult result) async {
    final token = _tokenFor(result);
    if (_persistedToken == token) {
      return;
    }

    try {
      final historyRepository = ref.read(quizHistoryRepositoryProvider);
      await historyRepository.addEntry(
        QuizHistoryEntry(
          quizType: result.config.quizType,
          score: result.score,
          totalQuestions: result.totalQuestions,
          difficulty: result.config.difficulty,
          surahFilter: result.config.surahFilter,
          completedAt: result.completedAt,
        ),
      );

      await _processMistakes(result);

      ref.invalidate(quizHistoryProvider(result.config.quizType));
      ref.invalidate(quizMistakesProvider(result.config.quizType));
      ref.invalidate(quizMistakeCountsProvider);
      _persistedToken = token;
    } catch (error, stackTrace) {
      _scheduledPersistenceToken = null;
      AppLogger.error('QuizResultScreen._persistResult', error, stackTrace);
    }
  }

  Future<void> _processMistakes(QuizResult result) async {
    final repository = ref.read(quizMistakeRepositoryProvider);
    final existingEntries = await repository.getMistakes(result.config.quizType);
    final entriesByKey = <String, QuizMistakeEntry>{
      for (final entry in existingEntries) entry.questionKey: entry,
    };

    for (final answer in result.answers) {
      if (answer.questionIndex < 0 || answer.questionIndex >= result.questions.length) {
        continue;
      }

      final question = result.questions[answer.questionIndex];
      final questionKey = quizQuestionKeyFor(question);

      if (!answer.isCorrect) {
        entriesByKey[questionKey] = buildQuizMistakeEntry(
          quizType: result.config.quizType,
          question: question,
          attemptedAt: result.completedAt,
        );
        continue;
      }

      final existingEntry = entriesByKey[questionKey];
      if (existingEntry == null) {
        continue;
      }

      existingEntry.recordCorrect(attemptedAt: result.completedAt);
      if (existingEntry.isGraduated) {
        entriesByKey.remove(questionKey);
      }
    }

    await repository.saveMistakes(
      result.config.quizType,
      entriesByKey.values.toList(growable: false),
    );
  }

  Future<void> _handleTryAgain(QuizResult result) async {
    if (_isRetrying) {
      return;
    }

    setState(() {
      _isRetrying = true;
    });

    try {
      final onTryAgain = widget.onTryAgain;
      if (onTryAgain != null) {
        await onTryAgain(context, result.config);
        return;
      }

      await ref.read(quizSessionProvider.notifier).startSession(result.config);
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  Future<void> _handleReviewExport({
    required QuizType quizType,
    required QuizQuestion question,
    required QuizAnswer answer,
  }) async {
    if (_isExportingCard) {
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;

        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                key: const Key('quiz-result-card-save-action'),
                leading: const Icon(Icons.download_rounded),
                title: Text(l10n.quizResultCardSaveAction),
                onTap: () {
                  Navigator.of(sheetContext).pop('save');
                },
              ),
              ListTile(
                key: const Key('quiz-result-card-share-action'),
                leading: const Icon(Icons.share_rounded),
                title: Text(l10n.quizResultCardShareAction),
                onTap: () {
                  Navigator.of(sheetContext).pop('share');
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    await _runReviewExport(
      quizType: quizType,
      question: question,
      answer: answer,
      action: action,
    );
  }

  Future<void> _runReviewExport({
    required QuizType quizType,
    required QuizQuestion question,
    required QuizAnswer answer,
    required String action,
  }) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isExportingCard = true;
    });

    try {
      final surahName = await _resolveSurahName(question.surahNumber);
      if (!mounted) {
        return;
      }

      setState(() {
        _exportQuestion = question;
        _exportAnswer = answer;
        _exportSurahName = surahName;
      });

      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

      if (!mounted) {
        return;
      }

      final pngBytes =
          await widget.imageExporter.captureCard(_shareableCardBoundaryKey);
      if (pngBytes == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.quizResultCardExportUnavailable)),
        );
        return;
      }

      final fileName = _buildExportFileName(
        quizType: quizType,
        question: question,
      );

      if (action == 'save') {
        await _saveReviewCard(
          pngBytes: pngBytes,
          fileName: fileName,
          messenger: messenger,
        );
        return;
      }

      final shared = await widget.imageExporter.shareImage(
        pngBytes,
        fileName,
      );
      if (!mounted || shared) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text(l10n.quizResultCardShareUnavailable)),
      );
      return;
    } catch (error, stackTrace) {
      AppLogger.error('QuizResultScreen._runReviewExport', error, stackTrace);
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            action == 'save'
                ? l10n.quizResultCardSaveUnavailable
                : l10n.quizResultCardShareUnavailable,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingCard = false;
          _exportQuestion = null;
          _exportAnswer = null;
          _exportSurahName = null;
        });
      }
    }
  }

  Future<void> _saveReviewCard({
    required Uint8List pngBytes,
    required String fileName,
    required ScaffoldMessengerState messenger,
  }) async {
    final outcome = await widget.imageExporter.saveToGallery(pngBytes, fileName);
    if (!mounted) {
      return;
    }

    switch (outcome) {
      case QuizCardImageSaveOutcome.success:
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.quizResultCardSaved)),
        );
        return;
      case QuizCardImageSaveOutcome.permissionDenied:
        final shared = await widget.imageExporter.shareImage(pngBytes, fileName);
        if (!mounted) {
          return;
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              shared
                  ? context.l10n.quizResultCardSavePermissionDenied
                  : context.l10n.quizResultCardShareUnavailable,
            ),
          ),
        );
        return;
      case QuizCardImageSaveOutcome.failure:
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.quizResultCardSaveUnavailable)),
        );
        return;
    }
  }

  Future<String> _resolveSurahName(int surahNumber) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final localizations = MaterialLocalizations.of(context);

    try {
      final externalResolver = widget.surahNameResolver;
      if (externalResolver != null) {
        return await externalResolver(surahNumber);
      }
    } catch (error, stackTrace) {
      AppLogger.error('QuizResultScreen._resolveSurahName', error, stackTrace);
    }

    if (languageCode == 'ar') {
      return localizations.formatDecimal(surahNumber);
    }

    return localizations.formatDecimal(surahNumber);
  }

  String _buildExportFileName({
    required QuizType quizType,
    required QuizQuestion question,
  }) {
    return 'quiz-card-${quizType.name}-${question.surahNumber}-${question.ayahNumber}-${DateTime.now().millisecondsSinceEpoch}';
  }

  List<_QuizQuestionReview> _buildReviews(QuizResult result) {
    final reviews = <_QuizQuestionReview>[];

    for (final answer in result.answers) {
      if (answer.questionIndex < 0 || answer.questionIndex >= result.questions.length) {
        continue;
      }

      reviews.add(
        _QuizQuestionReview(
          question: result.questions[answer.questionIndex],
          answer: answer,
        ),
      );
    }

    return reviews;
  }

  _QuizPerformanceTier _tierFor(QuizResult result) {
    final percentage = result.percentage;
    if (percentage >= 90) {
      return _QuizPerformanceTier.excellent;
    }
    if (percentage >= 75) {
      return _QuizPerformanceTier.veryGood;
    }
    if (percentage >= 50) {
      return _QuizPerformanceTier.goodStart;
    }
    return _QuizPerformanceTier.keepPracticing;
  }

  String _tokenFor(QuizResult result) {
    return '${result.config.quizType.name}:${result.completedAt.microsecondsSinceEpoch}:${result.score}:${result.totalQuestions}';
  }
}

class _QuizResultSummaryCard extends StatelessWidget {
  const _QuizResultSummaryCard({
    required this.result,
    required this.performanceTier,
    required this.scoreLabel,
  });

  final QuizResult result;
  final _QuizPerformanceTier performanceTier;
  final String scoreLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentageLabel = '${result.percentage.round()}%';
    final tone = performanceTier.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.24 : 0.16),
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
      child: Column(
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tone.withValues(alpha: isDark ? 0.18 : 0.10),
              border: Border.all(
                color: tone.withValues(alpha: isDark ? 0.72 : 0.42),
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  performanceTier.icon,
                  color: tone,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  percentageLabel,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.quizResultScore,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            scoreLabel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            performanceTier.label(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: tone,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          QuizDifficultyBadge(
            difficulty: result.config.difficulty,
          ),
        ],
      ),
    );
  }
}

class _QuizQuestionReview {
  const _QuizQuestionReview({
    required this.question,
    required this.answer,
  });

  final QuizQuestion question;
  final QuizAnswer answer;
}

enum _QuizPerformanceTier {
  excellent(
    color: AppColors.success,
    icon: Icons.emoji_events_rounded,
  ),
  veryGood(
    color: Color(0xFFE67E22),
    icon: Icons.stars_rounded,
  ),
  goodStart(
    color: AppColors.gold,
    icon: Icons.thumb_up_alt_rounded,
  ),
  keepPracticing(
    color: AppColors.warmBrown,
    icon: Icons.auto_stories_rounded,
  );

  const _QuizPerformanceTier({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;

  String label(BuildContext context) {
    final l10n = context.l10n;

    return switch (this) {
      _QuizPerformanceTier.excellent => l10n.quizResultExcellent,
      _QuizPerformanceTier.veryGood => l10n.quizResultVeryGood,
      _QuizPerformanceTier.goodStart => l10n.quizResultGoodStart,
      _QuizPerformanceTier.keepPracticing => l10n.quizResultKeepPracticing,
    };
  }
}
