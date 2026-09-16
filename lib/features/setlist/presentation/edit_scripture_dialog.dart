import 'package:flutter/material.dart';
import '../../songs/data/song.dart';
import '../data/setlist_item.dart';

class EditScriptureDialog extends StatefulWidget {
  final SongSetlistItem item;
  final String initialFormattedReference;

  const EditScriptureDialog({
    super.key,
    required this.item,
    required this.initialFormattedReference,
  });

  @override
  State<EditScriptureDialog> createState() => _EditScriptureDialogState();
}

class _EditScriptureDialogState extends State<EditScriptureDialog> {
  late final TextEditingController _referenceController;
  late final TextEditingController _verseController;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(text: widget.item.customReference ?? widget.initialFormattedReference);
    _verseController = TextEditingController(text: widget.item.song.lyrics);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  void _save() {
    final reference = _referenceController.text.trim();
    final verse = _verseController.text;

    final original = widget.item.song;
    DateTime lastMod = DateTime.now();
    try {
      lastMod = original.lastModified;
    } catch (_) {}

    final updatedSong = Song()
      ..id = original.id
      ..syncId = original.syncId
      ..title = original.title
      ..author = 'Bible'
      ..lyrics = verse
      ..backgroundUrl = original.backgroundUrl
      ..lastModified = lastMod
      ..isDualVersion = false
      ..secondaryTitle = null
      ..secondaryLyrics = null
      ..bookAlias = original.bookAlias
      ..secondaryBookAlias = null;

    final updatedItem = widget.item.copyWith(
      song: updatedSong,
      isEdited: true,
      customReference: reference,
    );

    Navigator.of(context).pop(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2D2D3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 540,
        height: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/scroll.png',
                      width: 20,
                      height: 20,
                      color: Colors.indigoAccent,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Scripture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reference Field
            const Text(
              'Reference (Book, Chapter & Verse)',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _referenceController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E2E),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.indigoAccent),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Verse Field
            const Text(
              'Verse Text',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: TextField(
                controller: _verseController,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E2E),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.indigoAccent),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
