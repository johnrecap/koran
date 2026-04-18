# Mu'allim Wave 3 Word Highlight Design

Date: 2026-04-13
Status: Approved

## Spike Findings

- QPC v4 page rendering already exposes one `QpcV4WordSegment` per word.
- `QpcV4RichTextLine` already derives `wordSelectionRange` from `WordInfoCtrl.selectedWordRef`.
- The existing `_AyahSelectionRenderBox` paint path can therefore render a Mu'allim word highlight without any new QCF drawing API.

## Approved Path

1. Keep Mu'allim timing ownership inside the app through `muallimWordHighlightProvider`.
2. Resolve the active Mu'allim `(ayahUQNumber, wordIndex)` pair into a `WordRef`.
3. Bridge that `WordRef` into `quran_library` through `WordInfoCtrl.setSelectedWord(...)`.
4. Clear the bridge-owned selection when timing is unavailable, Mu'allim stops, or the reader disposes.

## Why This Path

- It reuses the existing package painter instead of forking QCF rendering.
- It covers both page mode and continuous scroll mode because both already use `QpcV4RichTextLine`.
- It keeps the app-owned Mu'allim timing logic separate from package rendering internals.

## Deferred

- Translation-mode-specific word highlighting UI remains out of this Wave 3 path.
- Any richer precedence rules between user word selection and Mu'allim selection can wait for a later wave if direct word selection is re-enabled in the reader.
