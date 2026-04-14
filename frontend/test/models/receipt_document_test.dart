import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/cart_item.dart';
import 'package:pos_frontend/models/category.dart';
import 'package:pos_frontend/models/order.dart';
import 'package:pos_frontend/models/order_item.dart';
import 'package:pos_frontend/models/payment.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/models/receipt_document.dart';

void main() {
  test('builds receipt items from cart data when available', () {
    final document = ReceiptDocument.fromSale(
      order: _order,
      cartItems: [_cartItem],
      cashierName: 'Cashier One',
      changeAmount: 9.05,
    );

    expect(document.storeName, 'Project POS');
    expect(document.orderNo, _order.orderNo);
    expect(document.paymentMethodLabel, 'Cash');
    expect(document.items, hasLength(1));
    expect(document.items.single.label, 'Iced Latte');
    expect(document.items.single.sku, 'LATTE-001');
    expect(document.amountReceived, 100);
    expect(document.changeAmount, 9.05);
    expect(document.qrPayload, contains(_order.orderNo));
  });

  test('falls back to order item ids when cart snapshot is unavailable', () {
    final document = ReceiptDocument.fromSale(
      order: _order,
      cartItems: const [],
      cashierName: 'Cashier One',
    );

    expect(document.items, hasLength(1));
    expect(document.items.single.label, _product.id);
    expect(document.items.single.sku, isNull);
  });
}

final _category = Category(id: 'cat-1', name: 'Coffee');

final _product = Product(
  id: 'prod-1',
  sku: 'LATTE-001',
  name: 'Iced Latte',
  basePrice: 85,
  categoryId: _category.id,
  category: _category,
);

final _cartItem = CartItem(product: _product);

final _order = Order(
  id: 'order-1',
  orderNo: 'POS-0001',
  branchId: 'branch-1',
  staffId: 'user-1',
  totalAmount: 85,
  discountAmount: 0,
  vatAmount: 5.95,
  netAmount: 90.95,
  paymentStatus: 'paid',
  syncStatusAcc: false,
  createdAt: DateTime.utc(2026, 4, 12, 10, 30),
  items: [
    OrderItem(
      id: 'item-1',
      orderId: 'order-1',
      productId: 'prod-1',
      qty: 1,
      unitPrice: 85,
      subtotal: 85,
    ),
  ],
  payments: [
    Payment(
      id: 'payment-1',
      orderId: 'order-1',
      method: 'cash',
      amountReceived: 100,
    ),
  ],
);
