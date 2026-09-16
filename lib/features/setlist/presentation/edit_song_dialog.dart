import 'package:flutter/material.dart';
import '../../songs/data/song.dart';
import '../data/setlist_item.dart';

class EditSongDialog extends StatefulWidget {
  final SongSetlistItem item;

  const EditSongDialog({
    super.key,
    required this.item,
  });

  @override
  State<EditSongDialog> createState() => _EditSongDialogState();
}

class _EditSongDialogState extends State<EditSongDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _lyricsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.song.title);
    _lyricsController = TextEditingController(text: widget.item.song.lyrics);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final lyrics = _lyricsController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song title cannot be empty')),
      );
      return;
    }

    final original = widget.item.song;
    DateTime lastMod = DateTime.now();
    try {
      lastMod = original.lastModified;
    } catch (_) {}

    final updatedSong = Song()
      ..id = original.id
      ..syncId = original.syncId
      ..title = title
      ..author = original.author
      ..lyrics = lyrics
      ..backgroundUrl = original.backgroundUrl
      ..lastModified = lastMod
      ..isDualVersion = original.isDualVersion
      ..secondaryTitle = original.secondaryTitle
      ..secondaryLyrics = original.secondaryLyrics
      ..bookAlias = original.bookAlias
      ..secondaryBookAlias = original.secondaryBookAlias;

    final updatedItem = widget.item.copyWith(
      song: updatedSong,
      isEdited: true,
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
                const Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: Colors.deepPurpleAccent, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Edit Song',
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

            // Title Field
            const Text(
              'Title',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
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
                  borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Lyrics Field
            const Text(
              'Lyrics',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: TextField(
                controller: _lyricsController,
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
                    borderSide: const BorderSide(color: Colors.deepPurpleAccent),
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
                    backgroundColor: Colors.deepPurpleAccent,
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
