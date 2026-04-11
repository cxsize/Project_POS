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
  static const _refreshTokenKey = 'pos.auth.refresh_token';
  static const _userKey = 'pos.auth.user';

  final FlutterSecureStorage _storage;

  SecureAuthSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<AuthSession?> read() async {
    final token = await _storage.read(key: _tokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final userJson = await _storage.read(key: _userKey);
    if (token == null || userJson == null) {
      return null;
    }

    final decodedUser = jsonDecode(userJson);
    if (decodedUser is! Map<String, dynamic>) {
      return null;
    }

    return AuthSession.fromJson({
      'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
      'user': decodedUser,
    });
  }

  @override
  Future<void> write(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    if (session.refreshToken == null || session.refreshToken!.isEmpty) {
      await _storage.delete(key: _refreshTokenKey);
    } else {
      await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
    }
    await _storage.write(
      key: _userKey,
      value: jsonEncode(session.toJson()['user']),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
}
