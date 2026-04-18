# Feature Specification: Reader Screen Decomposition

**Feature Branch**: `audit-reader-decomposition`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: Comprehensive Codebase Audit — BUG-1, ARCH-4

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maintainable Reader Widget (Priority: P1)

As a developer, I need `reader_screen.dart` (currently 1,395 lines) decomposed into focused, single-responsibility units so that future features (AI integration, Quran Maps) can be added without regression risk.

**Why this priority**: The reader is the core experience — every Phase 3 feature touches it. A God Widget blocks safe iteration.
**Independent Test**: Each extracted mixin/controller compiles independently and its unit tests pass in isolation.

**Acceptance Scenarios**:

1. **Given** the current `reader_screen.dart`, **When** decomposition is complete, **Then** the main `ReaderScreen` widget is ≤ 400 lines.
2. **Given** reader progress tracking logic, **When** extracted to `reader_progress_mixin.dart`, **Then** khatma tracking, session save/restore, and reading position persistence work identically to current behavior.
3. **Given** fullscreen transitions, **When** extracted to `reader_fullscreen_mixin.dart`, **Then** enter/exit fullscreen with scroll-position restore works identically.
4. **Given** verse action callbacks, **When** extracted to `reader_verse_actions_mixin.dart`, **Then** bookmark, share, copy, note, tadabbur, and insights callbacks function without regressions.
5. **Given** Muallim integration, **When** extracted to `reader_muallim_mixin.dart`, **Then** Muallim toggle/playback/word-highlight work identically.

---

### User Story 2 - MuallimNotifier Modernization (Priority: P2)

As a developer, I need `MuallimNotifier` (704 lines, `StateNotifier`) migrated to Riverpod 2.0+ `Notifier` pattern to reduce boilerplate and improve lifecycle management.

**Why this priority**: Reduces manual `mounted` checks and stream subscription management by ~30%.
**Independent Test**: All existing Muallim behaviors (enable/disable, play/pause, word timing, session restore) pass after migration.

**Acceptance Scenarios**:

1. **Given** `MuallimNotifier` as `StateNotifier`, **When** migrated to `Notifier`, **Then** `ref.onDispose()` replaces manual `_subscription?.cancel()`.
2. **Given** `unawaited()` patterns for background work, **When** migrated, **Then** lifecycle-safe equivalents are used with automatic cancellation.
3. **Given** the existing `muallimStateProvider`, **When** changed to `NotifierProvider`, **Then** all downstream providers (`muallimWordHighlightProvider`, `muallimAutoNavigationTargetProvider`) function identically.

---

### Edge Cases

- What happens if a mixin accesses state from another mixin during `initState`?
- How does `WidgetsBindingObserver` lifecycle callback order interact with mixin initialization?
- Does `MuallimNotifier` migration affect hot-reload state persistence?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST decompose `reader_screen.dart` into ≤ 5 files, each ≤ 400 lines.
- **FR-002**: System MUST preserve all existing reader behaviors — zero functional regressions.
- **FR-003**: System MUST migrate `MuallimNotifier` from `StateNotifier` to `Notifier`.
- **FR-004**: System MUST NOT break the Muallim word-level highlighting pipeline.
- **FR-005**: System MUST maintain backward compatibility with `quran_library` package API.

### Key Entities

- **ReaderScreen**: Main shell widget — orchestrates sub-mixins, ≤ 400 lines.
- **ReaderProgressMixin**: Khatma tracking, session persistence, reading position.
- **ReaderFullscreenMixin**: Enter/exit fullscreen, scroll restore, AppBar hide/show.
- **ReaderVerseActionsMixin**: Bookmark, share, copy, note, tadabbur, insights callbacks.
- **ReaderMuallimMixin**: Muallim toggle, playback delegation, word highlight sync.
- **MuallimNotifier (v2)**: Riverpod `Notifier`-based, lifecycle-safe.

## Success Criteria *(mandatory)*

- **SC-001**: `reader_screen.dart` ≤ 400 lines after decomposition.
- **SC-002**: Zero test regressions — all existing reader tests pass.
- **SC-003**: `MuallimNotifier` uses `Notifier` base class — no manual `mounted` checks.
- **SC-004**: No new lint warnings introduced.
