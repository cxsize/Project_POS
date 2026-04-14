import 'dart:async';
import 'dart:convert';

import '../local/local_database_service.dart';
import '../local/models/sync_queue_local.dart';
import '../models/order.dart';
import 'api_client.dart';
import 'connectivity_service.dart';

class OfflineSyncService {
  OfflineSyncService(this._client, this._localDatabase, this._connectivity);

  final ApiClient _client;
  final LocalDatabaseService _localDatabase;
  final ConnectivityService _connectivity;

  StreamSubscription<bool>? _statusSubscription;
  bool _started = false;
  bool _syncing = false;

  Future<void> start() async {
    if (_started) {
      return;
    }

    _started = true;
    _statusSubscription = _connectivity.onStatusChanged.listen((isOnline) {
      if (isOnline) {
        unawaited(flushPendingQueue());
      }
    });

    if (await _connectivity.isOnline()) {
      await flushPendingQueue();
    }
  }

  Future<void> stop() async {
    _started = false;
    await _statusSubscription?.cancel();
    _statusSubscription = null;
  }

  Future<void> flushPendingQueue() async {
    if (_syncing || !await _connectivity.isOnline()) {
      return;
    }

    _syncing = true;
    try {
      final queue = await _localDatabase.getPendingSyncQueue();
      for (final item in queue) {
        if (!_isReadyToRetry(item)) {
          continue;
        }

        try {
          await _processQueueItem(item);
          await _localDatabase.markSyncQueueCompleted(item.queueKey);
        } catch (_) {
          await _localDatabase.markSyncQueueFailed(item.queueKey);
        }
      }
    } finally {
      _syncing = false;
    }
  }

  bool _isReadyToRetry(SyncQueueLocal item) {
    if (item.status == LocalDatabaseService.pendingSyncStatus) {
      return true;
    }

    final waitSeconds = 1 << item.retryCount.clamp(0, 6);
    final readyAt = item.updatedAt.add(Duration(seconds: waitSeconds));
    return !readyAt.isAfter(DateTime.now());
  }

  Future<void> _processQueueItem(SyncQueueLocal item) async {
    switch (item.action) {
      case 'create-order':
        await _syncOrderCreate(item);
        return;
      default:
        throw UnsupportedError('Unsupported sync action: ${item.action}');
    }
  }

  Future<void> _syncOrderCreate(SyncQueueLocal item) async {
    final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
    final response =
        await _client.post('/orders', body: payload) as Map<String, dynamic>;
    final order = Order.fromJson(response);

    if (item.localReferenceId != null && item.localReferenceId!.isNotEmpty) {
      await _localDatabase.replaceOfflineOrderSnapshot(
        item.localReferenceId!,
        order,
      );
      return;
    }

    await _localDatabase.saveOrderSnapshot(order);
  }
}
