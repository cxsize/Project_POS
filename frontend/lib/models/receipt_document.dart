import 'cart_item.dart';
import 'order.dart';

class ReceiptDocument {
  const ReceiptDocument({
    required this.storeName,
    required this.orderNo,
    required this.createdAt,
    required this.cashierName,
    required this.paymentMethodLabel,
    required this.totalAmount,
    required this.discountAmount,
    required this.vatAmount,
    required this.netAmount,
    required this.amountReceived,
    required this.changeAmount,
    required this.qrPayload,
    required this.items,
  });

  final String storeName;
  final String orderNo;
  final DateTime createdAt;
  final String cashierName;
  final String paymentMethodLabel;
  final double totalAmount;
  final double discountAmount;
  final double vatAmount;
  final double netAmount;
  final double amountReceived;
  final double changeAmount;
  final String qrPayload;
  final List<ReceiptLineItem> items;

  factory ReceiptDocument.fromSale({
    required Order order,
    required List<CartItem> cartItems,
    required String cashierName,
    String storeName = 'Project POS',
    double? amountReceived,
    double changeAmount = 0,
  }) {
    final payment = order.payments.isNotEmpty ? order.payments.last : null;
    final items = cartItems.isNotEmpty
        ? cartItems
              .map(
                (item) => ReceiptLineItem(
                  label: item.product.name,
                  sku: item.product.sku,
                  quantity: item.qty,
                  unitPrice: item.product.basePrice,
                  subtotal: item.subtotal,
                ),
              )
              .toList()
        : order.items
              .map(
                (item) => ReceiptLineItem(
                  label: item.productId,
                  quantity: item.qty,
                  unitPrice: item.unitPrice,
                  subtotal: item.subtotal,
                ),
              )
              .toList();

    final received =
        amountReceived ??
        payment?.amountReceived ??
        order.netAmount + changeAmount;

    return ReceiptDocument(
      storeName: storeName,
      orderNo: order.orderNo,
      createdAt: order.createdAt,
      cashierName: cashierName,
      paymentMethodLabel: _paymentMethodLabel(payment?.method),
      totalAmount: order.totalAmount,
      discountAmount: order.discountAmount,
      vatAmount: order.vatAmount,
      netAmount: order.netAmount,
      amountReceived: received,
      changeAmount: changeAmount,
      qrPayload:
          'POS|${order.orderNo}|${order.netAmount.toStringAsFixed(2)}'
          '|${order.createdAt.toIso8601String()}',
      items: items,
    );
  }

  static String _paymentMethodLabel(String? method) {
    switch ((method ?? '').toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'qr':
        return 'QR';
      default:
        return method == null || method.isEmpty ? 'Payment' : method;
    }
  }
}

class ReceiptLineItem {
  const ReceiptLineItem({
    required this.label,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.sku,
  });

  final String label;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double subtotal;
}
