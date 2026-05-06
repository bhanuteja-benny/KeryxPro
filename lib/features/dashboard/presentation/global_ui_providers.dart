import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tab Controller for Library (Songs vs Bible)
final libraryTabControllerProvider = StateProvider<TabController?>((ref) => null);

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
    ref.read(slideListFocusNodeProvider).requestFocus();
  }
}
