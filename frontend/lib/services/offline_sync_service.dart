import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_service.dart';
import 'order_service.dart';

class OfflineSyncService {
  OfflineSyncService(this._connectivityService, this._orderService);

  final ConnectivityService _connectivityService;
  final OrderService _orderService;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;
  bool _isSyncing = false;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    unawaited(syncNowIfOnline());
    _subscription = _connectivityService.onConnectivityChanged.listen((
      results,
    ) {
      if (_connectivityService.hasOnlineConnection(results)) {
        unawaited(syncNowIfOnline());
      }
    });
  }

  Future<void> stop() async {
    _started = false;
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> syncNowIfOnline() async {
    if (_isSyncing || !await _connectivityService.isOnline) {
      return;
    }

    _isSyncing = true;
    try {
      await _orderService.syncPendingQueue();
    } finally {
      _isSyncing = false;
    }
  }
}
