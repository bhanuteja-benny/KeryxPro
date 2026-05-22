import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';

import 'sync_config.dart';
import '../database/isar_service.dart';
import '../../../main.dart';
import 'data/processed_sync_event.dart';
import '../../features/songs/data/song.dart';
import '../../features/setlist/data/saved_setlist.dart';
import '../../features/settings/data/presentation_settings.dart';
import '../../features/bible/data/bible.dart';
import '../../features/bible/data/bible_import_service.dart';
import 'dart:async';

final syncConfigProvider = Provider<SyncConfig>((ref) {
  throw UnimplementedError('SyncConfig not initialized');
});

final hasPendingSyncProvider = StateProvider<bool>((ref) => false);

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    ref.read(isarServiceProvider),
    ref.read(syncConfigProvider),
    ref,
  );
  service.initBackgroundWatcher();
  return service;
});

class SyncService {
  final IsarService _isarService;
  final SyncConfig _config;
  final Ref _ref;
  StreamSubscription? _dirWatcher;

  SyncService(this._isarService, this._config, this._ref);

  /// Helper to get the absolute path to the sync folder
  String? get _syncFolderPath => _config.syncFolderPath;

  /// Check if sync is enabled and folder is set
  bool get canSync => _config.syncEnabled && _syncFolderPath != null && Directory(_syncFolderPath!).existsSync();

  /// Writes an event to the sync folder
  Future<void> _exportEvent(String type, Map<String, dynamic> payload) async {
    if (!canSync) return;

    final eventId = const Uuid().v4();
    final event = {
      'eventId': eventId,
      'machineId': _config.machineId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'payload': payload,
    };

    final jsonString = jsonEncode(event);
    final file = File('$_syncFolderPath${Platform.pathSeparator}event_$eventId.json');
    
    try {
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error exporting sync event: $e');
    }
  }

  // ---- Exporters ---- //

  Future<void> exportSong(Song song, {bool deleted = false}) async {
    if (deleted) {
      await _exportEvent('SONG_DELETE', {'syncId': song.syncId});
    } else {
      await _exportEvent('SONG_UPSERT', {
        'syncId': song.syncId,
        'title': song.title,
        'author': song.author,
        'lyrics': song.lyrics,
        'backgroundUrl': song.backgroundUrl,
        'lastModified': song.lastModified.millisecondsSinceEpoch,
      });
    }
  }

  Future<void> exportSetlist(SavedSetlist setlist, {bool deleted = false}) async {
    if (deleted) {
      await _exportEvent('SETLIST_DELETE', {'syncId': setlist.syncId});
    } else {
      await _exportEvent('SETLIST_UPSERT', {
        'syncId': setlist.syncId,
        'name': setlist.name,
        'songSyncIds': setlist.songSyncIds,
        'imageEntries': setlist.imageEntries,
        'itemOrder': setlist.itemOrder,
        'favorites': setlist.favorites,
        'lastModified': setlist.lastModified.millisecondsSinceEpoch,
      });
    }
  }

  Future<void> exportPresentationSettings(PresentationSettings settings) async {
    await _exportEvent('PRESET_UPSERT', settings.toMap());
  }

  Future<void> exportPresetDelete(String syncId) async {
    await _exportEvent('PRESET_DELETE', {'syncId': syncId});
  }

  Future<void> exportBible(BibleVersion version, String sourceFilePath) async {
    if (!canSync) return;
    
    final biblesDir = Directory('$_syncFolderPath${Platform.pathSeparator}Bibles');
    if (!biblesDir.existsSync()) {
      biblesDir.createSync(recursive: true);
    }
    
    final destFile = File('${biblesDir.path}${Platform.pathSeparator}${version.abbreviation}.xml');
    await File(sourceFilePath).copy(destFile.path);

    await _exportEvent('BIBLE_IMPORT', {
      'syncId': version.syncId,
      'abbreviation': version.abbreviation,
      'filename': '${version.abbreviation}.xml',
    });
  }

  // ---- Importer (Poll & Apply) ---- //

  void initBackgroundWatcher() {
    if (!canSync) return;
    final dir = Directory(_syncFolderPath!);
    
    // Initial check
    _checkForPendingEvents();

    // Watch for new files
    try {
      _dirWatcher = dir.watch(events: FileSystemEvent.create).listen((event) {
        if (event.path.endsWith('.json') && event.path.contains('event_')) {
          _checkForPendingEvents();
        }
      });
    } catch (e) {
      print('Error setting up directory watcher: $e');
      // Fallback to polling every 10 seconds if watch fails (e.g., network drives)
      Timer.periodic(const Duration(seconds: 10), (_) => _checkForPendingEvents());
    }
  }

  Future<void> _checkForPendingEvents() async {
    if (!canSync) return;

    final dir = Directory(_syncFolderPath!);
    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json') && f.path.contains('event_'));

    final isar = await _isarService.db;
    bool hasPending = false;

    for (final file in files) {
      try {
        final content = await file.readAsString();
        final event = jsonDecode(content) as Map<String, dynamic>;

        final eventId = event['eventId'] as String;
        final machineId = event['machineId'] as String;
        final type = event['type'] as String;

        // Ignore our own events
        if (machineId == _config.machineId) continue;

        // Check if already processed
        final alreadyProcessed = await isar.processedSyncEvents.filter().eventIdEqualTo(eventId).findFirst();
        if (alreadyProcessed != null) continue;

        // Automatically process Bible imports in the background
        if (type == 'BIBLE_IMPORT') {
          final payload = event['payload'] as Map<String, dynamic>;
          await isar.writeTxn(() async {
            await _applyEvent(isar, type, payload);
            final processed = ProcessedSyncEvent()..eventId = eventId..processedAt = DateTime.now();
            await isar.processedSyncEvents.put(processed);
          });
          continue; // Don't flag as pending since we just applied it
        }

        hasPending = true;
      } catch (e) {
        // ignore malformed files
      }
    }

    _ref.read(hasPendingSyncProvider.notifier).state = hasPending;
  }

  Future<void> syncPendingEvents() async {
    if (!canSync) return;

    final dir = Directory(_syncFolderPath!);
    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json') && f.path.contains('event_'));

    final isar = await _isarService.db;

    for (final file in files) {
      try {
        final content = await file.readAsString();
        final event = jsonDecode(content) as Map<String, dynamic>;

        final eventId = event['eventId'] as String;
        final machineId = event['machineId'] as String;

        // Ignore our own events
        if (machineId == _config.machineId) continue;

        // Check if already processed
        final alreadyProcessed = await isar.processedSyncEvents.filter().eventIdEqualTo(eventId).findFirst();
        if (alreadyProcessed != null) continue;

        // Process Event
        final type = event['type'] as String;
        final payload = event['payload'] as Map<String, dynamic>;

        await isar.writeTxn(() async {
          await _applyEvent(isar, type, payload);
          
          // Mark as processed
          final processed = ProcessedSyncEvent()
            ..eventId = eventId
            ..processedAt = DateTime.now();
          await isar.processedSyncEvents.put(processed);
        });
      } catch (e) {
        print('Error processing sync file ${file.path}: $e');
      }
    }
    
    // Clear pending badge and refresh UI
    _ref.read(hasPendingSyncProvider.notifier).state = false;
    // We should ideally trigger refresh on providers, but since it's granular,
    // reloading the UI or forcing a search refresh might be needed.
    // Riverpod's `ref.invalidate` for the lists could be done here:
    // We can't easily access all providers here, but when the user clicks the UI they are usually on a specific tab.
  }

  Future<void> _applyEvent(Isar isar, String type, Map<String, dynamic> payload) async {
    switch (type) {
      case 'SONG_UPSERT':
        final syncId = payload['syncId'] as String;
        var song = await isar.songs.filter().syncIdEqualTo(syncId).findFirst();
        song ??= Song()..syncId = syncId;
        song.title = payload['title'] as String;
        song.author = payload['author'] as String?;
        song.lyrics = payload['lyrics'] as String;
        song.backgroundUrl = payload['backgroundUrl'] as String?;
        song.lastModified = DateTime.fromMillisecondsSinceEpoch(payload['lastModified'] as int);
        await isar.songs.put(song);
        break;

      case 'SONG_DELETE':
        final syncId = payload['syncId'] as String;
        await isar.songs.filter().syncIdEqualTo(syncId).deleteAll();
        break;

      case 'SETLIST_UPSERT':
        final syncId = payload['syncId'] as String;
        var setlist = await isar.savedSetlists.filter().syncIdEqualTo(syncId).findFirst();
        setlist ??= SavedSetlist()..syncId = syncId;
        setlist.name = payload['name'] as String;
        
        // Resolve songSyncIds to local Isar IDs
        final songSyncIds = List<String>.from(payload['songSyncIds'] ?? []);
        setlist.songSyncIds = songSyncIds;
        final localSongIds = <int>[];
        for (final sId in songSyncIds) {
          final localSong = await isar.songs.filter().syncIdEqualTo(sId).findFirst();
          if (localSong != null) {
            localSongIds.add(localSong.id);
          }
        }
        setlist.songIds = localSongIds;

        setlist.imageEntries = List<String>.from(payload['imageEntries'] ?? []);
        setlist.itemOrder = List<String>.from(payload['itemOrder'] ?? []);
        setlist.favorites = List<bool>.from(payload['favorites'] ?? []);
        setlist.lastModified = DateTime.fromMillisecondsSinceEpoch(payload['lastModified'] as int);
        await isar.savedSetlists.put(setlist);
        break;

      case 'SETLIST_DELETE':
        final syncId = payload['syncId'] as String;
        await isar.savedSetlists.filter().syncIdEqualTo(syncId).deleteAll();
        break;

      case 'PRESET_UPSERT':
        final syncId = payload['syncId'] as String;
        var preset = await isar.presentationSettings.filter().syncIdEqualTo(syncId).findFirst();
        // payload represents the full toMap()
        final newPreset = PresentationSettings.fromMap(payload);
        if (preset != null) {
          newPreset.id = preset.id; // Retain local Isar ID to update existing
        }
        await isar.presentationSettings.put(newPreset);
        break;

      case 'PRESET_DELETE':
        final syncId = payload['syncId'] as String;
        await isar.presentationSettings.filter().syncIdEqualTo(syncId).deleteAll();
        break;

      case 'BIBLE_IMPORT':
        final syncId = payload['syncId'] as String;
        final filename = payload['filename'] as String;
        final abbreviation = payload['abbreviation'] as String;
        
        final existing = await isar.bibleVersions.filter().syncIdEqualTo(syncId).or().abbreviationEqualTo(abbreviation).findFirst();
        if (existing != null) break; // already have it

        final filePath = '$_syncFolderPath${Platform.pathSeparator}Bibles${Platform.pathSeparator}$filename';
        if (File(filePath).existsSync()) {
          final result = await BibleImportService.parseBibleFile(filePath);
          if (result != null && result.verses.isNotEmpty) {
            // Because this is inside a transaction, we must do Isar writes directly here rather than calling a repository.
            // Wait, BibleRepository uses writeTxn, but we are ALREADY inside writeTxn here.
            // Let's just write to Isar directly.
            result.version.syncId = syncId;
            await isar.bibleVersions.put(result.version);
            
            // Link verses
            for (var verse in result.verses) {
              verse.bibleVersionId = result.version.id;
            }
            await isar.bibleVerses.putAll(result.verses);
          }
        }
        break;
    }
  }
}
