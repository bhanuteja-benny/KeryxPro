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

  static String _safeDecode(String s) {
    try {
      return Uri.decodeComponent(s);
    } catch (_) {
      return s;
    }
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
            'id': song.id,
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
            final title = _safeDecode(parts[0]);
            final lyrics = _safeDecode(parts[1]);
            bool isDual = false;
            String? secTitle;
            String? secLyrics;
            if (parts.length >= 3) {
              isDual = parts[2] == '1' || parts[2].toLowerCase() == 'true';
            }
            if (parts.length >= 4 && parts[3].isNotEmpty) {
              secTitle = _safeDecode(parts[3]);
            }
            if (parts.length >= 5 && parts[4].isNotEmpty) {
              secLyrics = _safeDecode(parts[4]);
            }
            if ((secTitle != null && secTitle.isNotEmpty) || (secLyrics != null && secLyrics.isNotEmpty)) {
              isDual = true;
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
        'songIds': setlist.songIds,
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

    if (!data.containsKey('name') ||
        (!data.containsKey('itemOrder') && !data.containsKey('scriptures') && !data.containsKey('songs'))) {
      throw Exception('Invalid setlist JSON file format.');
    }

    final isar = await _db;
    final name = data['name'] as String;
    final rawSyncId = data['syncId'] as String? ?? const Uuid().v4();

    // 1. Process and upsert songs contained in the JSON
    final songsData = data['songs'] as List<dynamic>? ?? [];
    final syncIdToLocalId = <String, int>{};
    final oldSongIdToNewSongId = <int, int>{};

    await isar.writeTxn(() async {
      for (final rawSong in songsData) {
        if (rawSong is Map<String, dynamic>) {
          final oldId = rawSong['id'] as int?;
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
            if (oldId != null) {
              oldSongIdToNewSongId[oldId] = newId;
            }
          } else {
            syncIdToLocalId[sSyncId] = existingSong.id;
            if (oldId != null) {
              oldSongIdToNewSongId[oldId] = existingSong.id;
            }
          }
        }
      }
    });

    // 2. Re-map songSyncIds & songIds
    final rawSongIds = List<int>.from(data['songIds'] ?? []);
    final rawSongSyncIds = List<String>.from(data['songSyncIds'] ?? []);
    final localSongIds = <int>[];
    final finalSongSyncIds = <String>[];

    for (int i = 0; i < rawSongSyncIds.length; i++) {
      final sSyncId = rawSongSyncIds[i];
      int? localId;
      if (syncIdToLocalId.containsKey(sSyncId)) {
        localId = syncIdToLocalId[sSyncId]!;
      } else {
        // Fallback search in Isar
        final s = await isar.songs.filter().syncIdEqualTo(sSyncId).findFirst();
        if (s != null) {
          localId = s.id;
          syncIdToLocalId[sSyncId] = localId;
        }
      }

      if (localId != null) {
        localSongIds.add(localId);
        finalSongSyncIds.add(sSyncId);
        if (i < rawSongIds.length) {
          oldSongIdToNewSongId[rawSongIds[i]] = localId;
        }
      }
    }

    // 3. Process itemOrder: Map song IDs and normalize/enrich scriptures (especially dual scriptures)
    final rawItemOrder = List<String>.from(data['itemOrder'] ?? []);
    final scripturesData = data['scriptures'] as List<dynamic>? ?? [];
    final processedItemOrder = <String>[];
    int scriptureCounter = 0;

    for (final entry in rawItemOrder) {
      if (entry.startsWith('song:')) {
        final oldId = int.tryParse(entry.substring(5));
        if (oldId != null && oldSongIdToNewSongId.containsKey(oldId)) {
          processedItemOrder.add('song:${oldSongIdToNewSongId[oldId]}');
        } else {
          processedItemOrder.add(entry);
        }
      } else if (entry.startsWith('scripture:')) {
        final raw = entry.substring(10);
        final parts = raw.split('|');

        // Case A: Index-based scripture reference, e.g. "scripture:0"
        if (parts.length == 1 && int.tryParse(parts[0]) != null) {
          final idx = int.parse(parts[0]);
          if (idx >= 0 && idx < scripturesData.length && scripturesData[idx] is Map<String, dynamic>) {
            final sc = scripturesData[idx] as Map<String, dynamic>;
            final title = sc['title'] as String? ?? '';
            final lyrics = sc['lyrics'] as String? ?? '';
            final isDual = sc['isDualVersion'] == true;
            final secTitle = sc['secondaryTitle'] as String? ?? '';
            final secLyrics = sc['secondaryLyrics'] as String? ?? '';
            final hasSec = secTitle.isNotEmpty || secLyrics.isNotEmpty;
            processedItemOrder.add(
              'scripture:${Uri.encodeComponent(title)}|${Uri.encodeComponent(lyrics)}|${(isDual || hasSec) ? '1' : '0'}|${Uri.encodeComponent(secTitle)}|${Uri.encodeComponent(secLyrics)}',
            );
            continue;
          }
        }

        // Case B: Delimited scripture item
        if (parts.length >= 2) {
          final title = _safeDecode(parts[0]);
          final lyrics = _safeDecode(parts[1]);
          bool isDual = false;
          String? secTitle;
          String? secLyrics;

          if (parts.length >= 3) {
            isDual = parts[2] == '1' || parts[2].toLowerCase() == 'true';
          }
          if (parts.length >= 4 && parts[3].isNotEmpty) {
            secTitle = _safeDecode(parts[3]);
          }
          if (parts.length >= 5 && parts[4].isNotEmpty) {
            secLyrics = _safeDecode(parts[4]);
          }

          // Check if scriptures array in JSON has richer dual version data for this entry
          if ((!isDual || secTitle == null || secLyrics == null) && scriptureCounter < scripturesData.length) {
            final sc = scripturesData[scriptureCounter] is Map<String, dynamic>
                ? scripturesData[scriptureCounter] as Map<String, dynamic>
                : null;
            if (sc != null) {
              if (sc['isDualVersion'] == true) isDual = true;
              if ((secTitle == null || secTitle.isEmpty) && sc['secondaryTitle'] != null) {
                secTitle = sc['secondaryTitle'] as String;
              }
              if ((secLyrics == null || secLyrics.isEmpty) && sc['secondaryLyrics'] != null) {
                secLyrics = sc['secondaryLyrics'] as String;
              }
            }
          }
          scriptureCounter++;

          if ((secTitle != null && secTitle.isNotEmpty) || (secLyrics != null && secLyrics.isNotEmpty)) {
            isDual = true;
          }

          processedItemOrder.add(
            'scripture:${Uri.encodeComponent(title)}|${Uri.encodeComponent(lyrics)}|${isDual ? '1' : '0'}|${Uri.encodeComponent(secTitle ?? '')}|${Uri.encodeComponent(secLyrics ?? '')}',
          );
        } else {
          processedItemOrder.add(entry);
        }
      } else {
        processedItemOrder.add(entry);
      }
    }

    // Fallback: If itemOrder had no scripture items but scriptures array has items, append them
    if (processedItemOrder.where((e) => e.startsWith('scripture:')).isEmpty && scripturesData.isNotEmpty) {
      for (final rawSc in scripturesData) {
        if (rawSc is Map<String, dynamic>) {
          final title = rawSc['title'] as String? ?? '';
          final lyrics = rawSc['lyrics'] as String? ?? '';
          final isDual = rawSc['isDualVersion'] == true;
          final secTitle = rawSc['secondaryTitle'] as String? ?? '';
          final secLyrics = rawSc['secondaryLyrics'] as String? ?? '';
          final hasSec = secTitle.isNotEmpty || secLyrics.isNotEmpty;
          processedItemOrder.add(
            'scripture:${Uri.encodeComponent(title)}|${Uri.encodeComponent(lyrics)}|${(isDual || hasSec) ? '1' : '0'}|${Uri.encodeComponent(secTitle)}|${Uri.encodeComponent(secLyrics)}',
          );
        }
      }
    }

    // Ensure favorites list matches itemOrder length
    final rawFavorites = List<bool>.from(data['favorites'] ?? []);
    final finalFavorites = List<bool>.generate(
      processedItemOrder.length,
      (i) => i < rawFavorites.length ? rawFavorites[i] : false,
    );

    // 4. Upsert SavedSetlist
    final existingSetlist = await isar.savedSetlists.where().nameEqualTo(name).findFirst();
    final setlistToSave = existingSetlist ?? SavedSetlist();

    setlistToSave
      ..syncId = existingSetlist?.syncId ?? rawSyncId
      ..name = name
      ..songIds = localSongIds
      ..songSyncIds = finalSongSyncIds
      ..imageEntries = List<String>.from(data['imageEntries'] ?? [])
      ..itemOrder = processedItemOrder
      ..favorites = finalFavorites
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
