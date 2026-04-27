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
    final controller = ref.read(libraryTabControllerProvider);
    controller?.animateTo(1);
    ref.read(bibleSearchFocusNodeProvider).requestFocus();
  }

  void openSongsTab() {
    final controller = ref.read(libraryTabControllerProvider);
    controller?.animateTo(0);
    ref.read(songSearchFocusNodeProvider).requestFocus();
  }

  void focusSlides() {
    ref.read(slideListFocusNodeProvider).requestFocus();
  }
}
