# Tasks: Heritage Theme Unification

**Input**: Design documents from `/specs/audit-heritage-theme/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel
- **[Story]**: Which user story this task belongs to

## Phase 1: Color Cleanup (US1)

- [ ] T001 [US1] Audit all references to Legacy colors (`grep -rn "bgLight\|bgDark\|cardBg" lib/`)
- [ ] T002 [US1] Add `cardLight` and `cardDark` constants to `AppColors`
- [ ] T003 [US1] Replace all Legacy `bgLight` → `surfaceLight`, `bgDark` → `surfaceDark` references
- [ ] T004 [US1] Replace hardcoded `Color(0xFF2A2614)` in `app_theme.dart` with `AppColors.cardDark`
- [ ] T005 [US1] Remove Legacy constants from `AppColors` (mark as `@Deprecated` first if needed)
- [ ] T006 [US1] Run `flutter test` — verify no visual regressions

## Phase 2: ThemeExtension (US2)

- [ ] T007 [US2] Create `manuscript_colors.dart` with `ManuscriptColors extends ThemeExtension<ManuscriptColors>`
- [ ] T008 [US2] Implement `copyWith()`, `lerp()`, and static `light`/`dark` instances
- [ ] T009 [US2] Register `ManuscriptColors` in `AppTheme.lightTheme` and `AppTheme.darkTheme` via `extensions`
- [ ] T010 [US2] Write unit test: `Theme.of(context).extension<ManuscriptColors>()` resolves in both themes
- [ ] T011 [P] [US2] Migrate 3-5 representative widgets from `AppColors.xxx` to `ManuscriptColors` via context

## Phase 3: ManuscriptSnackBar (US3)

- [ ] T012 [US3] Create `manuscript_snack_bar.dart` with `success()`, `error()`, `info()` factories
- [ ] T013 [US3] Style with Heritage gold accent, Amiri/Inter typography, rounded corners
- [ ] T014 [P] [US3] Replace all `ScaffoldMessenger.showSnackBar(SnackBar(...))` calls with `ManuscriptSnackBar`

## Phase 4: Bottom Nav Polish (US4)

- [ ] T015 [US4] Replace 5px dot indicator with pill indicator (28w × 4h) in `_NavItem`
- [ ] T016 [US4] Add `HapticFeedback.selectionClick()` on tab tap
- [ ] T017 [US4] Add `TweenAnimationBuilder` scale animation (1.0 → 1.1) on active icon
- [ ] T018 [US4] Test on 320px, 375px, and 428px screen widths

## Phase 5: Verification

- [ ] T019 Run `flutter test` — zero regressions
- [ ] T020 Run `dart analyze` — zero new warnings
- [ ] T021 Visual smoke test: light mode → dark mode → Night Reader → back — color consistency
- [ ] T022 Update `constitution.md` — document ManuscriptColors pattern
