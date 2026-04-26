import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'song_providers.dart';
import 'song_selection_providers.dart';
import '../data/song.dart';
import '../../dashboard/presentation/global_ui_providers.dart';

final librarySelectedIndexProvider = StateProvider<int>((ref) => 0);

class SongLibraryTab extends ConsumerStatefulWidget {
  const SongLibraryTab({super.key});

  @override
  ConsumerState<SongLibraryTab> createState() => _SongLibraryTabState();
}

class _SongLibraryTabState extends ConsumerState<SongLibraryTab> {
  final FocusNode _listFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _listFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songState = ref.watch(songListProvider);
    final previewSong = ref.watch(previewSongProvider);
    final lyricsQuery = ref.watch(lyricsSearchProvider);

    return Column(
      children: [
        // Dual Search Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          color: Colors.black12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 24,
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showSongEditor(context, ref),
                  icon: const Icon(Icons.add, size: 12, color: Colors.blueAccent),
                  label: const Text('Add Song', style: TextStyle(fontSize: 10, color: Colors.blueAccent)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: ref.read(songSearchFocusNodeProvider),
                      onChanged: (val) => ref.read(titleSearchProvider.notifier).state = val,
                      onSubmitted: (_) => _listFocusNode.requestFocus(),
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        isDense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        hintText: 'Search Title...',
                        prefixIcon: const Icon(Icons.title, size: 12),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => ref.read(lyricsSearchProvider.notifier).state = val,
                      onSubmitted: (_) => _listFocusNode.requestFocus(),
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        isDense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        hintText: 'Search Lyrics...',
                        prefixIcon: const Icon(Icons.notes, size: 12),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        Expanded(
          child: songState.when(
            data: (songs) {
              if (songs.isEmpty) {
                return _buildEmptyState(ref, context);
              }

              final selectedIndex = ref.watch(librarySelectedIndexProvider);

              // Auto-scroll logic when selectedIndex changes
              ref.listen(librarySelectedIndexProvider, (previous, next) {
                if (_scrollController.hasClients) {
                  // Approximate item height is ~40px based on visual density
                  final targetOffset = next * 40.0; 
                  _scrollController.animateTo(
                    targetOffset,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                }
              });

              return Focus(
                focusNode: _listFocusNode,
                autofocus: false,
                onKeyEvent: (node, event) {
                  if (event is! KeyDownEvent) return KeyEventResult.ignored;

                  final currentIndex = ref.read(librarySelectedIndexProvider);

                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    if (currentIndex < songs.length - 1) {
                      final newIndex = currentIndex + 1;
                      ref.read(librarySelectedIndexProvider.notifier).state = newIndex;
                      ref.read(previewSongProvider.notifier).state = songs[newIndex];
                    }
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    if (currentIndex > 0) {
                      final newIndex = currentIndex - 1;
                      ref.read(librarySelectedIndexProvider.notifier).state = newIndex;
                      ref.read(previewSongProvider.notifier).state = songs[newIndex];
                    }
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                    if (songs.isNotEmpty && currentIndex >= 0 && currentIndex < songs.length) {
                      ref.read(setlistProvider.notifier).addSong(songs[currentIndex]);
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: songs.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final isSelected = selectedIndex == index;
                    
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      selected: isSelected,
                      selectedTileColor: Colors.blueAccent.withOpacity(0.1),
                      title: Text(song.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text(song.author ?? 'Unknown Author', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      trailing: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => ref.read(setlistProvider.notifier).addSong(song),
                          child: Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.add, size: 18, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      onTap: () {
                        ref.read(librarySelectedIndexProvider.notifier).state = index;
                        ref.read(previewSongProvider.notifier).state = song;
                        _listFocusNode.requestFocus();
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),

        // Lyrics Preview Subsection
        if (previewSong != null)
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              border: const Border(top: BorderSide(color: Colors.blueAccent, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: Colors.black26,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          previewSong.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: const Icon(Icons.edit, size: 14, color: Colors.blueGrey),
                        onPressed: () => _showSongEditor(context, ref, existingSong: previewSong),
                        tooltip: 'Edit Song',
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: const Icon(Icons.delete, size: 14, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteSong(context, ref, previewSong),
                        tooltip: 'Delete Song',
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                        onPressed: () => ref.read(previewSongProvider.notifier).state = null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: _HighlightedText(
                        text: previewSong.lyrics,
                        query: lyricsQuery,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(WidgetRef ref, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No songs found.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(songListProvider.notifier).seedMockData(),
            icon: const Icon(Icons.download),
            label: const Text('Import Sample Songs'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSong(BuildContext context, WidgetRef ref, Song song) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text('Are you sure you want to delete "${song.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(songListProvider.notifier).deleteSong(song.id);
              if (ref.read(previewSongProvider)?.id == song.id) {
                ref.read(previewSongProvider.notifier).state = null;
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSongEditor(BuildContext context, WidgetRef ref, {Song? existingSong}) {
    ref.read(songBeingEditedProvider.notifier).state = existingSong;
    ref.read(isSongEditorOpenProvider.notifier).state = true;
  }
}


class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4));
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    int start = 0;
    int indexOfMatch;
    
    while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }
      spans.add(TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + query.length),
        style: TextStyle(backgroundColor: Colors.yellow.withOpacity(0.3), color: Colors.white, fontWeight: FontWeight.bold),
      ));
      start = indexOfMatch + query.length;
    }
    
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4, fontFamily: 'monospace'),
        children: spans,
      ),
    );
  }
}
