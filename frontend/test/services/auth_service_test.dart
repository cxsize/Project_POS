import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/user.dart';
import 'package:pos_frontend/services/api_client.dart';
import 'package:pos_frontend/services/auth_service.dart';
import 'package:pos_frontend/services/session/auth_session.dart';
import 'package:pos_frontend/services/session/auth_session_store.dart';

void main() {
  group('AuthService', () {
    test(
      'login stores access and refresh tokens from backend response',
      () async {
        final apiClient = FakeAuthApiClient(
          postResponses: {
            '/auth/login': {
              'access_token': _buildJwt(
                sub: 'user-1',
                username: 'cashier1',
                role: 'cashier',
                fullName: 'Cashier One',
                branchId: 'branch-1',
                expiresAt: DateTime.now().add(const Duration(hours: 1)),
              ),
              'refresh_token': 'refresh-token-1',
              'user': {
                'id': 'user-1',
                'username': 'cashier1',
                'full_name': 'Cashier One',
                'role': 'cashier',
                'branch_id': 'branch-1',
              },
            },
          },
        );
        final store = InMemoryAuthSessionStore();
        final authService = AuthService(apiClient, sessionStore: store);

        final session = await authService.login('cashier1', 'secret');

        expect(session.token, isNotEmpty);
        expect(session.refreshToken, 'refresh-token-1');
        expect(session.user.username, 'cashier1');
        expect(store.session?.refreshToken, 'refresh-token-1');
        expect(apiClient.requestLog, ['POST /auth/login']);
        expect(apiClient.isAuthenticated, isTrue);
      },
    );

    test(
      'restoreSession refreshes expired access token and reloads profile',
      () async {
        final expiredToken = _buildJwt(
          sub: 'user-1',
          username: 'cashier1',
          role: 'cashier',
          fullName: 'Old Name',
          branchId: 'branch-1',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        final refreshedToken = _buildJwt(
          sub: 'user-1',
          username: 'cashier1',
          role: 'manager',
          fullName: 'Manager One',
          branchId: 'branch-2',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        final apiClient = FakeAuthApiClient(
          postResponses: {
            '/auth/refresh': {
              'access_token': refreshedToken,
              'refresh_token': 'refresh-token-2',
              'user': {
                'id': 'user-1',
                'username': 'cashier1',
                'full_name': 'Manager One',
                'role': 'manager',
                'branch_id': 'branch-2',
              },
            },
          },
          getResponses: {
            '/auth/me': {
              'id': 'user-1',
              'username': 'cashier1',
              'full_name': 'Manager One',
              'role': 'manager',
              'branch_id': 'branch-2',
            },
          },
        );
        final store = InMemoryAuthSessionStore(
          session: AuthSession(
            token: expiredToken,
            refreshToken: 'refresh-token-1',
            user: User(
              id: 'user-1',
              username: 'cashier1',
              fullName: 'Old Name',
              role: 'cashier',
              branchId: 'branch-1',
            ),
          ),
        );
        final authService = AuthService(apiClient, sessionStore: store);

        final restored = await authService.restoreSession();

        expect(restored, isNotNull);
        expect(restored!.token, refreshedToken);
        expect(restored.refreshToken, 'refresh-token-2');
        expect(restored.user.role, 'manager');
        expect(restored.user.branchId, 'branch-2');
        expect(apiClient.requestLog, ['POST /auth/refresh', 'GET /auth/me']);
        expect(store.session?.refreshToken, 'refresh-token-2');
        expect(apiClient.isAuthenticated, isTrue);
      },
    );
  });
}

class FakeAuthApiClient extends ApiClient {
  FakeAuthApiClient({
    Map<String, dynamic>? postResponses,
    Map<String, dynamic>? getResponses,
  }) : _postResponses = postResponses ?? const {},
       _getResponses = getResponses ?? const {},
       super(baseUrl: 'http://fake.local/api/v1');

  final Map<String, dynamic> _postResponses;
  final Map<String, dynamic> _getResponses;
  final List<String> requestLog = [];

  @override
  Future<dynamic> get(String path, {bool retryOnUnauthorized = true}) async {
    requestLog.add('GET $path');
    if (!_getResponses.containsKey(path)) {
      throw StateError('Unexpected GET request: $path');
    }
    return _getResponses[path];
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool retryOnUnauthorized = true,
  }) async {
    requestLog.add('POST $path');
    if (!_postResponses.containsKey(path)) {
      throw StateError('Unexpected POST request: $path');
    }
    return _postResponses[path];
  }
}

class InMemoryAuthSessionStore implements AuthSessionStore {
  InMemoryAuthSessionStore({this.session});

  AuthSession? session;

  @override
  Future<void> clear() async {
    session = null;
  }

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession session) async {
    this.session = session;
  }
}

String _buildJwt({
  required String sub,
  required String username,
  required String role,
  required String fullName,
  required String branchId,
  required DateTime expiresAt,
}) {
  final header = _encodeSegment({'alg': 'HS256', 'typ': 'JWT'});
  final payload = _encodeSegment({
    'sub': sub,
    'username': username,
    'role': role,
    'full_name': fullName,
    'branch_id': branchId,
    'exp': expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000,
  });
  return '$header.$payload.signature';
}

String _encodeSegment(Map<String, dynamic> jsonMap) {
  return base64Url.encode(utf8.encode(jsonEncode(jsonMap))).replaceAll('=', '');
}
