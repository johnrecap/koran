# Tasks: Reader Screen Decomposition

**Input**: Design documents from `/specs/audit-reader-decomposition/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel
- **[Story]**: Which user story this task belongs to

## Phase 1: Preparation

- [ ] T001 [US1] Snapshot current reader test results as baseline (`flutter test --reporter expanded`)
- [ ] T002 [US1] Document the exact line ranges for each extraction target in `reader_screen.dart`

## Phase 2: Mixin Extraction (US1)

- [ ] T003 [US1] Create `reader_progress_mixin.dart` — extract khatma tracking, session save/restore, reading position persistence
- [ ] T004 [US1] Create `reader_fullscreen_mixin.dart` — extract enter/exit fullscreen, scroll-position restore, overlay build
- [ ] T005 [P] [US1] Create `reader_verse_actions_mixin.dart` — extract bookmark/share/copy/note/tadabbur/insights callbacks
- [ ] T006 [P] [US1] Create `reader_muallim_mixin.dart` — extract muallim toggle, auto-navigation, controls build
- [ ] T007 [US1] Refactor `reader_screen.dart` to use all 4 mixins — strip to shell ≤ 400 lines
- [ ] T008 [US1] Run full test suite — verify zero regressions

## Phase 3: MuallimNotifier Migration (US2)

- [ ] T009 [US2] Create `MuallimNotifier` v2 as `Notifier<MuallimSnapshot>` alongside existing implementation
- [ ] T010 [US2] Replace manual stream subscription with `ref.onDispose()` lifecycle
- [ ] T011 [US2] Remove all manual `if (!mounted) return;` checks — verify Notifier lifecycle handles them
- [ ] T012 [US2] Update `muallimStateProvider` to `NotifierProvider<MuallimNotifier, MuallimSnapshot>`
- [ ] T013 [US2] Verify all downstream providers compile and function (`muallimWordHighlightProvider`, `muallimAutoNavigationTargetProvider`)
- [ ] T014 [US2] Run Muallim-specific tests — verify playback, word timing, session restore

## Phase 4: Verification

- [ ] T015 Run full `flutter test` suite — compare against Phase 1 baseline
- [ ] T016 Manual smoke test: open reader → scroll mode → fullscreen → exit → bookmark → share → muallim play → pause → stop
- [ ] T017 Verify `reader_screen.dart` line count ≤ 400
- [ ] T018 Run `dart analyze` — zero new warnings
- [ ] T019 Update constitution.md with new file structure
