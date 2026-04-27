import 'package:isar/isar.dart';

part 'saved_setlist.g.dart';

/// Persists a named SetList in the Isar database.
/// Songs are stored by their Isar IDs; image slides store their path + settings.
@collection
class SavedSetlist {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true, replace: true)
  late String name;

  /// Ordered list of song IDs in this setlist.
  late List<int> songIds;

  /// JSON-serialized image items. Stored as a JSON string list for Isar compatibility.
  /// Format per entry: "path|layout|alignment"
  late List<String> imageEntries;

  /// Ordered item order: each entry is either "song:<id>" or "image:<index>"
  /// This preserves mixed song + image ordering.
  late List<String> itemOrder;

  late DateTime lastModified;
}
