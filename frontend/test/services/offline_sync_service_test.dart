import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/local/local_database_service.dart';
import 'package:pos_frontend/services/api_client.dart';
import 'package:pos_frontend/services/connectivity_service.dart';
import 'package:pos_frontend/services/offline_sync_service.dart';
import 'package:pos_frontend/services/order_service.dart';

void main() {
  test('starts syncing immediately and when connectivity returns', () async {
    final connectivityService = StreamConnectivityService(isOnline: false);
    final orderService = TrackingOrderService(connectivityService);
    final offlineSyncService = OfflineSyncService(
      connectivityService,
      orderService,
    );

    offlineSyncService.start();
    await Future<void>.delayed(Duration.zero);
    expect(orderService.syncCalls, 0);

    connectivityService.setOnline(true);
    connectivityService.emit(const [ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(orderService.syncCalls, 1);

    await offlineSyncService.stop();
  });
}

class StreamConnectivityService extends ConnectivityService {
  StreamConnectivityService({required bool isOnline}) : _isOnline = isOnline;

  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();
  bool _isOnline;

  void setOnline(bool isOnline) {
    _isOnline = isOnline;
  }

  void emit(List<ConnectivityResult> results) {
    _controller.add(results);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return [_isOnline ? ConnectivityResult.wifi : ConnectivityResult.none];
  }
}

class TrackingOrderService extends OrderService {
  TrackingOrderService(ConnectivityService connectivityService)
    : super(
        _NoopApiClient(),
        LocalDatabaseService(),
        connectivityService: connectivityService,
      );

  int syncCalls = 0;

  @override
  Future<void> syncPendingQueue() async {
    syncCalls += 1;
  }
}

class _NoopApiClient extends ApiClient {
  _NoopApiClient() : super(baseUrl: 'http://fake.local/api/v1');
}
