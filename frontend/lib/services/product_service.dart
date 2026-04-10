import '../models/category.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  Future<List<Product>> getProducts() async {
    final data = await _client.get('/products') as List<dynamic>;
    return data
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final data = await _client.get('/products/categories/all') as List<dynamic>;
    return data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
