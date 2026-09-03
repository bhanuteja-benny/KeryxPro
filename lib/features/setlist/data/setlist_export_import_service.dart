import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/sync/sync_service.dart';
import '../../../main.dart';
import '../../songs/data/song.dart';
import 'saved_setlist.dart';

final setlistExportImportServiceProvider = Provider<SetlistExportImportService>((ref) {
  return SetlistExportImportService(
    ref.read(isarServiceProvider).db,
    ref.read(syncServiceProvider),
  );
});

class SetlistExportImportService {
  final Future<Isar> _db;
  final SyncService _syncService;

  SetlistExportImportService(this._db, this._syncService);

  /// Sanitizes setlist name for filesystem safety.
  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  /// Exports selected setlists to separate JSON files in the target directory.
  Future<int> exportSetlistsToFolder(List<SavedSetlist> setlists, String targetFolderPath) async {
    final isar = await _db;
    int count = 0;

    for (final setlist in setlists) {
      // Resolve songs referenced in this setlist
      final songs = await isar.songs.getAll(setlist.songIds);
      final songList = <Map<String, dynamic>>[];

      for (final song in songs) {
        if (song != null) {
          songList.add({
            'syncId': song.syncId,
            'title': song.title,
            'author': song.author,
            'lyrics': song.lyrics,
            'backgroundUrl': song.backgroundUrl,
            'lastModified': song.lastModified.millisecondsSinceEpoch,
          });
        }
      }

      // Extract scripture items from itemOrder
      final scriptureList = <Map<String, dynamic>>[];
      for (final entry in setlist.itemOrder) {
        if (entry.startsWith('scripture:')) {
          final parts = entry.substring(10).split('|');
          if (parts.length >= 2) {
            final title = Uri.decodeComponent(parts[0]);
            final lyrics = Uri.decodeComponent(parts[1]);
            bool isDual = false;
            String? secTitle;
            String? secLyrics;
            if (parts.length >= 5) {
              isDual = parts[2] == '1';
              secTitle = parts[3].isNotEmpty ? Uri.decodeComponent(parts[3]) : null;
              secLyrics = parts[4].isNotEmpty ? Uri.decodeComponent(parts[4]) : null;
            }
            scriptureList.add({
              'title': title,
              'lyrics': lyrics,
              'isDualVersion': isDual,
              'secondaryTitle': secTitle,
              'secondaryLyrics': secLyrics,
            });
          }
        }
      }

      final payload = {
        'version': 1,
        'syncId': setlist.syncId,
        'name': setlist.name,
        'songSyncIds': setlist.songSyncIds,
        'imageEntries': setlist.imageEntries,
        'itemOrder': setlist.itemOrder,
        'favorites': setlist.favorites,
        'lastModified': setlist.lastModified.millisecondsSinceEpoch,
        'songs': songList,
        'scriptures': scriptureList,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
      final fileName = '${_sanitizeFileName(setlist.name)}.json';
      final file = File('$targetFolderPath${Platform.pathSeparator}$fileName');

      await file.writeAsString(jsonString);
      count++;
    }

    return count;
  }

  /// Imports a setlist from a JSON file path.
  Future<SavedSetlist> importSetlistFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    if (!data.containsKey('name') || !data.containsKey('itemOrder')) {
      throw Exception('Invalid setlist JSON file format.');
    }

    final isar = await _db;
    final name = data['name'] as String;
    final rawSyncId = data['syncId'] as String? ?? const Uuid().v4();

    // 1. Process and upsert songs contained in the JSON
    final songsData = data['songs'] as List<dynamic>? ?? [];
    final syncIdToLocalId = <String, int>{};

    await isar.writeTxn(() async {
      for (final rawSong in songsData) {
        if (rawSong is Map<String, dynamic>) {
          final sSyncId = rawSong['syncId'] as String? ?? const Uuid().v4();
          final title = rawSong['title'] as String? ?? 'Untitled';
          final author = rawSong['author'] as String?;
          final lyrics = rawSong['lyrics'] as String? ?? '';
          final bgUrl = rawSong['backgroundUrl'] as String?;
          final lastMod = rawSong['lastModified'] as int? ?? DateTime.now().millisecondsSinceEpoch;

          var existingSong = await isar.songs.filter().syncIdEqualTo(sSyncId).findFirst();
          existingSong ??= await isar.songs.filter().titleEqualTo(title).and().authorEqualTo(author).findFirst();

          if (existingSong == null) {
            final newSong = Song()
              ..syncId = sSyncId
              ..title = title
              ..author = author
              ..lyrics = lyrics
              ..backgroundUrl = bgUrl
              ..lastModified = DateTime.fromMillisecondsSinceEpoch(lastMod);

            final newId = await isar.songs.put(newSong);
            syncIdToLocalId[sSyncId] = newId;
          } else {
            syncIdToLocalId[sSyncId] = existingSong.id;
          }
        }
      }
    });

    // 2. Re-map songSyncIds & songIds
    final rawSongSyncIds = List<String>.from(data['songSyncIds'] ?? []);
    final localSongIds = <int>[];
    final finalSongSyncIds = <String>[];

    for (final sSyncId in rawSongSyncIds) {
      if (syncIdToLocalId.containsKey(sSyncId)) {
        localSongIds.add(syncIdToLocalId[sSyncId]!);
        finalSongSyncIds.add(sSyncId);
      } else {
        // Fallback search in Isar
        final s = await isar.songs.filter().syncIdEqualTo(sSyncId).findFirst();
        if (s != null) {
          localSongIds.add(s.id);
          finalSongSyncIds.add(s.syncId);
        }
      }
    }

    // 3. Upsert SavedSetlist
    final existingSetlist = await isar.savedSetlists.where().nameEqualTo(name).findFirst();
    final setlistToSave = existingSetlist ?? SavedSetlist();

    setlistToSave
      ..syncId = existingSetlist?.syncId ?? rawSyncId
      ..name = name
      ..songIds = localSongIds
      ..songSyncIds = finalSongSyncIds
      ..imageEntries = List<String>.from(data['imageEntries'] ?? [])
      ..itemOrder = List<String>.from(data['itemOrder'] ?? [])
      ..favorites = List<bool>.from(data['favorites'] ?? [])
      ..lastModified = data['lastModified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastModified'] as int)
          : DateTime.now();

    await isar.writeTxn(() async {
      await isar.savedSetlists.put(setlistToSave);
    });

    _syncService.exportSetlist(setlistToSave);
    return setlistToSave;
  }
}
