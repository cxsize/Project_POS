import 'category.dart';

class Product {
  final String id;
  final String sku;
  final String name;
  final double basePrice;
  final String? categoryId;
  final bool isActive;
  final Category? category;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.basePrice,
    this.categoryId,
    this.isActive = true,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      basePrice: double.parse(json['base_price'].toString()),
      categoryId: json['category_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }
}
