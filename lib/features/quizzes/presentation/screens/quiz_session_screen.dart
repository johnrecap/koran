import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/widgets/app_error_widget.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_answer_choice.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_difficulty_badge.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_question_view.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';

class QuizSessionScreen extends ConsumerStatefulWidget {
  const QuizSessionScreen({
    super.key,
    this.onSessionComplete,
    this.onExitConfirmed,
  });

  final Future<void> Function(BuildContext context, QuizResult result)?
      onSessionComplete;
  final VoidCallback? onExitConfirmed;

  @override
  ConsumerState<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends ConsumerState<QuizSessionScreen> {
  QuizQuestion? _displayedQuestion;
  int? _displayedQuestionIndex;
  bool _isSubmittingAnswer = false;
  bool _isAdvancing = false;
  bool _isFullVerseVisible = false;
  bool _didHandleCompletion = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<QuizSessionState?>(quizSessionProvider, (previous, next) {
      if (next == null && previous != null && mounted) {
        setState(() {
          _displayedQuestion = null;
          _displayedQuestionIndex = null;
          _isFullVerseVisible = false;
          _didHandleCompletion = false;
        });
      }

      if (next?.isComplete == true && !_didHandleCompletion) {
        final result = ref.read(quizResultProvider);
        if (result != null) {
          _didHandleCompletion = true;
          final onSessionComplete = widget.onSessionComplete;
          if (onSessionComplete != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              onSessionComplete(context, result);
            });
          }
        }
      }
    });

    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = ref.watch(quizSessionProvider);
    final question = _syncDisplayedQuestion(session);
    final questionIndex = _displayedQuestionIndex;

    if (session == null || question == null || questionIndex == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        appBar: AppBar(),
        body: AppErrorWidget(
          message: l10n.errorLoadingData,
        ),
      );
    }

    final localizations = MaterialLocalizations.of(context);
    final currentAnswer = _answerFor(session.answers, questionIndex);
    final isQuestionLocked = currentAnswer != null || _isSubmittingAnswer;
    final progressLabel = l10n.quizProgress(
      localizations.formatDecimal(questionIndex + 1),
      localizations.formatDecimal(session.config.questionCount),
    );
    final showNextAction = currentAnswer != null && !session.isComplete;
    final shouldOfferFullVerse =
        question is VerseCompletionQuestion && currentAnswer?.isCorrect == false;

    return PopScope(
      canPop: session.isComplete,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handleExitPressed(session);
      },
      child: Scaffold(
        key: const Key('quiz-session-screen'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        appBar: AppBar(
          leading: IconButton(
            key: const Key('quiz-session-exit-action'),
            onPressed: () {
              _handleExitPressed(session);
            },
            icon: Icon(
              session.isComplete ? Icons.arrow_back_rounded : Icons.close_rounded,
            ),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  progressLabel,
                  key: const Key('quiz-session-progress'),
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              QuizDifficultyBadge(
                difficulty: session.currentDifficulty,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QuizQuestionView(
                        question: question,
                        showFullVerseAction: shouldOfferFullVerse,
                        isFullVerseVisible: _isFullVerseVisible,
                        onToggleFullVerse: shouldOfferFullVerse
                            ? () {
                                setState(() {
                                  _isFullVerseVisible = !_isFullVerseVisible;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(height: 18),
                      for (var index = 0; index < question.choices.length; index += 1)
                        QuizAnswerChoice(
                          choiceIndex: index,
                          label: question.choices[index],
                          state: _choiceStateFor(
                            question: question,
                            answer: currentAnswer,
                            choiceIndex: index,
                          ),
                          isLocked: isQuestionLocked,
                          onTap: () {
                            _handleSelectAnswer(index, answer: currentAnswer);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: currentAnswer == null
                    ? const SizedBox(height: 12)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          key: Key(
                            'quiz-session-feedback-${currentAnswer.isCorrect}',
                          ),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _QuizAnswerFeedbackBanner(
                              isCorrect: currentAnswer.isCorrect,
                            ),
                            if (showNextAction) ...[
                              const SizedBox(height: 12),
                              FilledButton(
                                key: const Key('quiz-session-next-action'),
                                onPressed: _isAdvancing
                                    ? null
                                    : () {
                                        _handleMoveNext();
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  l10n.quizNext,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  QuizQuestion? _syncDisplayedQuestion(QuizSessionState? session) {
    final currentQuestion = session?.currentQuestion;
    if (currentQuestion != null &&
        _displayedQuestionIndex != session!.currentQuestionIndex) {
      _displayedQuestion = currentQuestion;
      _displayedQuestionIndex = session.currentQuestionIndex;
      _isFullVerseVisible = false;
    } else if (_displayedQuestion == null && currentQuestion != null) {
      _displayedQuestion = currentQuestion;
      _displayedQuestionIndex = session!.currentQuestionIndex;
    }

    return currentQuestion ?? _displayedQuestion;
  }

  QuizAnswer? _answerFor(List<QuizAnswer> answers, int questionIndex) {
    for (final answer in answers) {
      if (answer.questionIndex == questionIndex) {
        return answer;
      }
    }

    return null;
  }

  QuizAnswerChoiceState _choiceStateFor({
    required QuizQuestion question,
    required QuizAnswer? answer,
    required int choiceIndex,
  }) {
    if (answer == null) {
      return QuizAnswerChoiceState.idle;
    }

    if (choiceIndex == answer.selectedIndex) {
      return answer.isCorrect
          ? QuizAnswerChoiceState.correct
          : QuizAnswerChoiceState.incorrect;
    }

    if (!answer.isCorrect && choiceIndex == question.correctIndex) {
      return QuizAnswerChoiceState.revealed;
    }

    return QuizAnswerChoiceState.idle;
  }

  Future<void> _handleSelectAnswer(
    int selectedIndex, {
    required QuizAnswer? answer,
  }) async {
    if (answer != null || _isSubmittingAnswer) {
      return;
    }

    setState(() {
      _isSubmittingAnswer = true;
    });

    try {
      await ref.read(quizSessionProvider.notifier).submitAnswer(selectedIndex);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingAnswer = false;
        });
      }
    }
  }

  Future<void> _handleMoveNext() async {
    if (_isAdvancing) {
      return;
    }

    setState(() {
      _isAdvancing = true;
    });

    try {
      await ref.read(quizSessionProvider.notifier).moveToNextQuestion();
    } finally {
      if (mounted) {
        setState(() {
          _isAdvancing = false;
        });
      }
    }
  }

  Future<void> _handleExitPressed(QuizSessionState session) async {
    if (session.isComplete) {
      Navigator.of(context).maybePop();
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = dialogContext.l10n;

        return AlertDialog(
          title: Text(l10n.quizExitConfirmTitle),
          content: Text(l10n.quizExitConfirmMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(l10n.quizExitCancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(l10n.quizExitConfirm),
            ),
          ],
        );
      },
    );

    if (shouldExit != true || !mounted) {
      return;
    }

    ref.read(quizSessionProvider.notifier).discardSession();
    widget.onExitConfirmed?.call();

    if (widget.onExitConfirmed == null) {
      Navigator.of(context).maybePop();
    }
  }
}

class _QuizAnswerFeedbackBanner extends StatelessWidget {
  const _QuizAnswerFeedbackBanner({
    required this.isCorrect,
  });

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isCorrect ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.72 : 0.38),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Text(
            isCorrect ? context.l10n.quizCorrect : context.l10n.quizIncorrect,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
