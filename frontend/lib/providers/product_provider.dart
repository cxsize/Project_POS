import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/product.dart';
import 'service_providers.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(productServiceProvider).getCategories();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final productSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = FutureProvider<List<Product>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);

  return ref
      .read(productServiceProvider)
      .getProducts(search: searchQuery, categoryId: selectedCategory);
});

final hasActiveProductFiltersProvider = Provider<bool>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);
  return selectedCategory != null || searchQuery.trim().isNotEmpty;
});
