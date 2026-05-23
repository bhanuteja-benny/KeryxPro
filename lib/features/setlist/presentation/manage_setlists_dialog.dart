import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manage_setlists_providers.dart';
import '../data/setlist_repository.dart';
import '../presentation/setlist_providers.dart';
import '../data/saved_setlist.dart';

class ManageSetlistsDialog extends ConsumerStatefulWidget {
  const ManageSetlistsDialog({super.key});

  @override
  ConsumerState<ManageSetlistsDialog> createState() => _ManageSetlistsDialogState();
}

class _ManageSetlistsDialogState extends ConsumerState<ManageSetlistsDialog> {
  final Set<String> _selectedNames = {};
  DateTime? _filterDate;

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
    // Default to 1 month ago if no previous filter
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
      // Add one day so that any time on the picked day is included
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

  Future<void> _deleteSelected() async {
    if (_selectedNames.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D3E),
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to permanently delete ${_selectedNames.length} setlists? This action cannot be undone and will affect synced devices.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(setlistRepositoryProvider);
      await repo.deleteMultipleByName(_selectedNames.toList());
      
      // If the currently active setlist was deleted, clear the active name
      final activeName = ref.read(activeSetlistNameProvider);
      if (activeName != null && _selectedNames.contains(activeName)) {
        ref.read(activeSetlistNameProvider.notifier).state = null;
        ref.read(activeSetlistSignatureProvider.notifier).state = '';
        ref.read(setlistProvider.notifier).clear();
      }

      ref.invalidate(savedSetlistNamesProvider);
      ref.invalidate(allSavedSetlistsProvider);
      
      setState(() {
        _selectedNames.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected setlists deleted successfully.')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
                  'Manage Setlists',
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
                  
                // Filter if a date is selected
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
                      
                      // List of setlists
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
                              backgroundColor: _selectedNames.isEmpty ? Colors.grey[800] : Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.delete, size: 18),
                            label: Text('Delete Selected (${_selectedNames.length})'),
                            onPressed: _selectedNames.isEmpty ? null : _deleteSelected,
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
              loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => Expanded(child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red)))),
            ),
          ],
        ),
      ),
    );
  }
}
