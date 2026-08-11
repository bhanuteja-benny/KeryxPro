import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/remote/remote_models.dart';
import '../../../core/remote/remote_providers.dart';

class RemoteClientTab extends ConsumerWidget {
  const RemoteClientTab({super.key});

  String _statusLabel(RemoteConnectionState state) {
    switch (state) {
      case RemoteConnectionState.idle:
        return 'Idle';
      case RemoteConnectionState.discovering:
        return 'Discovering';
      case RemoteConnectionState.connecting:
        return 'Connecting';
      case RemoteConnectionState.awaitingApproval:
        return 'Awaiting approval';
      case RemoteConnectionState.connected:
        return 'Connected';
      case RemoteConnectionState.disconnected:
        return 'Disconnected';
      case RemoteConnectionState.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(remoteSettingsProvider);
    final state = ref.watch(remoteConnectionStateProvider);
    final discovered = ref.watch(remoteDiscoveredServersProvider);
    final lastSync = ref.watch(remoteLastSyncProvider);
    final error = ref.watch(remoteErrorProvider);
    final service = ref.read(remoteServiceProvider);

    final isConnected = state == RemoteConnectionState.connected;
    final canConnect = 
        state != RemoteConnectionState.connecting && state != RemoteConnectionState.awaitingApproval;

    if (settings.mode != RemoteMode.client) {
      return Container(
        color: const Color(0xFF1E1E2E),
        alignment: Alignment.center,
        child: const Text(
          'Remote Mode - Client is available only when Remote Mode is set to Client.',
          style: TextStyle(color: Colors.white60, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      color: const Color(0xFF1E1E2E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.black26,
            child: Row(
              children: [
                const Icon(Icons.wifi_tethering, size: 16, color: Colors.lightBlueAccent),
                const SizedBox(width: 6),
                const Text('Remote Mode - Client', style: TextStyle(fontSize: 12, color: Colors.white)),
                const Spacer(),
                Text('Status: ${_statusLabel(state)}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: canConnect
                      ? () async {
                          if (discovered.isNotEmpty) {
                            final target = discovered.first;
                            await service.connectToServer(host: target.host, port: target.port);
                          } else {
                            await service.connectToServer();
                          }
                        }
                      : null,
                  icon: const Icon(Icons.link, size: 14),
                  label: const Text('Connect', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton.icon(
                  onPressed: isConnected || state == RemoteConnectionState.awaitingApproval
                      ? () => service.disconnect()
                      : null,
                  icon: const Icon(Icons.link_off, size: 14),
                  label: const Text('Disconnect', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton.icon(
                  onPressed: isConnected ? () => service.requestFreshSnapshot() : null,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Request Fresh Snapshot', style: TextStyle(fontSize: 11)),
                ),
                Text(
                  lastSync == null
                      ? 'Last sync: -'
                      : 'Last sync: ${lastSync.toLocal().toIso8601String().replaceFirst('T', ' ').substring(0, 19)}',
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          if (error != null && error.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: Text(error, style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
            ),
          const Divider(height: 1, color: Colors.black38),
          Expanded(
            child: discovered.isEmpty
                ? const Center(
                    child: Text(
                      'No servers discovered yet.\nUse manual host in Remote Mode settings if discovery is blocked.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  )
                : ListView.separated(
                    itemCount: discovered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black26),
                    itemBuilder: (context, index) {
                      final server = discovered[index];
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          title: Text(server.machineName, style: const TextStyle(fontSize: 12)),
                          subtitle: Text('${server.host}:${server.port}', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                          trailing: TextButton(
                            onPressed: canConnect
                                ? () => service.connectToServer(host: server.host, port: server.port)
                                : null,
                            child: const Text('Connect', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
