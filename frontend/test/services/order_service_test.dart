import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/local/local_database_service.dart';
import 'package:pos_frontend/models/cart_item.dart';
import 'package:pos_frontend/models/order.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/services/api_client.dart';
import 'package:pos_frontend/services/connectivity_service.dart';
import 'package:pos_frontend/services/order_service.dart';

void main() {
  group('OrderService', () {
    test(
      'createOrder stores offline snapshot and enqueues sync when offline',
      () async {
        final apiClient = FakeOrderApiClient();
        final localDatabase = FakeOrderLocalDatabaseService();
        final connectivity = FakeConnectivityService(initialOnline: false);
        final service = OrderService(apiClient, localDatabase, connectivity);

        final order = await service.createOrder(
          branchId: 'branch-1',
          staffId: 'staff-1',
          items: [
            CartItem(
              product: Product(
                id: 'prod-1',
                sku: 'SKU-1',
                name: 'Americano',
                basePrice: 90,
              ),
              qty: 2,
            ),
          ],
        );

        expect(apiClient.requestedPaths, isEmpty);
        expect(order.id, startsWith('local-'));
        expect(order.syncStatusAcc, isFalse);
        expect(localDatabase.savedOrders.single.id, order.id);
        expect(localDatabase.enqueuedActions.single.action, 'create-order');
        expect(localDatabase.enqueuedActions.single.localReferenceId, order.id);
      },
    );
  });
}

class FakeOrderApiClient extends ApiClient {
  FakeOrderApiClient() : super(baseUrl: 'http://fake.local/api/v1');

  final List<String> requestedPaths = [];

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool retryOnUnauthorized = true,
  }) async {
    requestedPaths.add(path);
    throw StateError('Unexpected network request');
  }
}

class FakeConnectivityService extends ConnectivityService {
  FakeConnectivityService({required bool initialOnline})
    : _isOnline = initialOnline;

  bool _isOnline;

  @override
  Future<bool> isOnline() async => _isOnline;

  void setOnline(bool value) {
    _isOnline = value;
  }
}

class FakeOrderLocalDatabaseService extends LocalDatabaseService {
  final List<Order> savedOrders = [];
  final List<EnqueuedAction> enqueuedActions = [];

  @override
  Future<void> saveOrderSnapshot(Order order) async {
    savedOrders.add(order);
  }

  @override
  Future<void> enqueueSyncAction({
    required String queueKey,
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
    String? localReferenceId,
  }) async {
    enqueuedActions.add(
      EnqueuedAction(
        queueKey: queueKey,
        entityType: entityType,
        action: action,
        payload: payload,
        localReferenceId: localReferenceId,
      ),
    );
  }
}

class EnqueuedAction {
  EnqueuedAction({
    required this.queueKey,
    required this.entityType,
    required this.action,
    required this.payload,
    required this.localReferenceId,
  });

  final String queueKey;
  final String entityType;
  final String action;
  final Map<String, dynamic> payload;
  final String? localReferenceId;
}
