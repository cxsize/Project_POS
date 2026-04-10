import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/app_environment.dart';

class AppConfigService {
  const AppConfigService();

  static const defaultApiBaseUrl = 'http://localhost:3000/api/v1';

  Future<AppEnvironment> load({
    required String localDatabasePath,
    required int registeredSchemaCount,
  }) async {
    await dotenv.load(fileName: '.env', isOptional: true);

    return AppEnvironment(
      apiBaseUrl: _readApiBaseUrl(),
      localDatabasePath: localDatabasePath,
      registeredSchemaCount: registeredSchemaCount,
    );
  }

  String _readApiBaseUrl() {
    final configuredValue = dotenv.maybeGet('API_BASE_URL')?.trim();
    if (configuredValue == null || configuredValue.isEmpty) {
      return defaultApiBaseUrl;
    }

    return configuredValue;
  }
}
