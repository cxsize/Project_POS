import 'package:isar/isar.dart';

part 'sync_queue_local.g.dart';

@collection
class SyncQueueLocal {
  SyncQueueLocal();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String queueKey;

  @Index()
  late String entityType;

  @Index()
  late String action;

  String? localReferenceId;
  late String payloadJson;

  @Index()
  late String status;

  late int retryCount;
  late DateTime createdAt;
  late DateTime updatedAt;
}
