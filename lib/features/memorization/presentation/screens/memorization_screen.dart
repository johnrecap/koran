import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_factory.dart';
import 'package:quran_kareem/features/memorization/domain/memorization_hub_summary.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/bookmark_tile.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/khatma_card.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/memorization_hub_hero.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/memorization_reviews_summary_card.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/memorization_hub_section.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/new_khatma_dialog.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/session_tile.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/torn_paper_banner.dart';
import 'package:quran_kareem/features/reader/providers/manual_bookmarks_provider.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

class MemorizationScreen extends ConsumerStatefulWidget {
  const MemorizationScreen({super.key});

  @override
  ConsumerState<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends ConsumerState<MemorizationScreen> {
  final _sessionsSectionKey = GlobalKey();
  final _bookmarksSectionKey = GlobalKey();

  Future<void> _openReaderAtAyah({
    required int surahNumber,
    required int ayahNumber,
    ReaderSessionIntent intent = const ReaderSessionIntent.general(),
  }) async {
    final resolvePage = ref.read(memorizationAyahPageResolverProvider);
    final pageNumber = await resolvePage(surahNumber, ayahNumber);

    if (!mounted) {
      return;
    }

    final target = ReaderEntryTargetPolicy.forSurah(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      pageNumber: pageNumber,
    );
    _openReaderTarget(target, intent: intent);
  }

  void _openReaderTarget(
    ReaderNavigationTarget target, {
    ReaderSessionIntent intent = const ReaderSessionIntent.general(),
  }) {
    ref.read(readerSessionIntentProvider.notifier).state = intent;
    ref.read(currentSurahProvider.notifier).state = target.surahNumber;
    ref.read(quranPageIndexProvider.notifier).state = target.pageNumber;
    ref.read(readerNavigationTargetProvider.notifier).state = target;
    context.go('/reader');
  }

  void _openKhatmaPlanner(String khatmaId) {
    context.go('/memorization/khatma/$khatmaId');
  }

  void _openAchievements() {
    context.go('/memorization/achievements');
  }

  void _openQuizHub() {
    context.go('/memorization/quiz');
  }

  Future<void> _resumeActiveKhatma(MemorizationHubSummary summary) async {
    final activeKhatma = summary.activeKhatma;
    if (activeKhatma == null) {
      _showNewKhatmaDialog();
      return;
    }

    final latestSession = summary.activeKhatmaSession;
    if (latestSession != null) {
      await _openReaderAtAyah(
        surahNumber: latestSession.surahNumber,
        ayahNumber: latestSession.ayahNumber,
        intent: ReaderSessionIntent.khatma(activeKhatma.id),
      );
      return;
    }

    final nextSurahNumber = (activeKhatma.completedSurahs + 1).clamp(1, 114);
    await _openReaderAtAyah(
      surahNumber: nextSurahNumber,
      ayahNumber: 1,
      intent: ReaderSessionIntent.khatma(activeKhatma.id),
    );
  }

  Future<void> _navigateToSession(ReadingSession session) async {
    await _openReaderAtAyah(
      surahNumber: session.surahNumber,
      ayahNumber: session.ayahNumber,
    );
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final targetContext = key.currentContext;
    if (targetContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _showNewKhatmaDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => NewKhatmaDialog(
        onCreate: (title, days) {
          ref.read(khatmasProvider.notifier).addKhatma(
                KhatmaFactory.create(
                  title: title,
                  targetDays: days,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = ref.watch(memorizationHubSummaryProvider);
    final reviewSummary = ref.watch(spacedReviewQueueSummaryProvider);
    final reviewNow = ref.watch(spacedReviewNowProvider)();
    final bookmarks = ref.watch(manualBookmarksProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          TornPaperBanner(title: l10n.memorizationTitle),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                children: [
                  MemorizationHubHero(
                    summary: summary,
                    onPrimaryAction: () {
                      _resumeActiveKhatma(summary);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context, summary),
                  const SizedBox(height: 16),
                  MemorizationHubSection(
                    key: _sessionsSectionKey,
                    title: l10n.memorizationHubRecentSessions,
                    subtitle: l10n.memorizationHubRecentSessionsSubtitle,
                    child: summary.recentRegularSessions.isEmpty
                        ? _MemorizationSectionEmptyState(
                            icon: Icons.menu_book_rounded,
                            title: l10n.memorizationSessionsEmptyTitle,
                            subtitle: l10n.memorizationSessionsEmptySubtitle,
                          )
                        : Column(
                            children: summary.recentRegularSessions
                                .map(
                                  (session) => SessionTile(
                                    session: session,
                                    onTap: () {
                                      _navigateToSession(session);
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  MemorizationHubSection(
                    title: l10n.memorizationHubKhatmasTitle,
                    subtitle: l10n.memorizationHubKhatmasSubtitle,
                    trailing: TextButton(
                      onPressed: _showNewKhatmaDialog,
                      child: Text(l10n.memorizationKhatmasNew),
                    ),
                    child: summary.activeKhatmas.isEmpty &&
                            summary.completedKhatmas.isEmpty
                        ? _MemorizationSectionEmptyState(
                            icon: Icons.auto_stories_rounded,
                            title: l10n.memorizationKhatmasEmptyTitle,
                            subtitle: l10n.memorizationKhatmasEmptySubtitle,
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                ...summary.activeKhatmas.map(
                                  (khatma) => KhatmaCard(
                                    khatma: khatma,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    onTap: () {
                                      _openKhatmaPlanner(khatma.id);
                                    },
                                  ),
                                ),
                                ...summary.completedKhatmas.map(
                                  (khatma) => KhatmaCard(
                                    khatma: khatma,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    onTap: () {
                                      _openKhatmaPlanner(khatma.id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  MemorizationHubSection(
                    key: _bookmarksSectionKey,
                    title: l10n.memorizationHubBookmarksTitle,
                    subtitle: l10n.memorizationHubBookmarksSubtitle,
                    child: bookmarks.isEmpty
                        ? _MemorizationSectionEmptyState(
                            icon: Icons.bookmark_border_rounded,
                            title: l10n.memorizationBookmarksEmptyTitle,
                            subtitle: l10n.memorizationBookmarksEmptySubtitle,
                          )
                        : Column(
                            children: bookmarks
                                .map(
                                  (bookmark) => BookmarkTile(
                                    bookmark: bookmark,
                                    onTap: () {
                                      _openReaderAtAyah(
                                        surahNumber: bookmark.surahNumber,
                                        ayahNumber: bookmark.ayahNumber,
                                      );
                                    },
                                    onRemove: () {
                                      ref
                                          .read(
                                            manualBookmarksProvider.notifier,
                                          )
                                          .toggle(
                                            bookmark.surahNumber,
                                            bookmark.ayahNumber,
                                            bookmark.surahName,
                                          );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  MemorizationHubSection(
                    title: l10n.memorizationHubUpcomingReviewsTitle,
                    subtitle: l10n.memorizationHubUpcomingReviewsSubtitle,
                    child: MemorizationReviewsSummaryCard(
                      summary: reviewSummary,
                      now: reviewNow,
                      onStartReviews: () {
                        context.go('/memorization/reviews');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    MemorizationHubSummary summary,
  ) {
    final l10n = context.l10n;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (summary.hasActiveKhatma)
            FilledButton.icon(
              onPressed: () {
                _resumeActiveKhatma(summary);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.memorizationHubResume),
            ),
          OutlinedButton.icon(
            onPressed: _showNewKhatmaDialog,
            icon: const Icon(Icons.add_rounded, color: AppColors.gold),
            label: Text(l10n.memorizationKhatmasNew),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.42),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              _scrollToSection(_sessionsSectionKey);
            },
            icon: const Icon(Icons.history_rounded),
            label: Text(l10n.memorizationHubAllSessions),
          ),
          TextButton.icon(
            onPressed: _openAchievements,
            icon: const Icon(Icons.workspace_premium_rounded),
            label: Text(l10n.achievementsTitle),
          ),
          TextButton.icon(
            onPressed: _openQuizHub,
            icon: const Icon(Icons.quiz_rounded),
            label: Text(l10n.memorizationQuizAction),
          ),
          TextButton.icon(
            onPressed: () => context.go('/analytics'),
            icon: const Icon(Icons.insights_rounded),
            label: Text(l10n.analyticsTitle),
          ),
          TextButton.icon(
            onPressed: () {
              _scrollToSection(_bookmarksSectionKey);
            },
            icon: const Icon(Icons.bookmarks_rounded),
            label: Text(l10n.memorizationHubBookmarksTitle),
          ),
        ],
      ),
    );
  }
}

class _MemorizationSectionEmptyState extends StatelessWidget {
  const _MemorizationSectionEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: AppColors.gold.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
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
    );
  }
}
