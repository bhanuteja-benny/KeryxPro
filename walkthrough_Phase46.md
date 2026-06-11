# Walkthrough - Phase 46: Preloaded Themes for Presentation

This walkthrough documents the design, implementation, and verification details for the Preloaded Themes feature added to KeryxPro in Phase 46.

---

## 1. Accomplished Changes

### Dependencies (`pubspec.yaml`)
- Added `archive: ^3.6.1` to support zipping/unzipping theme folders programmatically across all desktop and web platforms.

### Presentation Settings Dialog (`lib/features/settings/presentation/widgets/presentation_settings_dialog.dart`)
- **State Properties & Mode Extension**:
  - Extended the `ViewMode` enum with `editTheme`.
  - Added state properties: `_editingThemeName`, `_themeSettings` (holding theme-specific `PresentationSettings`), `_themeNameCtrl`, `_previewThemeAsSong` (toggles preview mode between Song and Scripture within the theme builder).
- **Preset Selection View Updates**:
  - Inserted the **Create Theme** option (visible in debug builds only) and **Import Theme** option next to the preset name entry field.
- **Theme Editing View**:
  - Renders a clean workspace with a single **Theme Settings** panel containing:
    - Aspect ratio selector (with custom width/height support).
    - Background settings (color, transparency, and background image picking).
    - Title/Chapter Typography settings.
    - Body/Verse Typography settings.
    - Export button (packages the theme as a `.zip` file).
    - Save button (serializes options to `theme.json` and copies chosen background media into the local theme folder).
- **Import/Apply Engine**:
  - **Import**: Allows selecting a `.zip` file containing a theme configuration, extracts it to `{Application Documents}/KeryxPro/Themes/[Theme Name]/`, and registers the theme.
  - **Apply**: Adds an `Apply Theme` button to the Song/Scripture tabs within the Preset Editor. Renders a card-based grid overlay of all imported themes with live preview mockups. Applies all selected settings onto the active preset configuration, skipping mismatched fields (e.g. `bodyLineBreak` on scripture settings).

---

## 2. Code Modifications

### pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  # ...
  archive: ^3.6.1
```

### lib/features/settings/presentation/widgets/presentation_settings_dialog.dart
- Added the theme settings UI panel, layout mapping, background image file synchronization, zip packing and extraction methods.

---

## 3. Verification Steps

1. **Start the Application in Debug Mode**:
   - Check the **Create Theme** button's visibility next to the Preset controls.
2. **Create a Theme**:
   - Choose a name (e.g. "Warm Emerald").
   - Configure a custom aspect ratio, custom background color/image, title font size/family, and body layout options.
   - Click **Save Theme**.
3. **Verify Local Output**:
   - Inspect `{Application Documents}/KeryxPro/Themes/Warm Emerald/`.
   - Confirm `theme.json` lists all settings.
   - Confirm picked background images are copied locally to the theme folder and stored with relative filenames in `theme.json`.
4. **Export Theme**:
   - Click **Export (Zip)** and save the zipped archive package.
5. **Import & Apply**:
   - Navigate to song/scripture preset tabs, click **Apply Theme**.
   - Review live rendering cards displaying the "Warm Emerald" mockup.
   - Select the theme to overlay the layout parameters onto the current editing state.
