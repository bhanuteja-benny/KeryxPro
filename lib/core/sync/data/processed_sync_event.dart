import 'package:isar/isar.dart';

part 'processed_sync_event.g.dart';

@collection
class ProcessedSyncEvent {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String eventId;

  late DateTime processedAt;
}
