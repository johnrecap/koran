# Tasks: Backend Architecture Hardening

**Input**: Design documents from `/specs/audit-backend-hardening/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel
- **[Story]**: Which user story this task belongs to

## Phase 1: Crash Reporting (US1) — Priority P1

- [ ] T001 [US1] Add `firebase_crashlytics` dependency to `pubspec.yaml` (or Sentry — pending user decision)
- [ ] T002 [US1] Create `crashlytics_error_reporting.dart` implementing `ErrorReportingService`
- [ ] T003 [US1] Wire `ErrorReporting.install(CrashlyticsErrorReportingService())` in release mode in `main.dart`
- [ ] T004 [US1] Keep `NoopErrorReportingService` for debug mode
- [ ] T005 [US1] Test: throw test exception → verify it appears in dashboard

## Phase 2: Localization Safety (US2) — Priority P1

- [ ] T006 [P] [US2] Create `test/core/localization/localization_coverage_test.dart`
- [ ] T007 [P] [US2] Implement key parity assertion: `expect(arKeys, equals(enKeys))`
- [ ] T008 [US2] Run test — fix any discovered missing keys in `app_localizations.dart`

## Phase 3: Atomic Settings Writes (US3) — Priority P2

- [ ] T009 [US3] Add `StorageKeys.nightReaderSchedule` key for JSON object storage
- [ ] T010 [US3] Refactor `UserPreferences.setNightReaderSchedule` to write single JSON `{"start": N, "end": N}`
- [ ] T011 [US3] Refactor `UserPreferences.getNightReaderStartMinutes` / `getNightReaderEndMinutes` to read from JSON
- [ ] T012 [US3] Add `DataMigrationService` step to merge old separate keys into new JSON format
- [ ] T013 [US3] Update `AppBootstrapService` to use new getter
- [ ] T014 [US3] Unit test: write schedule → crash simulation → read → verify atomicity

## Phase 4: Router Provider (US4) — Priority P2

- [ ] T015 [P] [US4] Create `appRouterProvider = Provider<GoRouter>((ref) => createAppRouter())`
- [ ] T016 [P] [US4] Update `MaterialApp.router` in `main.dart` to use `ref.watch(appRouterProvider)`
- [ ] T017 [US4] Deprecate global `appRouter` with `@Deprecated` annotation
- [ ] T018 [US4] Update all `appRouter.go(...)` call sites to use provider-based access
- [ ] T019 [US4] Run full test suite — verify navigation works identically

## Phase 5: Database DI (US5) — Priority P3

- [ ] T020 [US5] Create `quran_database_provider.dart` — `Provider<QuranDatabase>((ref) => QuranDatabase())`
- [ ] T021 [US5] Add instance method equivalents to `QuranDatabase` (non-breaking — statics remain)
- [ ] T022 [US5] Migrate 2-3 high-traffic consumers to use provider (e.g., search, memorization)
- [ ] T023 [US5] Mark static methods as `@Deprecated` with migration guidance

## Phase 6: Khatma Comparison Fix (US5)

- [ ] T024 [P] [US5] Replace `sameKhatmas` JSON encoding with `DeepCollectionEquality` from `collection` package
- [ ] T025 [P] [US5] Unit test: compare identical and different Khatma lists — verify correctness + performance

## Phase 7: Sessions SQLite Migration (US6) — Priority P3

- [ ] T026 [US6] Create `sessions_database.dart` with SQLite schema (table, indices)
- [ ] T027 [US6] Implement CRUD methods: `insertSession`, `upsertSession`, `deleteSession`, `querySessions`, `queryByKhatmaId`
- [ ] T028 [US6] Create `migration_v2.dart` — read JSON from SharedPreferences → batch insert SQLite → confirm → clear JSON
- [ ] T029 [US6] Register `migration_v2` in `DataMigrationService.defaultMigrationSteps`
- [ ] T030 [US6] Update `SessionsNotifier` to use `sessions_database.dart` instead of JSON persistence
- [ ] T031 [US6] Performance test: upsert 500 sessions → verify < 50ms total
- [ ] T032 [US6] Backward compatibility test: fresh install + old version data → migration succeeds

## Phase 8: Verification

- [ ] T033 Run `flutter test` — zero regressions across all changes
- [ ] T034 Run `dart analyze` — zero new warnings
- [ ] T035 Manual test: full app workflow (splash → reader → settings → memorization → audio)
- [ ] T036 Update `constitution.md` with new patterns (crash reporting, appRouterProvider, sessions SQLite)
