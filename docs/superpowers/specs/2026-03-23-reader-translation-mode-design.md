# Reader Translation Mode Design

## Context

The current reader has two fully supported surfaces:

- `scroll` via `ContinuousSurahContent`
- `page` via `QuranLibraryScreen`

Translation mode is missing even though the product roadmap requires it and the
current persistence path already hints at it. The safest design is to keep
Arabic mushaf rendering responsibilities inside `quran_library` for the
authentic modes, and build translation mode as a separate app-owned surface.

## Approaches

### Approach 1: App-Owned Translation Surface (Recommended)

Add `ReaderMode.translation`, fetch translation rows from `Quran.com API v4`,
merge them with local ayahs for the current surah, and render a dedicated list
widget where Arabic appears on top and translation below each ayah.

Pros:

- Clean separation from `quran_library`
- Full control over translation layout and loading states
- Easier to test
- Safer for future additions like translation source switching

Cons:

- Requires a small new data layer
- Needs explicit anchoring logic to land near the current ayah target

### Approach 2: Overlay Translation on Existing `quran_library` Surfaces

Try to inject translation text into the current page/scroll rendering paths.

Pros:

- Reuses more of the current reader shell

Cons:

- High coupling to `quran_library`
- Poor control over verse-by-verse translation layout
- Likely to fight authentic mushaf rendering assumptions
- Harder to maintain and test

### Approach 3: Replace All Reader Modes with App-Owned Widgets

Rebuild `scroll`, `page`, and `translation` all inside the app’s own widget
stack.

Pros:

- One rendering architecture

Cons:

- Much larger than the requested scope
- Risks regressing the authentic mushaf experience already stabilized in the
  local fork
- Unnecessary for the first missing Phase 1 slice

## Recommendation

Use Approach 1.

It respects the current architecture, minimizes risk to the authentic reader,
and delivers the missing feature with clear boundaries:

- mode contract in reader domain
- remote translation fetching in a dedicated data layer
- translation presentation in app-owned widgets

## Proposed Design

### 1. Reader Mode Contract

Extend `ReaderMode` to three values: `scroll`, `page`, `translation`.

Replace the current binary toggle helper with an explicit selection control.
This should be a dedicated reader widget rather than logic buried inside
`ReaderScreen`. The selector can live in the current app bar action area for
now, which keeps the feature scoped without blocking on the final reader bottom
toolbar redesign.

### 2. Translation Data Flow

Add a small feature-owned data path:

- remote data source: calls `Quran.com API v4`
- repository: normalizes payloads into feature/domain models
- provider: loads translations for the active surah and source id

Arabic ayah text continues to come from `QuranDatabase.getAyahsBySurah(...)`.
The translation layer should not own Arabic text.

### 3. Translation Rendering

Create a dedicated `TranslationModeView` that:

- receives the active `ReaderNavigationTarget`
- loads local ayahs for the current surah
- loads translations for the same surah
- renders one tile per ayah:
  - Arabic text
  - verse marker/reference
  - translated text

The tile should remain compatible with long-press verse actions where practical
so the translation surface feels like part of the same reader, not a separate
screen.

### 4. Navigation and State

Translation mode should still obey the current reader contracts:

- surah drawer updates the reader target
- jump-to updates the reader target
- fullscreen stays controlled by the existing fullscreen provider
- switching modes should preserve the current target instead of resetting

For initial UX, it is sufficient to anchor the translation list to the target
ayah on entry and after explicit navigation. Perfect continuous visible-ayah
tracking can stay secondary unless it becomes necessary during implementation.

### 5. Error Handling and UX

Translation mode must have explicit states:

- loading
- loaded
- error with retry
- empty/fallback if API returns no usable translation rows

All strings must go through `AppLocalizations`.

## Testing Strategy

- unit tests for `ReaderModePolicy` parsing/serialization with `translation`
- unit tests for translation payload mapping
- widget tests for translation mode loading/error/success states
- optional reader widget test for mode selector behavior if the widget is
  isolated enough
