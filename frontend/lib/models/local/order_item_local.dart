import '../order_item.dart';

class OrderItemLocal {
  final String id;
  final String orderId;
  final String productId;
  final int qty;
  final double unitPrice;
  final double subtotal;
  final String? productNameSnapshot;
  final String? productSkuSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderItemLocal({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
    this.productNameSnapshot,
    this.productSkuSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItemLocal.fromOrderItem(
    OrderItem item, {
    String? productNameSnapshot,
    String? productSkuSnapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderItemLocal(
      id: item.id,
      orderId: item.orderId,
      productId: item.productId,
      qty: item.qty,
      unitPrice: item.unitPrice,
      subtotal: item.subtotal,
      productNameSnapshot: productNameSnapshot,
      productSkuSnapshot: productSkuSnapshot,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory OrderItemLocal.fromMap(Map<String, dynamic> map) {
    return OrderItemLocal(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      qty: map['qty'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      productNameSnapshot: map['product_name_snapshot'] as String?,
      productSkuSnapshot: map['product_sku_snapshot'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'qty': qty,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'product_name_snapshot': productNameSnapshot,
      'product_sku_snapshot': productSkuSnapshot,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrderItem toOrderItem() {
    return OrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      qty: qty,
      unitPrice: unitPrice,
      subtotal: subtotal,
    );
  }

  OrderItemLocal copyWith({
    String? id,
    String? orderId,
    String? productId,
    int? qty,
    double? unitPrice,
    double? subtotal,
    String? productNameSnapshot,
    String? productSkuSnapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderItemLocal(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      productSkuSnapshot: productSkuSnapshot ?? this.productSkuSnapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
