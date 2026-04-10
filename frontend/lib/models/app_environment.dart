class AppEnvironment {
  const AppEnvironment({
    required this.apiBaseUrl,
    required this.localDatabasePath,
    required this.registeredSchemaCount,
  });

  final String apiBaseUrl;
  final String localDatabasePath;
  final int registeredSchemaCount;
}
