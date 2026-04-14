import 'package:isar/isar.dart';

import '../../models/payment.dart';
part 'payment_local.g.dart';

@collection
class PaymentLocal {
  PaymentLocal();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  @Index()
  late String orderId;

  late String method;
  late double amountReceived;
  String? refNo;
  late DateTime syncedAt;

  factory PaymentLocal.fromDomain(
    String orderIdValue,
    Payment payment, {
    String? remoteId,
    DateTime? syncedAt,
  }) {
    return PaymentLocal()
      ..remoteId = remoteId ?? payment.id
      ..orderId = orderIdValue
      ..method = payment.method
      ..amountReceived = payment.amountReceived
      ..refNo = payment.refNo
      ..syncedAt = syncedAt ?? DateTime.now();
  }
}
