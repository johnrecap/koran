import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/library/data/library_topic_local_data_source.dart';
import 'package:quran_kareem/features/library/domain/library_topic.dart';
import 'package:quran_kareem/features/library/data/library_translation_search_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

export 'package:quran_kareem/features/library/data/library_topic_local_data_source.dart'
    show
        AssetLibraryTopicCatalogSource,
        LibraryTopicAyahResolver,
        LibraryTopicCatalogSource,
        QuranDatabaseLibraryTopicAyahResolver;
export 'package:quran_kareem/features/library/domain/library_topic.dart';
export 'package:quran_kareem/features/library/data/library_translation_search_remote_data_source.dart'
    show
        LibraryTranslationSearchMatch,
        LibraryTranslationSearchRemoteDataSource,
        LibraryTranslationSearchSource;

enum LibrarySearchScope {
  fullQuran,
  currentSurah,
}

enum LibrarySearchKind {
  ayahs,
  translations,
  topics,
}

class LibraryAyahSearchResult {
  const LibraryAyahSearchResult({
    required this.ayah,
    required this.surahName,
  });

  final Ayah ayah;
  final String surahName;
}

class LibraryTranslationSearchResult {
  const LibraryTranslationSearchResult({
    required this.ayah,
    required this.surahName,
    required this.translationText,
  });

  final Ayah ayah;
  final String surahName;
  final String translationText;
}

abstract class LibraryTranslationAyahResolver {
  Future<Ayah> resolveMatch(LibraryTranslationSearchMatch match);
}

class QuranDatabaseLibraryTranslationAyahResolver
    implements LibraryTranslationAyahResolver {
  const QuranDatabaseLibraryTranslationAyahResolver();

  @override
  Future<Ayah> resolveMatch(LibraryTranslationSearchMatch match) async {
    try {
      final ayah = await QuranDatabase.getAyah(
        match.surahNumber,
        match.ayahNumber,
      );
      if (ayah != null) {
        return ayah;
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'QuranDatabaseLibraryTranslationAyahResolver.resolveMatch',
        error,
        stackTrace,
      );
      // Fall back to the remote Arabic text when local metadata lookup is
      // unavailable, which keeps search results usable in isolated tests.
    }

    var pageNumber = 1;
    try {
      pageNumber = await QuranDatabase.getPageForAyah(
        match.surahNumber,
        match.ayahNumber,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'QuranDatabaseLibraryTranslationAyahResolver.resolveMatch',
        error,
        stackTrace,
      );
      pageNumber = 1;
    }

    return Ayah(
      id: (match.surahNumber * 1000) + match.ayahNumber,
      surahNumber: match.surahNumber,
      ayahNumber: match.ayahNumber,
      text: match.arabicText,
      page: pageNumber,
      juz: 0,
      hizb: 0,
    );
  }
}

abstract class LibraryAyahSearchSource {
  Future<List<Ayah>> searchAyahs({
    required String query,
    int? surahNumber,
  });
}

class LocalLibraryAyahSearchSource implements LibraryAyahSearchSource {
  const LocalLibraryAyahSearchSource();

  @override
  Future<List<Ayah>> searchAyahs({
    required String query,
    int? surahNumber,
  }) {
    return QuranDatabase.searchAyahs(
      query,
      surahNumber: surahNumber,
    );
  }
}

class LibrarySearchHistoryNotifier extends StateNotifier<List<String>> {
  LibrarySearchHistoryNotifier({
    Future<SharedPreferences> Function()? prefsLoader,
  })  : _prefsLoader = prefsLoader ?? (() => UserPreferences.prefs),
        super(const <String>[]) {
    _ready = _load();
  }

  static const _storageKey = 'librarySearchHistory';
  static const _maxItems = 8;

  final Future<SharedPreferences> Function() _prefsLoader;
  late final Future<void> _ready;

  Future<void> get ready => _ready;

  Future<void> recordSearch(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }

    await _ready;
    final next = <String>[
      normalized,
      ...state.where((item) => item != normalized),
    ];
    state = next.take(_maxItems).toList(growable: false);
    await _save();
  }

  Future<void> clearHistory() async {
    await _ready;
    state = const <String>[];
    final prefs = await _prefsLoader();
    await prefs.remove(_storageKey);
  }

  Future<void> _load() async {
    final prefs = await _prefsLoader();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return;
    }

    try {
      final decoded = (jsonDecode(raw) as List<dynamic>)
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
      state = decoded.take(_maxItems).toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error('LibrarySearchHistoryNotifier._load', error, stackTrace);
      state = const <String>[];
    }
  }

  Future<void> _save() async {
    final prefs = await _prefsLoader();
    await prefs.setString(_storageKey, jsonEncode(state));
  }
}


/// Provider for all surahs — delegates to the canonical [surahsProvider]
/// in reader_providers.dart to avoid a duplicate database query.
final allSurahsProvider = surahsProvider;


final libraryAyahSearchSourceProvider = Provider<LibraryAyahSearchSource>(
  (ref) => const LocalLibraryAyahSearchSource(),
);

final libraryTranslationSearchSourceProvider =
    Provider<LibraryTranslationSearchSource>((ref) {
  return LibraryTranslationSearchRemoteDataSource(
    client: ref.watch(readerTranslationHttpClientProvider),
  );
});

final libraryTranslationAyahResolverProvider =
    Provider<LibraryTranslationAyahResolver>(
  (ref) => const QuranDatabaseLibraryTranslationAyahResolver(),
);

final libraryTopicCatalogSourceProvider = Provider<LibraryTopicCatalogSource>(
  (ref) => AssetLibraryTopicCatalogSource(),
);

final libraryTopicAyahResolverProvider = Provider<LibraryTopicAyahResolver>(
  (ref) => const QuranDatabaseLibraryTopicAyahResolver(),
);

/// Provider for search query in the library screen.
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

/// Legacy alias kept so existing tests and surah-list consumers do not break.
final surahSearchQueryProvider = librarySearchQueryProvider;

final librarySearchKindProvider = StateProvider<LibrarySearchKind>(
  (ref) => LibrarySearchKind.ayahs,
);

final librarySearchScopeProvider = StateProvider<LibrarySearchScope>(
  (ref) => LibrarySearchScope.fullQuran,
);

final librarySelectedTopicCategoryProvider =
    StateProvider<LibraryTopicCategory>(
  (ref) => LibraryTopicCategory.all,
);

final librarySearchHistoryProvider =
    StateNotifierProvider<LibrarySearchHistoryNotifier, List<String>>(
  (ref) => LibrarySearchHistoryNotifier(),
);

final libraryTranslationSearchDebounceDurationProvider =
    Provider<Duration>((ref) {
  return const Duration(milliseconds: AppConstants.searchDebounceMs);
});

final libraryTopicCatalogProvider = FutureProvider<List<LibraryTopic>>(
  (ref) async {
    final source = ref.watch(libraryTopicCatalogSourceProvider);
    return source.loadTopics();
  },
);

final libraryDebouncedFullQuranTranslationQueryProvider =
    FutureProvider<String>((ref) async {
  final query = ref.watch(librarySearchQueryProvider).trim();
  final searchKind = ref.watch(librarySearchKindProvider);
  final searchScope = ref.watch(librarySearchScopeProvider);
  if (query.isEmpty ||
      searchKind != LibrarySearchKind.translations ||
      searchScope != LibrarySearchScope.fullQuran) {
    return query;
  }

  final delay = ref.watch(libraryTranslationSearchDebounceDurationProvider);
  final completer = Completer<void>();
  var disposed = false;
  late final Timer timer;
  timer = Timer(delay, () {
    if (!completer.isCompleted) {
      completer.complete();
    }
  });

  ref.onDispose(() {
    disposed = true;
    if (timer.isActive) {
      timer.cancel();
    }
    if (!completer.isCompleted) {
      completer.complete();
    }
  });

  await completer.future;
  if (disposed) {
    return '';
  }

  return ref.read(librarySearchQueryProvider).trim();
});

/// Provider for filtered surahs based on search query.
/// The UI only consumes this list when the query is empty, but keeping the
/// filter logic here preserves the original behavior for existing consumers.
final filteredSurahsProvider = Provider<AsyncValue<List<Surah>>>((ref) {
  final query = ref.watch(librarySearchQueryProvider).trim();
  final surahsAsync = ref.watch(allSurahsProvider);

  return surahsAsync.whenData((surahs) {
    if (query.isEmpty) {
      return surahs;
    }

    return surahs.where((s) {
      if (s.nameArabic.contains(query)) return true;
      if (s.number.toString() == query) return true;
      if (s.nameEnglish.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      return false;
    }).toList();
  });
});

final libraryStoredReadingPositionProvider =
    FutureProvider<ReadingPosition?>((ref) async {
  return UserPreferences.getLastReadingPosition();
});

final libraryCurrentSearchSurahNumberProvider =
    FutureProvider<int?>((ref) async {
  final fallbackCurrentSurah = ref.watch(currentSurahProvider);
  final storedPosition =
      await ref.watch(libraryStoredReadingPositionProvider.future);
  return storedPosition?.surahNumber ?? fallbackCurrentSurah;
});

final libraryAyahSearchResultsProvider =
    FutureProvider<List<LibraryAyahSearchResult>>((ref) async {
  final query = ref.watch(librarySearchQueryProvider).trim();
  if (query.isEmpty) {
    return const <LibraryAyahSearchResult>[];
  }

  final scope = ref.watch(librarySearchScopeProvider);
  final source = ref.watch(libraryAyahSearchSourceProvider);
  final surahs = await ref.watch(allSurahsProvider.future);
  final searchSurahNumber = scope == LibrarySearchScope.currentSurah
      ? await ref.watch(libraryCurrentSearchSurahNumberProvider.future)
      : null;
  final ayahs = await source.searchAyahs(
    query: query,
    surahNumber: searchSurahNumber,
  );

  return ayahs.map((ayah) {
    final surah = surahs.where((item) => item.number == ayah.surahNumber);
    final resolvedSurahName =
        surah.isEmpty ? ayah.surahNumber.toString() : surah.first.nameArabic;
    return LibraryAyahSearchResult(
      ayah: ayah,
      surahName: resolvedSurahName,
    );
  }).toList(growable: false);
});

final libraryTranslationSearchResultsProvider =
    FutureProvider<List<LibraryTranslationSearchResult>>((ref) async {
  final query = ref.watch(librarySearchQueryProvider).trim();
  final searchKind = ref.watch(librarySearchKindProvider);
  if (query.isEmpty || searchKind != LibrarySearchKind.translations) {
    return const <LibraryTranslationSearchResult>[];
  }

  final surahs = await ref.watch(allSurahsProvider.future);
  final surahNames = <int, String>{
    for (final surah in surahs) surah.number: surah.nameArabic,
  };
  final scope = ref.watch(librarySearchScopeProvider);
  if (scope == LibrarySearchScope.currentSurah) {
    final surahNumber =
        await ref.watch(libraryCurrentSearchSurahNumberProvider.future);
    if (surahNumber == null) {
      return const <LibraryTranslationSearchResult>[];
    }

    final ayahs = await ref.watch(surahAyahsProvider(surahNumber).future);
    final translations =
        await ref.watch(surahTranslationsProvider(surahNumber).future);
    final normalizedQuery = query.toLowerCase();

    return ayahs.where((ayah) {
      final translation = translations[ayah.ayahNumber];
      if (translation == null) {
        return false;
      }

      return translation.text.toLowerCase().contains(normalizedQuery);
    }).map((ayah) {
      return LibraryTranslationSearchResult(
        ayah: ayah,
        surahName: surahNames[ayah.surahNumber] ?? ayah.surahNumber.toString(),
        translationText: translations[ayah.ayahNumber]!.text,
      );
    }).toList(growable: false);
  }

  final source = ref.watch(libraryTranslationSearchSourceProvider);
  final resourceId = ref.watch(readerTranslationResourceIdProvider);
  final debouncedQuery = await ref.watch(
    libraryDebouncedFullQuranTranslationQueryProvider.future,
  );
  if (debouncedQuery.isEmpty) {
    return const <LibraryTranslationSearchResult>[];
  }
  final matches = await source.searchTranslations(
    query: debouncedQuery,
    resourceId: resourceId,
  );
  final resolver = ref.watch(libraryTranslationAyahResolverProvider);

  return Future.wait(
    matches.map((match) async {
      final ayah = await resolver.resolveMatch(match);
      return LibraryTranslationSearchResult(
        ayah: ayah,
        surahName:
            surahNames[match.surahNumber] ?? match.surahNumber.toString(),
        translationText: match.translationText,
      );
    }),
  );
});

final libraryTopicResultsProvider = FutureProvider<List<LibraryTopic>>(
  (ref) async {
    final searchKind = ref.watch(librarySearchKindProvider);
    if (searchKind != LibrarySearchKind.topics) {
      return const <LibraryTopic>[];
    }

    final selectedCategory = ref.watch(librarySelectedTopicCategoryProvider);
    final query = ref.watch(librarySearchQueryProvider).trim();
    final topics = await ref.watch(libraryTopicCatalogProvider.future);

    return topics.where((topic) {
      final matchesCategory = selectedCategory == LibraryTopicCategory.all ||
          topic.category == selectedCategory;
      final matchesQuery = topic.matchesQuery(query);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  },
);

final libraryTopicReferenceResultsProvider =
    FutureProvider.family<List<LibraryTopicReferenceResult>, String>(
  (ref, topicId) async {
    final topics = await ref.watch(libraryTopicCatalogProvider.future);
    LibraryTopic? topic;
    for (final candidate in topics) {
      if (candidate.id == topicId) {
        topic = candidate;
        break;
      }
    }

    if (topic == null) {
      return const <LibraryTopicReferenceResult>[];
    }

    final resolver = ref.watch(libraryTopicAyahResolverProvider);
    return resolver.resolveTopic(topic);
  },
);
