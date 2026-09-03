import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../data/setlist_export_import_service.dart';
import 'manage_setlists_providers.dart';
import 'setlist_providers.dart';

class ImportSetlistDialog extends ConsumerStatefulWidget {
  const ImportSetlistDialog({super.key});

  @override
  ConsumerState<ImportSetlistDialog> createState() => _ImportSetlistDialogState();
}

class _ImportSetlistDialogState extends ConsumerState<ImportSetlistDialog> {
  String? _selectedFilePath;
  String? _setlistName;
  int? _itemCount;
  String? _errorMessage;
  bool _isImporting = false;

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
    });

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        _parsePreview(path);
      }
    }
  }

  Future<void> _parsePreview(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (!data.containsKey('name') || !data.containsKey('itemOrder')) {
        setState(() {
          _errorMessage = 'Invalid setlist JSON file.';
          _selectedFilePath = null;
          _setlistName = null;
          _itemCount = null;
        });
        return;
      }

      final name = data['name'] as String;
      final itemOrder = data['itemOrder'] as List<dynamic>? ?? [];

      setState(() {
        _selectedFilePath = filePath;
        _setlistName = name;
        _itemCount = itemOrder.length;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to parse JSON file: $e';
        _selectedFilePath = null;
        _setlistName = null;
        _itemCount = null;
      });
    }
  }

  Future<void> _importSetlist() async {
    if (_selectedFilePath == null || _isImporting) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final service = ref.read(setlistExportImportServiceProvider);
      final imported = await service.importSetlistFromFile(_selectedFilePath!);

      ref.invalidate(savedSetlistNamesProvider);
      ref.invalidate(allSavedSetlistsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setlist "${imported.name}" imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error importing setlist: $e';
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Import Setlist',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Select a JSON setlist file to import into KeryxPro:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // File selection display & Browse button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D3E),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      _selectedFilePath ?? 'No file selected...',
                      style: TextStyle(
                        color: _selectedFilePath != null ? Colors.white : Colors.white38,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Browse'),
                  onPressed: _pickFile,
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],

            if (_setlistName != null && _itemCount != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Setlist Name: $_setlistName',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Items: $_itemCount',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFilePath != null && !_isImporting
                        ? Colors.deepPurpleAccent
                        : Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  icon: _isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Import Setlist'),
                  onPressed: _selectedFilePath != null && !_isImporting ? _importSetlist : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
