import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../live_projector_providers.dart';
import '../../../songs/presentation/song_selection_providers.dart';
import '../../../settings/presentation/presentation_settings_provider.dart';
import '../../../settings/presentation/projection_provider.dart';
import '../../../settings/data/presentation_settings.dart';
import '../../../presentation/presentation/widgets/projector_view.dart';
import 'monitor_settings_popup.dart';

class LiveProjectorPane extends ConsumerWidget {
  const LiveProjectorPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.grey[850],
            child: const TabBar(
              tabs: [
                Tab(height: 28, child: Text('Monitor 1 (Extended)', style: TextStyle(fontSize: 11))),
                Tab(height: 28, child: Text('Monitor 2 (Streaming)', style: TextStyle(fontSize: 11))),
              ],
              indicatorColor: Colors.blue,
              labelPadding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _Monitor1View(), // Extended
                _Monitor2View(), // Streaming
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Monitor 1: External projector window (Launch button) ───

class _Monitor1View extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionState = ref.watch(projectionProvider);
    final presetsAsync = ref.watch(presetsListProvider);
    final activeSlideText = ref.watch(m1ActiveSlideProvider);
    final activeTitle = ref.watch(activeTitleProvider);
    final isSong = ref.watch(isSongActiveProvider);

    final selectedPresetId = projectionState.config.monitor1PresetId;
    final isConnected = projectionState.hasSecondaryDisplay;
    final isActive = projectionState.isMonitor1Active;

    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Header: Status, Preset dropdown, Launch button
          Row(
            children: [
              InkWell(
                onTap: () => ref.read(projectionProvider.notifier).refreshDisplays(),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConnected ? Icons.circle : Icons.circle_outlined,
                        color: isConnected ? Colors.green : Colors.red,
                        size: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'CONNECTED' : 'NOT CONNECTED',
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 14),
                color: Colors.grey,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Refresh Monitor Status',
                onPressed: () => ref.read(projectionProvider.notifier).refreshDisplays(),
              ),
              const Spacer(),
              Builder(
                builder: (ctx) {
                  return IconButton(
                    icon: const Icon(Icons.settings, size: 18),
                    color: Colors.grey,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Settings',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => MonitorSettingsPopup(
                          monitorIndex: 1,
                          initialPresetId: selectedPresetId,
                        ),
                      );
                    },
                  );
                }
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: isConnected 
                  ? () {
                      if (isActive) {
                        ref.read(projectionProvider.notifier).stopMonitor1();
                      } else {
                        ref.read(projectionProvider.notifier).launchMonitor1(
                          text: activeSlideText,
                          title: activeTitle,
                          isSong: isSong,
                        );
                      }
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.red[900] : Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(80, 28),
                ),
                child: Text(
                  isActive ? 'STOP' : (projectionState.hasLaunchedOnce ? 'RE-LAUNCH' : 'LAUNCH'), 
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Preview Area
          Expanded(
            child: isConnected
              ? Center(
                  child: presetsAsync.when(
                    data: (presets) {
                      final currentId = selectedPresetId ?? presets.firstOrNull?.id;
                      final settings = presets.firstWhere(
                        (p) => p.id == currentId,
                        orElse: () => PresentationSettings(),
                      );
                      final aspectRatio = _getAspectRatio(settings, isSong);

                      return AspectRatio(
                        aspectRatio: aspectRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ProjectorView(
                            settings: settings,
                            activeSlideText: activeSlideText,
                            titleText: activeTitle,
                            isSong: isSong,
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.desktop_access_disabled, size: 48, color: Colors.white24),
                      SizedBox(height: 16),
                      Text('No Monitor Connected', style: TextStyle(color: Colors.white24)),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Monitor 2: Inline projection surface (no popup window) ───

class _Monitor2View extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionState = ref.watch(projectionProvider);
    final presetsAsync = ref.watch(presetsListProvider);
    final activeSlideText = ref.watch(m2ActiveSlideProvider);
    final activeTitle = ref.watch(activeTitleProvider);
    final isSong = ref.watch(isSongActiveProvider);

    final selectedPresetId = projectionState.config.monitor2PresetId;

    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Header: Preset dropdown only (no Launch button)
          Row(
            children: [
              const Icon(Icons.videocam, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              const Text(
                'OBS CAPTURE SURFACE',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Builder(
                builder: (ctx) {
                  return IconButton(
                    icon: const Icon(Icons.settings, size: 18),
                    color: Colors.grey,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Settings',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => MonitorSettingsPopup(
                          monitorIndex: 2,
                          initialPresetId: selectedPresetId,
                        ),
                      );
                    },
                  );
                }
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Projection Surface — this IS the capture region for OBS
          Expanded(
            child: Center(
              child: presetsAsync.when(
                data: (presets) {
                  final currentId = selectedPresetId ?? presets.firstOrNull?.id;
                  final settings = presets.firstWhere(
                    (p) => p.id == currentId,
                    orElse: () => PresentationSettings(),
                  );
                  final aspectRatio = _getAspectRatio(settings, isSong);

                  return AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ProjectorView(
                        settings: settings,
                        activeSlideText: activeSlideText,
                        titleText: activeTitle,
                        isSong: isSong,
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ───

double _getAspectRatio(PresentationSettings settings, bool isSong) {
  final ratio = isSong ? settings.songAspectRatio : settings.scriptureAspectRatio;
  switch (ratio) {
    case '4:3':
      return 4 / 3;
    case '4:1':
      return 4 / 1;
    case 'Custom':
      final w = isSong ? settings.songCustomWidth : settings.scriptureCustomWidth;
      final h = isSong ? settings.songCustomHeight : settings.scriptureCustomHeight;
      return (w > 0 && h > 0) ? w / h : 16 / 9;
    case '16:9':
    default:
      return 16 / 9;
  }
}
