# Implementation Plan - Phase 45: Help & Shortcuts Title Bar Icon

This plan outlines the design and integration of a help/shortcuts icon in the main title bar of the application. The icon will show a vertical list of available keyboard shortcuts when hovered.

---

## 1. UI Requirement & Placement

### Icon Button
* **Icon**: Standard question mark icon (`Icons.help_outline`, `size: 16`, `color: Colors.white70`).
* **Sizing**: Reuses the internal `_WindowButton` widget (`width: 46`, `height: 32`) to perfectly align with the existing sync and system window controls.
* **On Press (Optional/Standard)**: Triggers the existing `HelpDialog()` to show the full help window when clicked, ensuring intuitive behavior.

### Placement in Title Bar
The button will be positioned at the right end of the `CustomTitleBar`, specifically:
* After the **Global Sync Button** (if enabled).
* Before the **System Window Controls** (`WindowButtons` for Windows/Linux).
* On macOS, it will sit at the far right corner, since there are no system window controls on the right.

```dart
          // Global Sync Button (existing)
          if (ref.watch(syncConfigProvider).syncEnabled)
            ...

          // Help & Shortcuts Icon Button (NEW)
          Tooltip(
            ...
            child: _WindowButton(
              icon: Icons.help_outline,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const HelpDialog(),
                );
              },
            ),
          ),

          // System Window Controls (existing)
          if (!Platform.isMacOS) const WindowButtons(),
```

---

## 2. UI Visual Style & Tooltip Formatting

To ensure the list feels premium, standard, and fits the dark aesthetic of the application:
* **Background**: Sleek dark color (`const Color(0xFF1E1E1E)`) with a subtle border (`Border.all(color: Colors.white12)`) and rounded corners (`borderRadius: BorderRadius.circular(6)`).
* **Padding**: Dense padding (`EdgeInsets.symmetric(horizontal: 12, vertical: 8)`) to keep it compact with no excess space.
* **Responsiveness**: Set `waitDuration: const Duration(milliseconds: 100)` so that the tooltip displays instantly on mouse hover.
* **Position**: Set `preferBelow: true` to prevent the tooltip from going off-screen (since the title bar is at the very top).
* **Text Formatting**: We will use a `richMessage` containing a `TextSpan` with:
  * Key bindings styled in bold, yellow-accented color (`Colors.amberAccent`), and using the `'monospace'` font family.
  * Description styled in standard readable white text.
  * Line-by-line layout (using `\n`) with a dense line height (`height: 1.4`).

---

## 3. List of Shortcuts to Mention

The following list will be displayed in the tooltip exactly as requested (line-by-line):

* **'s'** - open scripture search
* **'q'** - open song search
* **'L'** - go to slides navigation
* **'enter' + 'enter'** in scripture search - add and display the verse immediately
* **'enter' + 'tab' + 'enter'** in scripture search - just add the verse
* **ctrl/cmd + b** - toggle bookmark on the current slide
* **'ctrl/cmd + up arrow'** - navigate to the bookmarked slides towards up
* **'ctrl/cmd + down arrow'** - navigate to the bookmarked slides towards down
* **'ctrl/cmd + right arrow'** - add and display next verse of the currently displaying verse
* **'ctrl/cmd + right arrow + right arrow'** - add and display next two verses of the currently displaying verse
* **'ctrl/cmd + left arrow'** - add and display before verse of the currently displaying verse
* **'ctrl/cmd + left arrow + left arrow'** - add and display before two verses of the currently displaying verse
* **'ctrl/cmd + s'** - open the current displaying verse in scripture search

---

## 4. Proposed Code Changes

### File: `lib/features/dashboard/presentation/widgets/custom_title_bar.dart`

```diff
@@ -213,2 +213,77 @@
             ),
+
+          // Help & Shortcuts Icon Button
+          Tooltip(
+            decoration: BoxDecoration(
+              color: const Color(0xFF1E1E1E),
+              borderRadius: BorderRadius.circular(6),
+              border: Border.all(color: Colors.white12),
+            ),
+            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
+            margin: const EdgeInsets.only(top: 8),
+            preferBelow: true,
+            waitDuration: const Duration(milliseconds: 100),
+            richMessage: TextSpan(
+              style: const TextStyle(
+                fontSize: 12,
+                color: Colors.white,
+                height: 1.4,
+              ),
+              children: [
+                TextSpan(
+                  text: "'s'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - open scripture search\n"),
+                TextSpan(
+                  text: "'q'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - open song search\n"),
+                TextSpan(
+                  text: "'L'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - go to slides navigation\n"),
+                TextSpan(
+                  text: "'enter' + 'enter'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " in scripture search - add and display the verse immediately\n"),
+                TextSpan(
+                  text: "'enter' + 'tab' + 'enter'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " in scripture search - just add the verse\n"),
+                TextSpan(
+                  text: "ctrl/cmd + b",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - toggle bookmark on the current slide\n"),
+                TextSpan(
+                  text: "'ctrl/cmd + up arrow'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - navigate to the bookmarked slides towards up\n"),
+                TextSpan(
+                  text: "'ctrl/cmd + down arrow'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - navigate to the bookmarked slides towards down\n"),
+                TextSpan(
+                  text: "'ctrl/cmd + right arrow'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - add and display next verse of the currently displaying verse\n"),
+                TextSpan(
+                  text: "'ctrl/cmd + right arrow + right arrow'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                TextSpan(
+                  text: "'ctrl/cmd + left arrow'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - add and display before verse of the currently displaying verse\n"),
+                TextSpan(
+                  text: "'ctrl/cmd + left arrow + left arrow'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - add and display before two verses of the currently displaying verse\n"),
+                TextSpan(
+                  text: "'ctrl/cmd + s'",
+                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
+                ),
+                const TextSpan(text: " - open the current displaying verse in scripture search"),
+              ],
+            ),
+            child: _WindowButton(
+              icon: Icons.help_outline,
+              onPressed: () {
+                showDialog(
+                  context: context,
+                  builder: (context) => const HelpDialog(),
+                );
+              },
+            ),
+          ),
 
           // System Window Controls
```

---

## 5. Explicit Assumptions & Presumptions for User Approval

1. **Clicking behavior**: Pressing/clicking the question mark icon will trigger `HelpDialog()` (the same dialog that appears when clicking the "Help" menu option).
2. **Shortcut Names**: The shortcut name formats are represented exactly as requested in the prompt, with key bindings enclosed/formatted consistently (e.g. `'s'`, `'q'`, `ctrl/cmd + b`, `'ctrl/cmd + up arrow'`).
3. **Tooltip placement**: The tooltip will display underneath the button so that the text isn't cut off by the edge of the monitor.

---

## 6. Verification Plan

1. **Visual Alignment**: Verify the icon is correctly aligned and matching the size/height of other title bar items.
2. **Hover Trigger**: Hover over the icon, verify that the list appears quickly and looks like a dense list.
3. **Verification of Content**: Confirm all 13 shortcuts are listed exactly as specified.
4. **Click Trigger**: Click the help icon and confirm the main help dialog appears.
