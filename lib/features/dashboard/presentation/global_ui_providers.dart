import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tab Controller for Library (Songs vs Bible)
final libraryTabControllerProvider = StateProvider<TabController?>((ref) => null);

/// Bookmarked slide keys in the current slides preview.
final slideBookmarksProvider = StateProvider<Set<String>>((ref) => {});

/// Transfer query for scripture search trigger from preview pane.
final bibleSearchQueryProvider = StateProvider<String?>((ref) => null);

// Focus Nodes for various sections
final songSearchFocusNodeProvider = Provider((ref) => FocusNode(debugLabel: 'SongSearchField'));
final bibleSearchFocusNodeProvider = Provider((ref) => FocusNode(debugLabel: 'BibleSearchField'));
final bibleVerseListFocusNodeProvider = Provider((ref) => FocusNode(debugLabel: 'BibleVerseList'));
final slideListFocusNodeProvider = Provider((ref) => FocusNode(debugLabel: 'SlideList'));

// Shared Scroll Controllers for cross-pane interaction
final slideListScrollControllerProvider = Provider((ref) => ScrollController());

// ─── Library Pane Auto-Hide State ───

/// Pin mode for the Library (Songs/Bible) pane.
enum LibraryPinMode { pinned, autoHide }

/// Whether the Library pane is pinned or in auto-hide mode. Default: pinned.
final libraryPinModeProvider = StateProvider<LibraryPinMode>(
  (ref) => LibraryPinMode.pinned,
);

/// Whether the Library pane is currently visible. Default: true.
final libraryPaneVisibleProvider = StateProvider<bool>((ref) => true);

/// Tracks which tab is active in the icon rail (0 = Songs, 1 = Bible).
final activeLibraryRailIndexProvider = StateProvider<int>((ref) => 0);

// ─── Monitor Pane Auto-Hide State ───

/// Pin mode for the Monitor 1 and 2 pane.
enum MonitorPinMode { pinned, autoHide }

/// Whether the Monitor pane is pinned or in auto-hide mode. Default: pinned.
final monitorPinModeProvider = StateProvider<MonitorPinMode>(
  (ref) => MonitorPinMode.pinned,
);

/// Whether the Monitor pane is currently visible. Default: true.
final monitorPaneVisibleProvider = StateProvider<bool>((ref) => true);

/// Sync Tab Controller for Monitor pane
final monitorTabControllerProvider = StateProvider<TabController?>((ref) => null);

/// Tracks which tab is active in the monitor bottom rail (0 = Monitor 1, 1 = Monitor 2).
final activeMonitorRailIndexProvider = StateProvider<int>((ref) => 0);

// ─── Live Screen Freeze State ───
/// Whether the separate live screens (Monitor 1 and Monitor 2 windows) are frozen.
final isLiveScreenFrozenProvider = StateProvider<bool>((ref) => false);

// Intents for Global Shortcuts
class BibleTabIntent extends Intent {
  const BibleTabIntent();
}

class SongsTabIntent extends Intent {
  const SongsTabIntent();
}

class SlidesFocusIntent extends Intent {
  const SlidesFocusIntent();
}

// Provider to manage the global shortcut actions
final globalShortcutActionProvider = Provider((ref) => GlobalShortcutActions(ref));

class GlobalShortcutActions {
  final Ref ref;
  GlobalShortcutActions(this.ref);

  void toggleFreeze() {
    final current = ref.read(isLiveScreenFrozenProvider);
    ref.read(isLiveScreenFrozenProvider.notifier).state = !current;
  }

  void handleEscape() {
    // If library pane is unpinned and visible, hide it
    if (ref.read(libraryPinModeProvider) == LibraryPinMode.autoHide &&
        ref.read(libraryPaneVisibleProvider)) {
      ref.read(libraryPaneVisibleProvider.notifier).state = false;
    }
    // If monitor pane is unpinned and visible, hide it
    if (ref.read(monitorPinModeProvider) == MonitorPinMode.autoHide &&
        ref.read(monitorPaneVisibleProvider)) {
      ref.read(monitorPaneVisibleProvider.notifier).state = false;
    }
  }

  void openBibleTab() {
    // Ensure library pane is visible (un-hide if hidden)
    ref.read(libraryPaneVisibleProvider.notifier).state = true;
    ref.read(activeLibraryRailIndexProvider.notifier).state = 1;
    final controller = ref.read(libraryTabControllerProvider);
    controller?.animateTo(1);
    ref.read(bibleSearchFocusNodeProvider).requestFocus();
  }

  void openSongsTab() {
    // Ensure library pane is visible (un-hide if hidden)
    ref.read(libraryPaneVisibleProvider.notifier).state = true;
    ref.read(activeLibraryRailIndexProvider.notifier).state = 0;
    final controller = ref.read(libraryTabControllerProvider);
    controller?.animateTo(0);
    ref.read(songSearchFocusNodeProvider).requestFocus();
  }

  void focusSlides() {
    // If library or monitor panes are unpinned and visible, hide them when focusing slides
    if (ref.read(libraryPinModeProvider) == LibraryPinMode.autoHide &&
        ref.read(libraryPaneVisibleProvider)) {
      ref.read(libraryPaneVisibleProvider.notifier).state = false;
    }
    if (ref.read(monitorPinModeProvider) == MonitorPinMode.autoHide &&
        ref.read(monitorPaneVisibleProvider)) {
      ref.read(monitorPaneVisibleProvider.notifier).state = false;
    }
    
    ref.read(slideListFocusNodeProvider).requestFocus();
  }
}
