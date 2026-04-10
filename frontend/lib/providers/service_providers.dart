import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/local_database_service.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final localDatabaseServiceProvider = Provider<LocalDatabaseService>(
  (ref) => LocalDatabaseService(),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(apiClientProvider)),
);

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
  ),
);
