import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../data/song.dart';

/// The song currently being previewed in the library bottom pane.
final previewSongProvider = StateProvider<Song?>((ref) => null);

/// Indicates whether the song editor pane should be visible.
final isSongEditorOpenProvider = StateProvider<bool>((ref) => false);

/// The song currently being edited, or null if adding a new song.
final songBeingEditedProvider = StateProvider<Song?>((ref) => null);

/// The list of songs added for the current session (middle pane).
class SetlistNotifier extends StateNotifier<List<Song>> {
  SetlistNotifier() : super([]);

  void addSong(Song song) {
    // We allow multiple instances if needed, but usually a setlist has unique songs.
    // However, church services sometimes repeat a chorus or a song. 
    // For simplicity, let's allow duplicates but treat them as distinct entries if we had a unique ID per entry.
    // For now, let's just add it.
    state = [...state, song];
  }

  void removeAt(int index) {
    final newList = List<Song>.from(state);
    newList.removeAt(index);
    state = newList;
  }

  void clear() {
    state = [];
  }
}

final setlistProvider = StateNotifierProvider<SetlistNotifier, List<Song>>((ref) {
  return SetlistNotifier();
});
