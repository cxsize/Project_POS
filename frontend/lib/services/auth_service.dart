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
              retryOnUnauthorized: false,
            )
            as Map<String, dynamic>;
    final session = authSessionFromResponse(data);

    await _sessionStore.write(session);
    _client.setToken(session.token);
    return session;
  }

  Future<AuthSession?> restoreSession() async {
    var session = await _sessionStore.read();
    if (session == null) {
      _client.clearToken();
      return null;
    }

    try {
      if (isJwtExpired(session.token)) {
        final refreshedSession = await refreshSession(
          refreshToken: session.refreshToken,
        );
        if (refreshedSession == null) {
          return null;
        }
        session = refreshedSession;
      }
    } on FormatException {
      await logout();
      return null;
    }

    _client.setToken(session.token);
    return refreshCurrentUser(session);
  }

  Future<void> saveSession(AuthSession session) async {
    await _sessionStore.write(session);
    _client.setToken(session.token);
  }

  Future<AuthSession?> refreshSession({String? refreshToken}) async {
    final activeRefreshToken = refreshToken?.trim();
    if (activeRefreshToken == null || activeRefreshToken.isEmpty) {
      await logout();
      return null;
    }

    try {
      final data =
          await _client.post(
                '/auth/refresh',
                body: {'refresh_token': activeRefreshToken},
                retryOnUnauthorized: false,
              )
              as Map<String, dynamic>;
      final session = authSessionFromResponse(data);
      await saveSession(session);
      return session;
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<String?> refreshAccessToken() async {
    final session = await _sessionStore.read();
    final refreshed = await refreshSession(refreshToken: session?.refreshToken);
    return refreshed?.token;
  }

  Future<AuthSession> refreshCurrentUser(AuthSession session) async {
    final user =
        await _client.get('/auth/me', retryOnUnauthorized: true)
            as Map<String, dynamic>;
    final updatedSession = AuthSession(
      token: session.token,
      refreshToken: session.refreshToken,
      user: userFromJson(user),
    );
    await saveSession(updatedSession);
    return updatedSession;
  }

  Future<void> logout() async {
    try {
      await _sessionStore.clear();
    } finally {
      _client.clearToken();
    }
  }
}
