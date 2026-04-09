import 'package:flutter/material.dart';

/// App color palette — Heritage Manuscript (المخطوطة التراثية)
class AppColors {
  AppColors._();

  // ─── Heritage Manuscript: Primary ───
  /// Warm camel — torn-paper banner, headers
  static const Color camel = Color(0xFFC4A882);
  /// Darker camel — dark mode banner
  static const Color camelDark = Color(0xFF6B5B3D);
  /// Gold/Bronze — verse markers, active nav, accents
  static const Color gold = Color(0xFFC5A059);

  // ─── Heritage Manuscript: Surfaces ───
  /// Light mode background — warm cream
  static const Color surfaceLight = Color(0xFFF9F9F7);
  /// Dark mode background — dark warm leather
  static const Color surfaceDark = Color(0xFF2A2218);
  /// Dark mode navbar bg
  static const Color surfaceDarkNav = Color(0xFF1E1A14);

  // ─── Heritage Manuscript: Text ───
  /// Light mode text — soft black (not pure)
  static const Color textLight = Color(0xFF1A1C1B);
  /// Dark mode text — warm cream
  static const Color textDark = Color(0xFFF5F0E0);
  /// Inactive nav icons
  static const Color textMuted = Color(0xFF8B8578);

  // ─── Heritage Manuscript: Accents ───
  /// Warm brown — tertiary accent
  static const Color warmBrown = Color(0xFF755750);
  /// Meccan chip — warm green
  static const Color meccan = Color(0xFF4CAF50);
  /// Medinan chip — calm blue
  static const Color medinan = Color(0xFF42A5F5);

  // ─── Legacy (kept for backward compatibility) ───
  static const Color primaryDark = Color(0xFF1A3A2A);
  static const Color primaryLight = Color(0xFF2D5D3E);
  static const Color goldReader = Color(0xFFC5A059);
  static const Color goldGeneral = Color(0xFFF4C025);
  static const Color bgParchment = Color(0xFFF5EDDF);
  static const Color bgLight = Color(0xFFF8F8F5);
  static const Color bgDark = Color(0xFF221E10);
  static const Color bgAudioDark = Color(0xFF16140C);
  static const Color textQuranLight = Color(0xFF3D2E1C);
  static const Color textQuranDark = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color childPurple = Color(0xFF7C4DFF);
  static const Color childPink = Color(0xFFFF4081);
  static const Color childGreen = Color(0xFF69F0AE);
  static const Color childYellow = Color(0xFFFFD740);
}
