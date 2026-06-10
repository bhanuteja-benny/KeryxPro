# Implementation Plan - Phase 42: Keyboard Shortcuts in Add Song Page

This implementation plan outlines the changes required to add the `Ctrl + S` keyboard shortcut in the song editor page to save changes, ensuring it works within textboxes, without altering existing design or functionality.

---

## 1. Assumptions & Rationale

1. **Focus Scope**: The user wants `Ctrl + S` (on Windows/Linux) or `Cmd + S` (on macOS) to save song changes when editing a song, regardless of which text field (Title, Author, or Lyrics) is currently focused.
2. **Global Shortcut Prevention**: When a modifier key (such as `Ctrl` or `Cmd`) is held down, normal single-key shortcuts (like `s` to open the Bible tab) must **not** fire. For example, pressing `Ctrl + S` must not open the Bible tab.
3. **Textbox Event Propagation**: In the global key listener (`_handleGlobalKeys`), keyboard events inside textboxes are normally ignored to prevent global hotkeys from intercepting character entry. We will modify this check so that shortcut combinations with `Ctrl`/`Cmd` are permitted to bypass this exclusion, allowing them to propagate down the focus tree to the local editor.
4. **No UI Changes**: No new UI elements, fields, or buttons will be added.

---

## 2. Proposed Changes

We will modify two files to implement the shortcut interaction:

### A. Global Key Event Handler (`lib/features/dashboard/presentation/pages/main_dashboard_page.dart`)
1. Detect whether the control or command/meta modifier keys are currently pressed.
2. Update the `isTextInput` check so that if `isControlPressed` is true, the key event is **not** immediately ignored. This allows Ctrl-key combinations to bubble down to the focused text editors.
3. Update the condition for normal single-key shortcuts (`s`, `q`, `l`, `f`) to ensure they only execute when `isControlPressed` is false.

### B. Song Editor Pane (`lib/features/songs/presentation/song_editor_pane.dart`)
1. Import `package:flutter/services.dart` to support key event definitions.
2. Wrap the `SongEditorPane` widget tree in a `CallbackShortcuts` widget.
3. Bind the `Ctrl + S` (and `Cmd + S` for macOS compatibility) shortcuts to call the existing `_save` method.

---

## 3. Detailed Code Diff Design

### File 1: `lib/features/dashboard/presentation/pages/main_dashboard_page.dart`

```diff
@@ -47,6 +47,9 @@
   bool _handleGlobalKeys(KeyEvent event) {
     if (event is! KeyDownEvent) return false;
 
+    // Check if Ctrl (Windows/Linux) or Cmd/Meta (macOS) is held down
+    final isControlPressed = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
+
     // Common sense: If we are typing in any text field, ignore shortcuts and let the text through
     final primaryFocus = FocusManager.instance.primaryFocus;
     if (primaryFocus != null && primaryFocus.context != null) {
@@ -57,19 +60,19 @@
                          context.findAncestorWidgetOfExactType<EditableText>() != null ||
                          context.findAncestorWidgetOfExactType<TextField>() != null;
                          
-      if (isTextInput) return false;
+      if (isTextInput && !isControlPressed) return false;
 
       // Fallback label checks
       final label = primaryFocus.debugLabel?.toLowerCase() ?? '';
       if (label.contains('editable') || label.contains('field') || label.contains('search') || label.contains('setlistname') || label.contains('title') || label.contains('author') || label.contains('lyrics') || label.contains('preset')) {
-        return false;
+        if (!isControlPressed) return false;
       }
     }
 
     final shortcuts = ref.read(globalShortcutActionProvider);
     final key = event.logicalKey;
 
-    if (key == LogicalKeyboardKey.keyS) {
+    if (key == LogicalKeyboardKey.keyS && !isControlPressed) {
       shortcuts.openBibleTab();
       return true;
-    } else if (key == LogicalKeyboardKey.keyQ) {
+    } else if (key == LogicalKeyboardKey.keyQ && !isControlPressed) {
       shortcuts.openSongsTab();
       return true;
-    } else if (key == LogicalKeyboardKey.keyL) {
+    } else if (key == LogicalKeyboardKey.keyL && !isControlPressed) {
       shortcuts.focusSlides();
       return true;
-    } else if (key == LogicalKeyboardKey.keyF) {
+    } else if (key == LogicalKeyboardKey.keyF && !isControlPressed) {
       shortcuts.toggleFreeze();
       return true;
     } else if (key == LogicalKeyboardKey.escape) {
```

### File 2: `lib/features/songs/presentation/song_editor_pane.dart`

```diff
@@ -1,5 +1,6 @@
 import 'package:flutter/material.dart';
+import 'package:flutter/services.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
 import '../data/song.dart';
 import 'song_providers.dart';
@@ -80,109 +81,117 @@
   Widget build(BuildContext context) {
     final isEditMode = ref.watch(songBeingEditedProvider) != null;
 
-    return Container(
-      color: Colors.grey[900],
-      child: Column(
-        children: [
-          Container(
-            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
-            color: Colors.black26,
-            child: Row(
-              children: [
-                Text(
-                  isEditMode ? 'Edit Song' : 'Add New Song',
-                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent),
-                ),
-                const Spacer(),
-                IconButton(
-                  padding: EdgeInsets.zero,
-                  constraints: const BoxConstraints(),
-                  icon: const Icon(Icons.close, color: Colors.grey, size: 16),
-                  onPressed: _close,
-                  tooltip: 'Cancel',
-                ),
-              ],
-            ),
-          ),
-          Expanded(
-            child: Padding(
-              padding: const EdgeInsets.all(12),
-              child: Column(
-                crossAxisAlignment: CrossAxisAlignment.start,
-                children: [
-                  TextField(
-                    controller: _titleController,
-                    style: const TextStyle(fontSize: 12),
-                    decoration: const InputDecoration(
-                      labelText: 'Title *',
-                      labelStyle: TextStyle(fontSize: 11),
-                      border: OutlineInputBorder(),
-                      isDense: true,
-                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
-                    ),
-                    autofocus: !isEditMode,
-                  ),
-                  const SizedBox(height: 8),
-                  TextField(
-                    controller: _authorController,
-                    style: const TextStyle(fontSize: 12),
-                    decoration: const InputDecoration(
-                      labelText: 'Author (Optional)',
-                      labelStyle: TextStyle(fontSize: 11),
-                      border: OutlineInputBorder(),
-                      isDense: true,
-                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
-                    ),
-                  ),
-                  const SizedBox(height: 8),
-                  Expanded(
-                    child: TextField(
-                      controller: _lyricsController,
-                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace', height: 1.4),
-                      decoration: const InputDecoration(
-                        border: OutlineInputBorder(),
-                        hintText: 'Enter song lyrics here...',
-                        contentPadding: EdgeInsets.all(8),
-                      ),
-                      expands: true,
-                      maxLines: null,
-                      minLines: null,
-                      keyboardType: TextInputType.multiline,
-                      textAlignVertical: TextAlignVertical.top,
-                    ),
-                  ),
-                  const SizedBox(height: 12),
-                  Row(
-                    mainAxisAlignment: MainAxisAlignment.end,
-                    children: [
-                      TextButton(
-                        onPressed: _isLoading ? null : _close,
-                        style: TextButton.styleFrom(
-                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
-                        ),
-                        child: const Text('Cancel', style: TextStyle(fontSize: 12)),
-                      ),
-                      const SizedBox(width: 8),
-                      ElevatedButton(
-                        style: ElevatedButton.styleFrom(
-                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
-                          backgroundColor: Colors.blueAccent,
-                          foregroundColor: Colors.white,
-                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
-                        ),
-                        onPressed: _isLoading ? null : _save,
-                        child: _isLoading 
-                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
-                          : const Text('Save Song', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
-                      ),
-                    ],
-                  ),
-                ],
-              ),
-            ),
-          ),
-        ],
-      ),
+    return CallbackShortcuts(
+      bindings: <ShortcutActivator, VoidCallback>{
+        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
+        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _save,
+      },
+      child: Container(
+        color: Colors.grey[900],
+        child: Column(
+          children: [
+            Container(
+              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
+              color: Colors.black26,
+              child: Row(
+                children: [
+                  Text(
+                    isEditMode ? 'Edit Song' : 'Add New Song',
+                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent),
+                  ),
+                  const Spacer(),
+                  IconButton(
+                    padding: EdgeInsets.zero,
+                    constraints: const BoxConstraints(),
+                    icon: const Icon(Icons.close, color: Colors.grey, size: 16),
+                    onPressed: _close,
+                    tooltip: 'Cancel',
+                  ),
+                ],
+              ),
+            ),
+            Expanded(
+              child: Padding(
+                padding: const EdgeInsets.all(12),
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
+                  children: [
+                    TextField(
+                      controller: _titleController,
+                      style: const TextStyle(fontSize: 12),
+                      decoration: const InputDecoration(
+                        labelText: 'Title *',
+                        labelStyle: TextStyle(fontSize: 11),
+                        border: OutlineInputBorder(),
+                        isDense: true,
+                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
+                      ),
+                      autofocus: !isEditMode,
+                    ),
+                    const SizedBox(height: 8),
+                    TextField(
+                      controller: _authorController,
+                      style: const TextStyle(fontSize: 12),
+                      decoration: const InputDecoration(
+                        labelText: 'Author (Optional)',
+                        labelStyle: TextStyle(fontSize: 11),
+                        border: OutlineInputBorder(),
+                        isDense: true,
+                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
+                      ),
+                    ),
+                    const SizedBox(height: 8),
+                    Expanded(
+                      child: TextField(
+                        controller: _lyricsController,
+                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace', height: 1.4),
+                        decoration: const InputDecoration(
+                          border: OutlineInputBorder(),
+                          hintText: 'Enter song lyrics here...',
+                          contentPadding: EdgeInsets.all(8),
+                        ),
+                        expands: true,
+                        maxLines: null,
+                        minLines: null,
+                        keyboardType: TextInputType.multiline,
+                        textAlignVertical: TextAlignVertical.top,
+                      ),
+                    ),
+                    const SizedBox(height: 12),
+                    Row(
+                      mainAxisAlignment: MainAxisAlignment.end,
+                      children: [
+                        TextButton(
+                          onPressed: _isLoading ? null : _close,
+                          style: TextButton.styleFrom(
+                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
+                          ),
+                          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
+                        ),
+                        const SizedBox(width: 8),
+                        ElevatedButton(
+                          style: ElevatedButton.styleFrom(
+                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
+                            backgroundColor: Colors.blueAccent,
+                            foregroundColor: Colors.white,
+                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
+                          ),
+                          onPressed: _isLoading ? null : _save,
+                          child: _isLoading 
+                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
+                            : const Text('Save Song', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
+                        ),
+                      ],
+                    ),
+                  ],
+                ),
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
   }
 }
+
