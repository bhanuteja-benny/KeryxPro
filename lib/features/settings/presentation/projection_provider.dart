import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../../core/database/isar_service.dart';
import '../data/projection_config.dart';
import '../data/presentation_settings.dart';

import '../../live_controller/presentation/live_projector_providers.dart';

class ProjectionState {
  final ProjectionConfig config;
  final List<Display> displays;
  final String? monitor1WindowId; // Monitor 1 is now Extended
  final String? monitor2WindowId; // Monitor 2 is now Streaming/OBS
  final bool hasLaunchedOnce;

  ProjectionState({
    required this.config,
    required this.displays,
    this.monitor1WindowId,
    this.monitor2WindowId,
    this.hasLaunchedOnce = false,
  });

  bool get isMonitor1Active => monitor1WindowId != null;
  bool get isMonitor2Active => monitor2WindowId != null;
  bool get hasSecondaryDisplay => displays.length >= 2;

  ProjectionState copyWith({
    ProjectionConfig? config,
    List<Display>? displays,
    String? monitor1WindowId,
    String? monitor2WindowId,
    bool clearMonitor1 = false,
    bool clearMonitor2 = false,
    bool? hasLaunchedOnce,
  }) {
    return ProjectionState(
      config: config ?? this.config,
      displays: displays ?? this.displays,
      monitor1WindowId: clearMonitor1 ? null : (monitor1WindowId ?? this.monitor1WindowId),
      monitor2WindowId: clearMonitor2 ? null : (monitor2WindowId ?? this.monitor2WindowId),
      hasLaunchedOnce: hasLaunchedOnce ?? this.hasLaunchedOnce,
    );
  }
}

class ProjectionNotifier extends StateNotifier<ProjectionState> with ScreenListener {
  final IsarService _isarService;
  final Ref _ref;

  ProjectionNotifier(this._isarService, this._ref) : super(
    ProjectionState(
      config: ProjectionConfig()..id = ProjectionConfig.singletonId, 
      displays: []
    )
  ) {
    _init();
  }

  Future<void> _init() async {
    final isar = await _isarService.db;
    
    ProjectionConfig? config = await isar.projectionConfigs.get(ProjectionConfig.singletonId);
    if (config == null) {
      config = ProjectionConfig()..id = ProjectionConfig.singletonId;
      await isar.writeTxn(() => isar.projectionConfigs.put(config!));
    } else {
      // Handle Isar minInt for newly added fields on existing records
      bool needsUpdate = false;
      if (config.monitor1MaxVerses < 1) { config.monitor1MaxVerses = 1; needsUpdate = true; }
      if (config.monitor2MaxVerses < 1) { config.monitor2MaxVerses = 1; needsUpdate = true; }
      if (config.monitor1MaxChars < 0) { config.monitor1MaxChars = 0; needsUpdate = true; }
      if (config.monitor2MaxChars < 0) { config.monitor2MaxChars = 0; needsUpdate = true; }
      if (config.monitor1Format != 'Verse' && config.monitor1Format != 'Paragraph') { config.monitor1Format = 'Verse'; needsUpdate = true; }
      if (config.monitor2Format != 'Verse' && config.monitor2Format != 'Paragraph') { config.monitor2Format = 'Verse'; needsUpdate = true; }
      
      if (needsUpdate) {
        await isar.writeTxn(() => isar.projectionConfigs.put(config!));
      }
    }

    ScreenRetriever.instance.addListener(this);
    List<Display> displays = await ScreenRetriever.instance.getAllDisplays();
    state = ProjectionState(config: config, displays: displays);

    // Listen for messages from sub-windows (like manual closure)
    WindowController.fromCurrentEngine().then((controller) {
      controller.setWindowMethodHandler((call) async {
        if (call.method == 'window_closed') {
          final closedId = call.arguments.toString();
          if (state.monitor1WindowId == closedId) {
            state = state.copyWith(clearMonitor1: true, hasLaunchedOnce: true);
          } else if (state.monitor2WindowId == closedId) {
            state = state.copyWith(clearMonitor2: true);
          }
        } else if (call.method == 'close_monitor2') {
          await stopMonitor2();
        } else if (call.method == 'minimize_monitor2') {
          await minimizeMonitor2Window();
        }
        return null;
      });
    });
  }

  Future<void> refreshDisplays() async {
    List<Display> displays = await ScreenRetriever.instance.getAllDisplays();
    state = state.copyWith(displays: displays);
  }

  @override
  void onDisplayAdded(Display display) {
    refreshDisplays();
  }

  @override
  void onDisplayRemoved(Display display) {
    refreshDisplays();
  }

  @override
  void dispose() {
    ScreenRetriever.instance.removeListener(this);
    super.dispose();
  }

  Future<void> updateMonitor1Preset(int? presetId) async {
    await updateMonitorConfig(monitorIndex: 1, presetId: presetId, updatePreset: true);
  }

  Future<void> updateMonitor2Preset(int? presetId) async {
    await updateMonitorConfig(monitorIndex: 2, presetId: presetId, updatePreset: true);
  }

  Future<void> updateMonitor1Settings(int maxVerses, int maxChars, String format) async {
    await updateMonitorConfig(
      monitorIndex: 1, 
      maxVerses: maxVerses, 
      maxChars: maxChars, 
      format: format
    );
  }

  Future<void> updateMonitor2Settings(int maxVerses, int maxChars, String format) async {
    await updateMonitorConfig(
      monitorIndex: 2, 
      maxVerses: maxVerses, 
      maxChars: maxChars, 
      format: format
    );
  }

  Future<void> updateMonitorConfig({
    required int monitorIndex,
    int? presetId,
    bool updatePreset = false,
    int? maxVerses,
    int? maxChars,
    String? format,
  }) async {
    final isar = await _isarService.db;
    
    // Always use the latest state and ensure singleton ID
    final newConfig = _copyConfig(state.config)..id = ProjectionConfig.singletonId;
    
    if (monitorIndex == 1) {
      if (updatePreset) newConfig.monitor1PresetId = presetId;
      if (maxVerses != null) newConfig.monitor1MaxVerses = maxVerses;
      if (maxChars != null) newConfig.monitor1MaxChars = maxChars;
      if (format != null) newConfig.monitor1Format = format;
    } else {
      if (updatePreset) newConfig.monitor2PresetId = presetId;
      if (maxVerses != null) newConfig.monitor2MaxVerses = maxVerses;
      if (maxChars != null) newConfig.monitor2MaxChars = maxChars;
      if (format != null) newConfig.monitor2Format = format;
    }

    await isar.writeTxn(() => isar.projectionConfigs.put(newConfig));
    state = state.copyWith(config: newConfig);

    if (monitorIndex == 1 && state.monitor1WindowId != null) {
      final actualPresetId = newConfig.monitor1PresetId;
      final preset = actualPresetId != null 
          ? await isar.presentationSettings.get(actualPresetId)
          : null;
      _syncToWindow(state.monitor1WindowId!, preset);
    } else if (monitorIndex == 2 && state.monitor2WindowId != null) {
      final actualPresetId = newConfig.monitor2PresetId;
      final preset = actualPresetId != null 
          ? await isar.presentationSettings.get(actualPresetId)
          : null;
      _syncToWindow(state.monitor2WindowId!, preset);
    }
  }

  ProjectionConfig _copyConfig(ProjectionConfig old) {
    return ProjectionConfig()
      ..id = old.id
      ..monitor1PresetId = old.monitor1PresetId
      ..monitor2PresetId = old.monitor2PresetId
      ..monitor1MaxVerses = old.monitor1MaxVerses
      ..monitor1MaxChars = old.monitor1MaxChars
      ..monitor1Format = old.monitor1Format
      ..monitor2MaxVerses = old.monitor2MaxVerses
      ..monitor2MaxChars = old.monitor2MaxChars
      ..monitor2Format = old.monitor2Format;
  }

  Size _getWindowSize(PresentationSettings? settings, bool isSong) {
    if (settings == null) return const Size(1280, 720);
    final ratio = isSong ? settings.songAspectRatio : settings.scriptureAspectRatio;
    switch (ratio) {
      case '4:3':
        return const Size(960, 720);
      case '4:1':
        return const Size(1200, 300);
      case 'Custom':
        final w = isSong ? settings.songCustomWidth : settings.scriptureCustomWidth;
        final h = isSong ? settings.songCustomHeight : settings.scriptureCustomHeight;
        return (w > 0 && h > 0) ? Size(w.toDouble(), h.toDouble()) : const Size(1280, 720);
      case '16:9':
      default:
        return const Size(1280, 720);
    }
  }

  Future<void> _configureSubwindowNatively({
    required int monitorIndex,
    required double x,
    required double y,
    required double w,
    required double h,
    required String title,
    bool noMove = false,
  }) async {
    try {
      const channel = MethodChannel('keryx/window');
      await channel.invokeMethod('configure_subwindow', {
        'monitorIndex': monitorIndex,
        'x': x,
        'y': y,
        'w': w,
        'h': h,
        'title': title,
        'noMove': noMove,
      });
    } catch (e) {
      print("Error configuring sub-window natively: $e");
    }
  }

  Future<void> launchMonitor2({
    String? text,
    String? title,
    bool isSong = true,
  }) async {
    final isar = await _isarService.db;
    final presetId = state.config.monitor2PresetId;
    final preset = presetId != null 
        ? await isar.presentationSettings.get(presetId)
        : null;

    final args = {
      'type': 'projector',
      'monitorIndex': 2,
      'presetId': presetId,
      'settings': preset?.toMap(),
      'text': text,
      'title': title,
      'isSong': isSong,
    };

    final config = WindowConfiguration(arguments: jsonEncode(args));
    final window = await WindowController.create(config);
    
    await window.show();

    // Wait for window creation, then rename + resize it natively.
    // desktop_multi_window creates windows with empty title; the native
    // side finds the unnamed window and renames it.
    await Future.delayed(const Duration(milliseconds: 300));
    final size = _getWindowSize(preset, isSong);
    await _configureSubwindowNatively(
      monitorIndex: 2,
      x: 100.0,
      y: 100.0,
      w: size.width,
      h: size.height,
      title: 'KeryxPro Monitor 2',
    );

    // Refocus main window
    try {
      const channel = MethodChannel('keryx/window');
      await channel.invokeMethod('refocus_main_window');
    } catch (e) {
      print("Error refocusing main window: $e");
    }

    state = state.copyWith(
      monitor2WindowId: window.windowId,
    );
  }

  Future<void> resizeMonitor2Window(bool isSong) async {
    if (state.monitor2WindowId == null) return;

    final isar = await _isarService.db;
    final presetId = state.config.monitor2PresetId;
    final preset = presetId != null 
        ? await isar.presentationSettings.get(presetId)
        : null;

    final size = _getWindowSize(preset, isSong);
    await _configureSubwindowNatively(
      monitorIndex: 2,
      x: 100.0,
      y: 100.0,
      w: size.width,
      h: size.height,
      title: 'KeryxPro Monitor 2',
      noMove: true,
    );
  }

  Future<void> stopMonitor2() async {
    if (state.monitor2WindowId != null) {
      try {
        const channel = MethodChannel('keryx/window');
        await channel.invokeMethod('close_subwindow', {
          'title': 'KeryxPro Monitor 2',
        });
      } catch (e) {
        print("Error closing Monitor 2 window natively: $e");
      }
      state = state.copyWith(clearMonitor2: true);
    }
  }

  Future<void> minimizeMonitor2Window() async {
    if (state.monitor2WindowId == null) return;
    try {
      const channel = MethodChannel('keryx/window');
      await channel.invokeMethod('minimize_subwindow', {
        'title': 'KeryxPro Monitor 2',
      });
    } catch (e) {
      print("Error minimizing Monitor 2 window: $e");
    }
  }

  Future<void> launchMonitor1({
    String? text,
    String? title,
    bool isSong = true,
  }) async {
    await refreshDisplays();
    if (state.displays.length < 2) {
      print("monitor does not exists");
      return;
    }

    final isar = await _isarService.db;
    final presetId = state.config.monitor1PresetId;
    final preset = presetId != null 
        ? await isar.presentationSettings.get(presetId)
        : null;

    final secondaryDisplay = state.displays[1];
    final displayX = secondaryDisplay.visiblePosition?.dx ?? secondaryDisplay.size.width;
    final displayY = secondaryDisplay.visiblePosition?.dy ?? 0.0;
    final displayW = secondaryDisplay.size.width;
    final displayH = secondaryDisplay.size.height;

    final args = {
      'type': 'projector',
      'monitorIndex': 1,
      'presetId': presetId,
      'settings': preset?.toMap(),
      'text': text,
      'title': title,
      'isSong': isSong,
      'displayX': displayX,
      'displayY': displayY,
      'displayW': displayW,
      'displayH': displayH,
    };

    final config = WindowConfiguration(arguments: jsonEncode(args));
    final window = await WindowController.create(config);
    
    // Show the window initially.
    await window.show();
    
    // Refocus main window immediately to prevent focus theft by the new window
    try {
      const channel = MethodChannel('keryx/window');
      await channel.invokeMethod('refocus_main_window');
    } catch (e) {
      print("Error refocusing main window: $e");
    }

    // The native side finds the unnamed sub-window (empty title) and
    // moves it full-screen to the secondary display.
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      const channel = MethodChannel('keryx/window');
      await channel.invokeMethod('move_subwindow_to_display', {
        'x': displayX.toInt(),
        'y': displayY.toInt(),
        'w': displayW.toInt(),
        'h': displayH.toInt(),
      });
    } catch (e) {
      print("Error moving sub-window: $e");
    }

    state = state.copyWith(
      monitor1WindowId: window.windowId,
      hasLaunchedOnce: true,
    );
  }

  Future<void> stopMonitor1() async {
    if (state.monitor1WindowId != null) {
      try {
        const channel = MethodChannel('keryx/window');
        await channel.invokeMethod('close_subwindow', {
          'title': 'KeryxPro Monitor 1',
        });
      } catch (e) {
        print("Error closing Monitor 1 window natively: $e");
      }
      state = state.copyWith(clearMonitor1: true);
    }
  }

  void _syncToWindow(String windowId, PresentationSettings? settings) {
    WindowController.fromWindowId(windowId).invokeMethod('update_preset', {
      'presetId': settings?.id,
      'settings': settings?.toMap(),
    }).catchError((e, stack) {
      print('[KeryxPro-v2] Error syncing preset to window $windowId (async): $e\n$stack');
    });
  }
}

final projectionProvider = StateNotifierProvider<ProjectionNotifier, ProjectionState>((ref) {
  return ProjectionNotifier(ref.watch(isarServiceProvider), ref);
});
