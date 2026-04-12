import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../local/local_database_service.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/payment.dart';
import 'api_client.dart';
import 'connectivity_service.dart';

class OrderService {
  OrderService(
    this._client,
    this._localDatabase, {
    ConnectivityService? connectivityService,
  }) : _connectivityService = connectivityService ?? ConnectivityService();

  final ApiClient _client;
  final LocalDatabaseService _localDatabase;
  final ConnectivityService _connectivityService;

  Future<Order> createOrder({
    required String branchId,
    required String staffId,
    required List<CartItem> items,
  }) async {
    final orderNo = _generateUuid();
    final payload = _buildCreateOrderPayload(
      orderNo: orderNo,
      branchId: branchId,
      staffId: staffId,
      items: items,
    );

    if (!await _connectivityService.isOnline) {
      return _createOfflineOrder(
        branchId: branchId,
        staffId: staffId,
        items: items,
        orderNo: orderNo,
        payload: payload,
      );
    }

    await syncPendingQueue();

    try {
      final data =
          await _client.post('/orders', body: payload) as Map<String, dynamic>;
      final order = Order.fromJson(data);
      await _localDatabase.saveOrderSnapshot(
        order,
        localReferenceId: order.id,
        syncStatusAcc: order.paymentStatus == 'paid',
      );
      return order;
    } catch (error) {
      if (!_isOfflineError(error)) {
        rethrow;
      }
      return _createOfflineOrder(
        branchId: branchId,
        staffId: staffId,
        items: items,
        orderNo: orderNo,
        payload: payload,
      );
    }
  }

  Future<({Order order, double change})> addPayment({
    required String orderId,
    required String orderNo,
    required String method,
    required double amountReceived,
    String? refNo,
  }) async {
    if (await _connectivityService.isOnline) {
      await syncPendingQueue();
    }

    final remoteOrderId = await _localDatabase.getRemoteOrderIdByOrderNo(
      orderNo,
    );
    if (remoteOrderId != null) {
      try {
        final data =
            await _client.post(
                  '/orders/$remoteOrderId/payments',
                  body: {
                    'method': method,
                    'amount_received': amountReceived,
                    if (refNo != null) 'ref_no': refNo,
                  },
                )
                as Map<String, dynamic>;

        final change = double.parse((data['change'] ?? 0).toString());
        data.remove('change');
        final order = Order.fromJson(data);
        await _localDatabase.saveOrderSnapshot(
          order,
          localReferenceId: orderId,
          syncStatusAcc: order.paymentStatus == 'paid',
        );

        return (order: order.copyWith(id: orderId), change: change);
      } catch (error) {
        if (!_isOfflineError(error)) {
          rethrow;
        }
      }
    }

    return _queueOfflinePayment(
      orderId: orderId,
      orderNo: orderNo,
      method: method,
      amountReceived: amountReceived,
      refNo: refNo,
    );
  }

  Future<void> syncPendingQueue() async {
    if (!await _connectivityService.isOnline) {
      return;
    }

    var madeProgress = true;
    while (madeProgress && await _connectivityService.isOnline) {
      madeProgress = false;
      final queueItems = await _localDatabase.getPendingSyncQueue();
      if (queueItems.isEmpty) {
        return;
      }

      for (final queueItem in queueItems) {
        try {
          final payload =
              jsonDecode(queueItem.payloadJson) as Map<String, dynamic>;

          if (queueItem.entityType == 'order' && queueItem.action == 'create') {
            final data =
                await _client.post(
                      '/orders',
                      body: Map<String, dynamic>.from(payload),
                    )
                    as Map<String, dynamic>;
            final order = Order.fromJson(data);
            await _localDatabase.saveOrderSnapshot(
              order,
              localReferenceId: queueItem.localReferenceId ?? order.id,
              syncStatusAcc: order.paymentStatus == 'paid',
            );
            await _localDatabase.markSyncQueueCompleted(queueItem.queueKey);
            madeProgress = true;
            continue;
          }

          if (queueItem.entityType == 'payment' &&
              queueItem.action == 'create') {
            final orderNo = payload['order_no'] as String?;
            if (orderNo == null) {
              await _localDatabase.markSyncQueueFailed(queueItem.queueKey);
              madeProgress = true;
              continue;
            }

            final remoteOrderId = await _localDatabase
                .getRemoteOrderIdByOrderNo(orderNo);
            if (remoteOrderId == null) {
              continue;
            }

            final data =
                await _client.post(
                      '/orders/$remoteOrderId/payments',
                      body: {
                        'method': payload['method'],
                        'amount_received': payload['amount_received'],
                        if (payload['ref_no'] != null)
                          'ref_no': payload['ref_no'],
                      },
                    )
                    as Map<String, dynamic>;
            data.remove('change');
            final order = Order.fromJson(data);
            await _localDatabase.saveOrderSnapshot(
              order,
              localReferenceId: queueItem.localReferenceId ?? order.id,
              syncStatusAcc: order.paymentStatus == 'paid',
            );
            await _localDatabase.markSyncQueueCompleted(queueItem.queueKey);
            madeProgress = true;
          }
        } catch (error) {
          if (_isOfflineError(error)) {
            return;
          }
          await _localDatabase.markSyncQueueFailed(queueItem.queueKey);
          madeProgress = true;
        }
      }
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      await syncPendingQueue();
      final localOrders = await _localDatabase.getLocalOrders();
      final data = await _client.get('/orders') as List<dynamic>;
      final remoteOrders = data
          .map((entry) => Order.fromJson(entry as Map<String, dynamic>))
          .toList();

      final merged = <String, Order>{
        for (final remoteOrder in remoteOrders)
          remoteOrder.orderNo: remoteOrder,
        for (final localOrder in localOrders) localOrder.orderNo: localOrder,
      };

      final orders = merged.values.toList()
        ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
      return orders;
    } catch (error) {
      if (!_isOfflineError(error)) {
        rethrow;
      }
      return _localDatabase.getLocalOrders();
    }
  }

  Future<Order> getOrder(String id) async {
    try {
      final data = await _client.get('/orders/$id') as Map<String, dynamic>;
      return Order.fromJson(data);
    } catch (error) {
      if (!_isOfflineError(error)) {
        rethrow;
      }

      final localOrders = await _localDatabase.getLocalOrders();
      final localOrder = localOrders.cast<Order?>().firstWhere(
        (order) => order?.id == id,
        orElse: () => null,
      );
      if (localOrder == null) {
        rethrow;
      }
      return localOrder;
    }
  }

  Future<({Order order, double change})> _queueOfflinePayment({
    required String orderId,
    required String orderNo,
    required String method,
    required double amountReceived,
    String? refNo,
  }) async {
    final existingOrder = (await _localDatabase.getLocalOrders())
        .cast<Order?>()
        .firstWhere((order) => order?.id == orderId, orElse: () => null);
    if (existingOrder == null) {
      throw StateError('Order $orderId is not available in local storage');
    }

    final payment = Payment(
      id: _generateUuid(),
      orderId: orderId,
      method: method,
      amountReceived: amountReceived,
      refNo: refNo,
    );
    final totalPaid = existingOrder.payments.fold<double>(
      0,
      (sum, entry) => sum + entry.amountReceived,
    );
    final newTotalPaid = totalPaid + amountReceived;
    final change = max(
      0,
      _roundCurrency(newTotalPaid - existingOrder.netAmount),
    ).toDouble();
    final paymentStatus = newTotalPaid >= existingOrder.netAmount
        ? 'paid'
        : 'pending';

    final updatedOrder = existingOrder.copyWith(
      paymentStatus: paymentStatus,
      payments: [...existingOrder.payments, payment],
    );
    final existingRemoteOrderId = await _localDatabase
        .getRemoteOrderIdByOrderNo(orderNo);

    await _localDatabase.saveOrderSnapshot(
      updatedOrder,
      remoteId: existingRemoteOrderId ?? orderId,
      localReferenceId: orderId,
      syncStatusAcc: false,
      syncedAt: existingRemoteOrderId == null
          ? LocalDatabaseService.unsyncedMarker
          : DateTime.now(),
    );
    await _localDatabase.enqueueSyncAction(
      queueKey: 'payment:create:$orderNo:${payment.id}',
      entityType: 'payment',
      action: 'create',
      localReferenceId: orderId,
      payloadJson: jsonEncode({
        'order_no': orderNo,
        'method': method,
        'amount_received': amountReceived,
        if (refNo != null) 'ref_no': refNo,
      }),
    );

    return (order: updatedOrder, change: change);
  }

  Map<String, dynamic> _buildCreateOrderPayload({
    required String orderNo,
    required String branchId,
    required String staffId,
    required List<CartItem> items,
  }) {
    return {
      'order_no': orderNo,
      'branch_id': branchId,
      'staff_id': staffId,
      'discount_amount': 0,
      'items': items
          .map(
            (item) => {
              'product_id': item.product.id,
              'qty': item.qty,
              'unit_price': item.product.basePrice,
            },
          )
          .toList(),
    };
  }

  Future<Order> _createOfflineOrder({
    required String branchId,
    required String staffId,
    required List<CartItem> items,
    required String orderNo,
    required Map<String, dynamic> payload,
  }) async {
    final localOrder = _buildLocalOrder(
      branchId: branchId,
      staffId: staffId,
      orderNo: orderNo,
      items: items,
    );
    await _localDatabase.saveOrderSnapshot(
      localOrder,
      remoteId: localOrder.id,
      localReferenceId: localOrder.id,
      syncStatusAcc: false,
      syncedAt: LocalDatabaseService.unsyncedMarker,
    );
    await _localDatabase.enqueueSyncAction(
      queueKey: 'order:create:$orderNo',
      entityType: 'order',
      action: 'create',
      localReferenceId: localOrder.id,
      payloadJson: jsonEncode(payload),
    );
    return localOrder;
  }

  Order _buildLocalOrder({
    required String branchId,
    required String staffId,
    required String orderNo,
    required List<CartItem> items,
  }) {
    final localOrderId = _generateUuid();
    final createdAt = DateTime.now();
    final totalAmount = _roundCurrency(
      items.fold<double>(0, (sum, item) => sum + item.subtotal),
    );
    final discountAmount = 0.0;
    final vatAmount = _roundCurrency((totalAmount - discountAmount) * 0.07);
    final netAmount = _roundCurrency(totalAmount - discountAmount + vatAmount);

    return Order(
      id: localOrderId,
      orderNo: orderNo,
      branchId: branchId,
      staffId: staffId,
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      vatAmount: vatAmount,
      netAmount: netAmount,
      paymentStatus: 'pending',
      createdAt: createdAt,
      items: items
          .map(
            (item) => OrderItem(
              id: _generateUuid(),
              orderId: localOrderId,
              productId: item.product.id,
              qty: item.qty,
              unitPrice: item.product.basePrice,
              subtotal: _roundCurrency(item.subtotal),
            ),
          )
          .toList(),
    );
  }

  bool _isOfflineError(Object error) {
    return error is SocketException ||
        error is HttpException ||
        error is http.ClientException;
  }

  double _roundCurrency(num value) {
    return (value * 100).round() / 100;
  }

  String _generateUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hexByte(int byte) => byte.toRadixString(16).padLeft(2, '0');
    final hex = bytes.map(hexByte).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
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
    DateTime? createdAt,
    List<OrderItem>? items,
    List<Payment>? payments,
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
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      payments: payments ?? this.payments,
    );
  }
}
