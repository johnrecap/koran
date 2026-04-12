import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/widgets/app_error_widget.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_chapter.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:quran_kareem/features/stories/domain/story_verse.dart';
import 'package:quran_kareem/features/stories/presentation/shareable_story_card.dart';
import 'package:quran_kareem/features/stories/presentation/story_chapter_nav.dart';
import 'package:quran_kareem/features/stories/presentation/story_chapter_view.dart';
import 'package:quran_kareem/features/stories/presentation/story_completion_view.dart';
import 'package:quran_kareem/features/stories/providers/story_providers.dart';

class StoryReaderScreen extends ConsumerStatefulWidget {
  StoryReaderScreen({
    super.key,
    required this.storyId,
    this.onVersePressed,
    this.onBackToHub,
    this.onSharePressed,
    StoryCardImageExporter? imageExporter,
  }) : imageExporter = imageExporter ?? StoryCardImageExporter();

  final String storyId;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    StoryVerse verse,
  )? onVersePressed;
  final VoidCallback? onBackToHub;
  final VoidCallback? onSharePressed;
  final StoryCardImageExporter imageExporter;

  @override
  ConsumerState<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends ConsumerState<StoryReaderScreen> {
  PageController? _pageController;
  Timer? _progressDebounce;
  String? _initializedStoryId;
  bool _isInitializingStory = false;
  bool _isSharing = false;
  int _currentPageIndex = 0;
  final GlobalKey _shareCardKey = GlobalKey();
  QuranStory? _currentStoryForShare;

  @override
  void dispose() {
    _progressDebounce?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    final callback = widget.onSharePressed;
    if (callback != null) {
      callback();
      return;
    }

    final story = _currentStoryForShare;
    if (story == null || _isSharing) {
      return;
    }

    final chapters = _sortedChapters(story);
    if (_currentPageIndex < 0 || _currentPageIndex >= chapters.length) {
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      await Future<void>.delayed(Duration.zero);
      final pngBytes = await widget.imageExporter.captureCard(_shareCardKey);
      if (!mounted) {
        return;
      }

      if (pngBytes == null) {
        _showShareFailure();
        return;
      }

      final didShare = await widget.imageExporter.shareImage(
        pngBytes,
        '${story.id}-${chapters[_currentPageIndex].id}',
      );
      if (!mounted) {
        return;
      }

      if (!didShare) {
        _showShareFailure();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _showShareFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.storiesShareUnavailable)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storiesAsync = ref.watch(storyIndexProvider);
    final storyMeta = storiesAsync.valueOrNull == null
        ? null
        : _storyForId(storiesAsync.valueOrNull!, widget.storyId);
    final isBookmarked =
        ref.watch(storyBookmarkNotifierProvider).contains(widget.storyId);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          _titleForStory(context, storyMeta),
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: storyMeta == null
            ? null
            : [
                AnimatedScale(
                  scale: isBookmarked ? 1 : 0.92,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: IconButton(
                    key: const Key('story-reader-bookmark-toggle'),
                    tooltip: isBookmarked
                        ? context.l10n.storiesRemoveFromFavorites
                        : context.l10n.storiesAddToFavorites,
                    onPressed: () {
                      unawaited(
                        ref
                            .read(storyBookmarkNotifierProvider.notifier)
                            .toggle(widget.storyId),
                      );
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isBookmarked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey<bool>(isBookmarked),
                        color: isBookmarked ? AppColors.gold : null,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('story-reader-share'),
                  tooltip: context.l10n.storiesShareChapter,
                  onPressed: _isSharing ? null : _handleShare,
                  icon: const Icon(Icons.ios_share_rounded),
                ),
              ],
      ),
      body: storiesAsync.when(
        data: (stories) {
          final resolvedMeta = _storyForId(stories, widget.storyId);
          if (resolvedMeta == null ||
              resolvedMeta.file == null ||
              resolvedMeta.file!.trim().isEmpty) {
            return AppErrorWidget(
              message: context.l10n.errorLoadingData,
              onRetry: () {
                ref.invalidate(storyIndexProvider);
              },
            );
          }

          final storyDetailAsync =
              ref.watch(storyDetailProvider(resolvedMeta.file!));
          return storyDetailAsync.when(
            data: (storyDetail) => _buildStoryContent(
              context,
              _mergeStory(meta: resolvedMeta, detail: storyDetail),
            ),
            loading: () => const _StoryReaderLoadingView(),
            error: (_, __) => AppErrorWidget(
              message: context.l10n.errorLoadingData,
              onRetry: () {
                ref.invalidate(storyDetailProvider(resolvedMeta.file!));
              },
            ),
          );
        },
        loading: () => const _StoryReaderLoadingView(),
        error: (_, __) => AppErrorWidget(
          message: context.l10n.errorLoadingData,
          onRetry: () {
            ref.invalidate(storyIndexProvider);
          },
        ),
      ),
    );
  }

  Widget _buildStoryContent(BuildContext context, QuranStory story) {
    _currentStoryForShare = story;

    final chapters = _sortedChapters(story);
    if (chapters.isEmpty) {
      return AppErrorWidget(message: context.l10n.errorLoadingData);
    }

    _ensureInitialized(story, chapters.length);
    final pageController = _pageController;

    if (_initializedStoryId != story.id || pageController == null) {
      return const _StoryReaderLoadingView();
    }

    final isCompletionPage = _currentPageIndex >= chapters.length;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: PageView.builder(
                key: const Key('story-reader-page-view'),
                controller: pageController,
                itemCount: chapters.length + 1,
                onPageChanged: (page) => _handlePageChanged(story, page),
                itemBuilder: (context, index) {
                  if (index >= chapters.length) {
                    return StoryCompletionView(
                      story: story,
                      onMarkAsRead: () {
                        unawaited(
                          ref
                              .read(storyProgressNotifierProvider.notifier)
                              .markCompleted(story.id),
                        );
                      },
                      onBackToHub: _handleBackToHub,
                    );
                  }

                  final chapter = chapters[index];
                  return StoryChapterView(
                    key: ValueKey('${story.id}-${chapter.id}-$index'),
                    chapter: chapter,
                    onVersePressed: (verse) {
                      unawaited(_handleVersePressed(verse));
                    },
                  );
                },
              ),
            ),
            if (!isCompletionPage)
              StoryChapterNav(
                currentChapterIndex: _currentPageIndex,
                totalChapters: chapters.length,
                onPrevious: _currentPageIndex <= 0
                    ? null
                    : () => _animateToPage(_currentPageIndex - 1),
                onNext: _currentPageIndex >= chapters.length
                    ? null
                    : () => _animateToPage(
                          (_currentPageIndex + 1).clamp(0, chapters.length),
                        ),
              ),
          ],
        ),
        PositionedDirectional(
          start: -10000,
          top: 0,
          child: IgnorePointer(
            child: RepaintBoundary(
              key: _shareCardKey,
              child: SizedBox(
                width: 380,
                child: ShareableStoryCard(
                  story: story,
                  chapter:
                      chapters[_currentPageIndex.clamp(0, chapters.length - 1)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _ensureInitialized(QuranStory story, int chapterCount) {
    if (_initializedStoryId == story.id || _isInitializingStory) {
      return;
    }

    _isInitializingStory = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeStory(story, chapterCount));
    });
  }

  Future<void> _initializeStory(QuranStory story, int chapterCount) async {
    await ref.read(storyProgressNotifierProvider.notifier).ready;
    if (!mounted) {
      return;
    }

    final progress = ref.read(storyProgressNotifierProvider)[story.id];
    final initialPage = _resolveInitialPage(
      progress: progress,
      chapterCount: chapterCount,
    );
    final nextController = PageController(initialPage: initialPage);

    _pageController?.dispose();

    setState(() {
      _pageController = nextController;
      _currentPageIndex = initialPage;
      _initializedStoryId = story.id;
      _isInitializingStory = false;
    });

    _scheduleProgressSave(story, initialPage);
  }

  int _resolveInitialPage({
    required StoryReadingProgress? progress,
    required int chapterCount,
  }) {
    if (chapterCount <= 0 || progress == null) {
      return 0;
    }

    if (progress.isCompleted) {
      return chapterCount;
    }

    return (progress.lastChapterIndex + 1).clamp(0, chapterCount);
  }

  void _handlePageChanged(QuranStory story, int page) {
    setState(() {
      _currentPageIndex = page;
    });
    _scheduleProgressSave(story, page);
  }

  void _scheduleProgressSave(QuranStory story, int pageIndex) {
    _progressDebounce?.cancel();

    if (story.chapterCount <= 0) {
      return;
    }

    final chapterIndex = pageIndex.clamp(0, story.chapterCount - 1);
    _progressDebounce = Timer(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }

      unawaited(
        ref
            .read(storyProgressNotifierProvider.notifier)
            .updateProgress(story.id, chapterIndex, story.chapterCount),
      );
    });
  }

  Future<void> _animateToPage(int page) async {
    final controller = _pageController;
    if (controller == null) {
      return;
    }

    await controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleVersePressed(StoryVerse verse) async {
    final customHandler = widget.onVersePressed;
    if (customHandler != null) {
      await customHandler(context, ref, verse);
      return;
    }

    final pageNumber = await QuranDatabase.getPageForAyah(
      verse.surah,
      verse.ayahStart,
    );
    if (!mounted) {
      return;
    }

    ref.read(readerSessionIntentProvider.notifier).state =
        const ReaderSessionIntent.general();
    ref.read(currentSurahProvider.notifier).state = verse.surah;
    ref.read(quranPageIndexProvider.notifier).state = pageNumber;
    ref.read(readerNavigationTargetProvider.notifier).state =
        ReaderEntryTargetPolicy.forSurah(
      surahNumber: verse.surah,
      ayahNumber: verse.ayahStart,
      pageNumber: pageNumber,
    );

    await context.push('/reader');
  }

  void _handleBackToHub() {
    final callback = widget.onBackToHub;
    if (callback != null) {
      callback();
      return;
    }

    Navigator.of(context).maybePop();
  }

  String _titleForStory(BuildContext context, QuranStory? story) {
    if (story == null) {
      return context.l10n.quranStories;
    }

    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (isEnglish && story.titleEn.trim().isNotEmpty) {
      return story.titleEn;
    }
    return story.titleAr;
  }
}

QuranStory? _storyForId(List<QuranStory> stories, String storyId) {
  for (final story in stories) {
    if (story.id == storyId) {
      return story;
    }
  }
  return null;
}

QuranStory _mergeStory({
  required QuranStory meta,
  required QuranStory detail,
}) {
  return QuranStory(
    id: detail.id.isNotEmpty ? detail.id : meta.id,
    file: detail.file ?? meta.file,
    titleAr: detail.titleAr.isNotEmpty ? detail.titleAr : meta.titleAr,
    titleEn: detail.titleEn.isNotEmpty ? detail.titleEn : meta.titleEn,
    category: detail.category,
    iconKey: detail.iconKey.isNotEmpty ? detail.iconKey : meta.iconKey,
    summaryAr: detail.summaryAr.isNotEmpty ? detail.summaryAr : meta.summaryAr,
    summaryEn: detail.summaryEn.isNotEmpty ? detail.summaryEn : meta.summaryEn,
    chapterCount:
        detail.chapterCount > 0 ? detail.chapterCount : meta.chapterCount,
    totalVerses: detail.totalVerses > 0 ? detail.totalVerses : meta.totalVerses,
    estimatedReadingMinutes: detail.estimatedReadingMinutes > 0
        ? detail.estimatedReadingMinutes
        : meta.estimatedReadingMinutes,
    mainSurahsAr: detail.mainSurahsAr.isNotEmpty
        ? detail.mainSurahsAr
        : meta.mainSurahsAr,
    mainSurahsNumbers: detail.mainSurahsNumbers.isNotEmpty
        ? detail.mainSurahsNumbers
        : meta.mainSurahsNumbers,
    order: detail.order ?? meta.order,
    chapters: detail.chapters,
  );
}

List<StoryChapter> _sortedChapters(QuranStory story) {
  final chapters =
      List<StoryChapter>.from(story.chapters ?? const <StoryChapter>[]);
  chapters.sort((left, right) => left.order.compareTo(right.order));
  return List<StoryChapter>.unmodifiable(chapters);
}

class _StoryReaderLoadingView extends StatelessWidget {
  const _StoryReaderLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _StoryReaderSkeletonBlock(height: 34, widthFactor: 0.58),
        SizedBox(height: 10),
        _StoryReaderSkeletonBlock(height: 16, widthFactor: 0.26),
        SizedBox(height: 22),
        _StoryReaderSkeletonBlock(height: 220, widthFactor: 1),
        SizedBox(height: 16),
        _StoryReaderSkeletonBlock(height: 176, widthFactor: 1),
        SizedBox(height: 16),
        _StoryReaderSkeletonBlock(height: 108, widthFactor: 1),
      ],
    );
  }
}

class _StoryReaderSkeletonBlock extends StatelessWidget {
  const _StoryReaderSkeletonBlock({
    required this.height,
    required this.widthFactor,
  });

  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.camel.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
