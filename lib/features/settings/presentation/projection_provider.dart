import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'dart:convert';

import '../../../main.dart';
import '../../../core/database/isar_service.dart';
import '../data/projection_config.dart';

class ProjectionState {
  final ProjectionConfig config;
  final List<Display> displays;
  final String? monitor2WindowId;

  ProjectionState({
    required this.config,
    required this.displays,
    this.monitor2WindowId,
  });

  bool get isMonitor2Active => monitor2WindowId != null;
  bool get hasSecondaryDisplay => displays.length >= 2;

  ProjectionState copyWith({
    ProjectionConfig? config,
    List<Display>? displays,
    String? monitor2WindowId,
    bool clearMonitor2 = false,
  }) {
    return ProjectionState(
      config: config ?? this.config,
      displays: displays ?? this.displays,
      monitor2WindowId: clearMonitor2 ? null : (monitor2WindowId ?? this.monitor2WindowId),
    );
  }
}

class ProjectionNotifier extends StateNotifier<ProjectionState> {
  final IsarService _isarService;

  ProjectionNotifier(this._isarService) : super(ProjectionState(config: ProjectionConfig(), displays: [])) {
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

    List<Display> displays = await ScreenRetriever.instance.getAllDisplays();
    state = ProjectionState(config: config, displays: displays);
  }

  Future<void> refreshDisplays() async {
    List<Display> displays = await ScreenRetriever.instance.getAllDisplays();
    state = state.copyWith(displays: displays);
  }

  Future<void> updateMonitor1Preset(int? presetId) async {
    final isar = await _isarService.db;
    final newConfig = _copyConfig(state.config)
      ..monitor1PresetId = presetId;
    
    await isar.writeTxn(() => isar.projectionConfigs.put(newConfig));
    state = state.copyWith(config: newConfig);
    // No window sync needed — Monitor 1 reads state directly via Riverpod
  }

  Future<void> updateMonitor2Preset(int? presetId) async {
    final isar = await _isarService.db;
    final newConfig = _copyConfig(state.config)
      ..monitor2PresetId = presetId;
    
    await isar.writeTxn(() => isar.projectionConfigs.put(newConfig));
    state = state.copyWith(config: newConfig);
    if (state.monitor2WindowId != null) {
      _syncToWindow(state.monitor2WindowId!, presetId);
    }
  }

  Future<void> updateMonitor1Settings(int maxVerses, int maxChars, String format) async {
    final isar = await _isarService.db;
    final newConfig = _copyConfig(state.config)
      ..monitor1MaxVerses = maxVerses
      ..monitor1MaxChars = maxChars
      ..monitor1Format = format;
    
    await isar.writeTxn(() => isar.projectionConfigs.put(newConfig));
    state = state.copyWith(config: newConfig);
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

  Future<void> launchMonitor2() async {
    if (state.displays.length < 2) return;

    final args = {
      'type': 'projector',
      'monitorIndex': 2,
      'presetId': state.config.monitor2PresetId,
    };

    final config = WindowConfiguration(arguments: jsonEncode(args));
    final window = await WindowController.create(config);
    await window.show();
    
    state = state.copyWith(monitor2WindowId: window.windowId);
  }

  void _syncToWindow(String windowId, int? presetId) {
    WindowController.fromWindowId(windowId).invokeMethod('update_preset', {
      'presetId': presetId,
    });
  }
}

final projectionProvider = StateNotifierProvider<ProjectionNotifier, ProjectionState>((ref) {
  return ProjectionNotifier(ref.watch(isarServiceProvider));
});
