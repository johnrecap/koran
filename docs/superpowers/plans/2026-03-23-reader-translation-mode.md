# Reader Translation Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a third reader mode that displays verse-by-verse translation and
allows explicit switching between `scroll`, `page`, and `translation`.

**Architecture:** Preserve `quran_library` for the authentic Arabic-only modes,
and build translation mode as an app-owned surface backed by a dedicated remote
translation data layer. Keep navigation anchored to the existing
`ReaderNavigationTarget` contract so mode switching and reader entry remain
consistent across the app.

**Tech Stack:** Flutter, Riverpod, GoRouter, `http`, `sqflite`, local
`quran_library` fork, app localization in `AppLocalizations`

---

### Task 1: Extend Reader Mode Contracts

**Files:**
- Modify: `lib/features/reader/domain/reader_mode_policy.dart`
- Modify: `lib/data/datasources/local/user_preferences.dart`
- Test: `test/features/reader/domain/reader_mode_policy_test.dart`

- [ ] **Step 1: Write the failing tests for the new mode**

Add expectations for:
- `ReaderMode.translation`
- parsing `translation`
- serializing `translation`

- [ ] **Step 2: Run the targeted reader-mode tests to verify failure**

Run:
```powershell
flutter test test/features/reader/domain/reader_mode_policy_test.dart
```

- [ ] **Step 3: Extend the reader mode enum and persistence policy**

Implement:
- `ReaderMode.translation`
- `ReaderModePolicy.fromPreference('translation')`
- `ReaderModePolicy.toPreference(ReaderMode.translation)`

- [ ] **Step 4: Re-run the targeted reader-mode tests**

Run:
```powershell
flutter test test/features/reader/domain/reader_mode_policy_test.dart
```

- [ ] **Step 5: Commit**

```powershell
git add lib/features/reader/domain/reader_mode_policy.dart lib/data/datasources/local/user_preferences.dart test/features/reader/domain/reader_mode_policy_test.dart
git commit -m "test: add translation reader mode contracts"
```

### Task 2: Add Translation Domain and Remote Data Layer

**Files:**
- Create: `lib/features/reader/domain/ayah_translation.dart`
- Create: `lib/features/reader/data/reader_translation_remote_data_source.dart`
- Create: `lib/features/reader/data/reader_translation_repository.dart`
- Modify: `lib/core/constants/app_constants.dart`
- Test: `test/features/reader/data/reader_translation_remote_data_source_test.dart`

- [ ] **Step 1: Write failing data-mapping tests**

Cover:
- API response parsing
- missing verse handling
- preserving ayah numbers for merge-by-reference

- [ ] **Step 2: Run the targeted data-layer tests to verify failure**

Run:
```powershell
flutter test test/features/reader/data/reader_translation_remote_data_source_test.dart
```

- [ ] **Step 3: Implement the translation models and remote source**

Create a remote source that:
- accepts surah number and translation resource id
- calls `Quran.com API v4`
- maps results to feature/domain models

- [ ] **Step 4: Implement a repository boundary**

The repository should normalize API rows into a lookup keyed by
`ayahNumber` for UI merging.

- [ ] **Step 5: Re-run the targeted data-layer tests**

Run:
```powershell
flutter test test/features/reader/data/reader_translation_remote_data_source_test.dart
```

- [ ] **Step 6: Commit**

```powershell
git add lib/features/reader/domain/ayah_translation.dart lib/features/reader/data/reader_translation_remote_data_source.dart lib/features/reader/data/reader_translation_repository.dart lib/core/constants/app_constants.dart test/features/reader/data/reader_translation_remote_data_source_test.dart
git commit -m "feat: add reader translation data layer"
```

### Task 3: Add Translation Providers and Reader Mode Selector

**Files:**
- Modify: `lib/features/reader/providers/reader_providers.dart`
- Create: `lib/features/reader/presentation/widgets/reader_mode_selector.dart`
- Test: `test/features/reader/domain/reader_interaction_policy_test.dart`

- [ ] **Step 1: Add tests or assertions for explicit three-state mode behavior**

If the selector logic is isolated in a policy/helper, test it directly.

- [ ] **Step 2: Run the relevant targeted tests**

Run:
```powershell
flutter test test/features/reader/domain/reader_interaction_policy_test.dart
```

- [ ] **Step 3: Add providers for translation loading**

Include:
- translation source id provider
- translation-surah provider keyed by `surahNumber`

- [ ] **Step 4: Create the reader mode selector widget**

The widget must expose all three modes explicitly and avoid binary toggle logic.

- [ ] **Step 5: Re-run the targeted tests**

Run:
```powershell
flutter test test/features/reader/domain/reader_interaction_policy_test.dart
```

- [ ] **Step 6: Commit**

```powershell
git add lib/features/reader/providers/reader_providers.dart lib/features/reader/presentation/widgets/reader_mode_selector.dart test/features/reader/domain/reader_interaction_policy_test.dart
git commit -m "feat: add reader mode selector and translation providers"
```

### Task 4: Build Translation Mode UI

**Files:**
- Create: `lib/features/reader/presentation/widgets/translation_mode_view.dart`
- Create: `lib/features/reader/presentation/widgets/translated_ayah_tile.dart`
- Test: `test/features/reader/presentation/widgets/translation_mode_view_test.dart`

- [ ] **Step 1: Write failing widget tests for translation mode states**

Cover:
- loading
- error
- rendered ayah + translation
- missing translation fallback per ayah if needed

- [ ] **Step 2: Run the translation widget tests to verify failure**

Run:
```powershell
flutter test test/features/reader/presentation/widgets/translation_mode_view_test.dart
```

- [ ] **Step 3: Implement `TranslatedAyahTile`**

Render:
- Arabic text
- ayah reference
- translation text

- [ ] **Step 4: Implement `TranslationModeView`**

Responsibilities:
- load Arabic ayahs for the active surah
- load translated rows for the active surah
- merge them by `ayahNumber`
- anchor to the requested target ayah on initial build

- [ ] **Step 5: Re-run the translation widget tests**

Run:
```powershell
flutter test test/features/reader/presentation/widgets/translation_mode_view_test.dart
```

- [ ] **Step 6: Commit**

```powershell
git add lib/features/reader/presentation/widgets/translation_mode_view.dart lib/features/reader/presentation/widgets/translated_ayah_tile.dart test/features/reader/presentation/widgets/translation_mode_view_test.dart
git commit -m "feat: add translation mode reader surface"
```

### Task 5: Integrate Translation Mode Into `ReaderScreen`

**Files:**
- Modify: `lib/features/reader/presentation/screens/reader_screen.dart`
- Modify: `lib/core/localization/app_localizations.dart`
- Test: `test/features/reader/domain/reader_mode_policy_test.dart`
- Test: `test/features/reader/presentation/widgets/translation_mode_view_test.dart`

- [ ] **Step 1: Replace the current binary mode toggle with the explicit selector**

- [ ] **Step 2: Add a translation-mode branch in `ReaderScreen.build()`**

The reader body must select between:
- scroll mode
- page mode
- translation mode

- [ ] **Step 3: Keep navigation target behavior consistent**

Ensure:
- surah drawer still updates the active target
- jump-to still updates the active target
- switching modes keeps the same `ReaderNavigationTarget`

- [ ] **Step 4: Localize all new strings**

Add keys for:
- translation mode label
- loading
- retry
- translation unavailable/error states
- any new tooltips

- [ ] **Step 5: Re-run targeted tests**

Run:
```powershell
flutter test test/features/reader/domain/reader_mode_policy_test.dart
flutter test test/features/reader/presentation/widgets/translation_mode_view_test.dart
```

- [ ] **Step 6: Commit**

```powershell
git add lib/features/reader/presentation/screens/reader_screen.dart lib/core/localization/app_localizations.dart test/features/reader/domain/reader_mode_policy_test.dart test/features/reader/presentation/widgets/translation_mode_view_test.dart
git commit -m "feat: integrate reader translation mode"
```

### Task 6: Full Verification and Cleanup

**Files:**
- Review: `.specify/specs/reader-translation-mode/spec.md`
- Review: `.specify/specs/reader-translation-mode/plan.md`
- Review: `.specify/specs/reader-translation-mode/tasks.md`
- Review: `.specify/memory/constitution.md`

- [ ] **Step 1: Run reader-focused tests**

Run:
```powershell
flutter test test/features/reader
```

- [ ] **Step 2: Run project verification**

Run:
```powershell
flutter analyze
flutter test
flutter build apk --debug
flutter run -d 0H74425I251015CB --debug --no-resident
```

- [ ] **Step 3: Update constitution if implementation established a new lasting rule**

- [ ] **Step 4: Prepare execution handoff**

Execution options after approval:
1. Subagent-driven
2. Inline execution
