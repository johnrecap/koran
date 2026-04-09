# External Review Triage Execution Plan

**Purpose:** Convert the validated external review findings into a short
execution handoff that can be implemented wave by wave without reopening the
raw review report.

**Inputs:**
- Local code verification against the current codebase
- The earlier triage summary that split valid, partial, and outdated findings
- The existing stabilization plan in
  `docs/superpowers/plans/2026-03-27-app-stabilization-plan.md`

**How to use this file:**
1. Start from the first incomplete wave.
2. Finish all checklist items in that wave before moving forward.
3. Do not pull items from the defer section into execution unless a fresh
   product decision or reproduction exists.

---

## Wave A - Confirmed correctness fixes

**Status:** Completed on 2026-03-27

**Goal:** Resolve the clearly validated bugs that affect app behavior or
localized correctness.

**Primary file scope:**
- `lib/features/reader/presentation/screens/reader_screen.dart`
- `lib/features/reader/providers/manual_bookmarks_provider.dart`
- `lib/features/more/providers/more_providers.dart`

**Work items:**
1. Replace the hardcoded Arabic share prefix in the reader share action with
   the localized surah prefix.
2. Add a `_ready`-style load gate to manual bookmarks so initial reads and
   toggles cannot race the async bookmark load.
3. Make the prayer-time "now" source refresh on a schedule so the computed
   `nextPrayer` snapshot stays correct while the screen remains open.

**Completion checklist:**
- [x] Reader share text is localized in both Arabic and English flows
- [x] Manual bookmark state cannot be toggled against an empty pre-load state
- [x] Prayer hero keeps the next prayer/current state accurate while the screen
      stays mounted

**Recommended verification:**
- Targeted reader tests for share/bookmark behavior
- Targeted `/more` provider or widget tests for live prayer refresh behavior

---

## Wave B - UX fixes with low regression risk

**Status:** Completed on 2026-03-27

**Goal:** Clean up confirmed interaction issues that do not change core storage
or architecture.

**Primary file scope:**
- `lib/features/audio/presentation/screens/audio_hub_screen.dart`
- `lib/features/reader/presentation/screens/reader_screen.dart`
- `lib/data/datasources/local/quran_database.dart`

**Work items:**
1. Make the audio seek slider track the user drag visually instead of using a
   no-op `onChanged`.
2. Normalize the reader mode toggle behavior now that translation mode exists.
   The toggle should either clearly mean `page <-> scroll` only, or behave
   consistently from all three modes.
3. Stop returning `[]` silently from `QuranDatabase.searchAyahs()` when the
   query path fails; surface a real failure contract to the calling layer.

**Completion checklist:**
- [x] Audio slider drag behavior feels normal before release on `onChangeEnd`
- [x] Reader toggle behavior is explicit and no longer surprising from
      translation mode
- [x] Search failures can be surfaced as errors instead of fake "no results"

**Recommended verification:**
- Audio screen tests around slider state
- Reader mode interaction tests
- Datasource/provider tests for query failure surfacing

---

## Wave C - Product decision before code change

**Status:** Completed on 2026-03-27  
**Decision note:** `docs/superpowers/plans/2026-03-27-khatma-session-retention-decision-note.md`

**Goal:** Avoid implementing partially-correct review feedback without first
deciding the intended memorization behavior.

**Primary file scope:**
- `lib/features/memorization/providers/memorization_providers.dart`
- Any memorization hub/planner consumers affected by session retention rules

**Accepted decision:**
- Keep the current latest trusted anchor behavior for khatma-linked sessions.
- Do not rewrite `upsertSession()` to retain multiple khatma-linked
  `ReadingSession` rows in this wave.
- Treat any future "full khatma history" request as a separate feature that
  needs a dedicated history model or explicit anchor/history split.

**If the product later chooses "full history":**
1. Change `upsertSession()` so khatma-linked sessions no longer evict older
   sessions for the same `khatmaId`.
2. Re-check planner and resume consumers so they still use the right newest
   trusted anchor where needed.

**Why no code change shipped from Wave C:**
1. `ReaderSaveRecorder` already writes the khatma anchor with a fixed
   `khatma-<id>` identity and trusted-anchor metadata.
2. Memorization hub and planner consumers resume from one latest trusted
   khatma session, not a khatma-history list.
3. Regular non-khatma sessions already preserve general reading history.

**Completion checklist:**
- [x] Product/behavior decision is written down first
- [x] Session retention behavior matches that decision
- [x] Resume/planner paths still behave correctly after the decision

---

## Wave D - Cleanup and maintenance only

**Goal:** Reduce technical clutter after the validated fixes are complete.

**Primary file scope:**
- `lib/features/memorization/providers/memorization_providers.dart`
- `lib/features/library/providers/library_providers.dart`
- `lib/features/reader/providers/reader_providers.dart`

**Work items:**
1. Replace the `jsonEncode`-based `sameKhatmas()` comparison with a clearer
   comparison strategy.
2. Remove low-risk dead wrappers/getters that have no active consumers.
3. Review the duplicated surah-provider surface only if test overrides and
   feature ownership remain clear after consolidation.

**Completion checklist:**
- [ ] Cleanup work does not change user-facing behavior
- [ ] Tests/overrides that depend on provider boundaries still pass
- [ ] No cleanup item reopens previously closed correctness work

---

## Not in scope for execution from this file

These review items were checked and should not be scheduled from this handoff:

- Localization override ordering in `app_localizations.dart`
- Translation pagination timeout/loop concerns that are already fixed
- Audio bootstrap timeout concerns that are already fixed
- The library debounce "race" claim
- Package word-selection enablement inside the reader
- Legacy alias cleanup for `surahSearchQueryProvider`
- The broad `OVR-*` comments about policy-class style

---

## Suggested implementation order

1. `Wave A` completed on 2026-03-27
2. `Wave B` completed on 2026-03-27
3. `Wave C` decision accepted on 2026-03-27
4. Only `Wave D` remains if cleanup work is still worth scheduling

## Session handoff note

If a future session starts from this file, it should open the matching
`.specify/specs/` artifacts first. If the session is considering khatma session
retention again, it should read the Wave C decision note before reopening any
storage changes. Execute one remaining wave at a time rather than mixing tasks
across waves.
