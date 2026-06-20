# KeryxPro

KeryxPro is a professional, modern, and offline-first presentation and projection software designed specifically for churches, worship settings, and live events. Built using **Flutter**, **Isar Database**, and **Riverpod State Management**, KeryxPro allows presenters to manage song libraries, search scriptures, organize service setlists, and project text and media onto a secondary display or projector with ease.

---

## Key Features

### 🖥️ Multi-Window Projection & Live Control
- **Dual Display Support:** Seamlessly launch and control a secondary projection window dedicated to the public screen or projector.
- **Output Freeze:** Instantly freeze or unfreeze the projection output (shortcut `f`), letting you edit setlists or search scriptures in the control panel privately while the audience sees a static slide.
- **Flexible Aspect Ratios:** Define projection dimensions to match the display layout (16:9, 4:3, 4:1, or custom dimensions).

### 🎵 Song & Lyrics Library
- **Structured Song Database:** Store, edit, and organize song lyrics, authors, and background styles.
- **Interactive Song Editor:** Add new songs or customize existing lyrics directly in the editor.
- **OpenSong XML Import:** Seamlessly import entire song catalog files in the OpenSong XML format. The importer automatically cleans up and filters out guitar chords (lines starting with `.`) to prepare lyrics for projection.

### 📖 Bible & Scripture Integration
- **Advanced Verse Projection:** Search and display scripture verses on-the-fly.
- **Multi-Format Import:** Support for importing Bible translations from **Zefania XML** and **OpenSong XML** formats.
- **Dynamic Navigation:** Project adjacent verses instantly using keyboard shortcuts without returning to the search box (e.g., `Ctrl/Cmd + Right/Left Arrow`).

### 📁 Setlist Manager
- **Curated Service Flows:** Group songs, scripture passages, and media slides into a named setlist for a specific service.
- **Save & Load Setlists:** Save the layout locally, overwrite, or delete setlists as needed.
- **Interactive Slides & Favorites:** Reorder items easily, tag items as favorites, and add custom image slides with configurable alignment grids and layout modes (`contain`, `cover`, `stretch`).

### 🎨 Rich Layout & Preset Settings
- **Granular Formatting:** Style fonts, sizes, text colors, background colors, text outlines (stroke), and margins.
- **Component-Specific Themes:** Apply separate styles and background images for Songs, Scriptures, and Blank/clear screens.
- **Style Presets:** Save configuration settings as reusable style presets and switch between them instantly.

### 🔄 LAN & Media Synchronization
- **Local Folder Sync:** Connect multiple presentation computers via a shared folder (e.g., LAN network share, Dropbox, or OneDrive). The app monitors the directory and syncs songs, setlists, style presets, and Bible translations automatically.
- **Portable Media Mapping:** Uses tokenized paths (`[SYNC_MEDIA]` and `[LOCAL_MEDIA]`) for background images and image slides. This allows files to resolve correctly regardless of OS or absolute folder structure differences between computers.
- **Pending Changes Indicator:** View when new updates are available on the network and synchronize them with a single click.

---

## Keyboard Shortcuts (Power-User Controls)

KeryxPro is built to be controlled entirely from the keyboard during a live service:

| Shortcut Key | Action |
| :--- | :--- |
| `q` | Open song search panel |
| `s` | Open scripture search panel |
| `L` | Shift focus to the slides navigation pane |
| `Space` | Jump to the next slide |
| `Tab` | Jump to the next blank screen |
| `f` | Freeze or unfreeze the projector screen output |
| `Enter` + `Enter` *(in scripture search)* | Add and project the selected verse immediately |
| `Enter` + `Tab` + `Enter` *(in scripture search)* | Add the selected verse to the setlist without projecting it |
| `Ctrl/Cmd + S` | Load the currently projected verse back into the scripture search |
| `Ctrl/Cmd + Right Arrow` | Append and project the **next verse** of the active scripture |
| `Ctrl/Cmd + Right Arrow + Right Arrow` | Append and project the **next two verses** of the active scripture |
| `Ctrl/Cmd + Left Arrow` | Prepend and project the **previous verse** of the active scripture |
| `Ctrl/Cmd + Left Arrow + Left Arrow` | Prepend and project the **previous two verses** of the active scripture |
| `Ctrl/Cmd + B` | Toggle a bookmark on the currently selected slide |
| `Ctrl/Cmd + Up Arrow` | Navigate up to the previous bookmarked slide |
| `Ctrl/Cmd + Down Arrow` | Navigate down to the next bookmarked slide |

---

## File Format Support

- **Songs:** OpenSong XML (`.xml`)
- **Bibles:** Zefania XML (`.xml`), OpenSong XML (`.xml`)
- **Media Slides & Backgrounds:** standard image formats (PNG, JPG, JPEG)

---

## Getting Started

### Prerequisites & Installation
For pre-compiled executable links, system requirements, and step-by-step setup guides on Windows and macOS, please see the [Installation Guide](INSTALLATION_GUIDE.md).

### Developer Compilation
To compile KeryxPro from source code and build standalone release packages (`.exe` installers for Windows via Inno Setup or `.dmg` archives for macOS):
1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Set up platform compiler prerequisites (Visual Studio with C++ tools for Windows; Xcode and CocoaPods for macOS).
3. Run `flutter build windows --release` or `flutter build macos --release`.
4. Follow the specific packaging instructions in the [Developer Build Guide section of the Installation Guide](INSTALLATION_GUIDE.md#part-2-developer-build-guide).

---

## Technical Architecture

- **Framework:** Flutter (Desktop - Windows & macOS)
- **Database:** Isar (NoSQL embedded database with async transaction support)
- **State Management:** Riverpod (Decoupled, compile-time safe state architecture)
- **Multi-Window Interaction:** `desktop_multi_window` and `window_manager` for native window handles and cross-window event dispatching
- **Local Sync Watcher:** Dart `Directory.watch` API paired with file system synchronization files.
