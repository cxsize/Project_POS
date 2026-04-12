import 'package:isar/isar.dart';

import '../../models/order.dart';
part 'order_local.g.dart';

@collection
class OrderLocal {
  OrderLocal();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  @Index(unique: true, replace: true)
  late String localReferenceId;

  @Index(unique: true, replace: true)
  late String orderNo;

  late String branchId;
  late String staffId;
  late double totalAmount;
  late double discountAmount;
  late double vatAmount;
  late double netAmount;

  @Index()
  late String paymentStatus;

  @Index()
  late bool syncStatusAcc;

  late DateTime createdAt;
  late DateTime syncedAt;

  factory OrderLocal.fromDomain(
    Order order, {
    String? remoteId,
    String? localReferenceId,
    bool? syncStatusAcc,
    DateTime? syncedAt,
  }) {
    return OrderLocal()
      ..remoteId = remoteId ?? order.id
      ..localReferenceId = localReferenceId ?? order.id
      ..orderNo = order.orderNo
      ..branchId = order.branchId
      ..staffId = order.staffId
      ..totalAmount = order.totalAmount
      ..discountAmount = order.discountAmount
      ..vatAmount = order.vatAmount
      ..netAmount = order.netAmount
      ..paymentStatus = order.paymentStatus
      ..syncStatusAcc = syncStatusAcc ?? order.paymentStatus == 'paid'
      ..createdAt = order.createdAt
      ..syncedAt = syncedAt ?? DateTime.now();
  }
}
