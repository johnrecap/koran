# Implementation Plan: Reader Screen Decomposition

**Branch**: `audit-reader-decomposition` | **Date**: 2026-04-18 | **Spec**: [spec.md](spec.md)

## Summary

Decompose the monolithic `reader_screen.dart` (1,395 lines) into a shell widget + 4 focused mixins, and migrate `MuallimNotifier` from legacy `StateNotifier` to Riverpod 2.0+ `Notifier`. Goal: maintainability, testability, and safe Phase 3 feature expansion.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: flutter_riverpod, quran_library, go_router  
**Storage**: SharedPreferences (reading position, Khatma state)  
**Testing**: `flutter test` — widget tests + unit tests for extracted mixins  
**Target Platform**: iOS/Android  
**Project Type**: mobile-app

## Constitution Check

*GATE: Must pass before implementation.*

- ✅ Clean Architecture: Decomposition improves layer separation — no new cross-layer coupling.
- ✅ Riverpod patterns: Migration to `Notifier` aligns with Riverpod 2.0+ best practices.
- ✅ Local-first: No changes to data storage or network behavior.
- ✅ quran_library compatibility: No API surface changes — only internal refactoring.
- ✅ Localization: No new user-facing strings — purely structural change.

## Project Structure

```text
lib/features/reader/presentation/screens/
├── reader_screen.dart              ← Shell widget (≤ 400 lines)
├── reader_progress_mixin.dart      ← [NEW] Khatma tracking, session save/restore
├── reader_fullscreen_mixin.dart    ← [NEW] Fullscreen transitions, scroll restore
├── reader_verse_actions_mixin.dart ← [NEW] Bookmark/share/copy/note/tadabbur
└── reader_muallim_mixin.dart       ← [NEW] Muallim toggle, playback delegation

lib/features/reader/providers/
└── muallim_providers.dart          ← [MODIFY] MuallimNotifier → Notifier migration
```

### Files Modified

| File | Action | Change |
|------|--------|--------|
| `reader_screen.dart` | MODIFY | Strip to shell — delegate to mixins |
| `muallim_providers.dart` | MODIFY | `StateNotifier` → `Notifier`, remove manual `mounted` checks |
| `reader_progress_mixin.dart` | NEW | Extract progress tracking logic |
| `reader_fullscreen_mixin.dart` | NEW | Extract fullscreen enter/exit/restore |
| `reader_verse_actions_mixin.dart` | NEW | Extract verse action callbacks |
| `reader_muallim_mixin.dart` | NEW | Extract muallim mode integration |

## Decomposition Map

### reader_screen.dart → Shell (≤ 400 lines)
- `build()` method
- Widget composition (`Scaffold`, `CustomScrollView`, etc.)
- Provider watches (delegated to mixins for logic)
- `initState()` / `dispose()` — calls mixin lifecycle methods

### reader_progress_mixin.dart
**Source lines**: ~L326-L520
- `_saveReadingPosition()`
- `_onReaderSaveRecorderComplete()`
- `_updateKhatmaProgress()`
- `_handleSessionTracking()`

### reader_fullscreen_mixin.dart
**Source lines**: ~L1150-L1300
- `_enterFullscreen()` / `_exitFullscreen()`
- `_handleFullscreenScrollRestore()`
- `_buildFullscreenOverlay()`
- AppBar/BottomNav toggle

### reader_verse_actions_mixin.dart
**Source lines**: ~L700-L950
- `_onBookmark()` / `_onShare()` / `_onCopy()`
- `_onNote()` / `_onTadabbur()` / `_onInsights()`
- `_onTranslations()` / `_onListen()`
- `_showVerseActionMenu()`

### reader_muallim_mixin.dart
**Source lines**: ~L950-L1150
- `_toggleMuallim()`
- `_handleMuallimAutoNavigation()`
- `_buildMuallimControls()`

## MuallimNotifier Migration Strategy

| Before (StateNotifier) | After (Notifier) |
|------------------------|------------------|
| `extends StateNotifier<MuallimSnapshot>` | `extends Notifier<MuallimSnapshot>` |
| `StateNotifierProvider` | `NotifierProvider` |
| Manual `_subscription?.cancel()` in `dispose()` | `ref.onDispose(() => subscription.cancel())` |
| `if (!mounted) return;` checks | Automatic lifecycle via `ref.onDispose` |
| Constructor `unawaited(_bootstrap())` | `build()` method handles init |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Mixin pattern over sub-widgets | Mixins share `State` — needed for `ScrollController`, `AnimationController` access | Sub-widget extraction would require excessive callback threading and lose state locality |
| 4 new files | One mixin per concern | Fewer files would still result in >400 line units |
