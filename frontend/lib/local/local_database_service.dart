import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/payment.dart';
import '../models/product.dart';
import 'models/order_item_local.dart';
import 'models/order_local.dart';
import 'models/payment_local.dart';
import 'models/product_local.dart';
import 'models/sync_queue_local.dart';

class LocalDatabaseService {
  LocalDatabaseService();

  static final DateTime unsyncedMarker = DateTime.fromMillisecondsSinceEpoch(0);

  Isar? _isar;

  Future<Isar> open() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final directory = await getApplicationSupportDirectory();
    _isar = await Isar.open(
      [
        ProductLocalSchema,
        OrderLocalSchema,
        OrderItemLocalSchema,
        PaymentLocalSchema,
        SyncQueueLocalSchema,
      ],
      directory: directory.path,
      inspector: false,
    );
    return _isar!;
  }

  Future<void> cacheProducts(List<Product> products) async {
    final isar = await open();
    final localProducts = products.map(ProductLocal.fromDomain).toList();

    await isar.writeTxn(() async {
      await isar.productLocals.clear();
      await isar.productLocals.putAll(localProducts);
    });
  }

  Future<List<Product>> searchProducts({
    String search = '',
    String? categoryId,
  }) async {
    final isar = await open();
    final normalizedSearch = search.trim();

    final query = isar.productLocals.filter();
    final filtered = query
        .isActiveEqualTo(true)
        .optional(
          categoryId != null && categoryId.isNotEmpty,
          (q) => q.categoryIdEqualTo(categoryId),
        )
        .optional(
          normalizedSearch.isNotEmpty,
          (q) => q.group(
            (group) => group
                .nameContains(normalizedSearch, caseSensitive: false)
                .or()
                .skuContains(normalizedSearch, caseSensitive: false),
          ),
        );

    final localProducts = await filtered.sortByName().findAll();
    return localProducts.map((product) => product.toDomain()).toList();
  }

  Future<Product?> findProductBySku(String sku) async {
    final isar = await open();
    final localProduct = await isar.productLocals
        .filter()
        .skuEqualTo(sku.trim(), caseSensitive: false)
        .findFirst();

    return localProduct?.toDomain();
  }

  Future<List<Category>> getCategories() async {
    final isar = await open();
    final localProducts = await isar.productLocals
        .filter()
        .isActiveEqualTo(true)
        .findAll();
    final seen = <String>{};
    final categories = <Category>[];

    for (final product in localProducts) {
      final categoryId = product.categoryId;
      final categoryName = product.categoryName;
      if (categoryId == null || categoryName == null) {
        continue;
      }
      if (seen.add(categoryId)) {
        categories.add(Category(id: categoryId, name: categoryName));
      }
    }

    categories.sort((left, right) => left.name.compareTo(right.name));
    return categories;
  }

  Future<bool> hasCachedProducts() async {
    final isar = await open();
    return (await isar.productLocals.where().count()) > 0;
  }

  Future<void> saveOrderSnapshot(
    Order order, {
    String? remoteId,
    String? localReferenceId,
    bool? syncStatusAcc,
    DateTime? syncedAt,
  }) async {
    final isar = await open();
    final existingOrder = await isar.orderLocals
        .filter()
        .group(
          (query) => query
              .orderNoEqualTo(order.orderNo)
              .or()
              .localReferenceIdEqualTo(localReferenceId ?? order.id)
              .or()
              .remoteIdEqualTo(remoteId ?? order.id),
        )
        .findFirst();
    final resolvedLocalReferenceId =
        localReferenceId ?? existingOrder?.localReferenceId ?? order.id;
    final resolvedRemoteId = remoteId ?? order.id;
    final resolvedSyncedAt = syncedAt ?? DateTime.now();

    final orderLocal = OrderLocal.fromDomain(
      order,
      remoteId: resolvedRemoteId,
      localReferenceId: resolvedLocalReferenceId,
      syncStatusAcc: syncStatusAcc,
      syncedAt: resolvedSyncedAt,
    );
    if (existingOrder != null) {
      orderLocal.id = existingOrder.id;
    }

    final itemLocals = order.items
        .map(
          (item) => OrderItemLocal.fromDomain(resolvedLocalReferenceId, item),
        )
        .toList();
    final paymentLocals = order.payments
        .map(
          (payment) => PaymentLocal.fromDomain(
            resolvedLocalReferenceId,
            payment,
            syncedAt: resolvedSyncedAt,
          ),
        )
        .toList();

    await isar.writeTxn(() async {
      await isar.orderLocals.put(orderLocal);
      await isar.orderItemLocals
          .filter()
          .orderIdEqualTo(resolvedLocalReferenceId)
          .deleteAll();
      await isar.paymentLocals
          .filter()
          .orderIdEqualTo(resolvedLocalReferenceId)
          .deleteAll();
      if (itemLocals.isNotEmpty) {
        await isar.orderItemLocals.putAll(itemLocals);
      }
      if (paymentLocals.isNotEmpty) {
        await isar.paymentLocals.putAll(paymentLocals);
      }
    });
  }

  Future<List<Order>> getLocalOrders() async {
    final isar = await open();
    final orderLocals = await isar.orderLocals.where().findAll();
    final itemLocals = await isar.orderItemLocals.where().findAll();
    final paymentLocals = await isar.paymentLocals.where().findAll();

    final itemsByOrderId = <String, List<OrderItemLocal>>{};
    for (final item in itemLocals) {
      itemsByOrderId.putIfAbsent(item.orderId, () => []).add(item);
    }

    final paymentsByOrderId = <String, List<PaymentLocal>>{};
    for (final payment in paymentLocals) {
      paymentsByOrderId.putIfAbsent(payment.orderId, () => []).add(payment);
    }

    final orders =
        orderLocals.map((orderLocal) {
          final orderItems = (itemsByOrderId[orderLocal.localReferenceId] ?? [])
            ..sort((left, right) => left.id.compareTo(right.id));
          final payments =
              (paymentsByOrderId[orderLocal.localReferenceId] ?? [])
                ..sort((left, right) => left.id.compareTo(right.id));

          return Order(
            id: orderLocal.localReferenceId,
            orderNo: orderLocal.orderNo,
            branchId: orderLocal.branchId,
            staffId: orderLocal.staffId,
            totalAmount: orderLocal.totalAmount,
            discountAmount: orderLocal.discountAmount,
            vatAmount: orderLocal.vatAmount,
            netAmount: orderLocal.netAmount,
            paymentStatus: orderLocal.paymentStatus,
            syncStatusAcc: orderLocal.syncStatusAcc,
            createdAt: orderLocal.createdAt,
            items: orderItems
                .map(
                  (item) => OrderItem(
                    id: item.remoteId,
                    orderId: orderLocal.localReferenceId,
                    productId: item.productId,
                    qty: item.qty,
                    unitPrice: item.unitPrice,
                    subtotal: item.subtotal,
                  ),
                )
                .toList(),
            payments: payments
                .map(
                  (payment) => Payment(
                    id: payment.remoteId,
                    orderId: orderLocal.localReferenceId,
                    method: payment.method,
                    amountReceived: payment.amountReceived,
                    refNo: payment.refNo,
                  ),
                )
                .toList(),
          );
        }).toList()..sort(
          (left, right) => right.createdAt.compareTo(left.createdAt),
        );

    return orders;
  }

  Future<void> enqueueSyncAction({
    required String queueKey,
    required String entityType,
    required String action,
    String? localReferenceId,
    required String payloadJson,
  }) async {
    final isar = await open();
    final now = DateTime.now();
    final existing = await isar.syncQueueLocals.getByQueueKey(queueKey);
    final queueItem = existing ?? SyncQueueLocal();

    if (existing != null) {
      queueItem.id = existing.id;
      queueItem.createdAt = existing.createdAt;
      queueItem.retryCount = existing.retryCount;
    } else {
      queueItem.createdAt = now;
      queueItem.retryCount = 0;
    }

    queueItem
      ..queueKey = queueKey
      ..entityType = entityType
      ..action = action
      ..localReferenceId = localReferenceId
      ..payloadJson = payloadJson
      ..status = 'pending'
      ..updatedAt = now;

    await isar.writeTxn(() async {
      await isar.syncQueueLocals.putByQueueKey(queueItem);
    });
  }

  Future<List<SyncQueueLocal>> getPendingSyncQueue() async {
    final isar = await open();
    final queueItems = await isar.syncQueueLocals
        .filter()
        .group(
          (query) =>
              query.statusEqualTo('pending').or().statusEqualTo('failed'),
        )
        .findAll();

    queueItems.sort((left, right) {
      final createdAtComparison = left.createdAt.compareTo(right.createdAt);
      if (createdAtComparison != 0) {
        return createdAtComparison;
      }

      return _syncQueuePriority(left).compareTo(_syncQueuePriority(right));
    });
    return queueItems;
  }

  Future<void> markSyncQueueCompleted(String queueKey) async {
    final isar = await open();
    final existing = await isar.syncQueueLocals.getByQueueKey(queueKey);
    if (existing == null) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.syncQueueLocals.delete(existing.id);
    });
  }

  Future<void> markSyncQueueFailed(String queueKey) async {
    final isar = await open();
    final existing = await isar.syncQueueLocals.getByQueueKey(queueKey);
    if (existing == null) {
      return;
    }

    existing
      ..status = 'failed'
      ..retryCount += 1
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.syncQueueLocals.put(existing);
    });
  }

  Future<String?> getRemoteOrderIdByOrderNo(String orderNo) async {
    final isar = await open();
    final orderLocal = await isar.orderLocals
        .filter()
        .orderNoEqualTo(orderNo)
        .findFirst();
    if (orderLocal == null) {
      return null;
    }
    if (orderLocal.syncedAt == unsyncedMarker) {
      return null;
    }
    return orderLocal.remoteId;
  }

  int _syncQueuePriority(SyncQueueLocal queueItem) {
    if (queueItem.entityType == 'order' && queueItem.action == 'create') {
      return 0;
    }
    if (queueItem.entityType == 'payment' && queueItem.action == 'create') {
      return 1;
    }
    return 2;
  }
}
