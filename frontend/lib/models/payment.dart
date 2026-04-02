class Payment {
  final String id;
  final String orderId;
  final String method;
  final double amountReceived;
  final String? refNo;

  Payment({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amountReceived,
    this.refNo,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      method: json['method'] as String,
      amountReceived: double.parse(json['amount_received'].toString()),
      refNo: json['ref_no'] as String?,
    );
  }
}
