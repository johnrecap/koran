import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/providers/persistent_state_notifier.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibrarySearchHistoryNotifier
    extends PersistentStateNotifier<List<String>> {
  LibrarySearchHistoryNotifier({
    Future<SharedPreferences> Function()? prefsLoader,
  })  : _prefsLoader = prefsLoader ?? (() => UserPreferences.prefs),
        super(const <String>[]);

  static const _storageKey = StorageKeys.librarySearchHistory;
  static const _maxItems = 8;

  final Future<SharedPreferences> Function() _prefsLoader;

  Future<void> recordSearch(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }

    await updateState((current) {
      return <String>[
        normalized,
        ...current.where((item) => item != normalized),
      ];
    });
  }

  Future<void> clearHistory() async {
    await replaceState(const <String>[]);
  }

  @override
  Future<List<String>> loadPersistedState() async {
    final prefs = await _prefsLoader();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return const <String>[];
    }

    try {
      final decoded = (jsonDecode(raw) as List<dynamic>).whereType<String>();
      return decoded.toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error('LibrarySearchHistoryNotifier._load', error, stackTrace);
      return const <String>[];
    }
  }

  @override
  List<String> normalizeState(List<String> state) {
    return state
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .take(_maxItems)
        .toList(growable: false);
  }

  @override
  Future<void> persistState(
    List<String> previousState,
    List<String> currentState,
  ) async {
    final prefs = await _prefsLoader();
    if (currentState.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }

    await prefs.setString(_storageKey, jsonEncode(currentState));
  }
}

final librarySearchHistoryProvider =
    StateNotifierProvider<LibrarySearchHistoryNotifier, List<String>>(
  (ref) => LibrarySearchHistoryNotifier(),
);
