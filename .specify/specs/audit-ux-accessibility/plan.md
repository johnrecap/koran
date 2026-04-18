# Implementation Plan: UX Accessibility & Reader Polish

**Branch**: `audit-ux-accessibility` | **Date**: 2026-04-18 | **Spec**: [spec.md](spec.md)

## Summary

Improve accessibility (Semantics, touch targets, Tooltip), add fullscreen exit discoverability (auto-hide + first-time hint), enhance jump-to dialog with current position, and add mini player progress bar.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: flutter_riverpod, shared_preferences (first-time hint flag)  
**Storage**: SharedPreferences (fullscreen hint shown flag)  
**Testing**: `flutter test` — widget tests for Semantics, timer behavior  
**Target Platform**: iOS/Android  
**Project Type**: mobile-app

## Constitution Check

*GATE: Must pass before implementation.*

- ✅ Clean Architecture: UI changes in `presentation/` layer only.
- ✅ Localization: New strings for shortened Muallim label + fullscreen hint → `AppLocalizations`.
- ✅ Local-first: First-time hint flag stored in `UserPreferences`.
- ✅ Accessibility: This spec directly improves it — aligned with app values.

## Project Structure

```text
lib/features/reader/presentation/
├── widgets/
│   └── verse_action_menu.dart              ← [MODIFY] Semantics, Tooltip, Wrap, 48px
├── screens/
│   └── reader_screen.dart                  ← [MODIFY] Fullscreen auto-hide timer
└── widgets/
    └── fullscreen_exit_overlay.dart         ← [NEW] Extracted fullscreen overlay with timer

lib/core/
├── localization/
│   └── app_localizations.dart              ← [MODIFY] New/shortened strings
├── widgets/
│   └── app_shell.dart                      ← [MODIFY] Mini player progress bar
└── data/datasources/local/
    └── user_preferences.dart               ← [MODIFY] Add fullscreen hint shown key
```

### Files Modified

| File | Action | Change |
|------|--------|--------|
| `verse_action_menu.dart` | MODIFY | Add Semantics, Tooltip, Wrap layout, increase to 48px |
| `reader_screen.dart` | MODIFY | Extract fullscreen overlay, add auto-hide timer |
| `fullscreen_exit_overlay.dart` | NEW | Self-contained overlay with Timer + FadeTransition |
| `app_localizations.dart` | MODIFY | Add/shorten strings for Muallim label + fullscreen hint |
| `app_shell.dart` | MODIFY | Add `LinearProgressIndicator` to mini player |
| `user_preferences.dart` | MODIFY | Add `fullscreenHintShown` boolean key |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| `Wrap` instead of `GridView.count` | Dynamic item count (8 or 9 depending on Muallim) | `GridView` with fixed count can't gracefully handle 9th item |
| Separate `fullscreen_exit_overlay.dart` | Timer + animation + first-time logic is 60+ lines | Inline in reader_screen would increase its line count further |
