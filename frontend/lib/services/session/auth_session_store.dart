import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

import 'auth_session.dart';

abstract class AuthSessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

class FileAuthSessionStore implements AuthSessionStore {
  static const _directoryName = 'session';
  static const _fileName = 'auth_session.json';

  final Future<Directory> Function() _directoryProvider;

  FileAuthSessionStore({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  Future<File> _sessionFile() async {
    final directory = await _directoryProvider();
    final sessionDirectory = Directory(
      path.join(directory.path, _directoryName),
    );
    if (!await sessionDirectory.exists()) {
      await sessionDirectory.create(recursive: true);
    }
    return File(path.join(sessionDirectory.path, _fileName));
  }

  @override
  Future<AuthSession?> read() async {
    final file = await _sessionFile();
    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return null;
      }
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return AuthSession.fromJson(decoded);
    } on FormatException {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) async {
    final file = await _sessionFile();
    await file.writeAsString(jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() async {
    final file = await _sessionFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
