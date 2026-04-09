import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/widgets/app_error_widget.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_session_config_sheet.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_type_card.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';

class QuizHubScreen extends ConsumerWidget {
  const QuizHubScreen({
    super.key,
    this.onHistoryPressed,
    this.onBeginQuiz,
  });

  final VoidCallback? onHistoryPressed;
  final Future<void> Function(BuildContext context, QuizSessionConfig config)?
      onBeginQuiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availabilityAsync = ref.watch(quizTypeAvailabilityProvider);
    final mistakeCountsAsync = ref.watch(quizMistakeCountsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          l10n.quizHubTitle,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            key: const Key('quiz-hub-history-action'),
            onPressed: onHistoryPressed,
            icon: const Icon(Icons.history_rounded),
            label: Text(l10n.quizHistoryTitle),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: availabilityAsync.when(
        data: (availability) {
          final mistakeCounts =
              mistakeCountsAsync.valueOrNull ?? const <QuizType, int>{};

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              Text(
                l10n.quizHubDescription,
                key: const Key('quiz-hub-description'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              for (final quizType in QuizType.values)
                QuizTypeCard(
                  quizType: quizType,
                  isAvailable: availability[quizType] ?? false,
                  mistakeCount: mistakeCounts[quizType] ?? 0,
                  onPressed: () => _openConfigSheet(
                    context: context,
                    ref: ref,
                    quizType: quizType,
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
            ref.invalidate(quizTypeAvailabilityProvider);
            ref.invalidate(quizMistakeCountsProvider);
          },
        ),
      ),
    );
  }

  Future<void> _openConfigSheet({
    required BuildContext context,
    required WidgetRef ref,
    required QuizType quizType,
  }) async {
    await showQuizSessionConfigSheet(
      context: context,
      quizType: quizType,
      onBegin: (config) async {
        final beginQuiz = onBeginQuiz;
        if (beginQuiz != null) {
          await beginQuiz(context, config);
          return;
        }

        await ref.read(quizSessionProvider.notifier).startSession(config);
      },
    );
  }
}
