class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int qty;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      qty: json['qty'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
