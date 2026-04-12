import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';

import 'package:quran_kareem/features/ai/features/search/ai_search_result_tile.dart';
import 'package:quran_kareem/features/ai/features/search/semantic_search_provider.dart';
import 'package:quran_kareem/features/ai/widgets/ai_error_view.dart';
import 'package:quran_kareem/features/ai/widgets/ai_loading_shimmer.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

final aiSearchDebounceDurationProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 500),
);

class AiTopicSearchScreen extends ConsumerStatefulWidget {
  const AiTopicSearchScreen({super.key});

  @override
  ConsumerState<AiTopicSearchScreen> createState() => _AiTopicSearchScreenState();
}

class _AiTopicSearchScreenState extends ConsumerState<AiTopicSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _debouncedQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      ref.read(aiSearchDebounceDurationProvider),
      () {
        if (!mounted) {
          return;
        }
        setState(() {
          _debouncedQuery = value.trim();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _debouncedQuery;
    final resultsAsync = ref.watch(semanticSearchProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.smartSearch),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: context.l10n.searchTopicPlaceholder,
                prefixIcon: const Icon(Icons.auto_awesome_rounded),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _debouncedQuery = '';
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _SearchIdleState(
                    message: context.l10n.smartSearchHint,
                  )
                : resultsAsync.when(
                    loading: () => Padding(
                      padding: const EdgeInsets.all(16),
                      child: AiLoadingShimmer(
                        label: context.l10n.searchingTopics,
                      ),
                    ),
                    error: (error, _) {
                      if (error is AiOfflineException) {
                        return _OfflineFallbackResults(query: query);
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: AiErrorView(
                          exception: error is AiServiceException
                              ? error
                              : AiProviderException(
                                  message: error.toString(),
                                  provider: 'unknown',
                                  originalError: error,
                                ),
                          onRetry: () {
                            ref.invalidate(semanticSearchProvider(query));
                          },
                        ),
                      );
                    },
                    data: (results) {
                      if (results.isEmpty) {
                        return _SearchIdleState(
                          message: context.l10n.noSmartResults,
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: results.length,
                        itemBuilder: (context, index) => AiSearchResultTile(
                          result: results[index],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OfflineFallbackResults extends ConsumerWidget {
  const _OfflineFallbackResults({
    required this.query,
  });

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(allSurahsProvider);
    final source = ref.watch(libraryAyahSearchSourceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const Key('ai-search-offline-fallback-banner'),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.camel.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            context.l10n.fallbackToKeyword,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
        Expanded(
          child: surahsAsync.when(
            data: (surahs) => FutureBuilder<List<Ayah>>(
              future: source.searchAyahs(query: query),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: AiLoadingShimmer(
                      label: context.l10n.searchingTopics,
                    ),
                  );
                }

                final ayahs = snapshot.data ?? const <Ayah>[];
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = ayahs[index];
                    String? surahName;
                    for (final surah in surahs) {
                      if (surah.number == ayah.surahNumber) {
                        surahName = surah.nameEnglish;
                        break;
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(surahName ?? ayah.surahNumber.toString()),
                        subtitle: Text(
                          ayah.text,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _SearchIdleState extends StatelessWidget {
  const _SearchIdleState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textMuted,
                height: 1.6,
              ),
        ),
      ),
    );
  }
}
