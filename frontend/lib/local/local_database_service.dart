import '../models/local/local_types.dart';
import '../models/local/order_local.dart';
import '../models/local/order_item_local.dart';
import '../models/local/payment_local.dart';
import '../models/local/product_local.dart';
import '../models/local/sync_queue_local.dart';

class LocalDatabaseConfig {
  final String databaseName;
  final int schemaVersion;
  final bool enableDebugLogging;

  const LocalDatabaseConfig({
    this.databaseName = LocalDatabaseMetadata.databaseName,
    this.schemaVersion = LocalDatabaseMetadata.schemaVersion,
    this.enableDebugLogging = false,
  });
}

/// Contract for the local POS store.
///
/// The main agent can back this with Isar using the collection names and
/// entities defined under `models/local/`.
abstract class LocalDatabaseService {
  Future<void> initialize({
    LocalDatabaseConfig config = const LocalDatabaseConfig(),
  });

  bool get isInitialized;

  Future<void> close();

  Future<T> runTransaction<T>(Future<T> Function() action);

  Stream<List<ProductLocal>> watchProducts({
    String? query,
    String? categoryId,
    bool onlyActive = true,
  });

  Future<List<ProductLocal>> getProducts({
    String? query,
    String? categoryId,
    bool onlyActive = true,
  });

  Future<ProductLocal?> getProductById(String id);

  Future<void> upsertProducts(Iterable<ProductLocal> products);

  Future<void> deleteProduct(String id);

  Stream<List<OrderLocal>> watchOrders({int limit = 50});

  Future<List<OrderLocal>> getRecentOrders({int limit = 50});

  Future<OrderLocal?> getOrderById(String id);

  Future<void> upsertOrder(
    OrderLocal order, {
    Iterable<OrderItemLocal> items = const [],
    Iterable<PaymentLocal> payments = const [],
  });

  Future<void> upsertOrderItems(Iterable<OrderItemLocal> items);

  Future<List<OrderItemLocal>> getOrderItemsByOrderId(String orderId);

  Future<void> deleteOrderItem(String id);

  Future<void> upsertPayments(Iterable<PaymentLocal> payments);

  Future<List<PaymentLocal>> getPaymentsByOrderId(String orderId);

  Future<void> deletePayment(String id);

  Future<void> deleteOrder(String id);

  Stream<List<SyncQueueLocal>> watchSyncQueue({LocalSyncStatus? status});

  Future<List<SyncQueueLocal>> getSyncQueue({LocalSyncStatus? status});

  Future<void> enqueueSync(SyncQueueLocal entry);

  Future<void> markSyncInProgress(String id);

  Future<void> markSyncComplete(String id);

  Future<void> markSyncFailed(
    String id, {
    String? errorMessage,
    DateTime? nextAttemptAt,
  });

  Future<void> clearAll();
}
