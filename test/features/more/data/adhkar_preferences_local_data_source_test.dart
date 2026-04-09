import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/more/data/adhkar_preferences_local_data_source.dart';
import 'package:quran_kareem/features/more/domain/adhkar_counter_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  tearDown(() {
    UserPreferences.resetCache();
  });

  test('returns the default counter state when nothing is saved', () async {
    final source = SharedPreferencesAdhkarPreferencesLocalDataSource();

    final state = await source.loadCounterState();

    expect(state.count, 0);
    expect(state.target, 33);
  });

  test('saves and restores the local counter state', () async {
    final source = SharedPreferencesAdhkarPreferencesLocalDataSource();

    await source.saveCounterState(
      const AdhkarCounterState(
        count: 17,
        target: 100,
      ),
    );

    final restored = await source.loadCounterState();

    expect(restored.count, 17);
    expect(restored.target, 100);
  });

  test('tolerates malformed persisted counter payloads', () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'adhkarCounterState': jsonEncode(<String, Object?>{'count': 'bad'}),
      },
    );
    UserPreferences.resetCache();
    final source = SharedPreferencesAdhkarPreferencesLocalDataSource();

    final restored = await source.loadCounterState();

    expect(restored.count, 0);
    expect(restored.target, null);
  });
}
