import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
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

  static String _safeDecode(String s) {
    try {
      return Uri.decodeComponent(s);
    } catch (_) {
      return s;
    }
  }

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

      if (entry.startsWith('custom_song:')) {
        final parts = entry.substring(12).split('|');
        final id = int.tryParse(parts[0]);
        final title = parts.length >= 2 ? _safeDecode(parts[1]) : (id != null && songMap.containsKey(id) ? songMap[id]!.title : 'Untitled');
        final lyrics = parts.length >= 3 ? _safeDecode(parts[2]) : (id != null && songMap.containsKey(id) ? songMap[id]!.lyrics : '');
        final baseSong = (id != null && songMap.containsKey(id)) ? songMap[id]! : Song();
        final editedSong = Song()
          ..id = baseSong.id
          ..syncId = baseSong.syncId
          ..title = title
          ..author = baseSong.author
          ..lyrics = lyrics
          ..backgroundUrl = baseSong.backgroundUrl;
        items.add(SongSetlistItem(editedSong, isFavorite: isFav, isEdited: true));
      } else if (entry.startsWith('song:')) {
        final raw = entry.substring(5);
        if (raw.contains('|')) {
          final parts = raw.split('|');
          final id = int.tryParse(parts[0]);
          final title = parts.length >= 2 ? _safeDecode(parts[1]) : (id != null && songMap.containsKey(id) ? songMap[id]!.title : 'Untitled');
          final lyrics = parts.length >= 3 ? _safeDecode(parts[2]) : (id != null && songMap.containsKey(id) ? songMap[id]!.lyrics : '');
          final baseSong = (id != null && songMap.containsKey(id)) ? songMap[id]! : Song();
          final editedSong = Song()
            ..id = baseSong.id
            ..syncId = baseSong.syncId
            ..title = title
            ..author = baseSong.author
            ..lyrics = lyrics
            ..backgroundUrl = baseSong.backgroundUrl;
          items.add(SongSetlistItem(editedSong, isFavorite: isFav, isEdited: true));
        } else {
          final id = int.tryParse(raw);
          if (id != null && songMap.containsKey(id)) {
            items.add(SongSetlistItem(songMap[id]!, isFavorite: isFav, isEdited: false));
          }
        }
      } else if (entry.startsWith('scripture:')) {
        final parts = entry.substring(10).split('|');
        if (parts.length >= 2) {
          final title = _safeDecode(parts[0]);
          final lyrics = _safeDecode(parts[1]);
          bool isDual = false;
          String? secTitle;
          String? secLyrics;
          String? bkAlias;
          String? secBkAlias;
          bool isEdited = false;
          String? customReference;
          if (parts.length >= 3) {
            isDual = parts[2] == '1' || parts[2].toLowerCase() == 'true';
          }
          if (parts.length >= 4 && parts[3].isNotEmpty) {
            secTitle = _safeDecode(parts[3]);
          }
          if (parts.length >= 5 && parts[4].isNotEmpty) {
            secLyrics = _safeDecode(parts[4]);
          }
          if (parts.length >= 6 && parts[5].isNotEmpty) {
            bkAlias = _safeDecode(parts[5]);
          }
          if (parts.length >= 7 && parts[6].isNotEmpty) {
            secBkAlias = _safeDecode(parts[6]);
          }
          if (parts.length >= 8 && parts[7].isNotEmpty) {
            isEdited = parts[7] == '1' || parts[7].toLowerCase() == 'true';
          }
          if (parts.length >= 9 && parts[8].isNotEmpty) {
            customReference = _safeDecode(parts[8]);
          }
          if ((secTitle != null && secTitle.isNotEmpty) || (secLyrics != null && secLyrics.isNotEmpty)) {
            isDual = true;
          }
          final mockSong = Song()
            ..title = title
            ..author = 'Bible'
            ..lyrics = lyrics
            ..isDualVersion = isDual
            ..secondaryTitle = secTitle
            ..secondaryLyrics = secLyrics
            ..bookAlias = bkAlias
            ..secondaryBookAlias = secBkAlias;
          items.add(SongSetlistItem(mockSong, isFavorite: isFav, isEdited: isEdited, customReference: customReference));
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
      switch (item) {
        case SongSetlistItem(:final song, :final isEdited, :final customReference):
          favorites.add(item.isFavorite);
          if (song.author == 'Bible') {
            final encodedTitle = Uri.encodeComponent(song.title);
            final encodedLyrics = Uri.encodeComponent(song.lyrics);
            final isDual = song.isDualVersion ? '1' : '0';
            final encodedSecTitle = Uri.encodeComponent(song.secondaryTitle ?? '');
            final encodedSecLyrics = Uri.encodeComponent(song.secondaryLyrics ?? '');
            final encodedBkAlias = Uri.encodeComponent(song.bookAlias ?? '');
            final encodedSecBkAlias = Uri.encodeComponent(song.secondaryBookAlias ?? '');
            final editedFlag = isEdited ? '1' : '0';
            final encodedCustomRef = Uri.encodeComponent(customReference ?? '');
            itemOrder.add('scripture:$encodedTitle|$encodedLyrics|$isDual|$encodedSecTitle|$encodedSecLyrics|$encodedBkAlias|$encodedSecBkAlias|$editedFlag|$encodedCustomRef');
          } else {
            songIds.add(song.id);
            if (isEdited) {
              final encodedTitle = Uri.encodeComponent(song.title);
              final encodedLyrics = Uri.encodeComponent(song.lyrics);
              itemOrder.add('custom_song:${song.id}|$encodedTitle|$encodedLyrics');
            } else {
              itemOrder.add('song:${song.id}');
            }
          }
        case ImageSetlistItem(:final imagePath, :final layout, :final alignment):
          favorites.add(item.isFavorite);
          final idx = imageEntries.length;
          imageEntries.add('$imagePath|$layout|$alignment');
          itemOrder.add('image:$idx');
        case WindowSetlistItem():
          break;
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
