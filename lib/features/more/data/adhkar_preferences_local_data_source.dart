import 'dart:convert';

import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/domain/adhkar_counter_state.dart';

abstract class AdhkarPreferencesLocalDataSource {
  Future<AdhkarCounterState> loadCounterState();
  Future<void> saveCounterState(AdhkarCounterState state);
}

class SharedPreferencesAdhkarPreferencesLocalDataSource
    implements AdhkarPreferencesLocalDataSource {
  static const String _counterStateKey = 'adhkarCounterState';

  @override
  Future<AdhkarCounterState> loadCounterState() async {
    final prefs = await UserPreferences.prefs;
    final raw = prefs.getString(_counterStateKey);
    if (raw == null || raw.isEmpty) {
      return const AdhkarCounterState();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const AdhkarCounterState();
      }
      return AdhkarCounterState.fromMap(decoded);
    } catch (error, stackTrace) {
      AppLogger.error(
        'SharedPreferencesAdhkarPreferencesLocalDataSource.loadCounterState',
        error,
        stackTrace,
      );
      return const AdhkarCounterState();
    }
  }

  @override
  Future<void> saveCounterState(AdhkarCounterState state) async {
    final prefs = await UserPreferences.prefs;
    await prefs.setString(_counterStateKey, jsonEncode(state.toMap()));
  }
}
