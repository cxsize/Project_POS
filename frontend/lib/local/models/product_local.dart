import 'package:isar/isar.dart';

import '../../models/category.dart';
import '../../models/product.dart';
part 'product_local.g.dart';

@collection
class ProductLocal {
  ProductLocal();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  @Index(caseSensitive: false)
  late String sku;

  @Index(caseSensitive: false)
  late String name;

  late double basePrice;

  @Index()
  String? categoryId;

  String? categoryName;

  @Index()
  late bool isActive;

  late DateTime syncedAt;

  factory ProductLocal.fromDomain(Product product) {
    return ProductLocal()
      ..remoteId = product.id
      ..sku = product.sku
      ..name = product.name
      ..basePrice = product.basePrice
      ..categoryId = product.categoryId
      ..categoryName = product.category?.name
      ..isActive = product.isActive
      ..syncedAt = DateTime.now();
  }

  Product toDomain() {
    return Product(
      id: remoteId,
      sku: sku,
      name: name,
      basePrice: basePrice,
      categoryId: categoryId,
      isActive: isActive,
      category: categoryId != null && categoryName != null
          ? Category(id: categoryId!, name: categoryName!)
          : null,
    );
  }
}
