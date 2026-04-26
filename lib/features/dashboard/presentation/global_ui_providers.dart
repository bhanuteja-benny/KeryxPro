import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tab Controller for Library (Songs vs Bible)
final libraryTabControllerProvider = StateProvider<TabController?>((ref) => null);

// Focus Nodes for various sections
final songSearchFocusNodeProvider = Provider((ref) => FocusNode());
final bibleSearchFocusNodeProvider = Provider((ref) => FocusNode());
final bibleVerseListFocusNodeProvider = Provider((ref) => FocusNode());
final slideListFocusNodeProvider = Provider((ref) => FocusNode());

// Shared Scroll Controllers for cross-pane interaction
final slideListScrollControllerProvider = Provider((ref) => ScrollController());

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
