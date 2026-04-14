import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/local/local_database_service.dart';
import 'package:pos_frontend/local/models/sync_queue_local.dart';
import 'package:pos_frontend/models/cart_item.dart';
import 'package:pos_frontend/models/category.dart';
import 'package:pos_frontend/models/order.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/services/api_client.dart';
import 'package:pos_frontend/services/connectivity_service.dart';
import 'package:pos_frontend/services/order_service.dart';

void main() {
  group('OrderService offline sync', () {
    test(
      'createOrder stores a local snapshot and queue entry when offline',
      () async {
        final apiClient = FakeOrderApiClient(
          postResponses: {'/orders': const []},
        );
        final localDatabase = InMemoryLocalDatabaseService();
        final service = OrderService(
          apiClient,
          localDatabase,
          connectivityService: FakeConnectivityService(isOnline: false),
        );

        final order = await service.createOrder(
          branchId: _branchId,
          staffId: _staffId,
          items: [_cartItem],
        );

        expect(order.paymentStatus, 'pending');
        expect(order.items, hasLength(1));
        expect(localDatabase.orders, hasLength(1));
        expect(localDatabase.queueItems, hasLength(1));
        expect(localDatabase.queueItems.single.entityType, 'order');
        expect(localDatabase.queueItems.single.action, 'create');
        expect(localDatabase.queueItems.single.status, 'pending');
        expect(
          localDatabase.queueItems.single.payloadJson,
          contains(order.orderNo),
        );
        expect(localDatabase.orders.single.orderNo, order.orderNo);
      },
    );

    test('syncPendingQueue flushes queued local order and payment', () async {
      final remoteOrderId = 'f2082bcc-4d78-4049-bd38-f23402003caf';
      final remotePaymentId = '969be033-7e11-4130-b710-f77d2928224a';
      final queuedCreateOrderResponse = _buildOrderResponse(
        id: remoteOrderId,
        orderNo: 'will-be-replaced',
        paymentStatus: 'pending',
        payments: const [],
      );
      final queuedPaymentResponse = _buildOrderResponse(
        id: remoteOrderId,
        orderNo: 'will-be-replaced',
        paymentStatus: 'paid',
        payments: [
          {
            'id': remotePaymentId,
            'order_id': remoteOrderId,
            'method': 'cash',
            'amount_received': 90.95,
            'ref_no': null,
          },
        ],
        extra: {'change': 0},
      );
      final apiClient = FakeOrderApiClient(
        postResponses: {
          '/orders': [queuedCreateOrderResponse],
          '/orders/$remoteOrderId/payments': [queuedPaymentResponse],
        },
      );
      final localDatabase = InMemoryLocalDatabaseService();
      final connectivityService = FakeConnectivityService(isOnline: false);
      final service = OrderService(
        apiClient,
        localDatabase,
        connectivityService: connectivityService,
      );

      final localOrder = await service.createOrder(
        branchId: _branchId,
        staffId: _staffId,
        items: [_cartItem],
      );
      expect(localDatabase.queueItems, hasLength(1));
      queuedCreateOrderResponse['order_no'] = localOrder.orderNo;

      final paymentResult = await service.addPayment(
        orderId: localOrder.id,
        orderNo: localOrder.orderNo,
        method: 'cash',
        amountReceived: localOrder.netAmount,
      );

      expect(paymentResult.order.paymentStatus, 'paid');
      expect(localDatabase.queueItems, hasLength(2));
      expect(
        localDatabase.queueItems.map((entry) => entry.entityType),
        containsAll(['order', 'payment']),
      );

      queuedPaymentResponse['order_no'] = localOrder.orderNo;
      connectivityService.setOnline(true);

      await service.syncPendingQueue();

      expect(
        apiClient.requestLog,
        containsAll(['POST /orders', 'POST /orders/$remoteOrderId/payments']),
      );
      expect(localDatabase.queueItems, isEmpty);
      final syncedOrder = localDatabase.orders.single;
      expect(syncedOrder.orderNo, localOrder.orderNo);
      expect(
        localDatabase.getRemoteOrderIdByOrderNoValue(localOrder.orderNo),
        remoteOrderId,
      );
      expect(syncedOrder.paymentStatus, 'paid');
      expect(syncedOrder.payments, hasLength(1));
      expect(syncedOrder.payments.single.id, remotePaymentId);
    });
  });
}

final _category = Category(
  id: '8d8c2681-28de-4290-9d89-c6a2c8bef777',
  name: 'Coffee',
);

final _product = Product(
  id: '1ef6ea7d-c734-4387-9d8e-4fd2d1477ece',
  sku: 'LATTE-001',
  name: 'Iced Latte',
  basePrice: 85,
  categoryId: _category.id,
  category: _category,
);

final _cartItem = CartItem(product: _product);

const _branchId = 'f2d765be-f960-4f1b-8391-926b0dc9065e';
const _staffId = 'ca158fa4-c7f4-4a8d-96ba-d0d6b4c42c09';

Map<String, dynamic> _buildOrderResponse({
  required String id,
  required String orderNo,
  required String paymentStatus,
  bool syncStatusAcc = false,
  required List<Map<String, dynamic>> payments,
  Map<String, dynamic> extra = const {},
}) {
  return {
    'id': id,
    'order_no': orderNo,
    'branch_id': _branchId,
    'staff_id': _staffId,
    'total_amount': 85,
    'discount_amount': 0,
    'vat_amount': 5.95,
    'net_amount': 90.95,
    'payment_status': paymentStatus,
    'sync_status_acc': syncStatusAcc,
    'created_at': DateTime.utc(2026, 4, 12, 12).toIso8601String(),
    'items': [
      {
        'id': '9d2de6f2-e0ea-4a0f-91af-fdf7274f9479',
        'order_id': id,
        'product_id': _product.id,
        'qty': 1,
        'unit_price': 85,
        'subtotal': 85,
      },
    ],
    'payments': payments,
    ...extra,
  };
}

class FakeOrderApiClient extends ApiClient {
  FakeOrderApiClient({required this.postResponses})
    : super(baseUrl: 'http://fake.local/api/v1');

  final Map<String, List<Object>> postResponses;
  final List<String> requestLog = [];

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool retryOnUnauthorized = true,
  }) async {
    requestLog.add('POST $path');
    final responses = postResponses[path];
    if (responses == null || responses.isEmpty) {
      throw StateError('Unexpected POST request: $path');
    }

    final next = responses.removeAt(0);
    if (next is Exception) {
      throw next;
    }

    return next;
  }
}

class InMemoryLocalDatabaseService extends LocalDatabaseService {
  final List<Order> orders = [];
  final List<SyncQueueLocal> queueItems = [];
  final Map<String, String?> _remoteIdByOrderNo = {};
  final Map<String, DateTime> _syncedAtByOrderNo = {};

  @override
  Future<void> saveOrderSnapshot(
    Order order, {
    String? remoteId,
    String? localReferenceId,
    bool? syncStatusAcc,
    DateTime? syncedAt,
  }) async {
    final localId = localReferenceId ?? order.id;
    final storedOrder = order.copyWith(id: localId);
    orders.removeWhere((entry) => entry.orderNo == order.orderNo);
    orders.add(storedOrder);
    _remoteIdByOrderNo[order.orderNo] = remoteId ?? order.id;
    _syncedAtByOrderNo[order.orderNo] = syncedAt ?? DateTime.now();
  }

  @override
  Future<List<Order>> getLocalOrders() async {
    final copied = [...orders];
    copied.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return copied;
  }

  @override
  Future<void> enqueueSyncAction({
    required String queueKey,
    required String entityType,
    required String action,
    String? localReferenceId,
    required String payloadJson,
  }) async {
    queueItems.removeWhere((entry) => entry.queueKey == queueKey);
    final queueItem = SyncQueueLocal()
      ..queueKey = queueKey
      ..entityType = entityType
      ..action = action
      ..localReferenceId = localReferenceId
      ..payloadJson = payloadJson
      ..status = 'pending'
      ..retryCount = 0
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    queueItems.add(queueItem);
  }

  @override
  Future<List<SyncQueueLocal>> getPendingSyncQueue() async {
    final copied = [
      for (final item in queueItems)
        if (item.status == 'pending' || item.status == 'failed') item,
    ];
    copied.sort((left, right) {
      final createdAtComparison = left.createdAt.compareTo(right.createdAt);
      if (createdAtComparison != 0) {
        return createdAtComparison;
      }

      return _syncQueuePriority(left).compareTo(_syncQueuePriority(right));
    });
    return copied;
  }

  @override
  Future<void> markSyncQueueCompleted(String queueKey) async {
    queueItems.removeWhere((entry) => entry.queueKey == queueKey);
  }

  @override
  Future<void> markSyncQueueFailed(String queueKey) async {
    final entry = queueItems.firstWhere((item) => item.queueKey == queueKey);
    entry
      ..status = 'failed'
      ..retryCount += 1
      ..updatedAt = DateTime.now();
  }

  @override
  Future<String?> getRemoteOrderIdByOrderNo(String orderNo) async {
    final syncedAt = _syncedAtByOrderNo[orderNo];
    if (syncedAt == null || syncedAt == LocalDatabaseService.unsyncedMarker) {
      return null;
    }
    return _remoteIdByOrderNo[orderNo];
  }

  String? getRemoteOrderIdByOrderNoValue(String orderNo) {
    return _remoteIdByOrderNo[orderNo];
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

class FakeConnectivityService extends ConnectivityService {
  FakeConnectivityService({required bool isOnline}) : _isOnline = isOnline;

  bool _isOnline;

  void setOnline(bool value) {
    _isOnline = value;
  }

  @override
  Future<bool> get isOnline async => _isOnline;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return [_isOnline ? ConnectivityResult.wifi : ConnectivityResult.none];
  }
}

extension on Order {
  Order copyWith({
    String? id,
    String? orderNo,
    String? branchId,
    String? staffId,
    double? totalAmount,
    double? discountAmount,
    double? vatAmount,
    double? netAmount,
    String? paymentStatus,
    bool? syncStatusAcc,
    DateTime? createdAt,
    List<dynamic>? items,
    List<dynamic>? payments,
  }) {
    return Order(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      branchId: branchId ?? this.branchId,
      staffId: staffId ?? this.staffId,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      netAmount: netAmount ?? this.netAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      syncStatusAcc: syncStatusAcc ?? this.syncStatusAcc,
      createdAt: createdAt ?? this.createdAt,
      items: (items ?? this.items).cast(),
      payments: (payments ?? this.payments).cast(),
    );
  }
}
