# Deep Audit Remediation Deferred Backlog

**Recorded:** 2026-04-05  
**Source:** `.specify/specs/deep-audit-remediation/plan.md` and
`.specify/specs/deep-audit-remediation/tasks.md`

## Purpose

Keep intentionally deferred cleanup items out of the current remediation wave
while preserving clear follow-up scope for future sessions.

## Deferred Items

### 1. `reader_screen.dart` decomposition

- Scope: split the large reader screen into smaller screen/widget units with
  clearer ownership boundaries.
- Why deferred: this is a structural refactor with wider regression risk than
  the behavior-preserving audit fixes.
- Re-entry rule: requires its own spec, plan, tasks, and targeted reader
  regression coverage.

### 2. `Khatma` equality and `hashCode`

- Scope: define explicit value equality semantics for the planner aggregate.
- Why deferred: correctness is not blocked today, and the change needs a clear
  decision about identity, mutable progress fields, and collection behavior.
- Re-entry rule: requires a separate spec before any model-level equality
  change ships.

### 3. Policy class `///` documentation pass

- Scope: add missing API docs to policy classes incrementally.
- Why deferred: it improves maintainability but does not change runtime
  behavior or unblock current remediation.
- Re-entry rule: can be scheduled as a low-risk cleanup slice and should avoid
  mixing with behavioral work.

### 4. Reader and prayer test coverage expansion

- Scope: expand widget/provider coverage around `reader_screen.dart`,
  `more_providers.dart`, prayer surfaces, and adjacent error-state flows.
- Why deferred: the current wave focused on stabilizing behavior first, with
  targeted verification added where risk was highest.
- Re-entry rule: create a dedicated testing spec so coverage goals, fixtures,
  and expected regression cases are explicit.

### 5. Data migration strategy

- Scope: define migration rules for any future persisted-shape changes in local
  preferences, memorization data, or database-backed metadata.
- Why deferred: the current remediation stays backward-compatible and does not
  require a migration contract.
- Re-entry rule: any future storage-shape change must open a separate spec with
  compatibility, fallback, and rollback details.

## Execution Rule

Do not pull any item from this backlog into the completed remediation wave
without opening dedicated `.specify/specs/<feature>/` artifacts first.
