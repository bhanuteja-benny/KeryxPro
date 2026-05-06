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

class ProjectionState {
  final ProjectionConfig config;
  final List<Display> displays;
  final String? monitor1WindowId; // Monitor 1 is now Extended
  final bool hasLaunchedOnce;

  ProjectionState({
    required this.config,
    required this.displays,
    this.monitor1WindowId,
    this.hasLaunchedOnce = false,
  });

  bool get isMonitor1Active => monitor1WindowId != null;
  bool get isMonitor2Active => false; // Streaming is always "active" in a sense, but no window
  bool get hasSecondaryDisplay => displays.length >= 2;

  ProjectionState copyWith({
    ProjectionConfig? config,
    List<Display>? displays,
    String? monitor1WindowId,
    bool clearMonitor1 = false,
    bool? hasLaunchedOnce,
  }) {
    return ProjectionState(
      config: config ?? this.config,
      displays: displays ?? this.displays,
      monitor1WindowId: clearMonitor1 ? null : (monitor1WindowId ?? this.monitor1WindowId),
      hasLaunchedOnce: hasLaunchedOnce ?? this.hasLaunchedOnce,
    );
  }
}

class ProjectionNotifier extends StateNotifier<ProjectionState> with ScreenListener {
  final IsarService _isarService;

  ProjectionNotifier(this._isarService) : super(
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
          }
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

    // Now ask the native side (running in the main window's context)
    // to find the sub-window and move it to the secondary display.
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
        await channel.invokeMethod('close_subwindow');
      } catch (e) {
        print("Error closing sub-window natively: $e");
        // Fallback to old method just in case
        await WindowController.fromWindowId(state.monitor1WindowId!).invokeMethod('close_window');
      }
      state = state.copyWith(clearMonitor1: true);
    }
  }

  void _syncToWindow(String windowId, PresentationSettings? settings) {
    WindowController.fromWindowId(windowId).invokeMethod('update_preset', {
      'presetId': settings?.id,
      'settings': settings?.toMap(),
    });
  }
}

final projectionProvider = StateNotifierProvider<ProjectionNotifier, ProjectionState>((ref) {
  return ProjectionNotifier(ref.watch(isarServiceProvider));
});
