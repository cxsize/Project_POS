import '../local/local_database_service.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _client;
  final LocalDatabaseService _localDatabase;

  OrderService(this._client, this._localDatabase);

  Future<Order> createOrder({
    required String branchId,
    required String staffId,
    required List<CartItem> items,
  }) async {
    final data =
        await _client.post(
              '/orders',
              body: {
                'branch_id': branchId,
                'staff_id': staffId,
                'items': items
                    .map(
                      (item) => {
                        'product_id': item.product.id,
                        'qty': item.qty,
                      },
                    )
                    .toList(),
              },
            )
            as Map<String, dynamic>;

    final order = Order.fromJson(data);
    await _localDatabase.saveOrderSnapshot(order);
    return order;
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
}
