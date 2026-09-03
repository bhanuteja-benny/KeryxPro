import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../data/saved_setlist.dart';
import '../data/setlist_export_import_service.dart';
import 'manage_setlists_providers.dart';

class ExportSetlistsDialog extends ConsumerStatefulWidget {
  const ExportSetlistsDialog({super.key});

  @override
  ConsumerState<ExportSetlistsDialog> createState() => _ExportSetlistsDialogState();
}

class _ExportSetlistsDialogState extends ConsumerState<ExportSetlistsDialog> {
  final Set<String> _selectedNames = {};
  DateTime? _filterDate;
  bool _hasInitialSelectionBeenMade = false;

  void _toggleSelection(String name) {
    setState(() {
      if (_selectedNames.contains(name)) {
        _selectedNames.remove(name);
      } else {
        _selectedNames.add(name);
      }
    });
  }

  void _selectAll(List<SavedSetlist> setlists) {
    setState(() {
      _selectedNames.addAll(setlists.map((s) => s.name));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNames.clear();
    });
  }

  Future<void> _filterOlderThan(List<SavedSetlist> setlists) async {
    final initialDate = _filterDate != null
        ? _filterDate!.subtract(const Duration(days: 1))
        : DateTime.now().subtract(const Duration(days: 30));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurpleAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D3E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final targetDate = pickedDate.add(const Duration(days: 1));
      setState(() {
        _filterDate = targetDate;
        _selectedNames.clear();
        for (final setlist in setlists) {
          if (setlist.lastModified.isBefore(targetDate)) {
            _selectedNames.add(setlist.name);
          }
        }
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _filterDate = null;
    });
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _exportSelected(List<SavedSetlist> allSetlists) async {
    if (_selectedNames.isEmpty) return;

    final targetFolderPath = await FilePicker.getDirectoryPath();
    if (targetFolderPath == null) return; // User cancelled

    final selectedSetlists = allSetlists.where((s) => _selectedNames.contains(s.name)).toList();
    if (selectedSetlists.isEmpty) return;

    try {
      final exportService = ref.read(setlistExportImportServiceProvider);
      final count = await exportService.exportSetlistsToFolder(selectedSetlists, targetFolderPath);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully exported $count setlist(s) to destination.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting setlists: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final setlistsAsync = ref.watch(allSavedSetlistsProvider);

    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Export Setlists',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            setlistsAsync.when(
              data: (setlists) {
                if (setlists.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text('No saved setlists found.', style: TextStyle(color: Colors.white54)),
                    ),
                  );
                }

                // Sort by last modified, newest first
                final sortedSetlists = List<SavedSetlist>.from(setlists)
                  ..sort((a, b) => b.lastModified.compareTo(a.lastModified));

                // Pre-select the latest setlist by default on initial load
                if (!_hasInitialSelectionBeenMade) {
                  _hasInitialSelectionBeenMade = true;
                  if (sortedSetlists.isNotEmpty) {
                    _selectedNames.add(sortedSetlists.first.name);
                  }
                }

                // Filter if date filter active
                var displayedSetlists = sortedSetlists;
                if (_filterDate != null) {
                  displayedSetlists = displayedSetlists.where((s) => s.lastModified.isBefore(_filterDate!)).toList();
                }

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top actions
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _filterDate != null ? Colors.deepPurpleAccent : const Color(0xFF2D2D3E),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.calendar_month, size: 16),
                            label: Text(_filterDate != null
                                ? 'Older than ${_formatDate(_filterDate!.subtract(const Duration(days: 1)))}'
                                : 'Filter by Date...'),
                            onPressed: () => _filterOlderThan(setlists),
                          ),
                          if (_filterDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: Colors.white54),
                              onPressed: _clearFilter,
                              tooltip: 'Clear Filter',
                            ),
                          ],
                          const Spacer(),
                          TextButton(
                            onPressed: () => _selectAll(displayedSetlists),
                            child: const Text('Select All', style: TextStyle(color: Colors.deepPurpleAccent)),
                          ),
                          TextButton(
                            onPressed: _clearSelection,
                            child: const Text('Clear', style: TextStyle(color: Colors.white54)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Setlist Selection List
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.separated(
                            itemCount: displayedSetlists.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white12),
                            itemBuilder: (context, index) {
                              final setlist = displayedSetlists[index];
                              final isSelected = _selectedNames.contains(setlist.name);

                              return ListTile(
                                tileColor: isSelected ? Colors.deepPurpleAccent.withValues(alpha: 0.1) : null,
                                leading: Checkbox(
                                  value: isSelected,
                                  onChanged: (val) => _toggleSelection(setlist.name),
                                  activeColor: Colors.deepPurpleAccent,
                                ),
                                title: Text(setlist.name, style: const TextStyle(color: Colors.white)),
                                trailing: Text(
                                  _formatDate(setlist.lastModified),
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                onTap: () => _toggleSelection(setlist.name),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bottom bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedNames.length} selected',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedNames.isEmpty ? Colors.grey[800] : Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.file_upload_outlined, size: 18),
                            label: Text('Export Selected (${_selectedNames.length})'),
                            onPressed: _selectedNames.isEmpty ? null : () => _exportSelected(sortedSetlists),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
              loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => Expanded(
                child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
