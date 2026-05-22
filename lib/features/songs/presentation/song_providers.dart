import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart'; // To access isarServiceProvider
import '../data/isar_song_repository.dart';
import '../domain/song_repository.dart';
import '../data/song.dart';
import '../../../core/sync/sync_service.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return IsarSongRepository(isarService);
});

final titleSearchProvider = StateProvider<String>((ref) => '');
final lyricsSearchProvider = StateProvider<String>((ref) => '');

class SongListNotifier extends AsyncNotifier<List<Song>> {
  @override
  Future<List<Song>> build() async {
    final title = ref.watch(titleSearchProvider);
    final lyrics = ref.watch(lyricsSearchProvider);
    
    return _fetchSongs(title: title, lyrics: lyrics);
  }

  Future<List<Song>> _fetchSongs({String? title, String? lyrics}) async {
    final repository = ref.read(songRepositoryProvider);
    return repository.searchSongs(titleQuery: title, lyricsQuery: lyrics);
  }

  Future<void> seedMockData() async {
    final repository = ref.read(songRepositoryProvider);
    await repository.seedMockSongs();
    ref.invalidateSelf();
  }

  Future<String?> saveSong(Song song) async {
    final repository = ref.read(songRepositoryProvider);
    final isUnique = await repository.isTitleUnique(song.title, excludeId: song.id == 0 ? null : song.id);
    if (!isUnique) {
      return "A song with this title already exists.";
    }
    
    song.lastModified = DateTime.now();
    await repository.addSong(song);
    
    // Export sync event
    ref.read(syncServiceProvider).exportSong(song);

    ref.invalidateSelf();
    return null; // success
  }

  Future<int> importSongs(List<Song> songs) async {
    final repository = ref.read(songRepositoryProvider);
    final List<Song> songsToImport = [];

    for (var song in songs) {
      String newTitle = song.title;
      int counter = 1;
      
      // Append (1), (2), etc. if title already exists
      while (!(await repository.isTitleUnique(newTitle))) {
        newTitle = '${song.title} ($counter)';
        counter++;
      }
      
      song.title = newTitle;
      song.lastModified = DateTime.now();
      songsToImport.add(song);
    }

    if (songsToImport.isNotEmpty) {
      await repository.addSongs(songsToImport);
      
      // Export sync events for all imported songs
      final syncService = ref.read(syncServiceProvider);
      for (final s in songsToImport) {
        syncService.exportSong(s);
      }

      ref.invalidateSelf();
    }
    
    return songsToImport.length;
  }

  Future<void> deleteSong(int id) async {
    final repository = ref.read(songRepositoryProvider);
    // Need the song to get its syncId before deleting
    final song = (await repository.searchSongs()).where((s) => s.id == id).firstOrNull;
    
    await repository.deleteSong(id);
    
    if (song != null) {
      ref.read(syncServiceProvider).exportSong(song, deleted: true);
    }
    
    ref.invalidateSelf();
  }
}

final songListProvider = AsyncNotifierProvider<SongListNotifier, List<Song>>(
  () => SongListNotifier(),
);
