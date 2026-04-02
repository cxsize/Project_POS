import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_frontend/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PosApp()));
    await tester.pump();

    expect(find.text('POS Login'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
