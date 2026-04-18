# Tasks: UX Accessibility & Reader Polish

**Input**: Design documents from `/specs/audit-ux-accessibility/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel
- **[Story]**: Which user story this task belongs to

## Phase 1: VerseActionMenu Accessibility (US1)

- [ ] T001 [US1] Add `Semantics(label: l10n.verseAction*)` wrapper to each `_ActionButton`
- [ ] T002 [US1] Add `Tooltip(message: ...)` to each `_ActionButton`
- [ ] T003 [US1] Increase `_ActionButton` container from 44×44 to 48×48
- [ ] T004 [US1] Replace `GridView.count(crossAxisCount: 4)` with `Wrap(spacing: 10, runSpacing: 12)`
- [ ] T005 [US1] Shorten `mushafMuallimStartFromHere` to `mushafMuallimFromHere` in `app_localizations.dart` (ar: "المعلّم من هنا", en: "Muallim from here")
- [ ] T006 [US1] Test with TalkBack enabled — verify all buttons read aloud

## Phase 2: Fullscreen Exit Discoverability (US2)

- [ ] T007 [US2] Add `fullscreenHintShown` key to `StorageKeys` and `UserPreferences`
- [ ] T008 [US2] Create `fullscreen_exit_overlay.dart` with `Timer` (4s) + `FadeTransition`
- [ ] T009 [US2] Add first-time hint Tooltip: "اضغط هنا للخروج" / "Tap here to exit" — shown once, persisted
- [ ] T010 [US2] Integrate overlay into `reader_screen.dart` replacing inline fullscreen button
- [ ] T011 [US2] Test: enter fullscreen → button visible → wait 4s → button fades → tap → button reappears

## Phase 3: Jump-To Dialog (US3)

- [ ] T012 [P] [US3] Add current position header to jump-to dialog: "الموقع الحالي: {surah} — صفحة {page}"
- [ ] T013 [P] [US3] Add localized strings for current position display in `app_localizations.dart`

## Phase 4: Mini Player Progress (US4)

- [ ] T014 [P] [US4] Add 2px `LinearProgressIndicator` to mini player in `app_shell.dart`
- [ ] T015 [P] [US4] Sync progress bar value with audio position provider (`position / duration`)
- [ ] T016 [US4] Test: play audio → verify progress advances → pause → verify bar holds position

## Phase 5: Verification

- [ ] T017 Run `flutter test` — zero regressions
- [ ] T018 Run `dart analyze` — zero new warnings
- [ ] T019 Accessibility audit: TalkBack on Android, VoiceOver on iOS simulator
- [ ] T020 Update `constitution.md` with accessibility patterns and fullscreen overlay component
