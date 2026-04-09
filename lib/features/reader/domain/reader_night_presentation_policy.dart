import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_schedule_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';

class ReaderNightPalette {
  const ReaderNightPalette({
    required this.presentation,
    required this.useDarkReaderLibrary,
    required this.backgroundColor,
    required this.textColor,
    required this.mutedTextColor,
    required this.cardColor,
    required this.cardBorderColor,
    required this.drawerBackgroundColor,
    required this.drawerHeaderColor,
    required this.drawerHeaderTextColor,
    required this.drawerHeaderSubtitleColor,
    required this.drawerTileBadgeColor,
    required this.bannerColor,
    required this.bannerTextColor,
    required this.bannerEdgeColor,
    required this.fullscreenOverlayColor,
    required this.fullscreenIconColor,
    this.accentColor = AppColors.gold,
    this.selectedAyahBackgroundColor = const Color(0x33C5A059),
  });

  final ReaderNightPresentation presentation;
  final bool useDarkReaderLibrary;
  final Color backgroundColor;
  final Color textColor;
  final Color mutedTextColor;
  final Color cardColor;
  final Color cardBorderColor;
  final Color drawerBackgroundColor;
  final Color drawerHeaderColor;
  final Color drawerHeaderTextColor;
  final Color drawerHeaderSubtitleColor;
  final Color drawerTileBadgeColor;
  final Color bannerColor;
  final Color bannerTextColor;
  final Color bannerEdgeColor;
  final Color fullscreenOverlayColor;
  final Color fullscreenIconColor;
  final Color accentColor;
  final Color selectedAyahBackgroundColor;
}

abstract final class ReaderNightPresentationPolicy {
  static ReaderNightPresentation resolve({
    required bool autoEnable,
    required int startMinutes,
    required int endMinutes,
    required ReaderNightStyle preferredNightStyle,
    required DateTime nowLocal,
    ReaderNightPresentation? sessionOverride,
  }) {
    if (sessionOverride != null) {
      return sessionOverride;
    }

    if (!autoEnable) {
      return ReaderNightPresentation.normal;
    }

    final isWithinNightWindow = ReaderNightSchedulePolicy.isWithinWindow(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      nowLocal: nowLocal,
    );
    if (!isWithinNightWindow) {
      return ReaderNightPresentation.normal;
    }

    return ReaderNightStylePolicy.toPresentation(preferredNightStyle);
  }

  static ReaderNightPalette paletteFor({
    required ReaderNightPresentation presentation,
    required Brightness appBrightness,
  }) {
    return switch (presentation) {
      ReaderNightPresentation.normal => _normalPalette(
          appBrightness: appBrightness,
        ),
      ReaderNightPresentation.night => const ReaderNightPalette(
          presentation: ReaderNightPresentation.night,
          useDarkReaderLibrary: true,
          backgroundColor: Color(0xFF17130F),
          textColor: Color(0xFFF3EBDC),
          mutedTextColor: Color(0xFFBBAF95),
          cardColor: Color(0xFF211A14),
          cardBorderColor: Color(0xFF4A3C2B),
          drawerBackgroundColor: Color(0xFF15110D),
          drawerHeaderColor: Color(0xFF3A2F22),
          drawerHeaderTextColor: Color(0xFFF3EBDC),
          drawerHeaderSubtitleColor: Color(0xFFD4C5AB),
          drawerTileBadgeColor: Color(0xFF261F18),
          bannerColor: Color(0xFF3A2F22),
          bannerTextColor: Color(0xFFF3EBDC),
          bannerEdgeColor: Color(0xFF15110D),
          fullscreenOverlayColor: Color(0xC7000000),
          fullscreenIconColor: Color(0xFFF3EBDC),
        ),
      ReaderNightPresentation.amoled => const ReaderNightPalette(
          presentation: ReaderNightPresentation.amoled,
          useDarkReaderLibrary: true,
          backgroundColor: Colors.black,
          textColor: Color(0xFFF5F0E6),
          mutedTextColor: Color(0xFFB3AB9E),
          cardColor: Color(0xFF070707),
          cardBorderColor: Color(0xFF252525),
          drawerBackgroundColor: Colors.black,
          drawerHeaderColor: Color(0xFF111111),
          drawerHeaderTextColor: Color(0xFFF5F0E6),
          drawerHeaderSubtitleColor: Color(0xFFB3AB9E),
          drawerTileBadgeColor: Color(0xFF101010),
          bannerColor: Color(0xFF111111),
          bannerTextColor: Color(0xFFF5F0E6),
          bannerEdgeColor: Colors.black,
          fullscreenOverlayColor: Color(0xD9000000),
          fullscreenIconColor: Color(0xFFF5F0E6),
        ),
    };
  }

  static ReaderNightPalette _normalPalette({
    required Brightness appBrightness,
  }) {
    final isDark = appBrightness == Brightness.dark;
    return ReaderNightPalette(
      presentation: ReaderNightPresentation.normal,
      useDarkReaderLibrary: isDark,
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      textColor: isDark ? AppColors.textDark : AppColors.textLight,
      mutedTextColor: isDark ? Colors.white70 : AppColors.textMuted,
      cardColor: isDark ? AppColors.surfaceDarkNav : Colors.white,
      cardBorderColor:
          isDark ? const Color(0x1FFFFFFF) : const Color(0x29C5A059),
      drawerBackgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      drawerHeaderColor: isDark ? AppColors.camelDark : AppColors.camel,
      drawerHeaderTextColor: isDark ? AppColors.textDark : Colors.white,
      drawerHeaderSubtitleColor:
          isDark ? const Color(0xB3F5F0E0) : Colors.white70,
      drawerTileBadgeColor:
          isDark ? AppColors.surfaceDarkNav : const Color(0x1AC4A882),
      bannerColor: isDark ? AppColors.camelDark : AppColors.camel,
      bannerTextColor: isDark ? AppColors.textDark : Colors.white,
      bannerEdgeColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      fullscreenOverlayColor:
          isDark ? const Color(0xB3000000) : const Color(0xE6FFFFFF),
      fullscreenIconColor: isDark ? Colors.white : AppColors.textLight,
    );
  }
}
