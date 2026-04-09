import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_planner_summary.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/khatma_planner_assignment_card.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/khatma_planner_hero.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/khatma_planner_metrics_row.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/torn_paper_banner.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

class KhatmaPlannerScreen extends ConsumerWidget {
  const KhatmaPlannerScreen({
    super.key,
    required this.khatmaId,
  });

  final String khatmaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = ref.watch(khatmaPlannerSummaryProvider(khatmaId));

    if (summary == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        body: Center(
          child: Text(context.l10n.memorizationKhatmasEmptyTitle),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          TornPaperBanner(title: summary.khatma.title),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                children: [
                  KhatmaPlannerHero(
                    summary: summary,
                    onResume: () => _resumeReading(context, ref, summary),
                  ),
                  const SizedBox(height: 16),
                  KhatmaPlannerAssignmentCard(summary: summary),
                  const SizedBox(height: 16),
                  KhatmaPlannerMetricsRow(summary: summary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resumeReading(
    BuildContext context,
    WidgetRef ref,
    KhatmaPlannerSummary summary,
  ) async {
    final latestSession = summary.latestSession;
    if (latestSession != null) {
      final resolvePage = ref.read(memorizationAyahPageResolverProvider);
      final pageNumber = await resolvePage(
        latestSession.surahNumber,
        latestSession.ayahNumber,
      );
      if (!context.mounted) {
        return;
      }

      _openReaderTarget(
        context,
        ref,
        ReaderEntryTargetPolicy.forSurah(
          surahNumber: latestSession.surahNumber,
          ayahNumber: latestSession.ayahNumber,
          pageNumber: pageNumber,
        ),
        khatmaId: summary.khatma.id,
      );
      return;
    }

    final resolveAyah = ref.read(memorizationPageAyahResolverProvider);
    final ayah = await resolveAyah(summary.nextPageToRead);
    if (!context.mounted || ayah == null) {
      return;
    }

    _openReaderTarget(
      context,
      ref,
      ReaderEntryTargetPolicy.forSurah(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        pageNumber: summary.nextPageToRead,
      ),
      khatmaId: summary.khatma.id,
    );
  }

  void _openReaderTarget(
    BuildContext context,
    WidgetRef ref,
    ReaderNavigationTarget target,
    {
    required String khatmaId,
  }
  ) {
    ref.read(readerSessionIntentProvider.notifier).state =
        ReaderSessionIntent.khatma(khatmaId);
    ref.read(currentSurahProvider.notifier).state = target.surahNumber;
    ref.read(quranPageIndexProvider.notifier).state = target.pageNumber;
    ref.read(readerNavigationTargetProvider.notifier).state = target;
    context.go('/reader');
  }
}
