import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../features/songs/data/song.dart';
import '../../features/bible/data/bible.dart';
import '../../features/settings/data/presentation_settings.dart';
import '../../features/settings/data/projection_config.dart';
import '../../features/settings/data/app_settings.dart';
import '../../features/setlist/data/saved_setlist.dart';
import '../sync/data/processed_sync_event.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB().then((isar) {
      _warmUp(isar);
      return isar;
    });
  }

  void _warmUp(Isar isar) async {
    try {
      await isar.bibleVerses.where().findFirst();
      await isar.bibleVersions.where().findFirst();
    } catch (_) {}
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbDir = Directory('${appDocDir.path}${Platform.pathSeparator}KeryxPro');
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
      
      return await Isar.open(
        [
          SongSchema,
          BibleVersionSchema,
          BibleVerseSchema,
          PresentationSettingsSchema,
          ProjectionConfigSchema,
          AppSettingsSchema,
          SavedSetlistSchema,
          ProcessedSyncEventSchema,
        ],
        directory: dbDir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
