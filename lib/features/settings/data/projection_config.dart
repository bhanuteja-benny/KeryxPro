import 'package:isar/isar.dart';

part 'projection_config.g.dart';

@collection
class ProjectionConfig {
  Id id = Isar.autoIncrement;

  int? monitor1PresetId;
  int? monitor2PresetId;

  // Single config instance for the app
  static const int singletonId = 1;
}
