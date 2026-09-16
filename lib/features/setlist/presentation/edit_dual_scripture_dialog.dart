import 'package:flutter/material.dart';
import '../../songs/data/song.dart';
import '../data/setlist_item.dart';

class EditDualScriptureDialog extends StatefulWidget {
  final SongSetlistItem item;
  final String initialFormattedReference;

  const EditDualScriptureDialog({
    super.key,
    required this.item,
    required this.initialFormattedReference,
  });

  @override
  State<EditDualScriptureDialog> createState() => _EditDualScriptureDialogState();
}

class _EditDualScriptureDialogState extends State<EditDualScriptureDialog> {
  late final TextEditingController _referenceController;
  late final TextEditingController _primaryVerseController;
  late final TextEditingController _secondaryVerseController;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(text: widget.item.customReference ?? widget.initialFormattedReference);
    _primaryVerseController = TextEditingController(text: widget.item.song.lyrics);
    _secondaryVerseController = TextEditingController(text: widget.item.song.secondaryLyrics ?? '');
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _primaryVerseController.dispose();
    _secondaryVerseController.dispose();
    super.dispose();
  }

  void _save() {
    final reference = _referenceController.text.trim();
    final primaryVerse = _primaryVerseController.text;
    final secondaryVerse = _secondaryVerseController.text;

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
      ..lyrics = primaryVerse
      ..backgroundUrl = original.backgroundUrl
      ..lastModified = lastMod
      ..isDualVersion = true
      ..secondaryTitle = original.secondaryTitle
      ..secondaryLyrics = secondaryVerse
      ..bookAlias = original.bookAlias
      ..secondaryBookAlias = original.secondaryBookAlias;

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
        width: 600,
        height: 600,
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
                      'Edit Dual Scripture',
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

            // Verses Fields (Primary and Secondary)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Primary Verse
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Primary Verse Text',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: TextField(
                            controller: _primaryVerseController,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Secondary Verse
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Secondary Verse Text',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: TextField(
                            controller: _secondaryVerseController,
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
                      ],
                    ),
                  ),
                ],
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
