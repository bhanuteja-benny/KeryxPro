import 'package:isar/isar.dart';
import '../../../core/database/isar_service.dart';
import 'bible.dart';

class BibleRepository {
  final IsarService _isarService;

  BibleRepository(this._isarService);

  Future<void> saveBible(BibleVersion version, List<BibleVerse> verses) async {
    final isar = await _isarService.db;

    await isar.writeTxn(() async {
      // Check if version with same abbreviation exists
      final existingVersion = await isar.bibleVersions
          .filter()
          .abbreviationEqualTo(version.abbreviation)
          .findFirst();

      int versionId;
      if (existingVersion != null) {
        // Delete existing verses for this version
        await isar.bibleVerses
            .filter()
            .bibleVersionIdEqualTo(existingVersion.id)
            .deleteAll();
        
        version.id = existingVersion.id;
        versionId = await isar.bibleVersions.put(version);
      } else {
        versionId = await isar.bibleVersions.put(version);
      }

      // Link verses to the version
      for (var verse in verses) {
        verse.bibleVersionId = versionId;
      }

      // Batch insert verses
      // putAll is much faster for large datasets
      await isar.bibleVerses.putAll(verses);
    });
  }

  Future<List<BibleVersion>> getVersions() async {
    final isar = await _isarService.db;
    return await isar.bibleVersions.where().findAll();
  }
}
