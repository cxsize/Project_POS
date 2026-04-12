import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'service_providers.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(localDatabaseServiceProvider).open();
  await ref.read(authProvider.notifier).restoreSession();

  if (ref.read(authProvider).isAuthenticated) {
    await ref.read(productServiceProvider).warmupCatalog();
  }
});
