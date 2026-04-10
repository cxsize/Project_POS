enum LocalEntityType { product, order, orderItem, payment }

enum LocalSyncStatus { pending, inProgress, synced, failed }

enum LocalSyncOperation { upsert, delete }

class LocalDatabaseCollections {
  static const String products = 'products';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String payments = 'payments';
  static const String syncQueue = 'sync_queue';
}

class LocalDatabaseMetadata {
  static const String databaseName = 'pos_local_database';
  static const int schemaVersion = 1;
}

String encodeLocalEntityType(LocalEntityType value) => value.name;

LocalEntityType decodeLocalEntityType(String value) {
  switch (value) {
    case 'product':
      return LocalEntityType.product;
    case 'order':
      return LocalEntityType.order;
    case 'orderItem':
      return LocalEntityType.orderItem;
    case 'payment':
      return LocalEntityType.payment;
    default:
      return LocalEntityType.product;
  }
}

String encodeLocalSyncStatus(LocalSyncStatus value) => value.name;

LocalSyncStatus decodeLocalSyncStatus(String value) {
  switch (value) {
    case 'pending':
      return LocalSyncStatus.pending;
    case 'inProgress':
      return LocalSyncStatus.inProgress;
    case 'synced':
      return LocalSyncStatus.synced;
    case 'failed':
      return LocalSyncStatus.failed;
    default:
      return LocalSyncStatus.pending;
  }
}

String encodeLocalSyncOperation(LocalSyncOperation value) => value.name;

LocalSyncOperation decodeLocalSyncOperation(String value) {
  switch (value) {
    case 'upsert':
      return LocalSyncOperation.upsert;
    case 'delete':
      return LocalSyncOperation.delete;
    default:
      return LocalSyncOperation.upsert;
  }
}
