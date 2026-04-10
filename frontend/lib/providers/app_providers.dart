import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_environment.dart';
import '../services/app_config_service.dart';
import '../services/bootstrap_service.dart';
import '../services/local_database_service.dart';

final appConfigServiceProvider = Provider<AppConfigService>((ref) {
  return const AppConfigService();
});

final localDatabaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  return const LocalDatabaseService();
});

final bootstrapServiceProvider = Provider<BootstrapService>((ref) {
  return BootstrapService(
    configService: ref.watch(appConfigServiceProvider),
    localDatabaseService: ref.watch(localDatabaseServiceProvider),
  );
});

final startupProvider = FutureProvider<AppEnvironment>((ref) async {
  return ref.watch(bootstrapServiceProvider).initialize();
});
