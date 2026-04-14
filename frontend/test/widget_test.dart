import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_frontend/local/local_database_service.dart';
import 'package:pos_frontend/main.dart';
import 'package:pos_frontend/providers/auth_provider.dart';
import 'package:pos_frontend/providers/app_bootstrap_provider.dart';
import 'package:pos_frontend/providers/service_providers.dart';
import 'package:pos_frontend/services/api_client.dart';
import 'package:pos_frontend/services/connectivity_service.dart';
import 'package:pos_frontend/services/offline_sync_service.dart';

void main() {
  testWidgets('renders the login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appBootstrapProvider.overrideWith((ref) async {}),
          authProvider.overrideWith((ref) => FakeAuthNotifier()),
          offlineSyncServiceProvider.overrideWith(
            (ref) => OfflineSyncService(
              ApiClient(baseUrl: 'http://localhost:3000/api/v1'),
              LocalDatabaseService(),
              ConnectivityService(),
            ),
          ),
        ],
        child: const PosApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('POS Login'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(_UnsupportedRef()) {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  @override
  Future<void> login(String username, String password) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> restoreSession() async {}
}

class _UnsupportedRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
