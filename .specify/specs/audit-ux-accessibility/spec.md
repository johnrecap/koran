# Feature Specification: UX Accessibility & Reader Polish

**Feature Branch**: `audit-ux-accessibility`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: Comprehensive Codebase Audit — UI-1, UI-2, UI-3, UI-5, UI-6, UI-8, UI-12

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Verse Action Menu Accessibility (Priority: P1)

As a user with visual impairments using TalkBack/VoiceOver, I need every button in the verse action menu to be properly labeled with semantic descriptions so I can interact with all verse features.

**Why this priority**: Accessibility is a fundamental requirement — the Quran must be accessible to all Muslims.
**Independent Test**: Enable TalkBack on Android → long-press a verse → every action button is read aloud with its label.

**Acceptance Scenarios**:

1. **Given** a verse action menu is displayed, **When** TalkBack reads the buttons, **Then** each button announces its label (e.g., "استماع", "نسخ", "مشاركة").
2. **Given** `_ActionButton` has 44×44px touch target, **When** increased to 48×48px, **Then** meets both Apple (44pt) and Material (48dp) minimum touch targets.
3. **Given** `GridView.count(crossAxisCount: 4)` with 9 items (Muallim enabled), **When** rendered, **Then** uses `Wrap` instead to accommodate overflow gracefully.
4. **Given** the Muallim button label "ابدأ المصحف المعلّم من هنا", **When** displayed in a grid cell, **Then** the label is shortened to "المعلّم من هنا" to prevent text truncation.

---

### User Story 2 - Fullscreen Exit Discoverability (Priority: P2)

As a new user in fullscreen reader mode, I need a clear, temporary hint showing me how to exit fullscreen, so I don't feel trapped.

**Acceptance Scenarios**:

1. **Given** I enter fullscreen mode, **When** the exit button appears, **Then** it auto-hides after 4 seconds with a fade-out animation.
2. **Given** I enter fullscreen for the first time ever, **When** entering, **Then** a one-time tooltip shows "اضغط هنا للخروج من وضع الشاشة الكاملة".
3. **Given** I tap anywhere in fullscreen, **When** the overlay toggles, **Then** the exit button reappears for another 4 seconds.

---

### User Story 3 - Jump-To Dialog Enhancement (Priority: P3)

As a user opening the "go to page/surah" dialog, I need to see my current position (current surah name + page number) so I can navigate relative to where I am.

**Acceptance Scenarios**:

1. **Given** I'm on page 50 of Surah Al-Baqarah, **When** I open the jump-to dialog, **Then** it shows "الموقع الحالي: البقرة — صفحة ٥٠".
2. **Given** the dialog is in English locale, **When** displayed, **Then** it shows "Current: Al-Baqarah — Page 50".

---

### User Story 4 - Audio Mini Player Progress (Priority: P3)

As a user listening to audio recitation via the mini player, I need to see a thin progress bar showing how far into the current surah playback I am.

**Acceptance Scenarios**:

1. **Given** audio is playing, **When** the mini player is visible, **Then** a 2px linear progress indicator shows playback position relative to total duration.
2. **Given** audio is paused, **When** the mini player is visible, **Then** the progress bar remains at the paused position (not reset).

---

### Edge Cases

- What happens when `Tooltip` text in Arabic is long and the screen is narrow (320px)?
- How does the fullscreen auto-hide timer interact with Muallim word-highlight updates?
- Does the mini player progress bar affect scrolling performance on older devices?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST add `Semantics(label: ...)` to every `_ActionButton` in `VerseActionMenu`.
- **FR-002**: System MUST increase `_ActionButton` touch target to 48×48px.
- **FR-003**: System MUST add `Tooltip` to `_ActionButton`.
- **FR-004**: System MUST replace `GridView.count` with `Wrap` in `VerseActionMenu` for dynamic item count.
- **FR-005**: System MUST shorten Muallim button label in `AppLocalizations`.
- **FR-006**: System MUST add auto-hide timer (4s) + fade animation for fullscreen exit button.
- **FR-007**: System MUST show first-time fullscreen hint (persisted via `UserPreferences`).
- **FR-008**: System MUST show current position in jump-to dialog.
- **FR-009**: System MUST add thin progress indicator to audio mini player.

### Key Entities

- **VerseActionMenu**: Enhanced with Semantics, Tooltip, Wrap layout, 48px targets.
- **FullscreenOverlay**: Auto-hide timer, fade animation, first-time hint.
- **JumpToDialog**: Current position display header.
- **MiniPlayerProgress**: 2px `LinearProgressIndicator` synced to audio position.

## Success Criteria *(mandatory)*

- **SC-001**: TalkBack/VoiceOver reads all 8-9 verse action buttons correctly.
- **SC-002**: Touch targets ≥ 48dp on all interactive elements in `VerseActionMenu`.
- **SC-003**: Fullscreen exit button auto-hides after 4 seconds.
- **SC-004**: Jump-to dialog shows current surah + page.
- **SC-005**: Mini player shows playback progress.
