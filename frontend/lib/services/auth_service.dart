import 'session/auth_session.dart';
import 'session/auth_session_store.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client;
  final AuthSessionStore _sessionStore;

  AuthService(this._client, {AuthSessionStore? sessionStore})
    : _sessionStore = sessionStore ?? SecureAuthSessionStore();

  Future<AuthSession> login(String username, String password) async {
    final data =
        await _client.post(
              '/auth/login',
              body: {'username': username, 'password': password},
            )
            as Map<String, dynamic>;

    final token = data['access_token'] as String;
    final payload = decodeJwtPayload(token);
    final session = AuthSession(
      token: token,
      user: userFromJwtPayload(payload),
    );

    await _sessionStore.write(session);
    _client.setToken(token);
    return session;
  }

  Future<AuthSession?> restoreSession() async {
    final session = await _sessionStore.read();
    if (session == null) {
      _client.clearToken();
      return null;
    }

    try {
      if (isJwtExpired(session.token)) {
        await logout();
        return null;
      }
    } on FormatException {
      await logout();
      return null;
    }

    _client.setToken(session.token);
    return session;
  }

  Future<void> saveSession(AuthSession session) async {
    await _sessionStore.write(session);
    _client.setToken(session.token);
  }

  Future<void> logout() async {
    try {
      await _sessionStore.clear();
    } finally {
      _client.clearToken();
    }
  }
}
