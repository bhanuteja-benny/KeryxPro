# KeryxPro Installation & Build Guide

Welcome to the KeryxPro installation and setup guide. This document contains detailed instructions for both **End Users** (how to install the app) and **Developers** (how to compile and generate the setup installers).

---

## Part 1: End User Installation Guide

### Windows 
**System Requirements:**
- OS: Windows 10 (64-bit) or Windows 11
- Hardware: Minimum 4GB RAM, dual-core processor, secondary display output for projection.

**Installation Steps:**
1. Download the `KeryxPro_Setup_v1.0.0.exe` installer file.
2. Double-click the installer file.
3. Follow the on-screen instructions in the setup wizard.
4. Once completed, you can launch KeryxPro from the Desktop shortcut or the Start Menu.
*(Note: You do not need to manually install any external dependencies, as everything is securely packaged within the installer).*

### macOS
**System Requirements:**
- OS: macOS 11 (Big Sur) or newer.
- Hardware: Minimum 4GB RAM, Apple Silicon (M1/M2/M3) or Intel processor, secondary display output for projection.

**Installation Steps:**
1. Download the `KeryxPro_Mac_v1.0.0.dmg` disk image file.
2. Double-click the `.dmg` file to mount it.
3. A window will appear showing the KeryxPro application icon and a shortcut to your Applications folder.
4. Simply drag the **KeryxPro** app icon into the **Applications** folder shortcut.
5. You can now launch KeryxPro from your Launchpad or Applications folder.

---

## Part 2: Developer Build Guide

This section is for developers who want to compile the source code and generate the standalone installer files (`.exe` and `.dmg`).

### 1. Generating the Windows Installer (`.exe`)

**Prerequisites:**
1. **OS**: Windows 10 or 11.
2. **Flutter SDK**: Installed and added to system PATH.
3. **Visual Studio 2022**: With the "Desktop development with C++" workload installed.
4. **Inno Setup 6**: Download and install from [jrsoftware.org](https://jrsoftware.org/isdl.php).

**Build Steps:**
1. Open a terminal in the project root (`C:\Users\bhanu\projects\KeryxPro`).
2. Run the Flutter build command:
   ```bash
   flutter build windows --release
   ```
   *This compiles the application into `build\windows\x64\runner\Release`.*
3. Open **Inno Setup Compiler**.
4. Open the `packaging/windows/keryxpro_installer.iss` script file.
5. Click **Build > Compile** (or press Ctrl+F9).
6. The compiled `KeryxPro_Setup_v1.0.0.exe` will be generated in `build/windows/installer/`.

### 2. Generating the macOS Installer (`.dmg`)

**Prerequisites:**
1. **OS**: macOS (12+ recommended).
2. **Flutter SDK**: Installed and added to path.
3. **Xcode**: Latest version installed from the Mac App Store.
4. **CocoaPods**: Installed (`sudo gem install cocoapods`).

**Build Steps:**
1. Open a terminal in the project root.
2. Run the Flutter build command:
   ```bash
   flutter build macos --release
   ```
   *This compiles the `.app` bundle into `build/macos/Build/Products/Release/keryxpro.app`.*
3. Make the bash script executable (first time only):
   ```bash
   chmod +x packaging/macos/build_dmg.sh
   ```
4. Run the DMG builder script:
   ```bash
   cd packaging/macos
   ./build_dmg.sh
   ```
5. The standalone `KeryxPro_Mac_v1.0.0.dmg` file will be generated in `build/macos/installer/`.

---
*End of Guide*
