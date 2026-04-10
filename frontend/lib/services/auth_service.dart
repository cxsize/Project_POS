import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<({String token, User user})> login(
      String username, String password) async {
    final data = await _client.post('/auth/login', body: {
      'username': username,
      'password': password,
    }) as Map<String, dynamic>;

    final token = data['access_token'] as String;
    _client.setToken(token);

    // Decode JWT payload (middle segment)
    final parts = token.split('.');
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;

    final user = User.fromJwtPayload(payload);
    return (token: token, user: user);
  }

  void logout() {
    _client.clearToken();
  }
}
