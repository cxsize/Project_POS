import 'package:isar/isar.dart';

import '../../models/order_item.dart';
part 'order_item_local.g.dart';

@collection
class OrderItemLocal {
  OrderItemLocal();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  @Index()
  late String orderId;

  @Index()
  late String productId;

  late int qty;
  late double unitPrice;
  late double subtotal;

  factory OrderItemLocal.fromDomain(
    String orderIdValue,
    OrderItem item, {
    String? remoteId,
  }) {
    return OrderItemLocal()
      ..remoteId = remoteId ?? item.id
      ..orderId = orderIdValue
      ..productId = item.productId
      ..qty = item.qty
      ..unitPrice = item.unitPrice
      ..subtotal = item.subtotal;
  }
}
