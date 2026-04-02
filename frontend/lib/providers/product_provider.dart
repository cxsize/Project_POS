import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'service_providers.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(productServiceProvider).getCategories();
});

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.read(productServiceProvider).getProducts();
});

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String?>(
  SelectedCategoryNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return productsAsync.when(
    data: (products) {
      if (selectedCategory == null) return products;
      return products.where((p) => p.categoryId == selectedCategory).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
