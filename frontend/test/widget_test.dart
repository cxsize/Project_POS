import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_pos_frontend/app.dart';
import 'package:project_pos_frontend/models/app_environment.dart';
import 'package:project_pos_frontend/providers/app_providers.dart';

void main() {
  testWidgets('renders scaffold overview after startup', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupProvider.overrideWith((ref) async {
            return const AppEnvironment(
              apiBaseUrl: 'http://localhost:3000/api/v1',
              localDatabasePath: '/tmp/project_pos',
              registeredSchemaCount: 0,
            );
          }),
        ],
        child: const ProjectPosApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Project POS'), findsOneWidget);
    expect(find.text('Bootstrap checklist'), findsOneWidget);
    expect(
      find.text('POS-12: register Isar entities and generate code.'),
      findsOneWidget,
    );
  });
}
