import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    UserPreferences.resetCache();
  });

  tearDown(() {
    UserPreferences.resetCache();
  });

  test('debounces full-quran translation search to the final query only',
      () async {
    final source = _FakeLibraryTranslationSearchSource();
    final container = ProviderContainer(
      overrides: [
        allSurahsProvider.overrideWith(
          (ref) async => const <Surah>[],
        ),
        readerTranslationResourceIdProvider.overrideWith((ref) => 85),
        libraryTranslationSearchSourceProvider.overrideWithValue(source),
        libraryTranslationSearchDebounceDurationProvider.overrideWith(
          (ref) => const Duration(milliseconds: 10),
        ),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      libraryTranslationSearchResultsProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    container.read(librarySearchKindProvider.notifier).state =
        LibrarySearchKind.translations;
    container.read(librarySearchScopeProvider.notifier).state =
        LibrarySearchScope.fullQuran;

    container.read(librarySearchQueryProvider.notifier).state = 'm';
    container.read(librarySearchQueryProvider.notifier).state = 'me';
    container.read(librarySearchQueryProvider.notifier).state = 'mercy';

    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
    );
    await container.read(libraryTranslationSearchResultsProvider.future);

    expect(source.queries, <String>['mercy']);
  });

  test('recordSearch waits for the initial load before mutating history',
      () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'librarySearchHistory': jsonEncode(const <String>['existing']),
      },
    );
    UserPreferences.resetCache();
    final prefs = await SharedPreferences.getInstance();
    final prefsCompleter = Completer<SharedPreferences>();
    final notifier = LibrarySearchHistoryNotifier(
      prefsLoader: () => prefsCompleter.future,
    );

    final pendingRecord = notifier.recordSearch('fresh');
    prefsCompleter.complete(prefs);

    await pendingRecord;
    await notifier.ready;

    expect(notifier.state, const <String>['fresh', 'existing']);
  });

  test(
      'clearHistory waits for the initial load before removing persisted state',
      () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'librarySearchHistory': jsonEncode(const <String>['existing']),
      },
    );
    UserPreferences.resetCache();
    final prefs = await SharedPreferences.getInstance();
    final prefsCompleter = Completer<SharedPreferences>();
    final notifier = LibrarySearchHistoryNotifier(
      prefsLoader: () => prefsCompleter.future,
    );

    final pendingClear = notifier.clearHistory();
    prefsCompleter.complete(prefs);

    await pendingClear;
    await notifier.ready;

    expect(notifier.state, isEmpty);
    expect(prefs.getString('librarySearchHistory'), isNull);
  });
}

class _FakeLibraryTranslationSearchSource
    implements LibraryTranslationSearchSource {
  final List<String> queries = <String>[];

  @override
  Future<List<LibraryTranslationSearchMatch>> searchTranslations({
    required String query,
    required int resourceId,
  }) async {
    queries.add(query);
    return const <LibraryTranslationSearchMatch>[];
  }
}
