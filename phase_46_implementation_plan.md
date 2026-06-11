# Phase 46 Implementation Plan: Preloaded Themes for Presentation

This implementation plan outlines the introduction of preloaded themes for presentation in KeryxPro, supporting theme creation and exporting in developer mode (debug), and theme importing, previewing, and applying in user mode (release).

---

## 1. Directory Structure and Data Format

### Filesystem Storage
All themes (both created by developer and imported by user) will be stored in a dedicated subdirectory within the KeryxPro documents folder:
```
{Application Documents}/KeryxPro/Themes/
  ├── [Theme Name]/
  │     ├── theme.json
  │     └── [background_image].png  (optional local background image copy)
```

### Theme Schema (`theme.json`)
The theme settings will be stored in a JSON file containing the layout variables:
```json
{
  "themeName": "Emerald Glow",
  "aspectRatio": "16:9",
  "customWidth": 1920.0,
  "customHeight": 1080.0,
  "backgroundColor": 4278190335,
  "backgroundImage": "bg.png", 
  "backgroundImageLayout": "stretch",
  "backgroundImageAlignment": "center",
  "isImageEnabled": true,
  "isTransparent": false,
  
  "showTitle": true,
  "titleAlignment": "center",
  "titleVerticalAlignment": "bottom",
  "titleFontSize": 24.0,
  "titleFontFamily": "Arial",
  "titleFontColor": 2415919103,
  "titleBold": true,
  "titleItalic": false,
  "titleUnderline": false,
  "titleHasFill": false,
  "titleFillColor": 0,
  "titleHasStroke": false,
  "titleStrokeColor": 4278190080,
  "titleMarginTop": 16.0,
  "titleMarginBottom": 16.0,
  "titleMarginLeft": 16.0,
  "titleMarginRight": 16.0,
  
  "bodyAlignment": "center",
  "bodyVerticalAlignment": "center",
  "bodyFontSize": 80.0,
  "bodyFontFamily": "Arial",
  "bodyFontColor": 4294967295,
  "bodyBold": true,
  "bodyItalic": false,
  "bodyUnderline": false,
  "bodyHasFill": false,
  "bodyFillColor": 0,
  "bodyHasStroke": false,
  "bodyStrokeColor": 4278190080,
  "bodyMarginTop": 32.0,
  "bodyMarginBottom": 32.0,
  "bodyMarginLeft": 32.0,
  "bodyMarginRight": 32.0,
  "bodyLineBreak": false
}
```
> [!IMPORTANT]
> To ensure compatibility across different user systems, `backgroundImage` is stored as a **relative filename** (e.g. `bg.png`) in `theme.json` instead of an absolute path. The absolute path will be dynamically resolved at runtime relative to the corresponding theme folder.

---

## 2. Dependencies

To support file zipping and unzipping directly in Dart across all target platforms (Windows, macOS, Linux), we will add the `archive` dependency to `pubspec.yaml`:
```yaml
dependencies:
  archive: ^3.6.1
```

---

## 3. Implementation Details

### A. Developer Mode (Debug Build)
When `kDebugMode` is active:
1. **Create Theme Option**: A button labeled `Create Theme` is displayed in the "Choose Preset" view.
2. **Setup Theme Dialog**:
   - Prompt developer for a theme name.
   - Open a themed editing canvas containing a single tab: `'Theme Settings'`.
   - This tab merges the properties from both song and scripture presets (aspect ratio, custom dimensions, background settings, title styling, body styling).
3. **Save and Copy Media**:
   - When saved, create directory `${appDocDir}/KeryxPro/Themes/${themeName}`.
   - Write settings to `theme.json`.
   - If a background image is configured, copy the image file into the theme directory and save its filename in `theme.json`.
4. **Export (ZIP)**:
   - Provide a button to zip the folder using the `archive` library and export it using `FilePicker.saveFile`.

### B. End User Mode (Release/Production Build)
1. **Import Theme Option**:
   - A button labeled `Import Theme` is visible in the "Choose Preset" view in both debug and release configurations.
   - Opens `FilePicker` to select a `.zip` file.
   - Extracts the ZIP contents into `${appDocDir}/KeryxPro/Themes/${themeName}`.
2. **Apply Theme in Settings**:
   - Inside the Preset Editor (for both Song and Scripture tabs), display an `Apply Theme` button.
   - Clicking it launches the "Select Theme" overlay, which scans the `Themes` folder.
   - **Theme Preview**: Each theme option is rendered with a live visual card containing `ProjectorView`:
     - If accessed from the **Song** settings tab, the preview displays a sample song slide ("Amazing Grace...").
     - If accessed from the **Scripture** settings tab, the preview displays a sample Bible verse ("John 3:16...").
   - Clicking "Apply" copies the theme's settings into the active tab's preset configuration state:
     - Mismatched fields (e.g., `bodyLineBreak` applied to Scripture) are ignored.
     - The user is then returned to the Preset Editor, where they can refine settings and save them as a custom preset.

---

## 4. Setting Mappings Reference

### Theme Settings ➔ Song Settings Mapping
- `songAspectRatio` = theme `aspectRatio`
- `songBackgroundColor` = theme `backgroundColor`
- `songBackgroundImage` = resolved absolute path to local theme image
- `songBackgroundImageLayout` = theme `backgroundImageLayout`
- `songBackgroundImageAlignment` = theme `backgroundImageAlignment`
- `isSongImageEnabled` = theme `isImageEnabled`
- `isSongTransparent` = theme `isTransparent`
- Title styling variables ➔ Title variables (`showTitle`, `titleAlignment`, etc.)
- Body styling variables ➔ Lyrics variables (`lyricsFontSize`, `lyricsAlignment`, `lyricsLineBreak`, etc.)

### Theme Settings ➔ Scripture Settings Mapping
- `scriptureAspectRatio` = theme `aspectRatio`
- `scriptureBackgroundColor` = theme `backgroundColor`
- `scriptureBackgroundImage` = resolved absolute path to local theme image
- `scriptureBackgroundImageLayout` = theme `backgroundImageLayout`
- `scriptureBackgroundImageAlignment` = theme `backgroundImageAlignment`
- `isScriptureImageEnabled` = theme `isImageEnabled`
- `isScriptureTransparent` = theme `isTransparent`
- Title styling variables ➔ Chapter variables (`showChapter`, `chapterAlignment`, etc.)
- Body styling variables ➔ Verse variables (`verseFontSize`, `verseAlignment`, etc.)
- **Ignored field**: `bodyLineBreak` (scripture has no line-break option).

---

## 5. File Changes Outline

1. **`pubspec.yaml`**: Add `archive: ^3.6.1` dependency.
2. **`lib/features/settings/presentation/widgets/presentation_settings_dialog.dart`**:
   - Add theme creation interface, importing logic, single-tab theme editor, theme preview list, and configuration mapping methods.
   - Implement zipping/unzipping file handling.
3. **`lib/features/presentation/presentation/widgets/projector_view.dart`**:
   - Ensure media resolution can resolve relative theme assets if specified.

---

## 6. Proposed Verification Plan

1. **Verify UI elements in Debug Mode**:
   - Check visibility of "Create Theme" next to "Add New Preset".
   - Test naming, custom options configuration, and directory creation.
2. **Verify Theme Serialization**:
   - Confirm settings are written to `theme.json` and image files are correctly copied into `Themes/[Theme Name]/`.
   - Validate zip creation upon export.
3. **Verify Theme Import**:
   - Select zip package, check extraction into the `Themes` folder.
4. **Verify Apply Feature**:
   - Apply a theme on Song preset settings ➔ check lyrics layout and line break configuration.
   - Apply a theme on Scripture preset settings ➔ check chapter and verse layout (ignoring line break configuration).
   - Verify changes are editable and successfully save as a preset.
