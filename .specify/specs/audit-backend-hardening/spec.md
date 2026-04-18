# Feature Specification: Backend Architecture Hardening

**Feature Branch**: `audit-backend-hardening`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: Comprehensive Codebase Audit — BUG-2, BUG-5, ARCH-1, ARCH-2, ARCH-3, ARCH-5, ARCH-7, ARCH-8

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Crash Reporting in Production (Priority: P1)

As a developer, I need production crashes reported to an external service (Firebase Crashlytics or Sentry) so I can discover and fix issues before users report them.

**Why this priority**: Currently `ErrorReportingService` uses `NoopErrorReportingService` — zero visibility into production crashes.
**Independent Test**: Throw a test exception in debug mode → verify it appears in the Crashlytics/Sentry dashboard.

**Acceptance Scenarios**:

1. **Given** the app is in release mode, **When** an unhandled exception occurs, **Then** it is reported to the crash reporting service with stack trace and device info.
2. **Given** the app is in debug mode, **When** `ErrorReporting.report()` is called, **Then** it logs locally only (no remote reporting).
3. **Given** `ErrorReportingService` abstraction exists, **When** a Crashlytics implementation is provided, **Then** it plugs in without changing any call sites.

---

### User Story 2 - Localization Key Safety (Priority: P1)

As a developer, I need a CI-enforceable check that all localization keys exist in both `ar` and `en` maps, so missing translations are caught before they reach production.

**Why this priority**: Current `Map<String, Map<String, String>>` approach returns empty strings silently for missing keys — causes blank UI text.
**Independent Test**: Remove a key from one language map → run the test → test fails with clear error message.

**Acceptance Scenarios**:

1. **Given** a test file `test/core/localization/localization_coverage_test.dart`, **When** run, **Then** it verifies every key in `ar` exists in `en` and vice versa.
2. **Given** a developer adds a new key to `ar` only, **When** CI runs, **Then** the test fails listing the missing `en` key.
3. **Given** the test passes, **When** verified, **Then** both language maps have identical key sets.

---

### User Story 3 - Atomic Settings Writes (Priority: P2)

As a user changing night reader schedule, I need both start and end times saved atomically so a crash between writes doesn't leave inconsistent settings.

**Acceptance Scenarios**:

1. **Given** `setNightReaderSchedule()` is called, **When** both values are written, **Then** they are persisted in a single operation.
2. **Given** the app crashes during write, **When** restarted, **Then** the night schedule is either fully updated or fully unchanged — never partial.

---

### User Story 4 - Router as Provider (Priority: P2)

As a developer writing tests, I need `appRouter` accessible via a Riverpod provider so tests can override it with custom initial locations.

**Acceptance Scenarios**:

1. **Given** `appRouterProvider` exists, **When** used in `MaterialApp.router`, **Then** the app navigates identically to the current global instance.
2. **Given** a test needs custom router, **When** overriding `appRouterProvider`, **Then** the test router is used without affecting production code.

---

### User Story 5 - Database Dependency Injection (Priority: P3)

As a developer writing widget tests, I need `QuranDatabase` injectable via a provider instead of static methods, so tests don't rely on `debugOverride*ForTest()` hacks.

**Acceptance Scenarios**:

1. **Given** `quranDatabaseProvider` exists, **When** tests provide a mock, **Then** all database queries route through the mock — no shared static state.
2. **Given** production code, **When** using `ref.read(quranDatabaseProvider)`, **Then** behavior is identical to current `QuranDatabase.getAyah(...)`.

---

### User Story 6 - Sessions Storage Migration (Priority: P3)

As a user with 200+ reading sessions, I need session data stored in SQLite instead of SharedPreferences JSON, so the app doesn't slow down on save/load operations.

**Acceptance Scenarios**:

1. **Given** sessions in SharedPreferences JSON, **When** migration runs, **Then** all sessions are moved to SQLite and the JSON key is cleared.
2. **Given** 500 sessions in SQLite, **When** `upsertSession()` is called, **Then** the operation completes in < 50ms (vs current ~200ms JSON re-serialize).
3. **Given** backward compatibility, **When** old version data exists, **Then** `DataMigrationService` v2 handles the transition.

---

### Edge Cases

- What happens if Crashlytics initialization fails (no network)?
- How does the localization test handle keys that are intentionally different between languages (e.g., RTL markers)?
- What if SharedPreferences write fails silently — should we verify reads after writes?
- How do we handle the SQLite migration if the user downgrades the app?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST implement `CrashlyticsErrorReportingService` plugged into `ErrorReporting.install()`.
- **FR-002**: System MUST have a localization coverage test comparing `ar` and `en` key sets.
- **FR-003**: System MUST make `setNightReaderSchedule` atomic (single JSON object or batch commit).
- **FR-004**: System MUST expose `appRouter` via `appRouterProvider` Riverpod provider.
- **FR-005**: System MUST create `quranDatabaseProvider` wrapping `QuranDatabase` for DI.
- **FR-006**: System MUST add `DataMigrationService` v2 step to migrate sessions from JSON to SQLite.
- **FR-007**: System MUST replace `KhatmaSessionIntegrityPolicy.sameKhatmas` JSON comparison with `Equatable` or `DeepCollectionEquality`.

### Key Entities

- **CrashlyticsErrorReportingService**: Implements `ErrorReportingService` → Firebase Crashlytics.
- **LocalizationCoverageTest**: Test asserting ar/en key parity.
- **AppRouterProvider**: `Provider<GoRouter>` replacing global `appRouter`.
- **QuranDatabaseProvider**: `Provider<QuranDatabase>` replacing static methods.
- **SessionsDatabase**: SQLite table `reading_sessions` replacing SharedPreferences JSON.
- **MigrationV2**: DataMigration step to move sessions to SQLite.

## Success Criteria *(mandatory)*

- **SC-001**: Production crashes appear in Crashlytics/Sentry dashboard within 60 seconds.
- **SC-002**: Localization coverage test passes in CI — catches missing keys.
- **SC-003**: Night schedule writes are atomic — crash between writes is impossible.
- **SC-004**: `appRouter` only accessible via provider — no global mutable reference.
- **SC-005**: `QuranDatabase` testable without `debugOverride*ForTest()`.
- **SC-006**: 500 sessions save in < 50ms with SQLite (vs ~200ms JSON).
- **SC-007**: Zero `jsonEncode` comparisons in `KhatmaSessionIntegrityPolicy`.
