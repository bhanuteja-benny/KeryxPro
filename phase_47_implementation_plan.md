# Phase 47 Implementation Plan: PowerPoint Presentation Support

This implementation plan outlines the support for adding PowerPoint presentations (`.ppt`, `.pptx`, `.ppsx`) to the setlist, extracting slides as static images locally, and projecting them sequentially.

---

## 1. Questionnaire Responses & Architectural Proposals

### Q1: What type of file types can be accepted (.ppt, .pptx, .ppsx, any other)?
- **Response**: The file picker will accept `.ppt`, `.pptx`, and `.ppsx`. Because slide extraction is performed headlessly via the system's Microsoft PowerPoint application (using COM Interop on Windows and AppleScript on macOS), any file format compatible with the installed Microsoft PowerPoint application is supported. This also includes slide show formats (`.ppsx`, `.pps`) and macro-enabled presentations (`.pptm`).

### Q2: Can we give options like stretch or keep aspect ratio kind of things for these?
- **Response**: By default, PowerPoint slides will be rendered using `BoxFit.contain` (preserving original aspect ratio) aligned to the center. Since the rules explicitly forbid adding new UI elements, fields, or buttons unless approved ("Do NOT add extra fields or buttons"), we will hardcode the aspect ratio behavior to preserve the original design. If aspect-ratio configuration settings are desired in the future, they can be introduced in a later phase.

### Q3: If the slides contain any actions (like text appearing or underlining on click), how are these handled?
- **Response**: When exporting slides to static images via the office automation APIs, all click-to-build animations and slide transitions are **flattened**. Only the final state of each slide is captured and exported as a single image. Capturing intermediate animation states as separate slides is not supported by office export APIs. This is the industry-standard behavior for church presentation systems (e.g., ProPresenter, OpenLP).

### Q4: Any other challenges, suggestions, or betterments?
1. **PowerPoint Dependency**: Since conversion is performed using local office applications, Microsoft PowerPoint must be installed on the user's machine.
   - *Resolution*: We will handle this gracefully. If PowerPoint is not installed or the automation process fails, we will intercept the error and display an alert dialog: `"Microsoft PowerPoint is required to import presentation files. Alternatively, export your slides to images/PDF and import them."`
2. **Import Performance / Loading UI**: Exporting slides from PowerPoint can take 3 to 10 seconds.
   - *Resolution*: We will show a modal loading spinner dialog with the text `"Extracting PowerPoint slides..."` to block user input and keep the UI responsive.
3. **Database Schema Stability**: To avoid Isar database schema migrations (which require running build runner code-generation and risk database mismatch issues for users), we will encode PowerPoint setlist items within the existing `SavedSetlist` structure.
   - *Resolution*: A PowerPoint item will be represented in `itemOrder` as `powerpoint:pptxPath|uniqueId`. The slide images will be cached locally in `ApplicationDocumentsDirectory/KeryxPro/PPTX_Cache/<uniqueId>`. When the setlist is loaded, the repository checks the cache directory for the slide images. This keeps database operations simple, offline-first, and backwards-compatible.

---

## 2. Directory Structure & Storage

All extracted PowerPoint slides are stored in a cache folder:
```
{Application Documents}/KeryxPro/PPTX_Cache/
  └── [uniqueId]/
        ├── Slide1.PNG
        ├── Slide2.PNG
        └── ...
```

---

## 3. Proposed File Changes

### A. Add PowerPoint Setlist Item Model
**Target File**: `lib/features/setlist/data/setlist_item.dart`
- Create `PowerpointSetlistItem` extending `SetlistItem`:
```dart
class PowerpointSetlistItem extends SetlistItem {
  final String pptxPath;
  final List<String> slideImagePaths;

  PowerpointSetlistItem({
    required this.pptxPath,
    required this.slideImagePaths,
    super.uniqueId,
    super.isFavorite,
  });

  @override
  PowerpointSetlistItem copyWith({bool? isFavorite}) {
    return PowerpointSetlistItem(
      pptxPath: pptxPath,
      slideImagePaths: slideImagePaths,
      uniqueId: uniqueId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get displayName => pptxPath.split(RegExp(r'[/\\]')).last;
}
```

### B. Implement OS-Specific PowerPoint Extractor
**New File**: `lib/features/setlist/data/powerpoint_extractor.dart`
- Create a helper class `PowerpointExtractor` to invoke native office processes:
- **Windows Script (PowerShell)**:
  ```powershell
  $ppt = New-Object -ComObject PowerPoint.Application
  $ppt.Visible = [Microsoft.Office.Core.MsoTriState]::msoFalse
  $pres = $ppt.Presentations.Open("<pptxPath>", [Microsoft.Office.Core.MsoTriState]::msoTrue, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoFalse)
  $pres.SaveAs("<outputDir>", 17) # 17 = ppSaveAsPNG
  $pres.Close()
  $ppt.Quit()
  ```
- **macOS Script (AppleScript)**:
  ```applescript
  tell application "Microsoft PowerPoint"
      open file "<pptxPath>"
      save active presentation in "<outputDir>" as save as PNG
      close active presentation
      quit
  end tell
  ```
- After running the export script, the extractor will read the files from the target directory and sort them numerically using a natural sort algorithm (matching number sequences in filenames case-insensitively, e.g. `Slide1.PNG`, `Slide2.PNG`, `Slide10.PNG`).

### C. Update Setlist Repository Serialization
**Target File**: `lib/features/setlist/data/setlist_repository.dart`
- **`saveByName`**: Map `PowerpointSetlistItem` to `itemOrder` as `powerpoint:pptxPath|uniqueId`.
- **`loadByName`**: Parse entries starting with `powerpoint:`. Locate the cached images in `${appDocDir}/KeryxPro/PPTX_Cache/${uniqueId}` and load them back into the `PowerpointSetlistItem`.

### D. Setlist Pane UI Integration
**Target File**: `lib/features/dashboard/presentation/widgets/setlist_pane.dart`
- Replace `Icons.add_photo_alternate_rounded` in the toolbar with `Icons.perm_media_rounded` (Add Media).
- When the Media button is clicked:
  - Open a styled `showMenu` (popup menu) with items:
    1. **Add Image** (Trigger existing `_addImage` function).
    2. **Add Video** (Disabled/greyed out with icon `Icons.video_file_rounded`).
    3. **Add PowerPoint** (Trigger file picker for PowerPoint files, show loading indicator, call `PowerpointExtractor`, and insert `PowerpointSetlistItem` using `ref.read(setlistProvider.notifier)`).
- Update setlist list renderer:
  - If item is `PowerpointSetlistItem`, render a `Icons.slideshow_rounded` icon (in `orangeAccent` color) and display the filename (`item.displayName`).

### E. Slide Calculation & Mapping Providers
**Target File**: `lib/features/live_controller/presentation/live_projector_providers.dart`
- **`currentSlidesProvider`**:
  - Handle `PowerpointSetlistItem`: Add a `Slide` object for each image in `slideImagePaths`. The shortcut should be `${index + 1}` (slide number). Do not append blank slides in between slides.
- **`slideToSetlistItemIndexProvider`**:
  - Handle `PowerpointSetlistItem`: Map each PowerPoint slide index to the index of the corresponding PowerPoint setlist item.
- **`getSlideCountForItems`**:
  - Add support for counting slides inside `PowerpointSetlistItem`.

### F. Projector View Image Rendering
**Target File**: `lib/features/presentation/presentation/widgets/projector_view.dart`
- Treat `POWERPOINT:` slide contents identically to `IMAGE:` contents:
  ```dart
  final isImageSlide = (activeSlideText?.startsWith('IMAGE:') ?? false) || 
                       (activeSlideText?.startsWith('POWERPOINT:') ?? false);
  ```
- Modify `_buildImageWidget` to parse `POWERPOINT:` prefix offsets and retrieve the path.

---

## 4. Proposed Verification Plan

### Phase A: Import & Automation Tests
1. **Media Popup**: Verify that clicking the "Media" icon displays a popup containing "Add Image", "Add Video" (disabled), and "Add PowerPoint".
2. **File Picker**: Verify that "Add PowerPoint" successfully opens a file picker filtering for `.ppt`, `.pptx`, and `.ppsx`.
3. **Extraction Process**: Select a PowerPoint file and verify that:
   - A loading indicator dialog is displayed.
   - Images are generated inside `KeryxPro/PPTX_Cache/<uniqueId>`.
   - Slide sorting is correct (e.g. Slide 10 follows Slide 9, not Slide 1).

### Phase B: Slide Pane & Navigation Tests
1. **Slide Display**: Confirm that PowerPoint slides are loaded into the slides pane without blank slides between them.
2. **Shortcuts**: Verify that pressing keys `1`, `2`, `3` while the slide pane has focus navigates to the corresponding slide number.
3. **Bookmarking**: Toggle a bookmark on a PowerPoint slide, navigate using bookmark controls, and verify that the bookmarked slide is highlighted.
4. **Projector Output**: Open the projector display and confirm that the slides render at the correct ratio (`BoxFit.contain`) and center correctly.
5. **Persistence**: Save the setlist, restart the application, reload the setlist, and confirm that the PowerPoint item loads successfully with all slides cached.
