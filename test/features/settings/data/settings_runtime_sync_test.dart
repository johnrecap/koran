import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/settings/data/settings_runtime_sync.dart';
import 'package:quran_kareem/features/settings/domain/app_settings_state.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  test(
    'syncTajweed updates quran state, persists package storage, and refreshes page and scroll surfaces',
    () {
      final persistedValues = <bool>[];
      final quranCtrl = _SpyQuranCtrl();
      final surahCtrl = _SpySurahCtrl();
      final runtimeSync = QuranLibrarySettingsRuntimeSync(
        quranCtrl: quranCtrl,
        surahCtrl: surahCtrl,
        persistTajweed: persistedValues.add,
      );

      runtimeSync.syncTajweed(true);

      expect(quranCtrl.state.isTajweedEnabled.value, isTrue);
      expect(persistedValues, <bool>[true]);
      expect(quranCtrl.updateCalls, hasLength(2));
      expect(quranCtrl.updateCalls.first, isNull);
      expect(
        quranCtrl.updateCalls.last,
        equals(const <Object>['_pageViewBuild']),
      );
      expect(surahCtrl.updateCalls, <List<Object>?>[null]);
    },
  );

  test('sync delegates the unified tajweed setting value', () {
    final persistedValues = <bool>[];
    final quranCtrl = _SpyQuranCtrl();
    final runtimeSync = QuranLibrarySettingsRuntimeSync(
      quranCtrl: quranCtrl,
      persistTajweed: persistedValues.add,
    );

    runtimeSync.sync(
      const AppSettingsState(
        themeMode: ThemeMode.dark,
        locale: Locale('en'),
        arabicFontSize: 28,
        defaultReaderMode: ReaderMode.scroll,
        tajweedEnabled: true,
      ),
    );

    expect(quranCtrl.state.isTajweedEnabled.value, isTrue);
    expect(persistedValues, <bool>[true]);
  });
}

class _SpyQuranCtrl extends QuranCtrl {
  final List<List<Object>?> updateCalls = <List<Object>?>[];

  @override
  void update([List<Object>? ids, bool condition = true]) {
    updateCalls.add(ids == null ? null : List<Object>.of(ids));
  }
}

class _SpySurahCtrl extends SurahCtrl {
  final List<List<Object>?> updateCalls = <List<Object>?>[];

  @override
  void update([List<Object>? ids, bool condition = true]) {
    updateCalls.add(ids == null ? null : List<Object>.of(ids));
  }
}
