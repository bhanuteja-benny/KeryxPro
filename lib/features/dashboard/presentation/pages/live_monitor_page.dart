import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/presentation_settings_provider.dart';
import '../../../settings/presentation/projection_provider.dart';

class LiveMonitorPage extends ConsumerWidget {
  const LiveMonitorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionState = ref.watch(projectionProvider);
    final presetsAsync = ref.watch(presetsListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Monitor 1 (Extended)'),
              Tab(text: 'Monitor 2 (Streaming)'),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildMonitorTab(
              context, 
              ref, 
              1, 
              projectionState.config.monitor1PresetId, 
              projectionState.isMonitor1Active,
              projectionState.displays.length >= 2,
              presetsAsync
            ),
            _buildMonitorTab(
              context, 
              ref, 
              2, 
              projectionState.config.monitor2PresetId, 
              projectionState.isMonitor2Active,
              projectionState.displays.isNotEmpty, // Monitor 2 is now streaming, always available
              presetsAsync
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitorTab(
    BuildContext context, 
    WidgetRef ref, 
    int monitorIndex, 
    int? selectedPresetId, 
    bool isActive,
    bool isConnected,
    AsyncValue<List<dynamic>> presetsAsync
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.monitor : Icons.monitor_weight_outlined,
                color: isConnected ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitor $monitorIndex',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isConnected ? 'Connected' : 'No Monitor Connected',
                    style: TextStyle(color: isConnected ? Colors.green : Colors.red),
                  ),
                ],
              ),
              const Spacer(),
              if (isActive)
                const Chip(
                  label: Text('ACTIVE'),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Select Presentation Preset:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          presetsAsync.when(
            data: (presets) => DropdownButtonFormField<int>(
              value: selectedPresetId ?? presets.firstOrNull?.id,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black12,
              ),
              items: presets.map((p) => DropdownMenuItem<int>(
                value: p.id,
                child: Text(p.presetName),
              )).toList(),
              onChanged: (val) {
                if (monitorIndex == 1) {
                  ref.read(projectionProvider.notifier).updateMonitor1Preset(val);
                } else {
                  ref.read(projectionProvider.notifier).updateMonitor2Preset(val);
                }
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (err, st) => Text('Error loading presets: $err'),
          ),
          const SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 300,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isConnected ? () {
                  if (monitorIndex == 1) {
                    final activeSlideText = ref.read(m1ActiveSlideProvider);
                    final activeTitle = ref.read(activeTitleProvider);
                    final isSong = ref.read(isSongActiveProvider);
                    if (isActive) {
                      ref.read(projectionProvider.notifier).stopMonitor1();
                    } else {
                      ref.read(projectionProvider.notifier).launchMonitor1(
                        text: activeSlideText,
                        title: activeTitle,
                        isSong: isSong,
                      );
                    }
                  } else {
                    final activeSlideText = ref.read(m2ActiveSlideProvider);
                    final activeTitle = ref.read(activeTitleProvider);
                    final isSong = ref.read(isSongActiveProvider);
                    if (isActive) {
                      ref.read(projectionProvider.notifier).stopMonitor2();
                    } else {
                      ref.read(projectionProvider.notifier).launchMonitor2(
                        text: activeSlideText,
                        title: activeTitle,
                        isSong: isSong,
                      );
                    }
                  }
                } : null,
                icon: Icon(isActive ? Icons.stop : Icons.launch),
                label: Text(isActive ? 'STOP OUTPUT' : 'LAUNCH OUTPUT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.red[900] : Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (monitorIndex == 1 && !isConnected)
            const Center(
              child: Text(
                'Please connect an extended monitor to enable Monitor 1 output.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}
