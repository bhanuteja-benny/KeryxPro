import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/song.dart';
import 'song_providers.dart';
import 'song_selection_providers.dart';

class SongEditorPane extends ConsumerStatefulWidget {
  const SongEditorPane({super.key});

  @override
  ConsumerState<SongEditorPane> createState() => _SongEditorPaneState();
}

class _SongEditorPaneState extends ConsumerState<SongEditorPane> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _lyricsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final existingSong = ref.read(songBeingEditedProvider);
    _titleController = TextEditingController(text: existingSong?.title ?? '');
    _authorController = TextEditingController(text: existingSong?.author ?? '');
    _lyricsController = TextEditingController(text: existingSong?.lyrics ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final lyrics = _lyricsController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    if (lyrics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lyrics are required')));
      return;
    }

    setState(() => _isLoading = true);

    final existingSong = ref.read(songBeingEditedProvider);
    final song = existingSong ?? Song();
    song.title = title;
    song.author = author.isEmpty ? null : author;
    song.lyrics = lyrics;

    final error = await ref.read(songListProvider.notifier).saveSong(song);

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
      } else {
        if (existingSong != null && ref.read(previewSongProvider)?.id == song.id) {
          ref.read(previewSongProvider.notifier).state = song;
        }
        _close();
      }
    }
  }

  void _close() {
    ref.read(isSongEditorOpenProvider.notifier).state = false;
    ref.read(songBeingEditedProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = ref.watch(songBeingEditedProvider) != null;

    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.black26,
            child: Row(
              children: [
                Text(
                  isEditMode ? 'Edit Song' : 'Add New Song',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent),
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                  onPressed: _close,
                  tooltip: 'Cancel',
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      labelStyle: TextStyle(fontSize: 11),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    autofocus: !isEditMode,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _authorController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Author (Optional)',
                      labelStyle: TextStyle(fontSize: 11),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _lyricsController,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace', height: 1.4),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter song lyrics here...',
                        contentPadding: EdgeInsets.all(8),
                      ),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : _close,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: _isLoading ? null : _save,
                        child: _isLoading 
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Song', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
