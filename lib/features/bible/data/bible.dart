import 'package:isar/isar.dart';

part 'bible.g.dart';

@collection
class BibleVersion {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String abbreviation; // e.g., "KJV"
  
  late String name;         // e.g., "King James Version"
  late String language;
}

@collection
class BibleVerse {
  Id id = Isar.autoIncrement;

  // Link to the version
  @Index()
  late int bibleVersionId;

  @Index(type: IndexType.value)
  late String bookName;

  @Index()
  late int chapterNumber;

  @Index()
  late int verseNumber;

  // Used for rapid scripture searching across the entire bible.
  @Index(type: IndexType.value)
  late String text;
}
