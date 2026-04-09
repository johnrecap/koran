# App Stabilization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stabilize the app by executing only the fixes that are confirmed by current code review and runtime verification, while explicitly deferring speculative or unsafe proposals from the imported external plan.

**Architecture:** This plan treats the external AI reports as input, not truth. Confirmed defects are grouped into small execution phases that preserve current behavior and existing error surfaces, especially around audio bootstrap, tafsir routing, and local data access. Items that still need runtime proof or broader design decisions are isolated into a follow-up section so they do not get implemented blindly.

**Tech Stack:** Flutter 3.x, Dart 3.x, Riverpod 2.x, GoRouter 15.x, SharedPreferences, local SQLite access via `sqflite`, project-local Markdown planning artifacts

---

## Planning Rules

- Execute this plan in order unless a later session explicitly re-prioritizes it.
- Preserve current recovery UX where it already exists; do not replace visible retryable failures with silent fallback states.
- Treat large behavioral changes as follow-up work unless there is fresh reproduction evidence.
- Add or update tests whenever a fix changes logic, not just formatting or dead code.

## Scope Summary

### Confirmed fix groups

1. Reader localization and clipboard correctness
2. Translation pagination hardening
3. Reader dead-code cleanup
4. Local data error surfacing with safe consumer updates
5. Audio bootstrap hardening without hiding failures
6. Static analysis cleanup and low-risk maintenance

### Follow-up investigations

1. Audio `isPlaying` dual-source flicker
2. Prayer stale-cache UX indicator
3. SQLite singleton concurrency hardening
4. Shared HTTP client consolidation
5. Provider duplication and equality-model cleanup

### Rejected external proposals

1. Returning `AudioHubPlaybackSnapshot.empty()` when audio bootstrap fails
2. Replacing invalid tafsir routes with a blank widget page
3. Switching `Khatma` equality to `id`-only and then using it for progress comparison
4. Blanket `try/catch` masking around provider debounce reads without a reproduced failure

## File Map

### Confirmed work

- `lib/features/reader/presentation/screens/reader_screen.dart`
- `lib/features/reader/domain/reader_mode_policy.dart`
- `lib/core/localization/app_localizations.dart`
- `lib/features/reader/data/reader_translation_repository.dart`
- `lib/features/audio/data/package_audio_hub_playback_service.dart`
- `lib/features/audio/providers/audio_providers.dart`
- `lib/data/datasources/local/quran_database.dart`
- `lib/features/library/presentation/widgets/surah_tile.dart`
- `lib/features/memorization/presentation/widgets/memorization_surah_tile.dart`

### Expected test files

- `test/features/reader/domain/reader_interaction_policy_test.dart`
- `test/features/reader/data/reader_translation_repository_test.dart`
- `test/features/audio/presentation/screens/audio_hub_screen_test.dart`
- `test/features/audio/providers/audio_hub_controller_test.dart`
- `test/data/datasources/local/quran_database_test.dart`

## Phase 1: Reader Localization and Copy Correctness

**Why first:** These are confirmed functional issues that leak Arabic-only text into English flows and are safe to fix without architectural churn.

### Task 1.1: Localize reader hardcoded tooltips and fonts dialog copy

**Files:**
- Modify: `lib/features/reader/presentation/screens/reader_screen.dart`
- Modify: `lib/core/localization/app_localizations.dart`
- Test: `test/features/settings/presentation/screens/settings_screen_test.dart`

- [ ] Add new localization keys for the reader mode toggle tooltips, quick-jump tooltip, mushaf-fonts dialog title, dialog notes, dialog progress text, and the generic surah prefix.
- [ ] Replace the hardcoded Arabic strings in `reader_screen.dart` with `context.l10n` lookups.
- [ ] Keep the existing UI behavior unchanged aside from language correctness.
- [ ] Run targeted widget tests or add one if current coverage does not exercise these strings.

### Task 1.2: Localize copied verse metadata

**Files:**
- Modify: `lib/features/reader/domain/reader_mode_policy.dart`
- Modify: `lib/features/reader/presentation/screens/reader_screen.dart`
- Test: `test/features/reader/domain/reader_interaction_policy_test.dart`

- [ ] Change `ReaderVerseActionPolicy.buildCopyText(...)` to accept a localized surah prefix instead of hardcoding Arabic in the domain layer.
- [ ] Pass the localized prefix from the screen or calling policy boundary.
- [ ] Update the existing copy-text test to cover both the new method signature and the localized output contract.

### Task 1.3: Localize the torn-paper banner prefix

**Files:**
- Modify: `lib/features/reader/presentation/screens/reader_screen.dart`

- [ ] Replace the hardcoded `'سورة ...'` banner prefix with the same localization key used by the copy-text path.
- [ ] Verify that the banner still appears only in scroll mode and still uses the Arabic surah name value from metadata.

## Phase 2: Translation Pagination and Reader Cleanup

**Why second:** The translation pagination loop is a real correctness risk, and the reader dead-code cleanup lowers maintenance noise without product risk.

### Task 2.1: Guard translation pagination against bad `nextPage` behavior

**Files:**
- Modify: `lib/features/reader/data/reader_translation_repository.dart`
- Create: `test/features/reader/data/reader_translation_repository_test.dart`

- [ ] Add loop protection using both a visited-page set and a reasonable max-page limit.
- [ ] Keep the repository behavior unchanged for valid paginated API responses.
- [ ] Add tests that cover:
  - normal multi-page completion,
  - repeated `nextPage` values,
  - stopping at the max-page guard.

### Task 2.2: Remove obsolete commented dialog blocks from the reader

**Files:**
- Modify: `lib/features/reader/presentation/screens/reader_screen.dart`

- [ ] Delete the dead commented-out dialog implementations below `_showVerseActionMenuForAyah(...)` and `_showVerseActionMenu(...)`.
- [ ] Keep the live `VerseActionMenu` wiring untouched.
- [ ] Run targeted reader widget tests to confirm there is no accidental behavior change.

## Phase 3: Local Data Error Surfacing

**Why third:** The current database layer swallows local failures too aggressively, but changing that globally can break consumers. This phase must harden behavior carefully.

### Task 3.1: Introduce explicit failure surfacing for local Quran lookups

**Files:**
- Modify: `lib/data/datasources/local/quran_database.dart`
- Modify: consumer providers/screens that rely on affected methods
- Create or modify: `test/data/datasources/local/quran_database_test.dart`

- [ ] Audit each `catch (_) { return []; }` or `catch (_) { return null; }` path in `QuranDatabase`.
- [ ] Keep schema fallback logic for alternate table names.
- [ ] Replace only the terminal silent-failure paths with explicit, typed failure behavior that callers can react to.
- [ ] Update the most important consumers so they convert these failures into existing UI error states instead of crashing.
- [ ] Add tests for the new failure contract before broadening the change to additional methods.

**Implementation note:** Do not flip every method from silent fallback to thrown error in one pass unless the consuming provider/screen is updated in the same change set.

### Task 3.2: Keep invalid tafsir input handling visible, not blank

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/tafsir/providers/tafsir_browser_providers.dart`
- Modify: `lib/features/tafsir/presentation/screens/tafsir_browser_screen.dart`

- [ ] Preserve the current invalid-verse UX path instead of returning `SizedBox.shrink()` from the router.
- [ ] If additional guardrails are added, put them at the target/provider/screen boundary so invalid params still land in a visible invalid state.
- [ ] Add or extend tests if route-level validation logic changes.

## Phase 4: Audio Bootstrap Hardening

**Why fourth:** Audio bootstrap risk is real, but the app already has an explicit retryable error surface. The fix must preserve that behavior.

### Task 4.1: Replace opaque polling with an explicit timeout contract

**Files:**
- Modify: `lib/features/audio/data/package_audio_hub_playback_service.dart`
- Modify: `lib/features/audio/providers/audio_providers.dart`
- Modify: `test/features/audio/presentation/screens/audio_hub_screen_test.dart`
- Modify: `test/features/audio/providers/audio_hub_controller_test.dart`

- [ ] Rework `_waitForPackageAudioBootstrap()` so the wait semantics are explicit and easier to reason about than the current fixed polling loop.
- [ ] Keep initialization failure observable to `AudioHubController`; do not convert it into a fake empty playback snapshot.
- [ ] Preserve the current screen behavior where bootstrap failure becomes an app-owned retry state.
- [ ] Add or update tests to prove the controller still enters `AsyncError` and the screen still renders retry UI.

### Task 4.2: Only adjust playback snapshot logic after reproduction evidence

**Files:**
- No implementation in this phase by default

- [ ] Do not change the `isPlaying` aggregation logic yet unless a real flicker is reproduced on device or in a targeted failing test.
- [ ] If reproduced later, create a small follow-up spec for that exact symptom instead of folding it into bootstrap hardening.

## Phase 5: Low-Risk Cleanup and Maintenance

**Why fifth:** These items are worth doing, but they are not the main stabilization risks.

### Task 5.1: Make static analysis clean again

**Files:**
- Modify: `lib/features/library/presentation/widgets/surah_tile.dart`
- Modify: `lib/features/memorization/presentation/widgets/memorization_surah_tile.dart`

- [ ] Replace deprecated `withOpacity()` calls with `withValues(alpha: ...)`.
- [ ] Re-run `flutter analyze` to confirm the deprecation warnings are gone.

### Task 5.2: Reuse the cached SharedPreferences accessor in notifier code

**Files:**
- Modify: `lib/features/memorization/providers/memorization_providers.dart`
- Modify: `lib/features/library/providers/library_providers.dart`
- Modify tests if notifier initialization behavior changes

- [ ] Switch repeated `SharedPreferences.getInstance()` calls in the app-owned notifiers to `UserPreferences.prefs` or an equivalent shared accessor.
- [ ] Keep storage keys and persisted data format unchanged.
- [ ] Treat this as a maintenance cleanup, not a semantic state-management rewrite.

## Follow-Up Investigation Backlog

These items should not be implemented from the external plan without fresh evidence:

### F1: Audio `isPlaying` flicker

- Status: completed in `stabilization-wave5-audio-playback-state-consistency`.
- Evidence: app-owned focused tests now cover the stale package `isPlaying` path and prove that `ProcessingState.idle` clears false playing/session state while preserving paused non-idle sessions.

### F2: Prayer stale-cache badge

- Status: completed in `stabilization-wave7-prayer-stale-cache-indicator`.
- Evidence: cached prayer snapshots now carry stale metadata, the Home Tools hero renders a compact localized saved-time badge for cached data, and the badge clears once fresh remote data arrives.

### F3: SQLite initialization race protection

- Status: completed in `stabilization-wave6-quran-database-single-flight-init`.
- Evidence: focused datasource tests now prove concurrent callers share one in-flight `QuranDatabase` initialization and that a failed init clears retry state for a later successful attempt.

### F4: Shared HTTP client consolidation

- Need: a design pass that decides whether connection reuse is worth the additional indirection in this app.
- Reason deferred: this is cleanup, not stabilization-critical.

### F5: Equality-model overhaul

- Need: model-by-model design, not a bulk `==/hashCode` sweep.
- Reason deferred: naive id-only equality for planner aggregates would break legitimate state comparisons.

## Rejected External Proposals

### R1: Return `AudioHubPlaybackSnapshot.empty()` on bootstrap failure

- Rejected because it hides initialization failure behind a fake success-like state and conflicts with the current retryable error UI.

### R2: Return a blank widget for invalid tafsir routes

- Rejected because the current app already has a visible invalid-verse state, which is better than silently rendering nothing.

### R3: Compare `Khatma` objects by `id` only, then use that for `sameKhatmas()`

- Rejected because planner progress would stop being observable when non-id fields change.

### R4: Add broad `try/catch` around debounced provider reads with no reproduced failure

- Rejected because it can hide lifecycle bugs without proving that the feared error happens in this codebase.

## Verification Plan

### Minimum commands after each implementation wave

```powershell
cd "e:\work silf\quran kareem"
flutter analyze
flutter test
flutter build apk --debug
```

### Additional targeted verification

- Reader localization wave:
  - Switch app language to English.
  - Open the reader and verify tooltips, fonts dialog, copy text, and banner prefix no longer show hardcoded Arabic-only labels where localization is expected.
- Translation repository wave:
  - Run the new pagination-guard tests.
  - Smoke-test translation mode on a long surah.
- Local data error-surfacing wave:
  - Confirm affected screens show error or fallback states intentionally rather than crashing or silently going blank.
- Audio bootstrap wave:
  - Confirm initialization failures still land on the retry screen.
  - Do not close the issue based on code inspection alone; test the failure path.

## Execution Recommendation

Start with Phases 1 and 2 in the next implementation session; they carry the most confirmed value with the lowest regression risk. Phase 3 should be split into smaller commits because database error surfacing can cascade into multiple consumers. Phase 4 should only proceed with tests in the same change set. Phase 5 can be batched after the higher-risk logic work is stable.
