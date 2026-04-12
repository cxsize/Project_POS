import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_frontend/local/local_database_service.dart';
import 'package:pos_frontend/models/category.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/models/user.dart';
import 'package:pos_frontend/providers/auth_provider.dart';
import 'package:pos_frontend/providers/product_provider.dart';
import 'package:pos_frontend/providers/service_providers.dart';
import 'package:pos_frontend/screens/checkout_screen.dart';
import 'package:pos_frontend/services/api_client.dart';
import 'package:pos_frontend/services/product_service.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.com');
  });

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

  testWidgets('scanner HID input adds a matched SKU to the cart', (
    tester,
  ) async {
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
      sku: '123456',
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
          productServiceProvider.overrideWithValue(
            FakeProductService({'123456': product}),
          ),
        ],
        child: const MaterialApp(home: CheckoutScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 items'), findsOneWidget);

    await _sendBarcodeScan(
      tester,
      barcode: '123456',
      keys: const [
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
        LogicalKeyboardKey.digit5,
        LogicalKeyboardKey.digit6,
      ],
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 950));

    expect(find.text('1 items'), findsOneWidget);
    expect(find.text('Added Iced Latte to cart'), findsOneWidget);
  });
}

Future<void> _sendBarcodeScan(
  WidgetTester tester, {
  required String barcode,
  required List<LogicalKeyboardKey> keys,
}) async {
  for (var index = 0; index < barcode.length; index++) {
    final character = barcode[index];
    final logicalKey = keys[index];
    await tester.sendKeyDownEvent(logicalKey, character: character);
    await tester.sendKeyUpEvent(logicalKey);
    await tester.pump(const Duration(milliseconds: 8));
  }

  await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
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

class FakeProductService extends ProductService {
  FakeProductService(this._products)
    : super(_UnsupportedApiClient(), _UnsupportedDb());

  final Map<String, Product> _products;

  @override
  Future<Product?> findProductByBarcode(String barcode) async {
    return _products[barcode];
  }
}

class _UnsupportedApiClient extends ApiClient {}

class _UnsupportedDb extends LocalDatabaseService {}
