import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_service.dart';
import '../../songs/data/song.dart';
import 'saved_setlist.dart';
import 'setlist_item.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final setlistRepositoryProvider = Provider<SetlistRepository>((ref) {
  return SetlistRepository(ref.read(isarServiceProvider).db);
});

class SetlistRepository {
  final Future<Isar> _db;
  SetlistRepository(this._db);

  Future<List<String>> getAllNames() async {
    final isar = await _db;
    final lists = await isar.savedSetlists.where().findAll();
    return lists.map((s) => s.name).toList();
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
    for (final entry in saved.itemOrder) {
      if (entry.startsWith('song:')) {
        final id = int.tryParse(entry.substring(5));
        if (id != null && songMap.containsKey(id)) {
          items.add(SongSetlistItem(songMap[id]!));
        }
      } else if (entry.startsWith('image:')) {
        final idx = int.tryParse(entry.substring(6));
        if (idx != null && imageItems.containsKey(idx)) {
          items.add(imageItems[idx]!);
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

    for (final item in items) {
      switch (item) {
        case SongSetlistItem(:final song):
          songIds.add(song.id);
          itemOrder.add('song:${song.id}');
        case ImageSetlistItem(:final imagePath, :final layout, :final alignment):
          final idx = imageEntries.length;
          imageEntries.add('$imagePath|$layout|$alignment');
          itemOrder.add('image:$idx');
      }
    }

    final saved = SavedSetlist()
      ..name = name
      ..songIds = songIds
      ..imageEntries = imageEntries
      ..itemOrder = itemOrder
      ..lastModified = DateTime.now();

    await isar.writeTxn(() async {
      await isar.savedSetlists.put(saved);
    });
  }

  Future<void> deleteByName(String name) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.savedSetlists.where().nameEqualTo(name).deleteAll();
    });
  }
}
