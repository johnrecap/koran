# Implementation Plan: Backend Architecture Hardening

**Branch**: `audit-backend-hardening` | **Date**: 2026-04-18 | **Spec**: [spec.md](spec.md)

## Summary

Harden backend infrastructure: add crash reporting, localization key safety test, atomic SharedPreferences writes, provider-based DI for router and database, efficient Khatma comparison, and SQLite migration for sessions.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: flutter_riverpod, sqflite, shared_preferences, firebase_crashlytics (new), equatable (new)  
**Storage**: SharedPreferences → SQLite migration for sessions  
**Testing**: `flutter test` — unit tests for migration, localization, providers  
**Target Platform**: iOS/Android  
**Project Type**: mobile-app

## Constitution Check

*GATE: Must pass before implementation.*

- ✅ Clean Architecture: All changes follow existing layer boundaries.
- ✅ Local-first: SQLite migration keeps data local — no cloud dependency.
- ✅ Riverpod patterns: New providers follow established `Provider<T>` conventions.
- ✅ Firebase Crashlytics: Optional dependency — `NoopErrorReportingService` remains for debug.
- ⚠️ **New dependency**: `firebase_crashlytics` — must be evaluated against local-first principle. Alternative: Sentry (no Firebase dependency). **Decision needed from user.**
- ⚠️ **New dependency**: `equatable` — lightweight, no platform concerns. Can use `collection` package's `DeepCollectionEquality` instead if preferred.

## Project Structure

```text
lib/core/
├── services/
│   └── error_reporting_service.dart         ← [MODIFY] Keep abstraction
│   └── crashlytics_error_reporting.dart     ← [NEW] Firebase Crashlytics impl
├── router/
│   └── app_router.dart                      ← [MODIFY] Wrap in provider
├── providers/
│   └── quran_database_provider.dart         ← [NEW] DI for QuranDatabase

lib/data/datasources/local/
├── user_preferences.dart                    ← [MODIFY] Atomic night schedule
├── quran_database.dart                      ← [MODIFY] Instance methods, deprecate static
└── sessions_database.dart                   ← [NEW] SQLite sessions table

lib/core/services/migrations/
└── migration_v2.dart                        ← [NEW] Sessions JSON → SQLite

lib/features/memorization/providers/
└── memorization_providers.dart              ← [MODIFY] Equatable Khatma comparison

test/core/localization/
└── localization_coverage_test.dart          ← [NEW] Key parity test
```

### Files Modified

| File | Action | Change |
|------|--------|--------|
| `error_reporting_service.dart` | KEEP | Abstraction unchanged |
| `crashlytics_error_reporting.dart` | NEW | Crashlytics implementation |
| `app_router.dart` | MODIFY | Wrap in `appRouterProvider`, deprecate global |
| `quran_database_provider.dart` | NEW | `Provider<QuranDatabase>` |
| `quran_database.dart` | MODIFY | Add instance method equivalents, deprecate statics |
| `user_preferences.dart` | MODIFY | Atomic night schedule write |
| `sessions_database.dart` | NEW | SQLite table + CRUD for reading sessions |
| `migration_v2.dart` | NEW | JSON → SQLite data migration |
| `data_migration_service.dart` | MODIFY | Register v2 step |
| `memorization_providers.dart` | MODIFY | Replace JSON comparison with equality |
| `localization_coverage_test.dart` | NEW | ar/en key parity assertion |

## Atomic Night Schedule Strategy

### Option A: Single JSON Object (Recommended)
```dart
// Store as JSON: {"start": 1200, "end": 300}
static Future<void> setNightReaderSchedule({
  required int startMinutes,
  required int endMinutes,
}) async {
  final p = await prefs;
  await p.setString(
    StorageKeys.nightReaderSchedule,
    jsonEncode({'start': startMinutes, 'end': endMinutes}),
  );
}
```

### Option B: Keep separate keys, read both on load
Less safe — still two writes. Rejected.

## Sessions SQLite Schema

```sql
CREATE TABLE reading_sessions (
  id TEXT PRIMARY KEY,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER,
  page_number INTEGER,
  khatma_id TEXT,
  is_trusted_khatma_anchor INTEGER NOT NULL DEFAULT 0,
  timestamp TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 0,
  metadata TEXT  -- JSON blob for future extensibility
);

CREATE INDEX idx_sessions_khatma ON reading_sessions(khatma_id);
CREATE INDEX idx_sessions_timestamp ON reading_sessions(timestamp DESC);
```

## Migration V2 Strategy

1. Read existing sessions from `SharedPreferences` key `StorageKeys.readingSessions`.
2. Parse JSON array → `List<ReadingSession>`.
3. Batch insert into SQLite `reading_sessions` table.
4. **Do NOT delete** the SharedPreferences key until SQLite write is confirmed.
5. Mark migration v2 complete.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| `firebase_crashlytics` dependency | Production crash visibility | `NoopErrorReportingService` provides zero visibility |
| SQLite for sessions | 500 sessions in JSON causes O(n) serialize on every write | SharedPreferences has no partial update capability |
| Instance methods on `QuranDatabase` | Enable DI and testing without debug overrides | Static methods are untestable without global mutable state |
