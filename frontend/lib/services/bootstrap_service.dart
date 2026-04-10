import '../models/app_environment.dart';
import 'app_config_service.dart';
import 'local_database_service.dart';

class BootstrapService {
  const BootstrapService({
    required AppConfigService configService,
    required LocalDatabaseService localDatabaseService,
  }) : _configService = configService,
       _localDatabaseService = localDatabaseService;

  final AppConfigService _configService;
  final LocalDatabaseService _localDatabaseService;

  Future<AppEnvironment> initialize() async {
    final databaseState = await _localDatabaseService.initialize();

    return _configService.load(
      localDatabasePath: databaseState.directoryPath,
      registeredSchemaCount: databaseState.registeredSchemaCount,
    );
  }
}
