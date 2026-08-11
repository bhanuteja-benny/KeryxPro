import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../songs/presentation/song_library_tab.dart';
import '../../../bible/presentation/widgets/bible_search_tab.dart';
import '../../../remote/presentation/remote_client_tab.dart';
import '../../../../core/remote/remote_models.dart';
import '../../../../core/remote/remote_providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../global_ui_providers.dart';

class LibraryPane extends ConsumerStatefulWidget {
  const LibraryPane({super.key});

  @override
  ConsumerState<LibraryPane> createState() => _LibraryPaneState();
}

class _LibraryPaneState extends ConsumerState<LibraryPane> {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    // Sync tab changes to the rail index provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller = ref.read(libraryTabControllerProvider);
      _controller?.addListener(_onTabChanged);
    });
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (_controller != null && !_controller!.indexIsChanging) {
      ref.read(activeLibraryRailIndexProvider.notifier).state = _controller!.index;
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabController = ref.watch(libraryTabControllerProvider);
    final pinMode = ref.watch(libraryPinModeProvider);
    final remoteMode = ref.watch(remoteSettingsProvider).mode;

final isPinned = pinMode == LibraryPinMode.pinned;

if (remoteMode == RemoteMode.client) {
  return Column(
    children: [
      SizedBox(
        height: 30,
        child: Container(
          color: Colors.grey[900],
          child: Row(
            children: [
              const Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_tethering, size: 16),
                      SizedBox(width: 4),
                      Text('Remote Mode - Client', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                child: Tooltip(
                  message: isPinned ? 'Unpin (Auto Hide)' : 'Pin',
                  waitDuration: const Duration(milliseconds: 500),
                  child: InkWell(
                    onTap: () {
                      if (isPinned) {
                        ref.read(libraryPinModeProvider.notifier).state = LibraryPinMode.autoHide;
                        ref.read(libraryPaneVisibleProvider.notifier).state = false;
                      } else {
                        ref.read(libraryPinModeProvider.notifier).state = LibraryPinMode.pinned;
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Center(
                      child: isPinned
                          ? const Icon(Icons.push_pin, size: 14, color: Colors.grey)
                          : Transform.rotate(
                              angle: math.pi / 4,
                              child: const Icon(Icons.push_pin_outlined, size: 14, color: Colors.grey),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const Expanded(child: RemoteClientTab()),
    ],
  );
}

    if (tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Container(
            color: Colors.grey[900], // Darker background for tab bar
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: tabController,
                    indicatorColor: Colors.deepPurpleAccent,
                    tabs: const [
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.library_music, size: 16), SizedBox(width: 4), Text('Songs', style: TextStyle(fontSize: 11))])),
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.menu_book, size: 16), SizedBox(width: 4), Text('Bible', style: TextStyle(fontSize: 11))])),
                    ],
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Tooltip(
                    message: isPinned ? 'Unpin (Auto Hide)' : 'Pin',
                    waitDuration: const Duration(milliseconds: 500),
                    child: InkWell(
                      onTap: () {
                        if (isPinned) {
                          // Switch to auto-hide mode and hide pane
                          ref.read(libraryPinModeProvider.notifier).state = LibraryPinMode.autoHide;
                          ref.read(libraryPaneVisibleProvider.notifier).state = false;
                        } else {
                          // Switch back to pinned mode (pane stays visible)
                          ref.read(libraryPinModeProvider.notifier).state = LibraryPinMode.pinned;
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Center(
                        child: isPinned
                            ? const Icon(Icons.push_pin, size: 14, color: Colors.grey)
                            : Transform.rotate(
                                angle: math.pi / 4,
                                child: const Icon(Icons.push_pin_outlined, size: 14, color: Colors.grey),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.grey[850],
            child: TabBarView(
              controller: tabController,
              children: const [
                SongLibraryTab(),
                BibleSearchTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
