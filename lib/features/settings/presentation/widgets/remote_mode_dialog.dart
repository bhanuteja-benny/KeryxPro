import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/remote/remote_models.dart';
import '../../../../core/remote/remote_providers.dart';

class RemoteModeDialog extends ConsumerStatefulWidget {
  const RemoteModeDialog({super.key});

  @override
  ConsumerState<RemoteModeDialog> createState() => _RemoteModeDialogState();
}

class _RemoteModeDialogState extends ConsumerState<RemoteModeDialog> {
  late TextEditingController _machineNameCtrl;
  late TextEditingController _portCtrl;
  late TextEditingController _manualHostCtrl;
  late TextEditingController _imageMaxMbCtrl;
  late RemoteMode _mode;
  late bool _discoveryEnabled;
  late bool _imageByteFallbackEnabled;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(remoteSettingsProvider);
    _machineNameCtrl = TextEditingController(text: settings.machineName);
    _portCtrl = TextEditingController(text: settings.port.toString());
    _manualHostCtrl = TextEditingController(text: settings.manualHost);
    _imageMaxMbCtrl = TextEditingController(
      text: (settings.imageByteFallbackMaxBytes / (1024 * 1024)).toStringAsFixed(1),
    );
    _mode = settings.mode;
    _discoveryEnabled = settings.discoveryEnabled;
    _imageByteFallbackEnabled = settings.imageByteFallbackEnabled;
  }

  @override
  void dispose() {
    _machineNameCtrl.dispose();
    _portCtrl.dispose();
    _manualHostCtrl.dispose();
    _imageMaxMbCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final notifier = ref.read(remoteSettingsProvider.notifier);
    final parsedPort = int.tryParse(_portCtrl.text.trim()) ?? 7689;

    await notifier.updateMachineName(_machineNameCtrl.text);
    await notifier.updatePort(parsedPort);
    await notifier.updateDiscoveryEnabled(_discoveryEnabled);
    await notifier.updateManualHost(_manualHostCtrl.text);
    await notifier.updateImageByteFallbackEnabled(_imageByteFallbackEnabled);
    final mb = double.tryParse(_imageMaxMbCtrl.text.trim()) ?? 5.0;
    final maxBytes = (mb * 1024 * 1024).round();
    await notifier.updateImageByteFallbackMaxBytes(maxBytes);
    await notifier.updateMode(_mode);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Text('Remote Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mode', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<RemoteMode>(
                    value: _mode,
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: RemoteMode.off, child: Text('Off')),
                      DropdownMenuItem(value: RemoteMode.client, child: Text('Client')),
                      DropdownMenuItem(value: RemoteMode.server, child: Text('Server')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _mode = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _machineNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Machine Name',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _portCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      value: _discoveryEnabled,
                      onChanged: (value) => setState(() => _discoveryEnabled = value),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable Device Discovery'),
                      subtitle: const Text('Uses LAN discovery to find Server without typing IP.'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _manualHostCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Manual Host / IP (Fallback)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      value: _imageByteFallbackEnabled,
                      onChanged: (value) => setState(() => _imageByteFallbackEnabled = value),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Optional Image Byte Transfer Fallback'),
                      subtitle: const Text(
                        'Send image bytes inline for new image slides when remote machine cannot resolve media path.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _imageMaxMbCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Image Fallback Max Size (MB)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}