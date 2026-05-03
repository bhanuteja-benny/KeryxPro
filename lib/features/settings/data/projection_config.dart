import 'package:isar/isar.dart';

part 'projection_config.g.dart';

@collection
class ProjectionConfig {
  Id id = Isar.autoIncrement;

  int? monitor1PresetId;
  int? monitor2PresetId;

  // Monitor 1 Settings
  int monitor1MaxVerses = 1;
  int monitor1MaxChars = 0; // 0 means no limit
  String monitor1Format = 'Verse'; // 'Verse' or 'Paragraph'

  // Monitor 2 Settings (for future, but adding them now)
  int monitor2MaxVerses = 1;
  int monitor2MaxChars = 0;
  String monitor2Format = 'Verse';

  // Single config instance for the app
  static const int singletonId = 1;
}
