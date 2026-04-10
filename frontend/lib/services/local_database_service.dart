import 'package:path_provider/path_provider.dart';

class LocalDatabaseState {
  const LocalDatabaseState({
    required this.directoryPath,
    required this.registeredSchemaCount,
  });

  final String directoryPath;
  final int registeredSchemaCount;
}

class LocalDatabaseService {
  const LocalDatabaseService();

  Future<LocalDatabaseState> initialize() async {
    final appDirectory = await getApplicationSupportDirectory();

    return LocalDatabaseState(
      directoryPath: appDirectory.path,
      registeredSchemaCount: 0,
    );
  }
}
