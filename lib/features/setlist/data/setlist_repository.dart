import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../main.dart';
import '../../songs/data/song.dart';
import 'saved_setlist.dart';
import 'setlist_item.dart';

final setlistRepositoryProvider = Provider<SetlistRepository>((ref) {
  return SetlistRepository(
    ref.read(isarServiceProvider).db,
    ref.read(syncServiceProvider),
  );
});

class SetlistRepository {
  final Future<Isar> _db;
  final SyncService _syncService;
  
  SetlistRepository(this._db, this._syncService);

  Future<List<String>> getAllNames() async {
    final isar = await _db;
    final lists = await isar.savedSetlists.where().findAll();
    return lists.map((s) => s.name).toList();
  }

  Future<List<SavedSetlist>> getAllSetlists() async {
    final isar = await _db;
    return await isar.savedSetlists.where().findAll();
  }

  Future<List<SetlistItem>> loadByName(String name) async {
    final isar = await _db;
    final saved = await isar.savedSetlists.where().nameEqualTo(name).findFirst();
    if (saved == null) return [];

    // Build a map of imageIndex -> ImageSetlistItem
    final imageItems = <int, ImageSetlistItem>{};
    for (int i = 0; i < saved.imageEntries.length; i++) {
      final parts = saved.imageEntries[i].split('|');
      if (parts.length >= 3) {
        imageItems[i] = ImageSetlistItem(
          imagePath: parts[0],
          layout: parts[1],
          alignment: parts[2],
        );
      }
    }

    // Build map of songId -> Song
    final songIds = saved.songIds.toSet();
    final songs = await isar.songs.getAll(songIds.toList());
    final songMap = <int, Song>{};
    for (final song in songs) {
      if (song != null) songMap[song.id] = song;
    }

    // Reconstruct ordered list from itemOrder
    final items = <SetlistItem>[];
    for (int i = 0; i < saved.itemOrder.length; i++) {
      final entry = saved.itemOrder[i];
      bool isFav = false;
      try {
        isFav = i < saved.favorites.length ? saved.favorites[i] : false;
      } catch (_) {}

      if (entry.startsWith('song:')) {
        final id = int.tryParse(entry.substring(5));
        if (id != null && songMap.containsKey(id)) {
          items.add(SongSetlistItem(songMap[id]!, isFavorite: isFav));
        }
      } else if (entry.startsWith('scripture:')) {
        final parts = entry.substring(10).split('|');
        if (parts.length == 2) {
          final title = Uri.decodeComponent(parts[0]);
          final lyrics = Uri.decodeComponent(parts[1]);
          final mockSong = Song()
            ..title = title
            ..author = 'Bible'
            ..lyrics = lyrics;
          items.add(SongSetlistItem(mockSong, isFavorite: isFav));
        }
      } else if (entry.startsWith('image:')) {
        final idx = int.tryParse(entry.substring(6));
        if (idx != null && imageItems.containsKey(idx)) {
          items.add(imageItems[idx]!.copyWith(isFavorite: isFav));
        }
      }
    }
    return items;
  }

  Future<void> saveByName(String name, List<SetlistItem> items) async {
    final isar = await _db;

    final songIds = <int>[];
    final imageEntries = <String>[];
    final itemOrder = <String>[];
    final favorites = <bool>[];

    for (final item in items) {
      favorites.add(item.isFavorite);
      switch (item) {
        case SongSetlistItem(:final song):
          if (song.author == 'Bible') {
            final encodedTitle = Uri.encodeComponent(song.title);
            final encodedLyrics = Uri.encodeComponent(song.lyrics);
            itemOrder.add('scripture:$encodedTitle|$encodedLyrics');
          } else {
            songIds.add(song.id);
            itemOrder.add('song:${song.id}');
          }
        case ImageSetlistItem(:final imagePath, :final layout, :final alignment):
          final idx = imageEntries.length;
          imageEntries.add('$imagePath|$layout|$alignment');
          itemOrder.add('image:$idx');
      }
    }

    final existing = await isar.savedSetlists.where().nameEqualTo(name).findFirst();

    final saved = existing ?? SavedSetlist();
    saved
      ..name = name
      ..songIds = songIds
      ..imageEntries = imageEntries
      ..itemOrder = itemOrder
      ..favorites = favorites
      ..lastModified = DateTime.now();

    // Populate songSyncIds
    final songSyncIds = <String>[];
    for (final id in songIds) {
      final s = await isar.songs.get(id);
      if (s != null) songSyncIds.add(s.syncId);
    }
    saved.songSyncIds = songSyncIds;

    await isar.writeTxn(() async {
      await isar.savedSetlists.put(saved);
    });

    // Export sync event
    _syncService.exportSetlist(saved);
  }

  Future<void> deleteByName(String name) async {
    final isar = await _db;
    final existing = await isar.savedSetlists.where().nameEqualTo(name).findFirst();
    if (existing == null) return;

    await isar.writeTxn(() async {
      await isar.savedSetlists.delete(existing.id);
    });

    _syncService.exportSetlist(existing, deleted: true);
  }

  Future<void> deleteMultipleByName(List<String> names) async {
    final isar = await _db;
    final toDelete = await isar.savedSetlists
        .where()
        .anyOf(names, (q, String name) => q.nameEqualTo(name))
        .findAll();

    if (toDelete.isEmpty) return;

    final idsToDelete = toDelete.map((s) => s.id).toList();

    await isar.writeTxn(() async {
      await isar.savedSetlists.deleteAll(idsToDelete);
    });

    for (final existing in toDelete) {
      _syncService.exportSetlist(existing, deleted: true);
    }
  }
}
