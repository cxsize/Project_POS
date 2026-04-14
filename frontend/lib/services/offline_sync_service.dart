import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_service.dart';
import 'order_service.dart';

class OfflineSyncService {
  OfflineSyncService(
    this._connectivityService,
    this._orderService, {
    Duration pollInterval = const Duration(seconds: 30),
    Duration initialRetryDelay = const Duration(seconds: 2),
    Duration maxRetryDelay = const Duration(minutes: 1),
  }) : _pollInterval = pollInterval,
       _initialRetryDelay = initialRetryDelay,
       _maxRetryDelay = maxRetryDelay,
       _retryDelay = initialRetryDelay;

  final ConnectivityService _connectivityService;
  final OrderService _orderService;
  final Duration _pollInterval;
  final Duration _initialRetryDelay;
  final Duration _maxRetryDelay;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _pollTimer;
  Timer? _retryTimer;
  bool _started = false;
  bool _isSyncing = false;
  Duration _retryDelay;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    _resetRetryDelay();
    _startPolling();
    unawaited(syncNowIfOnline());
    _subscription = _connectivityService.onConnectivityChanged.listen((
      results,
    ) {
      if (_connectivityService.hasOnlineConnection(results)) {
        _cancelRetryTimer();
        _resetRetryDelay();
        unawaited(syncNowIfOnline());
      }
    });
  }

  Future<void> stop() async {
    _started = false;
    await _subscription?.cancel();
    _subscription = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _cancelRetryTimer();
  }

  Future<void> syncNowIfOnline() async {
    if (_isSyncing || !await _connectivityService.isOnline) {
      return;
    }

    _isSyncing = true;
    try {
      await _orderService.syncPendingQueue();
      _cancelRetryTimer();
      _resetRetryDelay();
    } catch (_) {
      _scheduleRetry();
    } finally {
      _isSyncing = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!_started) {
        return;
      }
      unawaited(syncNowIfOnline());
    });
  }

  void _scheduleRetry() {
    if (_retryTimer != null || !_started) {
      return;
    }

    final delay = _retryDelay;
    _retryDelay = _nextRetryDelay(_retryDelay);
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      if (!_started) {
        return;
      }
      unawaited(syncNowIfOnline());
    });
  }

  Duration _nextRetryDelay(Duration current) {
    final doubledMs = current.inMilliseconds * 2;
    if (doubledMs >= _maxRetryDelay.inMilliseconds) {
      return _maxRetryDelay;
    }
    return Duration(milliseconds: doubledMs);
  }

  void _cancelRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void _resetRetryDelay() {
    _retryDelay = _initialRetryDelay;
  }
}
