import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'song.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String syncId = const Uuid().v4();


  @Index(type: IndexType.value)
  late String title;

  String? author;

  // Storing lyrics as a block for full-text search capability.
  @Index(type: IndexType.value)
  late String lyrics;

  String? backgroundUrl;

  late DateTime lastModified;
}
