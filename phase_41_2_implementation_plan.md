# Implementation Plan - Phase 41.2: Dynamic Screen Resolution ("Fit to screen")

## Summary of Answers to Challenges

### Challenge 1
*“In case of two screens/monitors are connected (using some multi connectors) through a single connection, and the screens are different resolutions (aspect ratios), will the presentation fit to each screen according to its resolution?”*
- **Answer**: **No.** If two monitors are connected through a single physical port using a hardware splitter (mirroring), the operating system (OS) only detects a single logical monitor with a single resolution. Since the OS only reports one screen to KeryxPro, the application renders one signal, which the hardware splitter duplicates. As a result, they cannot be rendered at different aspect ratios or fitted independently from the software side.

### Challenge 2
*“In case of those two screens/monitors are connected as two different extended monitors, and their resolutions are different, will the presentation fit to each screen according to its resolution?”*
- **Answer**: **Yes.** When configured as two independent extended monitors in the OS settings (Windows or macOS), the OS exposes them as separate screens with their own coordinates and physical resolutions. When KeryxPro launches the presentation on the extended monitor (Monitor 1), it reads the target monitor's resolution. With the **"Fit to screen"** option, KeryxPro will dynamically adjust its virtual canvas size to match the target monitor's physical resolution exactly.

---

## Proposed Changes

We will introduce a new aspect ratio option: **`'Fit to screen'`**.

### 1. Presentation Settings UI (`lib/features/settings/presentation/widgets/presentation_settings_dialog.dart`)
We will add `'Fit to screen'` as a menu option in the Aspect Ratio dropdown selector:
```dart
DropdownMenuEntry(value: 'Fit to screen', label: 'Fit to screen'),
```
When this option is selected:
- The preview pane inside the settings dialog will fall back to **16:9** aspect ratio.
- The dashboard preview panes (Monitor 1 & 2 tabs) will fall back to **16:9** aspect ratio.

### 2. Multi-Window Projector Application (`lib/main.dart`)
We will update `ProjectorApp` to pass the parsed native `_monitorIndex` parameter down to the `ProjectorView` instance:
```dart
Widget view = ProjectorView(
  settings: _settings,
  activeSlideText: _activeSlideText,
  titleText: _titleText,
  isSong: _isSong,
  monitorIndex: _monitorIndex, // <-- Pass the monitor index
);
```

### 3. Projector View (`lib/features/presentation/presentation/widgets/projector_view.dart`)
We will extend `ProjectorView` to support `monitorIndex` and dynamically size the canvas when `'Fit to screen'` is active:

1. **Constructor Update**:
   Add `final int? monitorIndex` to `ProjectorView`.

2. **Canvas Sizing Update (`getCanvasSize`)**:
   Modify `getCanvasSize` to accept `BuildContext? context` and `int? monitorIndex`.
   - If the aspect ratio is `'Fit to screen'`:
     - If `monitorIndex == 1` (Monitor 1 / Extended monitor) and `context != null`:
       Read the screen size using `MediaQuery.of(context).size`.
       Use this size as `canvasWidth` and `canvasHeight`.
     - Otherwise (Monitor 2 or preview modes), default to **1920x1080** (16:9).

---

## Detailed Code Diff Design

### `lib/features/presentation/presentation/widgets/projector_view.dart`

```diff
 class ProjectorView extends ConsumerWidget {
   // On Windows, LWA_COLORKEY uses RGB(1,0,1) as the chroma key.
   // ...
   final PresentationSettings settings;
   final String? activeSlideText;
   final String? titleText;
   final bool isSong;
   final bool showCheckerboard;
+  final int? monitorIndex;
 
   const ProjectorView({
     super.key,
     required this.settings,
     this.activeSlideText,
     this.titleText,
     this.isSong = true,
     this.showCheckerboard = false,
+    this.monitorIndex,
   });
 
-  static Size getCanvasSize(PresentationSettings settings, {required bool isSong, required bool isBlank}) {
+  static Size getCanvasSize(
+    PresentationSettings settings, {
+    required bool isSong,
+    required bool isBlank,
+    BuildContext? context,
+    int? monitorIndex,
+  }) {
     final aspectRatioStr = isBlank ? settings.blankAspectRatio : (isSong ? settings.songAspectRatio : settings.scriptureAspectRatio);
     double canvasWidth = 1920;
     double canvasHeight = 1080;
 
     if (aspectRatioStr == '4:3') {
       canvasWidth = 1440;
       canvasHeight = 1080;
     } else if (aspectRatioStr == '4:1') {
       canvasWidth = 1920;
       canvasHeight = 480;
     } else if (aspectRatioStr == 'Custom') {
       canvasWidth = isBlank ? settings.blankCustomWidth : (isSong ? settings.songCustomWidth : settings.scriptureCustomWidth);
       canvasHeight = isBlank ? settings.blankCustomHeight : (isSong ? settings.songCustomHeight : settings.scriptureCustomHeight);
       if (canvasWidth <= 0) canvasWidth = 1920;
       if (canvasHeight <= 0) canvasHeight = 1080;
+    } else if (aspectRatioStr == 'Fit to screen') {
+      if (monitorIndex == 1 && context != null) {
+        final screenSize = MediaQuery.of(context).size;
+        if (screenSize.width > 0 && screenSize.height > 0) {
+          canvasWidth = screenSize.width;
+          canvasHeight = screenSize.height;
+        }
+      }
     }
     return Size(canvasWidth, canvasHeight);
   }
```

```diff
   @override
   Widget build(BuildContext context, WidgetRef ref) {
     // ...
     
     // Determine the reference canvas size
-    final size = getCanvasSize(settings, isSong: isSong, isBlank: isBlank);
+    final size = getCanvasSize(
+      settings,
+      isSong: isSong,
+      isBlank: isBlank,
+      context: context,
+      monitorIndex: monitorIndex,
+    );
     final double canvasWidth = size.width;
     final double canvasHeight = size.height;
```

### `lib/main.dart`

```diff
   @override
   Widget build(BuildContext context) {
     Widget view = ProjectorView(
       settings: _settings,
       activeSlideText: _activeSlideText,
       titleText: _titleText,
       isSong: _isSong,
+      monitorIndex: _monitorIndex,
     );
```

### `lib/features/settings/presentation/widgets/presentation_settings_dialog.dart`

```diff
           dropdownMenuEntries: const [
             DropdownMenuEntry(value: '16:9', label: '16:9'),
             DropdownMenuEntry(value: '4:3', label: '4:3'),
             DropdownMenuEntry(value: '4:1', label: '4:1 (Banner)'),
             DropdownMenuEntry(value: 'Custom', label: 'Custom'),
+            DropdownMenuEntry(value: 'Fit to screen', label: 'Fit to screen'),
           ],
```

---

## Verification Plan
1. Compile and run the app on Windows and macOS.
2. Open **Presentation Settings** -> Change Aspect Ratio to **Fit to screen**.
3. Verify that the settings preview pane displays in a default **16:9** aspect ratio.
4. Launch Monitor 1 (Presentation on extended monitor/projector).
5. Verify that the presentation canvas dynamically fits/resizes to the target screen resolution (without letterboxes).
6. Launch Monitor 2. Verify that it renders at the default **16:9** aspect ratio.
