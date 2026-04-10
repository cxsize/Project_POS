import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'models/order_item_local.dart';
import 'models/order_local.dart';
import 'models/payment_local.dart';
import 'models/product_local.dart';
import 'models/sync_queue_local.dart';

class LocalDatabaseService {
  LocalDatabaseService();

  Isar? _isar;

  Future<Isar> open() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final directory = await getApplicationSupportDirectory();
    _isar = await Isar.open(
      [
        ProductLocalSchema,
        OrderLocalSchema,
        OrderItemLocalSchema,
        PaymentLocalSchema,
        SyncQueueLocalSchema,
      ],
      directory: directory.path,
      inspector: false,
    );
    return _isar!;
  }

  Future<void> cacheProducts(List<Product> products) async {
    final isar = await open();
    final localProducts = products.map(ProductLocal.fromDomain).toList();

    await isar.writeTxn(() async {
      await isar.productLocals.clear();
      await isar.productLocals.putAll(localProducts);
    });
  }

  Future<List<Product>> searchProducts({
    String search = '',
    String? categoryId,
  }) async {
    final isar = await open();
    final normalizedSearch = search.trim();

    final query = isar.productLocals.filter();
    final filtered = query
        .isActiveEqualTo(true)
        .optional(
          categoryId != null && categoryId.isNotEmpty,
          (q) => q.categoryIdEqualTo(categoryId),
        )
        .optional(
          normalizedSearch.isNotEmpty,
          (q) => q.group(
            (group) => group
                .nameContains(normalizedSearch, caseSensitive: false)
                .or()
                .skuContains(normalizedSearch, caseSensitive: false),
          ),
        );

    final localProducts = await filtered.sortByName().findAll();
    return localProducts.map((product) => product.toDomain()).toList();
  }

  Future<Product?> findProductBySku(String sku) async {
    final isar = await open();
    final localProduct = await isar.productLocals
        .filter()
        .skuEqualTo(sku.trim(), caseSensitive: false)
        .findFirst();

    return localProduct?.toDomain();
  }

  Future<List<Category>> getCategories() async {
    final isar = await open();
    final localProducts = await isar.productLocals
        .filter()
        .isActiveEqualTo(true)
        .findAll();
    final seen = <String>{};
    final categories = <Category>[];

    for (final product in localProducts) {
      final categoryId = product.categoryId;
      final categoryName = product.categoryName;
      if (categoryId == null || categoryName == null) {
        continue;
      }
      if (seen.add(categoryId)) {
        categories.add(Category(id: categoryId, name: categoryName));
      }
    }

    categories.sort((left, right) => left.name.compareTo(right.name));
    return categories;
  }

  Future<bool> hasCachedProducts() async {
    final isar = await open();
    return (await isar.productLocals.where().count()) > 0;
  }

  Future<void> saveOrderSnapshot(Order order) async {
    final isar = await open();
    final orderLocal = OrderLocal.fromDomain(order);
    final itemLocals = order.items
        .map((item) => OrderItemLocal.fromDomain(order.id, item))
        .toList();
    final paymentLocals = order.payments
        .map((payment) => PaymentLocal.fromDomain(order.id, payment))
        .toList();

    await isar.writeTxn(() async {
      await isar.orderLocals.put(orderLocal);
      await isar.orderItemLocals.filter().orderIdEqualTo(order.id).deleteAll();
      await isar.paymentLocals.filter().orderIdEqualTo(order.id).deleteAll();
      if (itemLocals.isNotEmpty) {
        await isar.orderItemLocals.putAll(itemLocals);
      }
      if (paymentLocals.isNotEmpty) {
        await isar.paymentLocals.putAll(paymentLocals);
      }
    });
  }
}
