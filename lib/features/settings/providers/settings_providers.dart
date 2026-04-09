import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_locale_policy.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_schedule_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';

import '../data/settings_runtime_sync.dart';
import '../domain/app_settings_state.dart';

export '../data/settings_runtime_sync.dart';
export '../domain/app_settings_state.dart';

final appSettingsInitialStateProvider = Provider<AppSettingsState>((ref) {
  return const AppSettingsState.defaults();
});

final settingsRuntimeSyncProvider = Provider<SettingsRuntimeSync>((ref) {
  return const QuranLibrarySettingsRuntimeSync();
});

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettingsState>(
  AppSettingsController.new,
);

class AppSettingsController extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    return ref.watch(appSettingsInitialStateProvider);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state.themeMode == themeMode) {
      return;
    }

    state = state.copyWith(themeMode: themeMode);
    await UserPreferences.setThemeMode(_themeModePreference(themeMode));
  }

  Future<void> setLocale(Locale locale) async {
    final resolved = AppLocalePolicy.resolve(locale.languageCode);
    if (state.locale == resolved) {
      return;
    }

    state = state.copyWith(locale: resolved);
    await UserPreferences.setLanguage(resolved.languageCode);
  }

  Future<void> setArabicFontSize(double fontSize) async {
    final normalized = SettingsArabicFontSizePolicy.clamp(fontSize);
    if (state.arabicFontSize == normalized) {
      return;
    }

    state = state.copyWith(arabicFontSize: normalized);
    await UserPreferences.setArabicFontSize(normalized);
  }

  Future<void> setDefaultReaderMode(ReaderMode mode) async {
    if (state.defaultReaderMode == mode) {
      return;
    }

    state = state.copyWith(defaultReaderMode: mode);
    await UserPreferences.setReaderMode(ReaderModePolicy.toPreference(mode));
  }

  Future<void> setTajweedEnabled(bool enabled) async {
    if (state.tajweedEnabled == enabled) {
      return;
    }

    state = state.copyWith(tajweedEnabled: enabled);
    ref.read(settingsRuntimeSyncProvider).syncTajweed(enabled);
    await UserPreferences.setTajweedEnabled(enabled);
  }

  Future<void> setNightReaderAutoEnable(bool enabled) async {
    if (state.nightReaderSettings.autoEnable == enabled) {
      return;
    }

    state = state.copyWith(
      nightReaderSettings: state.nightReaderSettings.copyWith(
        autoEnable: enabled,
      ),
    );
    await UserPreferences.setNightReaderAutoEnable(enabled);
  }

  Future<void> setNightReaderSchedule({
    required int startMinutes,
    required int endMinutes,
  }) async {
    if (!ReaderNightSchedulePolicy.isValidWindow(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    )) {
      throw ArgumentError(
        'Night Reader schedule requires different start and end times.',
      );
    }

    final current = state.nightReaderSettings;
    if (current.startMinutes == startMinutes && current.endMinutes == endMinutes) {
      return;
    }

    state = state.copyWith(
      nightReaderSettings: current.copyWith(
        startMinutes: startMinutes,
        endMinutes: endMinutes,
      ),
    );
    await UserPreferences.setNightReaderStartMinutes(startMinutes);
    await UserPreferences.setNightReaderEndMinutes(endMinutes);
  }

  Future<void> setPreferredNightStyle(ReaderNightStyle style) async {
    if (state.nightReaderSettings.preferredStyle == style) {
      return;
    }

    state = state.copyWith(
      nightReaderSettings: state.nightReaderSettings.copyWith(
        preferredStyle: style,
      ),
    );
    await UserPreferences.setPreferredNightReaderStyle(style);
  }

  String _themeModePreference(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
  }
}
