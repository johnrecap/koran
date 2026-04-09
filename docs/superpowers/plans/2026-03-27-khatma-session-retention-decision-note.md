# Decision Note: Khatma Session Retention

**Date:** 2026-03-27  
**Status:** Accepted  
**Related handoff:** `docs/superpowers/plans/2026-03-27-external-review-triage-execution-plan.md` Wave C  
**Question:** Should khatma-linked sessions keep full history, or should they
remain a single authoritative resume anchor per khatma?

## Decision

Keep the current **latest trusted anchor only** behavior for khatma-linked
`ReadingSession` records.

Wave C should **not** change `SessionsNotifier.upsertSession()` to preserve
multiple khatma-linked rows for the same `khatmaId`. The current behavior is an
intentional resume/planner contract, not an accidental loss of required user
history.

## Evidence Reviewed

1. `lib/features/reader/data/reader_save_recorder.dart`
   - Khatma saves write a dedicated session with
     `id: 'khatma-<khatmaId>'` and `isTrustedKhatmaAnchor: true`.
   - That fixed id already models a single authoritative anchor, not an
     append-only khatma history log.
2. `lib/features/memorization/providers/memorization_providers.dart`
   - `SessionsNotifier.upsertSession()` evicts the older khatma-linked row for
     the same `khatmaId`.
   - `KhatmaSessionIntegrityPolicy.latestTrustedSession(...)` resolves one
     trusted session for resume/sanitization behavior.
3. `lib/features/memorization/domain/memorization_hub_summary.dart`
   - The memorization hub resumes from the active khatma's newest trusted
     session when one exists.
4. `lib/features/memorization/domain/khatma_planner_summary.dart`
   - Planner summary receives a single `latestSession` input rather than a
     session history model.
5. `lib/features/memorization/presentation/screens/memorization_screen.dart`
   and `lib/features/memorization/presentation/screens/khatma_planner_screen.dart`
   - Both screens resume reading from one latest trusted khatma session and
     fall back to planner-derived progress when no trusted anchor exists.

## What the Current Model Means

- **Regular sessions** (`khatmaId == null`) already provide general reader
  continuity and recent session history.
- **Khatma-linked sessions** are different: they exist to store the current
  trusted resume anchor for one khatma.
- The planner aggregate (`furthestPageRead`, `readingDayKeys`,
  `totalReadMinutes`) already owns the longitudinal khatma progress view.

This means the app is **not** losing all reading history today. It is storing
two different concepts separately:

1. general session history for browsing/continuity
2. one trusted khatma resume anchor for planner-driven resume

## Options Considered

## Option A - Keep latest trusted anchor only

**Pros**

- Matches the fixed `khatma-<id>` write path already used by the recorder.
- Matches the hub/planner consumers that expect one authoritative latest
  session.
- Keeps the integrity/sanitize logic simple and aligned with the existing
  trusted-anchor model.
- Avoids reopening the earlier khatma data-integrity regressions.

**Cons**

- Does not provide a per-khatma timeline of every reading session by itself.

## Option B - Preserve full khatma session history in `ReadingSession`

**Pros**

- Would provide a richer historical log for analytics or future timeline UI.

**Cons**

- Changes the meaning of the existing `ReadingSession` contract from
  "authoritative anchor" to "mixed history plus anchor."
- Requires a new rule for selecting the authoritative resume anchor from
  several khatma-linked rows.
- Risks breaking sanitize and resume behavior that currently assume one trusted
  khatma anchor.
- Is larger than a safe Wave C fix because it needs new product semantics, not
  just a dedupe tweak.

## Rationale

The external review item correctly noticed that the provider keeps only one
khatma-linked session per `khatmaId`, but that behavior is consistent with the
rest of the memorization architecture. The app already distinguishes:

- general reader history
- khatma planner progress
- trusted khatma resume anchor

Collapsing these into one append-only session log would be a different feature,
not a safe bug fix.

## Consequences

- Wave C is resolved as a **documented design decision**, not a storage change.
- `SessionsNotifier.upsertSession()` should stay as-is for khatma-linked rows.
- Future review comments about "missing khatma history" should first answer
  whether the product wants a new history feature or only reliable resume.

## Follow-Up Rule

If the product later wants a full khatma history timeline, add a separate
app-owned history model or explicit anchor/history split. Do not repurpose the
current trusted-anchor contract by simply removing the khatma dedupe rule.
