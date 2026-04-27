import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/presentation/projection_broadcaster.dart';
import '../widgets/library_pane.dart';
import '../widgets/preview_pane.dart';
import '../widgets/setlist_pane.dart';
import '../../../live_controller/presentation/widgets/live_projector_pane.dart';
import '../widgets/custom_title_bar.dart';
import '../../../songs/presentation/song_editor_pane.dart';
import '../../../songs/presentation/song_selection_providers.dart';

import 'package:flutter/services.dart';
import '../global_ui_providers.dart';

class MainDashboardPage extends ConsumerStatefulWidget {
  const MainDashboardPage({super.key});

  @override
  ConsumerState<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends ConsumerState<MainDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _libraryTabController;

  @override
  void initState() {
    super.initState();
    _libraryTabController = TabController(length: 2, vsync: this);
    // Give the controller to the provider so other widgets can use it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryTabControllerProvider.notifier).state = _libraryTabController;
    });
  }

  @override
  void dispose() {
    _libraryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize broadcaster
    ref.watch(projectionBroadcasterProvider);
    final isEditorOpen = ref.watch(isSongEditorOpenProvider);
    final shortcuts = ref.read(globalShortcutActionProvider);

    return Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        // Common sense: If we are typing in any text field, ignore shortcuts and let the text through
        final primaryFocus = FocusManager.instance.primaryFocus;
        if (primaryFocus != null) {
          final label = primaryFocus.debugLabel?.toLowerCase() ?? '';
          // Check for editable fields or our specifically labeled search boxes
          if (label.contains('editable') || label.contains('field') || label.contains('search')) {
            return KeyEventResult.ignored;
          }
          
          // Double check the context widget as a backup
          final widget = primaryFocus.context?.widget;
          if (widget is EditableText || widget is TextField) {
            return KeyEventResult.ignored;
          }
        }

        // Not typing? Handle shortcuts
        if (event.logicalKey == LogicalKeyboardKey.keyS) {
          shortcuts.openBibleTab();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.keyQ) {
          shortcuts.openSongsTab();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
          shortcuts.focusSlides();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Pull focus away from search boxes when clicking any empty area
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Column(
            children: [
              // Premium Custom Title Bar (VS Code Style)
              const CustomTitleBar(),
              
              Expanded(
                child: Row(
                  children: [
                    // Left: Library (Songs, Bible, Media) — 40% (Flex 8)
                    const Expanded(
                      flex: 8,
                      child: LibraryPane(),
                    ),
                    const VerticalDivider(width: 1, color: Colors.black),
                    
                    if (isEditorOpen)
                      const Expanded(
                        flex: 12, // 3 + 9 = 12
                        child: SongEditorPane(),
                      )
                    else ...[
                      // Middle: Setlist (Active Queue) — 10% (Flex 3)
                      const Expanded(
                        flex: 3,
                        child: SetlistPane(),
                      ),
                      const VerticalDivider(width: 1, color: Colors.black),
                      
                      // Right: Slides (top) + Live Projection (bottom) — 50% (Flex 9)
                      Expanded(
                        flex: 9,
                        child: Column(
                          children: [
                            // Upper: Slides / Preview
                            const Expanded(
                              flex: 3,
                              child: PreviewPane(),
                            ),
                            const Divider(height: 1, color: Colors.black),
                            // Lower: Live Projection Screens (Monitor 1 & 2 tabs)
                            const Expanded(
                              flex: 2,
                              child: LiveProjectorPane(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
