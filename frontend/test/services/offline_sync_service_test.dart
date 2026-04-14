import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/local/local_database_service.dart';
import 'package:pos_frontend/local/models/sync_queue_local.dart';
import 'package:pos_frontend/models/order.dart';
import 'package:pos_frontend/services/api_client.dart';
import 'package:pos_frontend/services/connectivity_service.dart';
import 'package:pos_frontend/services/offline_sync_service.dart';

void main() {
  group('OfflineSyncService', () {
    test(
      'flushPendingQueue syncs queued orders and marks them completed',
      () async {
        final apiClient = FakeSyncApiClient(
          responseByPath: {
            '/orders': {
              'id': 'remote-order-1',
              'order_no': 'ORD-001',
              'branch_id': 'branch-1',
              'staff_id': 'staff-1',
              'total_amount': 100,
              'discount_amount': 0,
              'vat_amount': 7,
              'net_amount': 107,
              'payment_status': 'pending',
              'sync_status_acc': false,
              'created_at': '2026-04-13T09:00:00.000Z',
              'items': const [],
              'payments': const [],
            },
          },
        );
        final localDatabase = FakeSyncLocalDatabaseService(
          queue: [
            SyncQueueLocal()
              ..queueKey = 'order-create-local-1'
              ..entityType = 'order'
              ..action = 'create-order'
              ..localReferenceId = 'local-1'
              ..payloadJson = jsonEncode({
                'branch_id': 'branch-1',
                'staff_id': 'staff-1',
                'items': [
                  {'product_id': 'prod-1', 'qty': 1},
                ],
              })
              ..status = LocalDatabaseService.pendingSyncStatus
              ..retryCount = 0
              ..createdAt = DateTime(2026, 4, 13, 9)
              ..updatedAt = DateTime(2026, 4, 13, 9),
          ],
        );
        final connectivity = FakeStreamConnectivityService(initialOnline: true);
        final service = OfflineSyncService(
          apiClient,
          localDatabase,
          connectivity,
        );

        await service.flushPendingQueue();

        expect(apiClient.requestedPaths, ['/orders']);
        expect(localDatabase.completedQueueKeys, ['order-create-local-1']);
        expect(localDatabase.replacedSnapshots.single.$1, 'local-1');
        expect(localDatabase.replacedSnapshots.single.$2.id, 'remote-order-1');
      },
    );
  });
}

class FakeSyncApiClient extends ApiClient {
  FakeSyncApiClient({required Map<String, dynamic> responseByPath})
    : _responseByPath = responseByPath,
      super(baseUrl: 'http://fake.local/api/v1');

  final Map<String, dynamic> _responseByPath;
  final List<String> requestedPaths = [];

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool retryOnUnauthorized = true,
  }) async {
    requestedPaths.add(path);
    return _responseByPath[path];
  }
}

class FakeStreamConnectivityService extends ConnectivityService {
  FakeStreamConnectivityService({required bool initialOnline})
    : _isOnline = initialOnline;

  final _controller = StreamController<bool>.broadcast();
  final bool _isOnline;

  @override
  Future<bool> isOnline() async => _isOnline;

  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  Future<void> dispose() async {
    await _controller.close();
  }
}

class FakeSyncLocalDatabaseService extends LocalDatabaseService {
  FakeSyncLocalDatabaseService({required this.queue});

  final List<SyncQueueLocal> queue;
  final List<String> completedQueueKeys = [];
  final List<(String, Order)> replacedSnapshots = [];

  @override
  Future<List<SyncQueueLocal>> getPendingSyncQueue({int limit = 20}) async {
    return queue.take(limit).toList();
  }

  @override
  Future<void> markSyncQueueCompleted(String queueKey) async {
    completedQueueKeys.add(queueKey);
  }

  @override
  Future<void> replaceOfflineOrderSnapshot(
    String localOrderId,
    Order syncedOrder,
  ) async {
    replacedSnapshots.add((localOrderId, syncedOrder));
  }
}
