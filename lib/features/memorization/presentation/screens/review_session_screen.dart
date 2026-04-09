import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/spaced_review_tile.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

class ReviewSessionScreen extends ConsumerStatefulWidget {
  const ReviewSessionScreen({
    super.key,
    required this.reviewId,
  });

  final String reviewId;

  @override
  ConsumerState<ReviewSessionScreen> createState() =>
      _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  bool _hasOpenedReader = false;

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(spacedReviewItemByIdProvider(widget.reviewId));
    final now = ref.watch(spacedReviewNowProvider)();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.memorizationReviewsSessionTitle),
      ),
      body: item == null
          ? _ReviewSessionEmptyState(
              title: context.l10n.memorizationReviewsQueueEmptyTitle,
              subtitle: context.l10n.memorizationReviewsQueueEmptySubtitle,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReviewSessionCard(
                    child: SpacedReviewTile(
                      item: item,
                      now: now,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ReviewSessionCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _hasOpenedReader
                              ? context.l10n.memorizationReviewsChooseResult
                              : context.l10n.memorizationReviewsOpenReaderFirst,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!_hasOpenedReader)
                          FilledButton.icon(
                            onPressed: () {
                              _openReader(item);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.menu_book_rounded),
                            label: Text(
                              context.l10n.memorizationReviewsOpenReader,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _OutcomeButton(
                                label: context.l10n.memorizationReviewsEasy,
                                onPressed: () {
                                  _submitOutcome(
                                    reviewId: item.id,
                                    outcome: ReviewOutcome.easy,
                                  );
                                },
                              ),
                              _OutcomeButton(
                                label: context.l10n.memorizationReviewsMedium,
                                onPressed: () {
                                  _submitOutcome(
                                    reviewId: item.id,
                                    outcome: ReviewOutcome.medium,
                                  );
                                },
                              ),
                              _OutcomeButton(
                                label: context.l10n.memorizationReviewsHard,
                                onPressed: () {
                                  _submitOutcome(
                                    reviewId: item.id,
                                    outcome: ReviewOutcome.hard,
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _openReader(SpacedReviewItem item) async {
    final l10n = context.l10n;
    final resolveAyah = ref.read(memorizationPageAyahResolverProvider);
    final ayah = await resolveAyah(item.startPage);

    if (!mounted) {
      return;
    }

    if (ayah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.memorizationReviewsUnableToOpenReader),
        ),
      );
      return;
    }

    ref.read(readerSessionIntentProvider.notifier).state =
        const ReaderSessionIntent.general();
    ref.read(currentSurahProvider.notifier).state = ayah.surahNumber;
    ref.read(quranPageIndexProvider.notifier).state = item.startPage;
    ref.read(readerNavigationTargetProvider.notifier).state =
        ReaderNavigationTarget(
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          pageNumber: item.startPage,
        );

    setState(() {
      _hasOpenedReader = true;
    });

    await context.push('/reader');
  }

  Future<void> _submitOutcome({
    required String reviewId,
    required ReviewOutcome outcome,
  }) async {
    await ref.read(spacedReviewItemsProvider.notifier).recordOutcome(
          reviewId: reviewId,
          outcome: outcome,
          reviewedAt: ref.read(spacedReviewNowProvider)(),
        );

    if (!mounted) {
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/memorization/reviews');
  }
}

class _ReviewSessionCard extends StatelessWidget {
  const _ReviewSessionCard({
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.12 : 0.16),
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _OutcomeButton extends StatelessWidget {
  const _OutcomeButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
}

class _ReviewSessionEmptyState extends StatelessWidget {
  const _ReviewSessionEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
