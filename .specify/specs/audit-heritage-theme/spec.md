# Feature Specification: Heritage Theme Unification

**Feature Branch**: `audit-heritage-theme`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: Comprehensive Codebase Audit — BUG-3, BUG-4, UI-4, UI-7, UI-10, UI-11

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Unified Color Palette (Priority: P1)

As a user, I expect all screens to use the same visual identity — no subtle color mismatches between the reader, hub screens, and settings.

**Why this priority**: Two parallel color sets (`bgLight` vs `surfaceLight`, `bgDark` vs `surfaceDark`) cause visible inconsistency in dark mode.
**Independent Test**: After unification, `grep -r "bgLight\|bgDark\|cardBg" lib/` returns zero results — only Heritage colors remain.

**Acceptance Scenarios**:

1. **Given** `AppColors` with Legacy + Heritage duplicates, **When** unified, **Then** only one set of surface/background colors exists.
2. **Given** `AppTheme.darkTheme` using `bgDark` (0xFF221E10), **When** updated to Heritage `surfaceDark` (0xFF2A2218), **Then** dark mode looks consistent across all screens.
3. **Given** hardcoded `Color(0xFF2A2614)` in `app_theme.dart:78`, **When** replaced with `AppColors.cardDark`, **Then** the constant is centralized and maintainable.

---

### User Story 2 - ThemeExtension for Manuscript Colors (Priority: P2)

As a developer, I want Heritage colors accessible via `Theme.of(context).extension<ManuscriptColors>()` so widgets don't import `AppColors` directly.

**Why this priority**: Direct `AppColors` usage bypasses theming — prevents dynamic theme switching.
**Independent Test**: A widget using `ManuscriptColors` from context renders the correct Heritage palette in both light and dark modes.

**Acceptance Scenarios**:

1. **Given** no `ThemeExtension` exists, **When** `ManuscriptColors` is created, **Then** it contains all Heritage surface/text/accent colors.
2. **Given** `lightTheme` and `darkTheme`, **When** `ManuscriptColors` is registered as extension, **Then** `Theme.of(context).extension<ManuscriptColors>()!.surface` resolves correctly.

---

### User Story 3 - Manuscript SnackBar (Priority: P2)

As a user, I expect feedback messages (bookmark saved, verse copied) to match the Heritage Manuscript visual language — not the default Material gray.

**Acceptance Scenarios**:

1. **Given** a successful action (bookmark), **When** snackbar appears, **Then** it uses Heritage gold accent with Amiri typography.
2. **Given** an error action (copy failed), **When** snackbar appears, **Then** it uses a warm red tone consistent with the Heritage palette.

---

### User Story 4 - Bottom Nav Visual Polish (Priority: P3)

As a user, I want the active tab in the bottom navigation to be clearly distinguished with a modern pill indicator and subtle scale animation with haptic feedback.

**Acceptance Scenarios**:

1. **Given** a tab is active, **When** displayed, **Then** it shows a pill indicator (not a 5px dot).
2. **Given** I tap a tab, **When** the tap registers, **Then** I feel a haptic click and see a brief scale animation.

---

### Edge Cases

- What happens when system dark mode changes while the app is in Night Reader mode?
- How do `ManuscriptColors` interact with the existing Night Reader palette override?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST remove all Legacy color constants from `AppColors` and update all references.
- **FR-002**: System MUST create `ManuscriptColors` as `ThemeExtension`.
- **FR-003**: System MUST create `ManuscriptSnackBar` utility.
- **FR-004**: System MUST update bottom navigation indicator from dot to pill.
- **FR-005**: System MUST add haptic feedback on tab tap.
- **FR-006**: System MUST NOT break Night Reader theme override system.

### Key Entities

- **ManuscriptColors**: `ThemeExtension<ManuscriptColors>` — surface, card, text, accent, gold, camel.
- **ManuscriptSnackBar**: Static builder — `success()`, `error()`, `info()` factory methods.

## Success Criteria *(mandatory)*

- **SC-001**: Zero references to Legacy `bgLight`/`bgDark`/`cardBg` in codebase.
- **SC-002**: `ManuscriptColors` accessible via `Theme.of(context)` in both light and dark.
- **SC-003**: All SnackBars in the app use `ManuscriptSnackBar`.
- **SC-004**: Bottom nav pill indicator renders correctly on 320px-428px screen widths.
