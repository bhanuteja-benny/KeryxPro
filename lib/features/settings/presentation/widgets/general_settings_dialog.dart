import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../../main.dart';
import '../../data/app_settings.dart';

class GeneralSettingsDialog extends ConsumerStatefulWidget {
  const GeneralSettingsDialog({super.key});

  @override
  ConsumerState<GeneralSettingsDialog> createState() => _GeneralSettingsDialogState();
}

class _GeneralSettingsDialogState extends ConsumerState<GeneralSettingsDialog> {
  bool _isErrorLoggingEnabled = false;
  AppSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isarService = ref.read(isarServiceProvider);
    final isar = await isarService.db;
    final settings = await isar.appSettings.where().findFirst();
    if (settings != null) {
      if (mounted) {
        setState(() {
          _settings = settings;
          _isErrorLoggingEnabled = settings.isErrorLoggingEnabled;
        });
      }
    } else {
      final newSettings = AppSettings();
      await isar.writeTxn(() async {
        await isar.appSettings.put(newSettings);
      });
      if (mounted) {
        setState(() {
          _settings = newSettings;
          _isErrorLoggingEnabled = false;
        });
      }
    }
  }

  Future<void> _updateLogging(bool value) async {
    final isarService = ref.read(isarServiceProvider);
    final isar = await isarService.db;
    if (_settings != null) {
      setState(() {
        _isErrorLoggingEnabled = value;
      });
      _settings!.isErrorLoggingEnabled = value;
      await isar.writeTxn(() async {
        await isar.appSettings.put(_settings!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Text('General Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Enable Error Logging'),
                    subtitle: const Text('Write application errors and exceptions to a local error.log file.'),
                    value: _isErrorLoggingEnabled,
                    onChanged: _updateLogging,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
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
