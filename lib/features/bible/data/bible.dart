import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'bible.g.dart';

@collection
class BibleVersion {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String syncId = const Uuid().v4();


  @Index(unique: true)
  late String abbreviation; // e.g., "KJV"
  
  late String name;         // e.g., "King James Version"
  late String language;

  String? bookNameMappingsJson;

  @ignore
  Map<String, String> get bookNameMappings {
    if (bookNameMappingsJson == null || bookNameMappingsJson!.isEmpty) return {};
    try {
      final decoded = jsonDecode(bookNameMappingsJson!);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }

  set bookNameMappings(Map<String, String> map) {
    bookNameMappingsJson = jsonEncode(map);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleVersion &&
          runtimeType == other.runtimeType &&
          (id == other.id || (abbreviation.isNotEmpty && abbreviation == other.abbreviation));

  @override
  int get hashCode => id.hashCode ^ abbreviation.hashCode;
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
