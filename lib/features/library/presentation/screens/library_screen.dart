import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:quran_kareem/features/library/presentation/widgets/library_ayah_search_result_tile.dart';
import 'package:quran_kareem/features/library/presentation/widgets/library_topic_card.dart';
import 'package:quran_kareem/features/library/presentation/widgets/library_translation_search_result_tile.dart';
import 'package:quran_kareem/features/library/presentation/screens/library_topic_details_screen.dart';
import 'package:quran_kareem/features/library/presentation/widgets/surah_tile.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_factory.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/khatma_card.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/new_khatma_dialog.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/bookmark_tile.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/torn_paper_banner.dart';
import 'package:quran_kareem/features/reader/providers/manual_bookmarks_provider.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _openReaderTarget(ReaderNavigationTarget target) {
    ref.read(readerSessionIntentProvider.notifier).state =
        const ReaderSessionIntent.general();
    ref.read(currentSurahProvider.notifier).state = target.surahNumber;
    ref.read(quranPageIndexProvider.notifier).state = target.pageNumber;
    ref.read(readerNavigationTargetProvider.notifier).state = target;
    context.go('/reader');
  }

  void _openKhatmaPlanner(String khatmaId) {
    context.go('/memorization/khatma/$khatmaId');
  }

  void _openStoriesHub() {
    context.push('/library/stories');
  }

  void _openAiSearch() {
    context.push('/library/ai-search');
  }

  void _openReaderForSurah(Surah surah) {
    _openReaderTarget(
      ReaderEntryTargetPolicy.forSurah(
        surahNumber: surah.number,
        pageNumber: surah.page,
      ),
    );
  }

  Future<void> _openReaderAtAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final pageNumber = await QuranDatabase.getPageForAyah(
      surahNumber,
      ayahNumber,
    );
    if (!mounted) {
      return;
    }

    _openReaderTarget(
      ReaderEntryTargetPolicy.forSurah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        pageNumber: pageNumber,
      ),
    );
  }

  void _setLibrarySearchQuery(
    String value, {
    bool syncController = false,
  }) {
    if (syncController && _searchController.text != value) {
      _searchController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    ref.read(librarySearchQueryProvider.notifier).state = value;
  }

  Future<void> _recordSearch(String query) async {
    await ref.read(librarySearchHistoryProvider.notifier).recordSearch(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _setLibrarySearchQuery('');
  }

  Future<void> _openTopicDetails(LibraryTopic topic) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LibraryTopicDetailsScreen(
          topic: topic,
          onOpenAyah: (result) {
            Navigator.of(context).pop();
            _openReaderTarget(
              ReaderEntryTargetPolicy.forSurah(
                surahNumber: result.ayah.surahNumber,
                ayahNumber: result.ayah.ayahNumber,
                pageNumber: result.ayah.page,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openReaderFromSearchResult(
    Ayah ayah,
    String query,
  ) async {
    await _recordSearch(query);
    if (!mounted) {
      return;
    }

    _openReaderTarget(
      ReaderEntryTargetPolicy.forSurah(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        pageNumber: ayah.page,
      ),
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


    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          TornPaperBanner(title: l10n.libraryTitle),
          SliverPersistentHeader(
            pinned: true,
            delegate: _LibraryTabBarDelegate(
              isDark: isDark,
              tabBar: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.gold,
                indicatorWeight: 3,
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: l10n.libraryTabSurahs),
                  Tab(text: l10n.libraryTabKhatmas),
                  Tab(text: l10n.libraryTabManualSaves),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSurahsTab(context, isDark),
            _buildKhatmasTab(context, isDark),
            _buildManualSavesTab(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahsTab(BuildContext context, bool isDark) {
    final l10n = context.l10n;
    final aiAvailable = ref.watch(aiAvailableProvider);
    final query = ref.watch(librarySearchQueryProvider).trim();
    final searchKind = ref.watch(librarySearchKindProvider);
    final searchScope = ref.watch(librarySearchScopeProvider);
    final selectedTopicCategory =
        ref.watch(librarySelectedTopicCategoryProvider);
    final recentSearches = ref.watch(librarySearchHistoryProvider);
    final filteredSurahs = ref.watch(filteredSurahsProvider);
    final ayahSearchResults = ref.watch(libraryAyahSearchResultsProvider);
    final translationSearchResults =
        ref.watch(libraryTranslationSearchResultsProvider);
    final topicResults = ref.watch(libraryTopicResultsProvider);
    final isSearching = query.isNotEmpty;
    final showTopicBrowser = searchKind == LibrarySearchKind.topics;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            children: [
              OutlinedButton.icon(
                key: const Key('library-stories-entry'),
                onPressed: _openStoriesHub,
                icon: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.gold,
                ),
                label: Text(
                  l10n.quranStories,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              if (aiAvailable) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const Key('library-ai-search-entry'),
                  onPressed: _openAiSearch,
                  icon: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.gold,
                  ),
                  label: Text(
                    l10n.smartSearch,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    side: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                _setLibrarySearchQuery(value);
              },
              onSubmitted: (value) {
                final normalized = value.trim();
                if (normalized.isNotEmpty) {
                  _recordSearch(normalized);
                }
              },
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              decoration: InputDecoration(
                hintText: l10n.librarySearchHint,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Amiri',
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceDarkNav
                    : AppColors.camel.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.librarySearchKindAyahs),
                      selected: searchKind == LibrarySearchKind.ayahs,
                      onSelected: (_) {
                        ref.read(librarySearchKindProvider.notifier).state =
                            LibrarySearchKind.ayahs;
                      },
                      selectedColor: AppColors.gold.withValues(alpha: 0.18),
                      side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.35),
                      ),
                      showCheckmark: false,
                    ),
                    ChoiceChip(
                      label: Text(l10n.librarySearchKindTranslations),
                      selected: searchKind == LibrarySearchKind.translations,
                      onSelected: (_) {
                        ref.read(librarySearchKindProvider.notifier).state =
                            LibrarySearchKind.translations;
                      },
                      selectedColor: AppColors.gold.withValues(alpha: 0.18),
                      side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.35),
                      ),
                      showCheckmark: false,
                    ),
                    ChoiceChip(
                      label: Text(l10n.librarySearchKindTopics),
                      selected: searchKind == LibrarySearchKind.topics,
                      onSelected: (_) {
                        ref.read(librarySearchKindProvider.notifier).state =
                            LibrarySearchKind.topics;
                      },
                      selectedColor: AppColors.gold.withValues(alpha: 0.18),
                      side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.35),
                      ),
                      showCheckmark: false,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (showTopicBrowser)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTopicCategoryChip(
                        context: context,
                        label: l10n.libraryTopicsCategoryAll,
                        category: LibraryTopicCategory.all,
                        selectedCategory: selectedTopicCategory,
                      ),
                      _buildTopicCategoryChip(
                        context: context,
                        label: l10n.libraryTopicsCategoryStories,
                        category: LibraryTopicCategory.stories,
                        selectedCategory: selectedTopicCategory,
                      ),
                      _buildTopicCategoryChip(
                        context: context,
                        label: l10n.libraryTopicsCategoryLaws,
                        category: LibraryTopicCategory.laws,
                        selectedCategory: selectedTopicCategory,
                      ),
                      _buildTopicCategoryChip(
                        context: context,
                        label: l10n.libraryTopicsCategoryAfterlife,
                        category: LibraryTopicCategory.afterlife,
                        selectedCategory: selectedTopicCategory,
                      ),
                    ],
                  )
                else if (isSearching)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.librarySearchScopeFullQuran),
                        selected: searchScope == LibrarySearchScope.fullQuran,
                        onSelected: (_) {
                          ref.read(librarySearchScopeProvider.notifier).state =
                              LibrarySearchScope.fullQuran;
                        },
                        selectedColor: AppColors.gold.withValues(alpha: 0.18),
                        side: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.35),
                        ),
                        showCheckmark: false,
                      ),
                      ChoiceChip(
                        label: Text(l10n.librarySearchScopeCurrentSurah),
                        selected:
                            searchScope == LibrarySearchScope.currentSurah,
                        onSelected: (_) {
                          ref.read(librarySearchScopeProvider.notifier).state =
                              LibrarySearchScope.currentSurah;
                        },
                        selectedColor: AppColors.gold.withValues(alpha: 0.18),
                        side: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.35),
                        ),
                        showCheckmark: false,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (!isSearching && !showTopicBrowser && recentSearches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.libraryRecentSearches,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(librarySearchHistoryProvider.notifier)
                            .clearHistory();
                      },
                      child: Text(l10n.librarySearchClearHistory),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in recentSearches)
                        ActionChip(
                          label: Text(item),
                          avatar: const Icon(
                            Icons.history_rounded,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () {
                            _setLibrarySearchQuery(
                              item,
                              syncController: true,
                            );
                          },
                          side: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.2),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _buildSurahTabBody(
            context: context,
            isDark: isDark,
            query: query,
            isSearching: isSearching,
            searchKind: searchKind,
            showTopicBrowser: showTopicBrowser,
            filteredSurahs: filteredSurahs,
            ayahSearchResults: ayahSearchResults,
            translationSearchResults: translationSearchResults,
            topicResults: topicResults,
          ),
        ),
      ],
    );
  }

  Widget _buildSurahTabBody({
    required BuildContext context,
    required bool isDark,
    required String query,
    required bool isSearching,
    required LibrarySearchKind searchKind,
    required bool showTopicBrowser,
    required AsyncValue<List<Surah>> filteredSurahs,
    required AsyncValue<List<LibraryAyahSearchResult>> ayahSearchResults,
    required AsyncValue<List<LibraryTranslationSearchResult>>
        translationSearchResults,
    required AsyncValue<List<LibraryTopic>> topicResults,
  }) {
    final l10n = context.l10n;

    if (showTopicBrowser) {
      return topicResults.when(
        data: (results) {
          if (results.isEmpty) {
            return _LibraryEmptyState(
              icon: Icons.topic_outlined,
              title: l10n.libraryTopicsEmpty,
              subtitle: null,
              isDark: isDark,
            );
          }

          final languageCode = Localizations.localeOf(context).languageCode;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final topic = results[index];
              return LibraryTopicCard(
                topic: topic,
                languageCode: languageCode,
                onTap: () => _openTopicDetails(topic),
              );
            },
          );
        },
        loading: () => _LibraryLoadingState(
          message: l10n.libraryTopicsLoading,
          isDark: isDark,
        ),
        error: (error, stackTrace) => _LibraryEmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.libraryTopicsLoadError,
          subtitle: null,
          isDark: isDark,
        ),
      );
    }

    if (isSearching) {
      if (searchKind == LibrarySearchKind.ayahs) {
        return ayahSearchResults.when(
          data: (results) {
            if (results.isEmpty) {
              return _LibraryEmptyState(
                icon: Icons.search_off_rounded,
                title: l10n.librarySearchResultsEmpty,
                subtitle: null,
                isDark: isDark,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return LibraryAyahSearchResultTile(
                  result: result,
                  query: query,
                  onTap: () => _openReaderFromSearchResult(
                    result.ayah,
                    query,
                  ),
                );
              },
            );
          },
          loading: () => _LibraryLoadingState(
            message: l10n.librarySearchResultsLoading,
            isDark: isDark,
          ),
          error: (error, stackTrace) => _LibraryEmptyState(
            icon: Icons.error_outline_rounded,
            title: l10n.librarySearchLoadError,
            subtitle: null,
            isDark: isDark,
          ),
        );
      }

      return translationSearchResults.when(
        data: (results) {
          if (results.isEmpty) {
            return _LibraryEmptyState(
              icon: Icons.translate_rounded,
              title: l10n.libraryTranslationSearchResultsEmpty,
              subtitle: null,
              isDark: isDark,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return LibraryTranslationSearchResultTile(
                result: result,
                query: query,
                onTap: () => _openReaderFromSearchResult(
                  result.ayah,
                  query,
                ),
              );
            },
          );
        },
        loading: () => _LibraryLoadingState(
          message: l10n.libraryTranslationSearchResultsLoading,
          isDark: isDark,
        ),
        error: (error, stackTrace) => _LibraryEmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.libraryTranslationSearchLoadError,
          subtitle: null,
          isDark: isDark,
        ),
      );
    }

    return filteredSurahs.when(
      data: (surahs) {
        if (surahs.isEmpty) {
          return _LibraryEmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.libraryNoResults,
            subtitle: null,
            isDark: isDark,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return SurahTile(
              surah: surah,
              onTap: () => _openReaderForSurah(surah),
            );
          },
        );
      },
      loading: () => _LibraryLoadingState(
        message: l10n.librarySurahsLoading,
        isDark: isDark,
      ),
      error: (error, stackTrace) => _LibraryEmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.librarySurahsLoadError,
        subtitle: null,
        isDark: isDark,
      ),
    );
  }

  Widget _buildTopicCategoryChip({
    required BuildContext context,
    required String label,
    required LibraryTopicCategory category,
    required LibraryTopicCategory selectedCategory,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedCategory == category,
      onSelected: (_) {
        ref.read(librarySelectedTopicCategoryProvider.notifier).state =
            category;
      },
      selectedColor: AppColors.gold.withValues(alpha: 0.18),
      side: BorderSide(
        color: AppColors.gold.withValues(alpha: 0.35),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildKhatmasTab(BuildContext context, bool isDark) {
    final l10n = context.l10n;
    final khatmas = ref.watch(effectiveKhatmasProvider);

    if (khatmas.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        children: [
          _buildCreateKhatmaButton(context),
          const SizedBox(height: 24),
          _LibraryEmptyState(
            icon: Icons.auto_stories_rounded,
            title: l10n.libraryKhatmasEmptyTitle,
            subtitle: l10n.libraryKhatmasEmptySubtitle,
            isDark: isDark,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      children: [
        _buildCreateKhatmaButton(context),
        const SizedBox(height: 12),
        ...khatmas.map(
          (khatma) => KhatmaCard(
            khatma: khatma,
            onTap: () => _openKhatmaPlanner(khatma.id),
          ),
        ),
      ],
    );
  }

  Widget _buildManualSavesTab(BuildContext context, bool isDark) {
    final l10n = context.l10n;
    final bookmarks = ref.watch(manualBookmarksProvider);

    if (bookmarks.isEmpty) {
      return _LibraryEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: l10n.libraryManualSavesEmptyTitle,
        subtitle: l10n.libraryManualSavesEmptySubtitle,
        isDark: isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return BookmarkTile(
          bookmark: bookmark,
          onTap: () => _openReaderAtAyah(
            surahNumber: bookmark.surahNumber,
            ayahNumber: bookmark.ayahNumber,
          ),
          onRemove: () {
            unawaited(
              ref.read(manualBookmarksProvider.notifier).toggle(
                    bookmark.surahNumber,
                    bookmark.ayahNumber,
                    bookmark.surahName,
                  ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateKhatmaButton(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: _showNewKhatmaDialog,
        icon: const Icon(Icons.add_rounded, color: AppColors.gold),
        label: Text(
          l10n.libraryKhatmasCreate,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.gold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _LibraryTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _LibraryTabBarDelegate({
    required this.tabBar,
    required this.isDark,
  });

  final TabBar tabBar;
  final bool isDark;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_LibraryTabBarDelegate oldDelegate) => false;
}

class _LibraryEmptyState extends StatelessWidget {
  const _LibraryEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryLoadingState extends StatelessWidget {
  const _LibraryLoadingState({
    required this.message,
    required this.isDark,
  });

  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Amiri',
              color: isDark ? AppColors.textDark : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
