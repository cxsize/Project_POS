import '../category.dart';
import '../product.dart';

class ProductLocal {
  final String id;
  final String sku;
  final String name;
  final double basePrice;
  final String? categoryId;
  final String? categoryName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductLocal({
    required this.id,
    required this.sku,
    required this.name,
    required this.basePrice,
    this.categoryId,
    this.categoryName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductLocal.fromProduct(
    Product product, {
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductLocal(
      id: product.id,
      sku: product.sku,
      name: product.name,
      basePrice: product.basePrice,
      categoryId: product.categoryId,
      categoryName: product.category?.name,
      isActive: product.isActive,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory ProductLocal.fromMap(Map<String, dynamic> map) {
    return ProductLocal(
      id: map['id'] as String,
      sku: map['sku'] as String,
      name: map['name'] as String,
      basePrice: (map['base_price'] as num).toDouble(),
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'base_price': basePrice,
      'category_id': categoryId,
      'category_name': categoryName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product toProduct({Category? category}) {
    final resolvedCategory =
        category ??
        (categoryId != null && categoryName != null
            ? Category(id: categoryId!, name: categoryName!)
            : null);

    return Product(
      id: id,
      sku: sku,
      name: name,
      basePrice: basePrice,
      categoryId: categoryId,
      isActive: isActive,
      category: resolvedCategory,
    );
  }

  ProductLocal copyWith({
    String? id,
    String? sku,
    String? name,
    double? basePrice,
    String? categoryId,
    String? categoryName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductLocal(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
