import 'order_item.dart';
import 'payment.dart';

class Order {
  final String id;
  final String orderNo;
  final String branchId;
  final String staffId;
  final double totalAmount;
  final double discountAmount;
  final double vatAmount;
  final double netAmount;
  final String paymentStatus;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<Payment> payments;

  Order({
    required this.id,
    required this.orderNo,
    required this.branchId,
    required this.staffId,
    required this.totalAmount,
    required this.discountAmount,
    required this.vatAmount,
    required this.netAmount,
    required this.paymentStatus,
    required this.createdAt,
    this.items = const [],
    this.payments = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNo: json['order_no'] as String,
      branchId: json['branch_id'] as String,
      staffId: json['staff_id'] as String,
      totalAmount: double.parse(json['total_amount'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      vatAmount: double.parse(json['vat_amount'].toString()),
      netAmount: double.parse(json['net_amount'].toString()),
      paymentStatus: json['payment_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      payments: (json['payments'] as List<dynamic>?)
              ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
