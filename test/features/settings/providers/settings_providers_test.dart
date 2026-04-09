import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    UserPreferences.resetCache();
  });

  test('builds app settings state from the seeded initial value', () {
    final container = ProviderContainer(
      overrides: [
        appSettingsInitialStateProvider.overrideWithValue(
          const AppSettingsState(
            themeMode: ThemeMode.dark,
            locale: Locale('en'),
            arabicFontSize: 30,
            defaultReaderMode: ReaderMode.translation,
            tajweedEnabled: true,
            nightReaderSettings: NightReaderSettings(
              autoEnable: true,
              startMinutes: 21 * 60,
              endMinutes: 4 * 60,
              preferredStyle: ReaderNightStyle.amoled,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(appSettingsControllerProvider),
      const AppSettingsState(
        themeMode: ThemeMode.dark,
        locale: Locale('en'),
        arabicFontSize: 30,
        defaultReaderMode: ReaderMode.translation,
        tajweedEnabled: true,
        nightReaderSettings: NightReaderSettings(
          autoEnable: true,
          startMinutes: 21 * 60,
          endMinutes: 4 * 60,
          preferredStyle: ReaderNightStyle.amoled,
        ),
      ),
    );
  });

  test('persists theme and locale changes immediately', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(appSettingsControllerProvider.notifier)
        .setThemeMode(ThemeMode.light);
    await container
        .read(appSettingsControllerProvider.notifier)
        .setLocale(const Locale('en'));

    final state = container.read(appSettingsControllerProvider);
    expect(state.themeMode, ThemeMode.light);
    expect(state.locale, const Locale('en'));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'light');
    expect(prefs.getString('language'), 'en');
  });

  test('persists font size and default reader mode changes', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(appSettingsControllerProvider.notifier)
        .setArabicFontSize(34);
    await container
        .read(appSettingsControllerProvider.notifier)
        .setDefaultReaderMode(ReaderMode.page);

    final state = container.read(appSettingsControllerProvider);
    expect(state.arabicFontSize, 34);
    expect(state.defaultReaderMode, ReaderMode.page);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('arabicFontSize'), 34);
    expect(prefs.getString('readerMode'), 'page');
  });

  test('updates tajweed state and triggers runtime sync', () async {
    final runtimeSync = _FakeSettingsRuntimeSync();
    final container = ProviderContainer(
      overrides: [
        settingsRuntimeSyncProvider.overrideWithValue(runtimeSync),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(appSettingsControllerProvider.notifier)
        .setTajweedEnabled(true);

    expect(
      container.read(appSettingsControllerProvider).tajweedEnabled,
      isTrue,
    );
    expect(runtimeSync.syncedTajweedValues, <bool>[true]);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('tajweedEnabled'), isTrue);
  });

  test('persists night reader settings through the unified app settings layer',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(appSettingsControllerProvider.notifier)
        .setNightReaderAutoEnable(true);
    await container.read(appSettingsControllerProvider.notifier).setNightReaderSchedule(
          startMinutes: 21 * 60,
          endMinutes: (4 * 60) + 30,
        );
    await container
        .read(appSettingsControllerProvider.notifier)
        .setPreferredNightStyle(ReaderNightStyle.amoled);

    expect(
      container.read(appSettingsControllerProvider).nightReaderSettings,
      const NightReaderSettings(
        autoEnable: true,
        startMinutes: 21 * 60,
        endMinutes: (4 * 60) + 30,
        preferredStyle: ReaderNightStyle.amoled,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('nightReaderAutoEnable'), isTrue);
    expect(prefs.getInt('nightReaderStartMinutes'), 21 * 60);
    expect(prefs.getInt('nightReaderEndMinutes'), (4 * 60) + 30);
    expect(prefs.getString('nightReaderPreferredStyle'), 'amoled');
  });
}

class _FakeSettingsRuntimeSync implements SettingsRuntimeSync {
  final List<bool> syncedTajweedValues = <bool>[];

  @override
  void sync(AppSettingsState settings) {}

  @override
  void syncTajweed(bool enabled) {
    syncedTajweedValues.add(enabled);
  }
}
