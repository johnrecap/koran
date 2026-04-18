# Implementation Plan: Heritage Theme Unification

**Branch**: `audit-heritage-theme` | **Date**: 2026-04-18 | **Spec**: [spec.md](spec.md)

## Summary

Unify the dual color system (Legacy vs Heritage) into a single Heritage Manuscript palette, expose it via `ThemeExtension<ManuscriptColors>`, create a themed `ManuscriptSnackBar`, and polish bottom navigation with pill indicator + haptic feedback.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: flutter, google_fonts  
**Storage**: N/A — purely visual  
**Testing**: `flutter test` — widget tests for theme resolution  
**Target Platform**: iOS/Android  
**Project Type**: mobile-app

## Constitution Check

*GATE: Must pass before implementation.*

- ✅ Clean Architecture: Theme extension is a core concern — changes in `lib/core/theme/`.
- ✅ Heritage Design Language: This spec enforces it — full alignment.
- ✅ Night Reader compatibility: `ManuscriptColors` will coexist with Night Reader overrides — separate concerns.
- ✅ Localization: No new strings — purely visual changes.
- ✅ quran_library: Theme changes don't affect `useMaterial3: false` requirement.

## Project Structure

```text
lib/core/
├── constants/
│   └── app_colors.dart              ← [MODIFY] Remove Legacy duplicates
├── theme/
│   ├── app_theme.dart               ← [MODIFY] Register ManuscriptColors extension
│   └── manuscript_colors.dart       ← [NEW] ThemeExtension definition
└── widgets/
    ├── app_shell.dart               ← [MODIFY] Pill indicator + haptic feedback
    └── manuscript_snack_bar.dart    ← [NEW] Themed SnackBar builder
```

### Files Modified

| File | Action | Change |
|------|--------|--------|
| `app_colors.dart` | MODIFY | Remove Legacy `bgLight`/`bgDark`/`cardBg`, keep Heritage only |
| `manuscript_colors.dart` | NEW | `ThemeExtension<ManuscriptColors>` with `lerp()` support |
| `app_theme.dart` | MODIFY | Register `ManuscriptColors` in both themes, replace hardcoded colors |
| `manuscript_snack_bar.dart` | NEW | `ManuscriptSnackBar.success()`, `.error()`, `.info()` |
| `app_shell.dart` | MODIFY | Pill indicator, `HapticFeedback.selectionClick()`, scale animation |
| All files referencing Legacy colors | MODIFY | Update imports to Heritage equivalents |

## ManuscriptColors Definition

```dart
@immutable
class ManuscriptColors extends ThemeExtension<ManuscriptColors> {
  const ManuscriptColors({
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.gold,
    required this.camel,
    required this.divider,
  });

  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color gold;
  final Color camel;
  final Color divider;

  static const light = ManuscriptColors(
    surface: AppColors.surfaceLight,
    card: AppColors.cardLight,
    textPrimary: AppColors.textLight,
    textSecondary: AppColors.textLightSecondary,
    gold: AppColors.gold,
    camel: AppColors.camel,
    divider: AppColors.dividerLight,
  );

  static const dark = ManuscriptColors(
    surface: AppColors.surfaceDark,
    card: AppColors.cardDark,
    textPrimary: AppColors.textDark,
    textSecondary: AppColors.textDarkSecondary,
    gold: AppColors.gold,
    camel: AppColors.camel,
    divider: AppColors.dividerDark,
  );
  
  // lerp(), copyWith(), etc.
}
```

## Legacy → Heritage Color Mapping

| Legacy Constant | Heritage Replacement | Hex Diff |
|----------------|---------------------|----------|
| `bgLight` (0xFFF8F8F5) | `surfaceLight` (0xFFF9F9F7) | Minor warmth shift |
| `bgDark` (0xFF221E10) | `surfaceDark` (0xFF2A2218) | Lighter, warmer |
| `cardBg` (0xFFEDE5D0) | `cardLight` (new) | TBD — derive from Heritage |
| hardcoded `0xFF2A2614` | `AppColors.cardDark` (new) | Centralized |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| `ThemeExtension` over static constants | Enables dynamic theming and `lerp()` for animated theme transitions | Static constants can't participate in `ThemeData.lerp()` |
| `ManuscriptSnackBar` as standalone class | Centralizes all feedback styling | Inline styling per-callsite would duplicate Heritage visual logic |
