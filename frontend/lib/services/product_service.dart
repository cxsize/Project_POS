import '../local/local_database_service.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _client;
  final LocalDatabaseService _localDatabase;

  ProductService(this._client, this._localDatabase);

  Future<void> warmupCatalog() async {
    try {
      await syncCatalog();
    } catch (_) {
      // Allow the UI to continue with cached data when the API is unavailable.
    }
  }

  Future<void> syncCatalog() async {
    final categoryData =
        await _client.get('/products/categories/all') as List<dynamic>;
    final categories = categoryData
        .map((entry) => Category.fromJson(entry as Map<String, dynamic>))
        .toList();
    final categoryById = {
      for (final category in categories) category.id: category,
    };

    final productData = await _client.get('/products') as List<dynamic>;
    final products = productData
        .map((entry) => Product.fromJson(entry as Map<String, dynamic>))
        .map(
          (product) => Product(
            id: product.id,
            sku: product.sku,
            name: product.name,
            basePrice: product.basePrice,
            categoryId: product.categoryId,
            isActive: product.isActive,
            category: product.category ?? categoryById[product.categoryId],
          ),
        )
        .toList();

    await _localDatabase.cacheProducts(products);
  }

  Future<List<Product>> getProducts({
    String search = '',
    String? categoryId,
  }) async {
    if (!await _localDatabase.hasCachedProducts()) {
      await warmupCatalog();
    }

    return _localDatabase.searchProducts(
      search: search,
      categoryId: categoryId,
    );
  }

  Future<List<Category>> getCategories() async {
    if (!await _localDatabase.hasCachedProducts()) {
      await warmupCatalog();
    }

    return _localDatabase.getCategories();
  }

  Future<Product?> findProductByBarcode(String barcode) async {
    final cached = await _localDatabase.findProductBySku(barcode);
    if (cached != null) {
      return cached;
    }

    await warmupCatalog();
    return _localDatabase.findProductBySku(barcode);
  }
}
