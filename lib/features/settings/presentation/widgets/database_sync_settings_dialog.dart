import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/sync/sync_service.dart';

class DatabaseSyncSettingsDialog extends ConsumerStatefulWidget {
  const DatabaseSyncSettingsDialog({super.key});

  @override
  ConsumerState<DatabaseSyncSettingsDialog> createState() => _DatabaseSyncSettingsDialogState();
}

class _DatabaseSyncSettingsDialogState extends ConsumerState<DatabaseSyncSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(syncConfigProvider);

    return AlertDialog(
      title: const Text('Data Sync'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sync your data across multiple machines using a shared Dropbox or OneDrive folder.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Enable Sync'),
              value: config.syncEnabled,
              onChanged: (val) {
                config.setSyncEnabled(val);
                setState(() {}); // refresh dialog
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            const Text('Sync Folder Path', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      config.syncFolderPath ?? 'No folder selected',
                      style: TextStyle(
                        color: config.syncFolderPath == null ? Colors.white54 : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Browse'),
                  onPressed: () async {
                    String? selectedDirectory = await FilePicker.getDirectoryPath();
                    if (selectedDirectory != null) {
                      await config.setSyncFolderPath(selectedDirectory);
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Once configured, any changes made will be exported to this folder. Click the sync icon in the top right to import changes from other machines.',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
