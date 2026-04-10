import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const _defaultApiBaseUrl = 'http://localhost:3000/api/v1';

  static String get apiBaseUrl {
    final configured = dotenv.maybeGet('API_BASE_URL')?.trim();
    if (configured == null || configured.isEmpty) {
      return _defaultApiBaseUrl;
    }
    return configured;
  }
}
