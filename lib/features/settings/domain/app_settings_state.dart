import 'package:flutter/material.dart';
import 'package:quran_kareem/core/localization/app_locale_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';

class NightReaderSettings {
  const NightReaderSettings({
    required this.autoEnable,
    required this.startMinutes,
    required this.endMinutes,
    required this.preferredStyle,
  });

  const NightReaderSettings.defaults()
      : autoEnable = false,
        startMinutes = 20 * 60,
        endMinutes = 5 * 60,
        preferredStyle = ReaderNightStylePolicy.defaultStyle;

  final bool autoEnable;
  final int startMinutes;
  final int endMinutes;
  final ReaderNightStyle preferredStyle;

  NightReaderSettings copyWith({
    bool? autoEnable,
    int? startMinutes,
    int? endMinutes,
    ReaderNightStyle? preferredStyle,
  }) {
    return NightReaderSettings(
      autoEnable: autoEnable ?? this.autoEnable,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      preferredStyle: preferredStyle ?? this.preferredStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NightReaderSettings &&
        other.autoEnable == autoEnable &&
        other.startMinutes == startMinutes &&
        other.endMinutes == endMinutes &&
        other.preferredStyle == preferredStyle;
  }

  @override
  int get hashCode => Object.hash(
        autoEnable,
        startMinutes,
        endMinutes,
        preferredStyle,
      );
}

class AppSettingsState {
  const AppSettingsState({
    required this.themeMode,
    required this.locale,
    required this.arabicFontSize,
    required this.defaultReaderMode,
    required this.tajweedEnabled,
    this.nightReaderSettings = const NightReaderSettings.defaults(),
  });

  const AppSettingsState.defaults()
      : themeMode = ThemeMode.system,
        locale = AppLocalePolicy.defaultLocale,
        arabicFontSize = SettingsArabicFontSizePolicy.defaultValue,
        defaultReaderMode = ReaderMode.scroll,
        tajweedEnabled = false,
        nightReaderSettings = const NightReaderSettings.defaults();

  final ThemeMode themeMode;
  final Locale locale;
  final double arabicFontSize;
  final ReaderMode defaultReaderMode;
  final bool tajweedEnabled;
  final NightReaderSettings nightReaderSettings;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    double? arabicFontSize,
    ReaderMode? defaultReaderMode,
    bool? tajweedEnabled,
    NightReaderSettings? nightReaderSettings,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      defaultReaderMode: defaultReaderMode ?? this.defaultReaderMode,
      tajweedEnabled: tajweedEnabled ?? this.tajweedEnabled,
      nightReaderSettings: nightReaderSettings ?? this.nightReaderSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettingsState &&
        other.themeMode == themeMode &&
        other.locale == locale &&
        other.arabicFontSize == arabicFontSize &&
        other.defaultReaderMode == defaultReaderMode &&
        other.tajweedEnabled == tajweedEnabled &&
        other.nightReaderSettings == nightReaderSettings;
  }

  @override
  int get hashCode => Object.hash(
        themeMode,
        locale,
        arabicFontSize,
        defaultReaderMode,
        tajweedEnabled,
        nightReaderSettings,
      );
}

abstract final class SettingsArabicFontSizePolicy {
  static const double minimum = 24;
  static const double maximum = 36;
  static const double defaultValue = 28;
  static const int divisions = 6;

  static double clamp(double value) {
    return value.clamp(minimum, maximum).toDouble();
  }
}
