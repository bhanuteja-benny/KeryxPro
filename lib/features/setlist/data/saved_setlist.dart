import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'saved_setlist.g.dart';

/// Persists a named SetList in the Isar database.
/// Songs are stored by their Isar IDs; image slides store their path + settings.
@collection
class SavedSetlist {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String syncId = const Uuid().v4();

  @Index(type: IndexType.value, unique: true, replace: true)
  late String name;

  /// Ordered list of song IDs in this setlist.
  late List<int> songIds;

  /// Ordered list of song sync IDs. Used for resolving across different machines.
  List<String> songSyncIds = [];


  /// JSON-serialized image items. Stored as a JSON string list for Isar compatibility.
  /// Format per entry: "path|layout|alignment"
  late List<String> imageEntries;

  /// Ordered item order: each entry is either "song:<id>" or "image:<index>"
  /// This preserves mixed song + image ordering.
  late List<String> itemOrder;

  /// Ordered favorite status for each item in itemOrder.
  late List<bool> favorites;

  late DateTime lastModified;
}
