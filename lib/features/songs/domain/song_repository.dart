import '../data/song.dart';

abstract class SongRepository {
  Future<List<Song>> getAllSongs();
  Future<List<Song>> searchSongs({String? titleQuery, String? lyricsQuery});
  Future<void> addSong(Song song);
  Future<void> addSongs(List<Song> songs);
  Future<void> deleteSong(int id);
  Future<bool> isTitleUnique(String title, {int? excludeId});
  Future<void> seedMockSongs();
}
