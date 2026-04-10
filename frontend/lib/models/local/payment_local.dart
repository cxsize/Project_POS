import '../payment.dart';

class PaymentLocal {
  final String id;
  final String orderId;
  final String method;
  final double amountReceived;
  final String? refNo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentLocal({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amountReceived,
    this.refNo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentLocal.fromPayment(
    Payment payment, {
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentLocal(
      id: payment.id,
      orderId: payment.orderId,
      method: payment.method,
      amountReceived: payment.amountReceived,
      refNo: payment.refNo,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory PaymentLocal.fromMap(Map<String, dynamic> map) {
    return PaymentLocal(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      method: map['method'] as String,
      amountReceived: (map['amount_received'] as num).toDouble(),
      refNo: map['ref_no'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'method': method,
      'amount_received': amountReceived,
      'ref_no': refNo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Payment toPayment() {
    return Payment(
      id: id,
      orderId: orderId,
      method: method,
      amountReceived: amountReceived,
      refNo: refNo,
    );
  }

  PaymentLocal copyWith({
    String? id,
    String? orderId,
    String? method,
    double? amountReceived,
    String? refNo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentLocal(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      method: method ?? this.method,
      amountReceived: amountReceived ?? this.amountReceived,
      refNo: refNo ?? this.refNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
