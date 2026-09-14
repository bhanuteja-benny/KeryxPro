import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/bible.dart';
import '../../domain/bible_constants.dart';
import '../bible_providers.dart';

class BibleBookNamesImportDialog extends ConsumerStatefulWidget {
  const BibleBookNamesImportDialog({super.key});

  @override
  ConsumerState<BibleBookNamesImportDialog> createState() => _BibleBookNamesImportDialogState();
}

class _BibleBookNamesImportDialogState extends ConsumerState<BibleBookNamesImportDialog> {
  BibleVersion? _selectedVersion;
  final TextEditingController _textController = TextEditingController();
  bool _isSaving = false;

  void _populateExistingMappings(BibleVersion version) {
    final mappings = version.bookNameMappings;
    if (mappings.isEmpty) {
      _textController.text = '';
    } else {
      final buffer = StringBuffer();
      mappings.forEach((canonical, translated) {
        buffer.writeln('$canonical - $translated');
      });
      _textController.text = buffer.toString().trim();
    }
  }

  Future<void> _handleSave() async {
    if (_selectedVersion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Bible version')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final inputLines = _textController.text.split('\n');
      final Map<String, String> newMappings = {};
      int validCount = 0;
      for (var rawLine in inputLines) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;

        final delimiterIndex = line.indexOf(RegExp(r'[-:=]'));
        if (delimiterIndex == -1) continue;

        final leftRaw = line.substring(0, delimiterIndex).trim();
        final rightRaw = line.substring(delimiterIndex + 1).trim();

        if (leftRaw.isEmpty || rightRaw.isEmpty) continue;

        // Normalize left book name to resolve ambiguities (e.g. psalm/psalms -> Psalms)
        final normalizedCanonical = BibleConstants.normalizeBookName(leftRaw);
        if (normalizedCanonical != null) {
          newMappings[normalizedCanonical] = rightRaw;
          validCount++;
        } else {
          // If not matched directly, fallback to capitalised leftRaw
          newMappings[leftRaw] = rightRaw;
          validCount++;
        }
      }

      await ref.read(bibleRepositoryProvider).saveBookNameMappings(
        _selectedVersion!.id,
        newMappings,
      );

      // Invalidate versions provider to refresh Bible Search UI
      ref.invalidate(bibleVersionsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully saved $validCount book name mappings for ${_selectedVersion!.abbreviation}!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mappings: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final versionsAsync = ref.watch(bibleVersionsProvider);

    return Dialog(
      backgroundColor: const Color(0xFF262626),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              children: [
                const Icon(Icons.translate, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Import Book Names',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dropdown for Bible Version
            const Text(
              'Target Bible Version:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            versionsAsync.when(
              data: (versions) {
                if (versions.isEmpty) {
                  return const Text('No Bible versions installed', style: TextStyle(color: Colors.redAccent, fontSize: 12));
                }

                if (_selectedVersion == null && versions.isNotEmpty) {
                  _selectedVersion = versions.first;
                  _populateExistingMappings(versions.first);
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BibleVersion>(
                      value: _selectedVersion,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF333333),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedVersion = val;
                            _populateExistingMappings(val);
                          });
                        }
                      },
                      items: versions.map((v) {
                        return DropdownMenuItem<BibleVersion>(
                          value: v,
                          child: Text('${v.name} (${v.abbreviation})'),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(height: 36, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (e, _) => Text('Error loading versions: $e', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
            const SizedBox(height: 12),

            // Multiline Textbox
            const Text(
              'Enter Mappings (One per line e.g., Genesis - ఆదికాండము):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _textController,
              maxLines: 10,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Genesis - ఆదికాండము\n1 John - 1 యోహాను\nPsalms - కీర్తనలు',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                filled: true,
                fillColor: Colors.black38,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions (Cancel / Save)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
