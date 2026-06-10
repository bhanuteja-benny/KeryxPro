# Implementation Plan - Phase 43: Setlist Item Insertion and Delete Logic

This implementation plan details the changes required to update the slide/item insertion logic, setlist enter-key behavior, and saved setlist deletion logic, as well as toolbar updates.

---

## 1. Assumptions & Rationale

1. **Toolbar UI Updates**: The "stack" icon (`Icons.layers_rounded`) in the setlist toolbar will be replaced with a "refresh" icon (`Icons.refresh`). It will have no interaction (i.e. `onPressed: null` and `isSelected: false`).
2. **Centralized Insertion Index Logic**: The insertion index calculation will be centralized inside a helper method in `SetlistNotifier` (`setlist_providers.dart`) called `_calculateInsertIndex`.
   - When `goLive = false`:
     - If no setlist item is selected, it returns the end of the list (`state.length`).
     - If one or more setlist items are selected, it finds the top-most selected item (the one with the lowest index) and returns `topMostIndex + 1`.
   - When `goLive = true`:
     - It inserts below the currently displaying item index (`currentDisplayItemIndex + 1`), defaulting to the end of the list if no item is currently displaying.
3. **Setlist Name Deletion Dialog Text**: In accordance with the prompt:
   - If the setlist name is in the database (saved), we will display a confirmation dialog with the exact text content: **`Are you sure you want to delete setlist name?`**.
   - If it is not saved, we will clear the name selection/textbox directly without displaying a dialog.
   - If the name is already empty, no action is taken.
4. **Unselecting on Enter**: When pressing Enter on a selected setlist item, the item is selected for live display, and the item itself is unselected in the setlist selection provider. This removes the purple background from the item and applies the standard blue active highlighting. A user can later click the active item to re-select it (purple background applies to the item, but not to the slides list).

---

## 2. Proposed Changes

### A. Setlist Providers (`lib/features/setlist/presentation/setlist_providers.dart`)
1. Remove the unused `appendAtEndOfListProvider`.
2. Update the signatures of `insertSong` and `insertImage` in `SetlistNotifier` to receive selection state and display index:
   ```dart
   int insertSong(Song song, {required bool goLive, required Set<int> selectedIndices, required int? currentDisplayItemIndex})
   int insertImage(ImageSetlistItem imageItem, {required Set<int> selectedIndices, required int? currentDisplayItemIndex})
   ```
3. Add the helper `_calculateInsertIndex` to determine the insertion index.

### B. Song Library Tab (`lib/features/songs/presentation/song_library_tab.dart`)
1. Update `insertSong` calls (both key handling and tap gesture) to pass `goLive: false`, selection state, and current display index.

### C. Bible Search Tab (`lib/features/bible/presentation/widgets/bible_search_tab.dart`)
1. Update the `_addToSetlist` method to get `insertAt` from `insertSong` and pass `goLive`, selection state, and current display index.
2. If `goLive` is true, calculate the next active slide index using `getSlideCountForItems(newSetlist, insertAt - 1)`.

### D. Setlist Pane (`lib/features/dashboard/presentation/widgets/setlist_pane.dart`)
1. Replace `Icons.layers_rounded` with `Icons.refresh` (set `onPressed: null`, `isSelected: false`, `tooltip: 'Refresh'`).
2. Update the `onKeyEvent` for `LogicalKeyboardKey.enter` to clear setlist selection using `ref.read(setlistSelectionProvider.notifier).clear()` after updating `activeSlideIndexProvider`.
3. Update `_addImage` to use the updated `insertImage` signature.
4. Modify `_deleteAction` to check if the setlist name is in the database using `savedSetlistNamesProvider.future`.
   - If it exists, call a confirmation dialog with content `"Are you sure you want to delete setlist name?"`.
   - If it does not exist, clear the textbox and provider.

---

## 3. Detailed Code Diff Design

### File 1: `lib/features/setlist/presentation/setlist_providers.dart`

```diff
@@ -14,11 +14,14 @@
     state = [...state, SongSetlistItem(song)];
   }
 
-  void insertSong(Song song, int? atIndex) {
-    if (atIndex == null) {
-      addSong(song);
-    } else {
-      final newList = List<SetlistItem>.from(state);
-      final insertAt = (atIndex + 1).clamp(0, newList.length);
-      newList.insert(insertAt, SongSetlistItem(song));
-      state = newList;
-    }
+  int insertSong(Song song, {required bool goLive, required Set<int> selectedIndices, required int? currentDisplayItemIndex}) {
+    final insertAt = _calculateInsertIndex(goLive: goLive, selectedIndices: selectedIndices, currentDisplayItemIndex: currentDisplayItemIndex);
+    final newList = List<SetlistItem>.from(state);
+    newList.insert(insertAt, SongSetlistItem(song));
+    state = newList;
+    return insertAt;
   }
 
   void addImage(ImageSetlistItem imageItem) {
@@ -32,11 +35,28 @@
-  void insertImage(ImageSetlistItem imageItem, int? atIndex) {
-    if (atIndex == null) {
-      addImage(imageItem);
-    } else {
-      final newList = List<SetlistItem>.from(state);
-      final insertAt = (atIndex + 1).clamp(0, newList.length);
-      newList.insert(insertAt, imageItem);
-      state = newList;
-    }
+  int insertImage(ImageSetlistItem imageItem, {required Set<int> selectedIndices, required int? currentDisplayItemIndex}) {
+    final insertAt = _calculateInsertIndex(goLive: false, selectedIndices: selectedIndices, currentDisplayItemIndex: currentDisplayItemIndex);
+    final newList = List<SetlistItem>.from(state);
+    newList.insert(insertAt, imageItem);
+    state = newList;
+    return insertAt;
+  }
+
+  int _calculateInsertIndex({
+    required bool goLive,
+    required Set<int> selectedIndices,
+    required int? currentDisplayItemIndex,
+  }) {
+    if (goLive) {
+      if (currentDisplayItemIndex != null) {
+        return (currentDisplayItemIndex + 1).clamp(0, state.length);
+      } else {
+        return state.length;
+      }
+    } else {
+      if (selectedIndices.isEmpty) {
+        return state.length;
+      } else {
+        final topMostIndex = selectedIndices.reduce((a, b) => a < b ? a : b);
+        return (topMostIndex + 1).clamp(0, state.length);
+      }
+    }
   }
 
@@ -154,2 +174,0 @@
-final appendAtEndOfListProvider = StateProvider<bool>((ref) => false);
-
```

### File 2: `lib/features/songs/presentation/song_library_tab.dart`

```diff
@@ -149,5 +149,9 @@
-                      final appendAtEndOfList = ref.read(appendAtEndOfListProvider);
-                      final displayIndex = ref.read(currentDisplayItemIndexProvider);
-                      final insertIndex = appendAtEndOfList ? null : displayIndex;
-                      ref.read(setlistProvider.notifier).insertSong(songs[currentIndex], insertIndex);
+                      ref.read(setlistProvider.notifier).insertSong(
+                        songs[currentIndex],
+                        goLive: false,
+                        selectedIndices: ref.read(setlistSelectionProvider),
+                        currentDisplayItemIndex: ref.read(currentDisplayItemIndexProvider),
+                      );
                     }
```
```diff
@@ -178,5 +182,9 @@
-                            final appendAtEndOfList = ref.read(appendAtEndOfListProvider);
-                            final displayIndex = ref.read(currentDisplayItemIndexProvider);
-                            final insertIndex = appendAtEndOfList ? null : displayIndex;
-                            ref.read(setlistProvider.notifier).insertSong(song, insertIndex);
+                            ref.read(setlistProvider.notifier).insertSong(
+                              song,
+                              goLive: false,
+                              selectedIndices: ref.read(setlistSelectionProvider),
+                              currentDisplayItemIndex: ref.read(currentDisplayItemIndexProvider),
+                            );
                           },
```

### File 3: `lib/features/bible/presentation/widgets/bible_search_tab.dart`

```diff
@@ -250,15 +250,11 @@
-    final appendAtEndOfList = ref.read(appendAtEndOfListProvider);
-    final displayIndex = ref.read(currentDisplayItemIndexProvider);
-    final insertIndex = (goLive || !appendAtEndOfList) ? displayIndex : null;
-
-    final previousSlides = ref.read(currentSlidesProvider);
-    final setlist = ref.read(setlistProvider);
-    final int nextIndex;
-    if (insertIndex == null) {
-      nextIndex = previousSlides.length;
-    } else {
-      nextIndex = getSlideCountForItems(setlist, insertIndex);
-    }
-
-    ref.read(setlistProvider.notifier).insertSong(mockSong, insertIndex);
+    final insertAt = ref.read(setlistProvider.notifier).insertSong(
+      mockSong,
+      goLive: goLive,
+      selectedIndices: ref.read(setlistSelectionProvider),
+      currentDisplayItemIndex: ref.read(currentDisplayItemIndexProvider),
+    );
 
     // Auto-activate the newly added song and focus slides if goLive is true
     if (goLive) {
+      final nextIndex = getSlideCountForItems(ref.read(setlistProvider), insertAt - 1);
       ref.read(activeSlideIndexProvider.notifier).state = nextIndex;
```

### File 4: `lib/features/dashboard/presentation/widgets/setlist_pane.dart`

```diff
@@ -177,13 +177,13 @@
   void _deleteAction() {
     final selection = ref.read(setlistSelectionProvider);
     final items = ref.read(setlistProvider);
     final activeName = ref.read(activeSetlistNameProvider);
     
     if (selection.isNotEmpty) {
       ref.read(setlistProvider.notifier).removeAtIndices(selection);
       ref.read(setlistSelectionProvider.notifier).clear();
-    } else if (items.isEmpty && activeName != null) {
-      _confirmDeleteSetlist(activeName);
+    } else if (items.isEmpty && activeName != null && activeName.trim().isNotEmpty) {
+      _handleDeleteSetlistName(activeName.trim());
     }
   }
 
-  Future<void> _confirmDeleteSetlist(String name) async {
-    final confirm = await showDialog<bool>(
-      context: context,
-      builder: (ctx) => AlertDialog(
-        backgroundColor: const Color(0xFF2D2D3E),
-        title: const Text('Delete SetList', style: TextStyle(color: Colors.white, fontSize: 16)),
-        content: Text("Are you sure you want to delete the SetList '$name'?", style: const TextStyle(color: Colors.white70, fontSize: 13)),
-        actions: [
-          TextButton(
-            onPressed: () => Navigator.pop(ctx, false),
-            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
-          ),
-          TextButton(
-            onPressed: () => Navigator.pop(ctx, true),
-            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
-          ),
-        ],
-      )
-    );
-
-    if (confirm == true) {
-      final repo = ref.read(setlistRepositoryProvider);
-      await repo.deleteByName(name);
-      ref.read(activeSetlistNameProvider.notifier).state = null;
-      ref.read(activeSetlistSignatureProvider.notifier).state = '';
-      _nameCtrl.clear();
-      ref.invalidate(savedSetlistNamesProvider);
-    }
-  }
+  Future<void> _handleDeleteSetlistName(String name) async {
+    final savedNames = await ref.read(savedSetlistNamesProvider.future);
+    final isSaved = savedNames.contains(name);
+
+    if (isSaved) {
+      if (!mounted) return;
+      final confirm = await showDialog<bool>(
+        context: context,
+        builder: (ctx) => AlertDialog(
+          backgroundColor: const Color(0xFF2D2D3E),
+          title: const Text('Delete SetList', style: TextStyle(color: Colors.white, fontSize: 16)),
+          content: const Text('Are you sure you want to delete setlist name?', style: TextStyle(color: Colors.white70, fontSize: 13)),
+          actions: [
+            TextButton(
+              onPressed: () => Navigator.pop(ctx, false),
+              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
+            ),
+            TextButton(
+              onPressed: () => Navigator.pop(ctx, true),
+              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
+            ),
+          ],
+        )
+      );
+
+      if (confirm == true) {
+        final repo = ref.read(setlistRepositoryProvider);
+        await repo.deleteByName(name);
+        ref.read(activeSetlistNameProvider.notifier).state = null;
+        ref.read(activeSetlistSignatureProvider.notifier).state = '';
+        _nameCtrl.clear();
+        ref.invalidate(savedSetlistNamesProvider);
+      }
+    } else {
+      // Not saved yet, just clear selection and textbox
+      ref.read(activeSetlistNameProvider.notifier).state = null;
+      ref.read(activeSetlistSignatureProvider.notifier).state = '';
+      _nameCtrl.clear();
+    }
+  }
```
```diff
@@ -244,4 +244,5 @@
     if (result != null) {
-      final appendAtEndOfList = ref.read(appendAtEndOfListProvider);
-      final displayIndex = ref.read(currentDisplayItemIndexProvider);
-      final insertIndex = appendAtEndOfList ? null : displayIndex;
-      ref.read(setlistProvider.notifier).insertImage(result, insertIndex);
+      ref.read(setlistProvider.notifier).insertImage(
+        result,
+        selectedIndices: ref.read(setlistSelectionProvider),
+        currentDisplayItemIndex: ref.read(currentDisplayItemIndexProvider),
+      );
     }
```
```diff
@@ -387,9 +387,10 @@
         } else if (event.logicalKey == LogicalKeyboardKey.enter) {
           final sel = ref.read(setlistSelectionProvider);
           if (sel.isNotEmpty) {
             // Find the lowest selected index
             final selectedIndex = sel.reduce((a, b) => a < b ? a : b);
             final slideIndex = _getSlideStartIndex(selectedIndex);
             ref.read(activeSlideIndexProvider.notifier).state = slideIndex;
+            ref.read(setlistSelectionProvider.notifier).clear(); // Clear selection
             return KeyEventResult.handled;
           }
         }
```
```diff
@@ -621,9 +621,9 @@
                     _segmentedButton(
-                      icon: Icons.layers_rounded,
-                      tooltip: 'append new item at EOL',
-                      onPressed: () {
-                        ref.read(appendAtEndOfListProvider.notifier).update((state) => !state);
-                      },
-                      showBorder: false,
-                      isSelected: ref.watch(appendAtEndOfListProvider),
+                      icon: Icons.refresh,
+                      tooltip: 'Refresh',
+                      onPressed: null,
+                      showBorder: false,
+                      isSelected: false,
                     ),
```

---

## 4. Verification Plan

### Manual Verification Scenarios
1. **No Selected Items (golive = false)**:
   - Add a song from the library.
   - Verify it is appended at the end of the setlist.
2. **Selected Items (golive = false)**:
   - Select Item 1 in a list of 3 items.
   - Add a new song.
   - Verify the new song is inserted at index 2 (directly below Item 1).
3. **Inserting with golive = true**:
   - Double click a Bible verse (which goes live immediately).
   - Verify it is inserted directly below the currently displaying item/slide.
4. **Enter Key Handling on Setlist Item**:
   - Select a setlist item. Press Enter.
   - Verify the slide changes to show the song/scripture.
   - Verify the item is unselected (purple background is removed, active blue background is applied).
   - Select the currently displaying item again (purple background is applied, verify slides list does not turn purple).
5. **Delete Setlist Name**:
   - Ensure the setlist has no items.
   - If the name is saved (e.g. exists in dropdown database):
     - Click the delete icon.
     - Verify the dialog content is exactly `"Are you sure you want to delete setlist name?"`.
     - Click Cancel -> Verify nothing changes.
     - Click Delete -> Verify the name is deleted from DB and dropdown/textbox is cleared.
   - If the name is not saved (e.g. user typed a new name but did not save it):
     - Click the delete icon.
     - Verify the textbox is cleared immediately with no dialog shown.
   - If the textbox is empty:
     - Verify the delete icon is disabled or does nothing when clicked.
