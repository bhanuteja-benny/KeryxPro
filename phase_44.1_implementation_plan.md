# Implementation Plan - Phase 44.1: Verse Shifting Bug Fixes & Contextual Enablement

This plan details the fixes for the verse shifting reference label, correct multi-slide relative indices, and contextual enablement rules of the verse-shifting shortcuts/buttons.

---

## 1. Problem Descriptions & Solutions

### Problem 1: Incorrect Reference Label on Book/Chapter Transitions
* **Symptom**: When shifting backward from `Ephesians 1:1`, the verse text shows `Galatians 6:18` but the reference title incorrectly displays `Ephesians 1:18`.
* **Root Cause**: The title generation in `_performShift` was using the original `bookName` and `chapter` parsed from the base slide, rather than the book and chapter of the actual target verses fetched from the database.
* **Solution**: Extract and use the actual `bookName` and `chapterNumber` from the first element of the fetched `targetVerses` (e.g. `targetVerses.first.bookName` and `targetVerses.first.chapterNumber`) to build `newTitle`.

### Problem 2: Next/Before Verse Calculation with Multi-Slide Display
* **Symptom**: If multiple slides (e.g. `Ephesians 1:1-2`) are displayed simultaneously on a monitor and the next/before verse shortcut is clicked, the base slide selected is always the active clicked index (e.g. `Ephesians 1:1`), which incorrectly adds `Ephesians 1:2` instead of `Ephesians 1:3`.
* **Root Cause**: The shifting code was using `activeSlideIndexProvider` (the single cursor index) to find the base slide.
* **Solution**: Use `activeSlideIndicesProvider` (which tracks all currently displayed/highlighted slides):
  - For **next verse** (forward): Calculate the base slide using the maximum index (`activeIndices.reduce(max)`).
  - For **before verse** (backward): Calculate the base slide using the minimum index (`activeIndices.reduce(min)`).

### Problem 3: Contextual Enablement of Shifting Shortcuts & Buttons
* **Symptom**: Shifting should only be allowed when viewing the boundary slides of a scripture item.
* **Rules**:
  - **Next verse(s)** shortcut and buttons should be enabled **if and only if** the last content/verse slide of the current scripture item is currently displaying in at least one monitor (i.e. is in `activeIndices`).
  - **Before verse(s)** shortcut and buttons should be enabled **if and only if** the first content/verse slide of the current scripture item is currently displaying in at least one monitor (i.e. is in `activeIndices`).
* **Solution**:
  - Implement two getters `_canShiftNext` and `_canShiftPrev` in `_PreviewPaneState`.
  - Disable buttons (`onPressed: null`) if the respective getter returns false.
  - Reject keyboard shortcuts early if the respective getter returns false.

---

## 2. Proposed Changes

### File: `lib/features/dashboard/presentation/widgets/preview_pane.dart`

#### 1. Define `_canShiftNext` and `_canShiftPrev` getters:
```dart
  bool get _canShiftNext {
    final slides = ref.read(currentSlidesProvider);
    final activeIndices = ref.read(activeSlideIndicesProvider);
    if (slides.isEmpty || activeIndices.isEmpty) return false;

    final setlist = ref.read(setlistProvider);
    final slideToItemMapping = ref.read(slideToSetlistItemIndexProvider);

    for (final idx in activeIndices) {
      if (idx < 0 || idx >= slideToItemMapping.length) continue;
      final itemIndex = slideToItemMapping[idx];
      if (itemIndex < 0 || itemIndex >= setlist.length) continue;
      final item = setlist[itemIndex];
      if (item is SongSetlistItem && item.song.author == 'Bible') {
        final firstSlideIndex = getSlideCountForItems(setlist, itemIndex - 1);
        final totalSlidesCount = getSlideCountForItems(setlist, itemIndex) - firstSlideIndex;
        // The last content verse slide is the one just before the blank slide
        final lastVerseIndex = firstSlideIndex + totalSlidesCount - 2;
        if (idx == lastVerseIndex) {
          return true;
        }
      }
    }
    return false;
  }

  bool get _canShiftPrev {
    final slides = ref.read(currentSlidesProvider);
    final activeIndices = ref.read(activeSlideIndicesProvider);
    if (slides.isEmpty || activeIndices.isEmpty) return false;

    final setlist = ref.read(setlistProvider);
    final slideToItemMapping = ref.read(slideToSetlistItemIndexProvider);

    for (final idx in activeIndices) {
      if (idx < 0 || idx >= slideToItemMapping.length) continue;
      final itemIndex = slideToItemMapping[idx];
      if (itemIndex < 0 || itemIndex >= setlist.length) continue;
      final item = setlist[itemIndex];
      if (item is SongSetlistItem && item.song.author == 'Bible') {
        final firstSlideIndex = getSlideCountForItems(setlist, itemIndex - 1);
        if (idx == firstSlideIndex) {
          return true;
        }
      }
    }
    return false;
  }
```

#### 2. Update `_performShift` to:
- Check `_canShiftNext` / `_canShiftPrev`.
- Resolve the base index as the max or min of `activeIndices`.
- Construct `newTitle` using `targetVerses.first.bookName` and `targetVerses.first.chapterNumber`.

#### 3. Update header button callbacks and enablement:
- Double Left: `onPressed: _canShiftPrev ? () => _performShift(stepCount: 2, forward: false) : null`
- Single Left: `onPressed: _canShiftPrev ? () => _performShift(stepCount: 1, forward: false) : null`
- Single Right: `onPressed: _canShiftNext ? () => _performShift(stepCount: 1, forward: true) : null`
- Double Right: `onPressed: _canShiftNext ? () => _performShift(stepCount: 2, forward: true) : null`
- Protect `_handleLeftShift` and `_handleRightShift` keyboard triggers in `_handleKeyEvent` with `_canShiftPrev` and `_canShiftNext`.
