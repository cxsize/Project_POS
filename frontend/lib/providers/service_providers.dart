import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/local_database_service.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/offline_sync_service.dart';
import '../services/order_service.dart';
import '../services/printer/printer_service.dart';
import '../services/product_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final localDatabaseServiceProvider = Provider<LocalDatabaseService>(
  (ref) => LocalDatabaseService(),
);
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final authService = AuthService(apiClient);
  apiClient.setUnauthorizedRecovery(authService.refreshAccessToken);
  return authService;
});

final productServiceProvider = Provider<ProductService>(
  (ref) => ProductService(
    ref.read(apiClientProvider),
    ref.read(localDatabaseServiceProvider),
  ),
);

final orderServiceProvider = Provider<OrderService>(
  (ref) => OrderService(
    ref.read(apiClientProvider),
    ref.read(localDatabaseServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
  ),
);

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final service = OfflineSyncService(
    ref.read(connectivityServiceProvider),
    ref.read(orderServiceProvider),
  );
  ref.onDispose(() {
    service.stop();
  });
  return service;
});

final printerServiceProvider = Provider<PrinterService>((ref) {
  return PrinterService();
});
