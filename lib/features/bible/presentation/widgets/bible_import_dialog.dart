import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../bible_providers.dart';

class BibleImportDialog extends ConsumerWidget {
  const BibleImportDialog({super.key});

  Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && result.paths.isNotEmpty) {
      final paths = result.paths.whereType<String>().toList();
      if (paths.isNotEmpty) {
        final importedCount = await ref.read(bibleImportProvider.notifier).importBibleFiles(paths);
        
        // Refresh the versions list
        ref.invalidate(bibleVersionsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully imported $importedCount Bibles!')),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(bibleImportProvider);
    final isLoading = importState.isLoading;

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Bibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Supported formats: OpenSong XML, Zefania XML',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Where to find Bibles?',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Due to copyright restrictions, modern translations (NIV, NKJV, NASB, NLT, AMP, ESV) '
                    'are usually maintained in user-created community repositories rather than official websites.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Public domain versions (like KJV) and many international languages '
                    '(Telugu, Nepali, Hindi) are widely available online.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Search on Google for:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  _buildBulletPoint('"OpenSong Bibles download" (or open opensong.org/home/download)'),
                  _buildBulletPoint('"Zefania XML Bibles GitHub"'),
                  _buildBulletPoint('"OpenSong Telugu Bible XML"'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _handleImport(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: isLoading 
                    ? const SizedBox(
                        width: 16, height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Icon(Icons.upload_file),
                  label: Text(isLoading ? 'Importing...' : 'Select XML Files'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white70)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}
