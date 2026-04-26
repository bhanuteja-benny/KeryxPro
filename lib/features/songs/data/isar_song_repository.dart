import 'package:isar/isar.dart';
import '../../../core/database/isar_service.dart';
import '../domain/song_repository.dart';
import 'song.dart';

class IsarSongRepository implements SongRepository {
  final IsarService _isarService;

  IsarSongRepository(this._isarService);

  @override
  Future<List<Song>> getAllSongs() async {
    final db = await _isarService.db;
    return await db.songs.where().findAll();
  }

  @override
  Future<List<Song>> searchSongs({String? titleQuery, String? lyricsQuery}) async {
    final hasTitle = titleQuery != null && titleQuery.trim().isNotEmpty;
    final hasLyrics = lyricsQuery != null && lyricsQuery.trim().isNotEmpty;

    if (!hasTitle && !hasLyrics) {
      return getAllSongs();
    }
    
    final db = await _isarService.db;
    final query = db.songs.filter();

    if (hasTitle && hasLyrics) {
      return await query
          .titleContains(titleQuery!, caseSensitive: false)
          .and()
          .lyricsContains(lyricsQuery!, caseSensitive: false)
          .findAll();
    } else if (hasTitle) {
      return await query
          .titleContains(titleQuery!, caseSensitive: false)
          .findAll();
    } else {
      return await query
          .lyricsContains(lyricsQuery!, caseSensitive: false)
          .findAll();
    }
  }

  @override
  Future<void> addSong(Song song) async {
    final db = await _isarService.db;
    await db.writeTxn(() async {
      await db.songs.put(song);
    });
  }

  @override
  Future<void> addSongs(List<Song> songs) async {
    final db = await _isarService.db;
    await db.writeTxn(() async {
      await db.songs.putAll(songs);
    });
  }

  @override
  Future<void> deleteSong(int id) async {
    final db = await _isarService.db;
    await db.writeTxn(() async {
      await db.songs.delete(id);
    });
  }

  @override
  Future<bool> isTitleUnique(String title, {int? excludeId}) async {
    final db = await _isarService.db;
    final query = db.songs.filter().titleEqualTo(title, caseSensitive: false);
    
    if (excludeId != null) {
      final matches = await query.findAll();
      return !matches.any((s) => s.id != excludeId);
    } else {
      final count = await query.count();
      return count == 0;
    }
  }

  @override
  Future<void> seedMockSongs() async {
    final db = await _isarService.db;
    final count = await db.songs.count();
    
    if (count == 0) {
      final mockSongs = [
        Song()
          ..title = "Amazing Grace"
          ..author = "John Newton"
          ..lyrics = "Amazing grace how sweet the sound\nThat saved a wretch like me\nI once was lost, but now I'm found\nWas blind, but now I see.\n\n'Twas grace that taught my heart to fear\nAnd grace my fears relieved\nHow precious did that grace appear\nThe hour I first believed."
          ..lastModified = DateTime.now(),
        Song()
          ..title = "How Great Thou Art"
          ..author = "Carl Boberg"
          ..lyrics = "O Lord my God, When I in awesome wonder,\nConsider all the worlds Thy Hands have made;\nI see the stars, I hear the rolling thunder,\nThy power throughout the universe displayed.\n\nThen sings my soul, my Savior God, to Thee,\nHow great Thou art, how great Thou art!\nThen sings my soul, my Savior God, to Thee,\nHow great Thou art, how great Thou art!"
          ..lastModified = DateTime.now(),
        Song()
          ..title = "10,000 Reasons"
          ..author = "Matt Redman"
          ..lyrics = "Bless the Lord, O my soul\nO my soul\nWorship His holy name\nSing like never before\nO my soul\nI'll worship Your holy name\n\nThe sun comes up, it's a new day dawning\nIt's time to sing Your song again\nWhatever may pass, and whatever lies before me\nLet me be singing when the evening comes."
          ..lastModified = DateTime.now(),
      ];

      await db.writeTxn(() async {
        await db.songs.putAll(mockSongs);
      });
    }
  }
}
