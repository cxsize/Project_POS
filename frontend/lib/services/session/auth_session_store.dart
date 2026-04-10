import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';

abstract class AuthSessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

class SecureAuthSessionStore implements AuthSessionStore {
  static const _tokenKey = 'pos.auth.token';
  static const _userKey = 'pos.auth.user';

  final FlutterSecureStorage _storage;

  SecureAuthSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<AuthSession?> read() async {
    final token = await _storage.read(key: _tokenKey);
    final userJson = await _storage.read(key: _userKey);
    if (token == null || userJson == null) {
      return null;
    }

    final decodedUser = jsonDecode(userJson);
    if (decodedUser is! Map<String, dynamic>) {
      return null;
    }

    return AuthSession.fromJson({'token': token, 'user': decodedUser});
  }

  @override
  Future<void> write(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(
      key: _userKey,
      value: jsonEncode(session.toJson()['user']),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
