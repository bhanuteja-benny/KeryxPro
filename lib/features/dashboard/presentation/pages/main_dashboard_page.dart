import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/presentation/projection_broadcaster.dart';
import '../widgets/library_pane.dart';
import '../widgets/library_icon_rail.dart';
import '../widgets/preview_pane.dart';
import '../widgets/setlist_pane.dart';
import '../widgets/monitor_bottom_bar.dart';
import '../../../live_controller/presentation/widgets/live_projector_pane.dart';
import '../widgets/custom_title_bar.dart';
import '../../../songs/presentation/song_editor_pane.dart';
import '../../../songs/presentation/song_selection_providers.dart';
import '../../../settings/data/presentation_settings.dart';
import '../../../presentation/presentation/widgets/projector_view.dart';
import '../../../live_controller/domain/slide.dart';
import '../../../live_controller/presentation/live_projector_providers.dart';
import '../../../settings/presentation/presentation_settings_provider.dart';
import '../../../../core/sync/media_sync_manager.dart';
import '../../../settings/presentation/projection_provider.dart';

import 'package:flutter/services.dart';
import '../global_ui_providers.dart';

class MainDashboardPage extends ConsumerStatefulWidget {
  const MainDashboardPage({super.key});

  @override
  ConsumerState<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends ConsumerState<MainDashboardPage> with TickerProviderStateMixin {
  late TabController _libraryTabController;
  late TabController _monitorTabController;

  @override
  void initState() {
    super.initState();
    _libraryTabController = TabController(length: 2, vsync: this);
    _monitorTabController = TabController(length: 2, vsync: this);
    // Give the controllers to the providers so other widgets can use them
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryTabControllerProvider.notifier).state = _libraryTabController;
      ref.read(monitorTabControllerProvider.notifier).state = _monitorTabController;
    });
    HardwareKeyboard.instance.addHandler(_handleGlobalKeys);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeys);
    _libraryTabController.dispose();
    _monitorTabController.dispose();
    super.dispose();
  }

  bool _handleGlobalKeys(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // Common sense: If we are typing in any text field, ignore shortcuts and let the text through
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null && primaryFocus.context != null) {
      final context = primaryFocus.context!;
      
      // Robustly check if the focused widget is or is inside a text input field
      bool isTextInput = context.widget is EditableText || 
                         context.widget is TextField ||
                         context.findAncestorWidgetOfExactType<EditableText>() != null ||
                         context.findAncestorWidgetOfExactType<TextField>() != null;
                         
      if (isTextInput) return false;

      // Fallback label checks
      final label = primaryFocus.debugLabel?.toLowerCase() ?? '';
      if (label.contains('editable') || label.contains('field') || label.contains('search') || label.contains('setlistname') || label.contains('title') || label.contains('author') || label.contains('lyrics') || label.contains('preset')) {
        return false;
      }
    }

    final shortcuts = ref.read(globalShortcutActionProvider);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyS) {
      shortcuts.openBibleTab();
      return true;
    } else if (key == LogicalKeyboardKey.keyQ) {
      shortcuts.openSongsTab();
      return true;
    } else if (key == LogicalKeyboardKey.keyL) {
      shortcuts.focusSlides();
      return true;
    } else if (key == LogicalKeyboardKey.keyF) {
      shortcuts.toggleFreeze();
      return true;
    } else if (key == LogicalKeyboardKey.escape) {
      shortcuts.handleEscape();
      return true; // We can return true so it consumes the event
    }

    return false;
  }

  void _precachePresetBackgrounds(BuildContext context, PresentationSettings preset, MediaSyncManager mediaSync) {
    // 1. Blank background
    if (preset.isBlankImageEnabled && preset.blankBackgroundImage.isNotEmpty) {
      final path = mediaSync.resolveMediaPath(preset.blankBackgroundImage);
      if (path.isNotEmpty && File(path).existsSync()) {
        final size = ProjectorView.getCanvasSize(preset, isSong: false, isBlank: true);
        precacheImage(
          ProjectorView.getImageProvider(path: path, canvasWidth: size.width, canvasHeight: size.height),
          context,
        );
      }
    }

    // 2. Song background
    if (preset.isSongImageEnabled && preset.songBackgroundImage.isNotEmpty) {
      final path = mediaSync.resolveMediaPath(preset.songBackgroundImage);
      if (path.isNotEmpty && File(path).existsSync()) {
        final size = ProjectorView.getCanvasSize(preset, isSong: true, isBlank: false);
        precacheImage(
          ProjectorView.getImageProvider(path: path, canvasWidth: size.width, canvasHeight: size.height),
          context,
        );
      }
    }

    // 3. Scripture background
    if (preset.isScriptureImageEnabled && preset.scriptureBackgroundImage.isNotEmpty) {
      final path = mediaSync.resolveMediaPath(preset.scriptureBackgroundImage);
      if (path.isNotEmpty && File(path).existsSync()) {
        final size = ProjectorView.getCanvasSize(preset, isSong: false, isBlank: false);
        precacheImage(
          ProjectorView.getImageProvider(path: path, canvasWidth: size.width, canvasHeight: size.height),
          context,
        );
      }
    }
  }

  void _precacheSlideImages(BuildContext context, List<Slide> slides, MediaSyncManager mediaSync) {
    // Extract active presets for Monitor 1 and Monitor 2
    final projectionState = ref.read(projectionProvider);
    final presetsAsync = ref.read(presetsListProvider);
    final presets = presetsAsync.value ?? [];

    final m1PresetId = projectionState.config.monitor1PresetId;
    final m2PresetId = projectionState.config.monitor2PresetId;

    final m1Preset = presets.firstWhere((p) => p.id == m1PresetId, orElse: () => presets.firstOrNull ?? PresentationSettings());
    final m2Preset = presets.firstWhere((p) => p.id == m2PresetId, orElse: () => presets.firstOrNull ?? PresentationSettings());

    final m1Size = ProjectorView.getCanvasSize(m1Preset, isSong: false, isBlank: false);
    final m2Size = ProjectorView.getCanvasSize(m2Preset, isSong: false, isBlank: false);

    for (final slide in slides) {
      if (slide.content.startsWith('IMAGE:')) {
        final rest = slide.content.substring(6);
        final parts = rest.split('|');
        final rawPath = parts[0];
        final path = mediaSync.resolveMediaPath(rawPath);

        if (path.isNotEmpty && File(path).existsSync()) {
          // Precache for Monitor 1 canvas size
          precacheImage(
            ProjectorView.getImageProvider(path: path, canvasWidth: m1Size.width, canvasHeight: m1Size.height),
            context,
          );
          // Precache for Monitor 2 canvas size
          precacheImage(
            ProjectorView.getImageProvider(path: path, canvasWidth: m2Size.width, canvasHeight: m2Size.height),
            context,
          );
        }
      }
    }
  }

  void _setupPrecaching(BuildContext context) {
    final mediaSync = ref.watch(mediaSyncManagerProvider);

    // 1. Listen to presets changes to precache background images
    ref.listen<AsyncValue<List<PresentationSettings>>>(
      presetsListProvider,
      (previous, next) {
        next.whenData((presets) {
          for (final preset in presets) {
            _precachePresetBackgrounds(context, preset, mediaSync);
          }
        });
      },
    );

    // 2. Listen to slides changes to precache slide images
    ref.listen<List<Slide>>(
      currentSlidesProvider,
      (previous, next) {
        _precacheSlideImages(context, next, mediaSync);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _setupPrecaching(context);

    // Initial precaching after the first frame and subsequent changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final mediaSync = ref.read(mediaSyncManagerProvider);
      ref.read(presetsListProvider).whenData((presets) {
        for (final preset in presets) {
          _precachePresetBackgrounds(context, preset, mediaSync);
        }
      });
      _precacheSlideImages(context, ref.read(currentSlidesProvider), mediaSync);
    });

    // Initialize broadcaster
    ref.watch(projectionBroadcasterProvider);
    final isEditorOpen = ref.watch(isSongEditorOpenProvider);
    final shortcuts = ref.read(globalShortcutActionProvider);

    // Library pane auto-hide state
    final pinMode = ref.watch(libraryPinModeProvider);
    final isLibraryVisible = ref.watch(libraryPaneVisibleProvider);
    final isDockedVisible = pinMode == LibraryPinMode.pinned && isLibraryVisible;
    final isOverlayVisible = pinMode == LibraryPinMode.autoHide && isLibraryVisible;

    // Monitor pane auto-hide state
    final monitorPinMode = ref.watch(monitorPinModeProvider);
    final isMonitorVisible = ref.watch(monitorPaneVisibleProvider);
    final isMonitorDockedVisible = monitorPinMode == MonitorPinMode.pinned && isMonitorVisible;
    final isMonitorOverlayVisible = monitorPinMode == MonitorPinMode.autoHide && isMonitorVisible;

    return Scaffold(
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
                child: Stack(
                  children: [
                    // ─── Base Layout Row ───
                    Row(
                      children: [
                        // Always-visible icon rail
                        const LibraryIconRail(),
                        const VerticalDivider(width: 1, color: Colors.black),

                        // Library pane (docked) — only when pinned + visible
                        if (isDockedVisible) ...[
                          const Expanded(
                            flex: 3,
                            child: LibraryPane(),
                          ),
                          const VerticalDivider(width: 1, color: Colors.black),
                        ],
                        
                        if (isEditorOpen)
                          const Expanded(
                            flex: 7, 
                            child: SongEditorPane(),
                          )
                        else ...[
                          // Middle: Setlist (Active Queue)
                          const Expanded(
                            flex: 2,
                            child: SetlistPane(),
                          ),
                          const VerticalDivider(width: 1, color: Colors.black),
                          
                          // Right: Slides (top) + Live Projection (bottom) + Bottom Bar
                          Expanded(
                            flex: 5,
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    // Upper: Slides / Preview
                                    const Expanded(
                                      child: PreviewPane(),
                                    ),
                                    if (isMonitorDockedVisible) ...[
                                      const Divider(height: 1, color: Colors.black),
                                      // Lower: Live Projection Screens (Monitor 1 & 2 tabs)
                                      const SizedBox(
                                        height: 250,
                                        child: LiveProjectorPane(),
                                      ),
                                    ],
                                    const Divider(height: 1, color: Colors.black),
                                    // Bottom Navigation Bar
                                    const MonitorBottomBar(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    // ─── Auto-hide overlays ───
                    if (isOverlayVisible) ...[
                      // Dismiss barrier — tapping outside closes the overlay
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            ref.read(libraryPaneVisibleProvider.notifier).state = false;
                          },
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      // Overlay Library pane
                      Positioned(
                        left: 33, // icon rail (32) + divider (1)
                        top: 0,
                        bottom: 0,
                        width: math.max(400.0, MediaQuery.of(context).size.width * 0.35),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(2, 0),
                              ),
                            ],
                          ),
                          child: const LibraryPane(),
                        ),
                      ),
                    ],

                    if (isMonitorOverlayVisible && !isEditorOpen) ...[
                      // Dismiss barrier — tapping outside closes the overlay
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            ref.read(monitorPaneVisibleProvider.notifier).state = false;
                          },
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      // Overlay Monitor pane positioned exactly over the right column
                      Positioned.fill(
                        child: Row(
                          children: [
                            const IgnorePointer(child: SizedBox(width: 33)), // rail (32) + divider (1)
                            if (isDockedVisible) ...[
                              const Expanded(flex: 3, child: IgnorePointer(child: SizedBox.shrink())),
                              const IgnorePointer(child: SizedBox(width: 1)),
                            ],
                            const Expanded(flex: 2, child: IgnorePointer(child: SizedBox.shrink())),
                            const IgnorePointer(child: SizedBox(width: 1)),
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 29, // above bottom bar (28) + divider (1)
                                    height: 250,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, -2),
                                          ),
                                        ],
                                      ),
                                      child: const LiveProjectorPane(),
                                    ),
                                  ),
                                ],
                              ),
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
      );
  }
}

