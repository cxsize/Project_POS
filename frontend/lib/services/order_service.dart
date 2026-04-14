import 'dart:math';

import '../local/local_database_service.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import 'api_client.dart';
import 'connectivity_service.dart';

class OrderService {
  final ApiClient _client;
  final LocalDatabaseService _localDatabase;
  final ConnectivityService _connectivity;

  OrderService(this._client, this._localDatabase, this._connectivity);

  Future<Order> createOrder({
    required String branchId,
    required String staffId,
    required List<CartItem> items,
  }) async {
    final requestBody = {
      'branch_id': branchId,
      'staff_id': staffId,
      'items': items
          .map((item) => {'product_id': item.product.id, 'qty': item.qty})
          .toList(),
    };

    if (!await _connectivity.isOnline()) {
      return _createOfflineOrder(
        branchId: branchId,
        staffId: staffId,
        items: items,
        requestBody: requestBody,
      );
    }

    try {
      final data =
          await _client.post('/orders', body: requestBody)
              as Map<String, dynamic>;
      final order = Order.fromJson(data);
      await _localDatabase.saveOrderSnapshot(order);
      return order;
    } catch (_) {
      return _createOfflineOrder(
        branchId: branchId,
        staffId: staffId,
        items: items,
        requestBody: requestBody,
      );
    }
  }

  Future<({Order order, double change})> addPayment({
    required String orderId,
    required String method,
    required double amountReceived,
    String? refNo,
  }) async {
    final data =
        await _client.post(
              '/orders/$orderId/payments',
              body: {
                'method': method,
                'amount_received': amountReceived,
                if (refNo != null) 'ref_no': refNo,
              },
            )
            as Map<String, dynamic>;

    final change = double.parse((data['change'] ?? 0).toString());

    // Remove 'change' before parsing order to avoid confusion
    data.remove('change');
    final order = Order.fromJson(data);
    await _localDatabase.saveOrderSnapshot(order);

    return (order: order, change: change);
  }

  Future<List<Order>> getOrders() async {
    final data = await _client.get('/orders') as List<dynamic>;
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrder(String id) async {
    final data = await _client.get('/orders/$id') as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  Future<Order> _createOfflineOrder({
    required String branchId,
    required String staffId,
    required List<CartItem> items,
    required Map<String, dynamic> requestBody,
  }) async {
    final now = DateTime.now();
    final orderId =
        'local-${now.microsecondsSinceEpoch}-${Random().nextInt(9999)}';
    final orderNo = 'OFF-${now.millisecondsSinceEpoch}';
    final totalAmount = items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
    final discountAmount = 0.0;
    final vatAmount = ((totalAmount - discountAmount) * 0.07);
    final netAmount = totalAmount - discountAmount + vatAmount;

    final order = Order(
      id: orderId,
      orderNo: orderNo,
      branchId: branchId,
      staffId: staffId,
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      vatAmount: double.parse(vatAmount.toStringAsFixed(2)),
      netAmount: double.parse(netAmount.toStringAsFixed(2)),
      paymentStatus: 'pending',
      syncStatusAcc: false,
      createdAt: now,
      items: [
        for (var index = 0; index < items.length; index += 1)
          OrderItem(
            id: '$orderId-item-$index',
            orderId: orderId,
            productId: items[index].product.id,
            qty: items[index].qty,
            unitPrice: items[index].product.basePrice,
            subtotal: items[index].subtotal,
          ),
      ],
    );

    await _localDatabase.saveOrderSnapshot(order);
    await _localDatabase.enqueueSyncAction(
      queueKey: 'order-create-$orderId',
      entityType: 'order',
      action: 'create-order',
      payload: requestBody,
      localReferenceId: orderId,
    );
    return order;
  }
}
