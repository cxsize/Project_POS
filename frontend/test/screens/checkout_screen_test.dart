import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_frontend/models/category.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/models/user.dart';
import 'package:pos_frontend/providers/auth_provider.dart';
import 'package:pos_frontend/providers/product_provider.dart';
import 'package:pos_frontend/screens/checkout_screen.dart';

void main() {
  testWidgets('tapping a product tile adds it to the cart', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1400,
      1000,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
    addTearDown(() {
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    final category = Category(id: 'cat-1', name: 'Beverages');
    final product = Product(
      id: 'prod-1',
      sku: 'LATTE-001',
      name: 'Iced Latte',
      basePrice: 85,
      categoryId: category.id,
      category: category,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => FakeAuthNotifier()),
          categoriesProvider.overrideWith((ref) async => [category]),
          filteredProductsProvider.overrideWith((ref) async => [product]),
        ],
        child: const MaterialApp(home: CheckoutScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Barcode / Product Search'), findsOneWidget);
    expect(find.text('0 items'), findsOneWidget);

    await tester.tap(find.text('Iced Latte').first);
    await tester.pumpAndSettle();

    expect(find.text('1 items'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
  });
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(_UnsupportedRef()) {
    state = AuthState(
      user: User(
        id: 'user-1',
        username: 'cashier1',
        fullName: 'Cashier One',
        role: 'cashier',
        branchId: 'branch-1',
      ),
      token: 'token',
      status: AuthStatus.authenticated,
    );
  }

  @override
  Future<void> login(String username, String password) async {}

  @override
  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  @override
  Future<void> restoreSession() async {}
}

class _UnsupportedRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
