import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../global_ui_providers.dart';

class MonitorBottomBar extends ConsumerWidget {
  const MonitorBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(monitorPaneVisibleProvider);
    final activeIndex = ref.watch(activeMonitorRailIndexProvider);

    return Container(
      height: 28,
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BottomBarIcon(
            index: 1,
            tooltip: 'Monitor 1 (Extended)',
            isActive: isVisible && activeIndex == 0,
            onTap: () => _handleTap(ref, 0),
          ),
          const SizedBox(width: 8),
          _BottomBarIcon(
            index: 2,
            tooltip: 'Monitor 2 (Streaming)',
            isActive: isVisible && activeIndex == 1,
            onTap: () => _handleTap(ref, 1),
          ),
        ],
      ),
    );
  }

  void _handleTap(WidgetRef ref, int tappedIndex) {
    final isVisible = ref.read(monitorPaneVisibleProvider);
    final activeIndex = ref.read(activeMonitorRailIndexProvider);

    if (isVisible && tappedIndex == activeIndex) {
      ref.read(monitorPaneVisibleProvider.notifier).state = false;
    } else if (isVisible && tappedIndex != activeIndex) {
      ref.read(activeMonitorRailIndexProvider.notifier).state = tappedIndex;
      final controller = ref.read(monitorTabControllerProvider);
      controller?.animateTo(tappedIndex);
    } else {
      ref.read(activeMonitorRailIndexProvider.notifier).state = tappedIndex;
      ref.read(monitorPaneVisibleProvider.notifier).state = true;
      final controller = ref.read(monitorTabControllerProvider);
      controller?.animateTo(tappedIndex);
    }
  }
}

class _BottomBarIcon extends StatelessWidget {
  final int index;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomBarIcon({
    required this.index,
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
          width: 36,
          height: 24,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.monitor,
                size: 18,
                color: isActive ? Colors.white : Colors.white38,
              ),
              Positioned(
                top: 5, // Fine-tuned vertical alignment inside monitor icon screen
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
