import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/local/local_database_service.dart';
import 'package:pos_frontend/models/category.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/services/api_client.dart';
import 'package:pos_frontend/services/product_service.dart';

void main() {
  group('ProductService', () {
    test('searchCachedProducts uses local cache without calling API', () async {
      final bakery = Category(id: 'cat-1', name: 'Bakery');
      final fakeApiClient = FakeApiClient();
      final fakeLocalDatabase = FakeLocalDatabaseService(
        hasCachedProductsValue: true,
        products: [
          Product(
            id: 'prod-1',
            sku: 'CK-001',
            name: 'Chocolate Cake',
            basePrice: 120,
            categoryId: bakery.id,
            category: bakery,
          ),
          Product(
            id: 'prod-2',
            sku: 'LT-001',
            name: 'Iced Latte',
            basePrice: 85,
          ),
        ],
      );
      final service = ProductService(fakeApiClient, fakeLocalDatabase);

      final results = await service.searchCachedProducts(search: 'latte');

      expect(results.map((product) => product.name), ['Iced Latte']);
      expect(fakeApiClient.requestedPaths, isEmpty);
      expect(fakeLocalDatabase.searchCalls, 1);
      expect(fakeLocalDatabase.lastSearch, 'latte');
    });

    test('searchCachedProducts syncs once when cache is empty', () async {
      final fakeApiClient = FakeApiClient(
        responseByPath: {
          '/products/categories/all': [
            {'id': 'cat-1', 'name': 'Beverages'},
          ],
          '/products': [
            {
              'id': 'prod-1',
              'sku': 'LT-001',
              'name': 'Iced Latte',
              'base_price': 85,
              'category_id': 'cat-1',
              'is_active': true,
            },
            {
              'id': 'prod-2',
              'sku': 'TT-001',
              'name': 'Thai Tea',
              'base_price': 70,
              'category_id': 'cat-1',
              'is_active': true,
            },
          ],
        },
      );
      final fakeLocalDatabase = FakeLocalDatabaseService(
        hasCachedProductsValue: false,
      );
      final service = ProductService(fakeApiClient, fakeLocalDatabase);

      final results = await service.searchCachedProducts(search: 'latte');

      expect(fakeApiClient.requestedPaths, [
        '/products/categories/all',
        '/products',
      ]);
      expect(fakeLocalDatabase.cacheProductsCallCount, 1);
      expect(results.map((product) => product.name), ['Iced Latte']);
    });
  });
}

class FakeApiClient extends ApiClient {
  FakeApiClient({Map<String, dynamic>? responseByPath})
    : _responseByPath = responseByPath ?? <String, dynamic>{},
      super(baseUrl: 'http://fake.local/api/v1');

  final Map<String, dynamic> _responseByPath;
  final List<String> requestedPaths = [];

  @override
  Future<dynamic> get(String path) async {
    requestedPaths.add(path);
    if (!_responseByPath.containsKey(path)) {
      throw StateError('Unexpected GET request: $path');
    }

    return _responseByPath[path];
  }
}

class FakeLocalDatabaseService extends LocalDatabaseService {
  FakeLocalDatabaseService({
    required this.hasCachedProductsValue,
    List<Product>? products,
  }) : _products = List<Product>.from(products ?? const []);

  bool hasCachedProductsValue;
  List<Product> _products;

  int searchCalls = 0;
  int cacheProductsCallCount = 0;
  String lastSearch = '';
  String? lastCategoryId;

  @override
  Future<void> cacheProducts(List<Product> products) async {
    cacheProductsCallCount += 1;
    _products = List<Product>.from(products);
    hasCachedProductsValue = true;
  }

  @override
  Future<bool> hasCachedProducts() async => hasCachedProductsValue;

  @override
  Future<List<Product>> searchProducts({
    String search = '',
    String? categoryId,
  }) async {
    searchCalls += 1;
    lastSearch = search;
    lastCategoryId = categoryId;

    final normalizedSearch = search.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory =
          categoryId == null || product.categoryId == categoryId;
      if (!matchesCategory) {
        return false;
      }
      if (normalizedSearch.isEmpty) {
        return true;
      }

      return product.name.toLowerCase().contains(normalizedSearch) ||
          product.sku.toLowerCase().contains(normalizedSearch);
    }).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    final seen = <String>{};
    final categories = <Category>[];

    for (final product in _products) {
      final category = product.category;
      if (category == null) {
        continue;
      }
      if (seen.add(category.id)) {
        categories.add(category);
      }
    }

    return categories;
  }
}
