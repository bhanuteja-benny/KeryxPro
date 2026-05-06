import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../global_ui_providers.dart';

/// A slim vertical icon rail on the far left of the app.
/// Always visible. Contains Songs and Bible icons that toggle the Library pane.
class LibraryIconRail extends ConsumerWidget {
  const LibraryIconRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(libraryPaneVisibleProvider);
    final activeIndex = ref.watch(activeLibraryRailIndexProvider);

    return Container(
      width: 32,
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _RailIcon(
            icon: Icons.library_music,
            tooltip: 'Songs (Q)',
            isActive: isVisible && activeIndex == 0,
            onTap: () => _handleTap(ref, 0),
          ),
          const SizedBox(height: 4),
          _RailIcon(
            icon: Icons.menu_book,
            tooltip: 'Bible (S)',
            isActive: isVisible && activeIndex == 1,
            onTap: () => _handleTap(ref, 1),
          ),
        ],
      ),
    );
  }

  void _handleTap(WidgetRef ref, int tappedIndex) {
    final isVisible = ref.read(libraryPaneVisibleProvider);
    final activeIndex = ref.read(activeLibraryRailIndexProvider);

    if (isVisible && tappedIndex == activeIndex) {
      // Same tab tapped while visible → hide
      ref.read(libraryPaneVisibleProvider.notifier).state = false;
    } else if (isVisible && tappedIndex != activeIndex) {
      // Different tab tapped while visible → switch tab
      ref.read(activeLibraryRailIndexProvider.notifier).state = tappedIndex;
      final controller = ref.read(libraryTabControllerProvider);
      controller?.animateTo(tappedIndex);
    } else {
      // Pane is hidden → show it on the tapped tab
      ref.read(activeLibraryRailIndexProvider.notifier).state = tappedIndex;
      ref.read(libraryPaneVisibleProvider.notifier).state = true;
      final controller = ref.read(libraryTabControllerProvider);
      controller?.animateTo(tappedIndex);
    }
  }
}

class _RailIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _RailIcon({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 28,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isActive ? Colors.deepPurpleAccent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}
