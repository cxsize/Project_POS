import 'product.dart';

class CartItem {
  final Product product;
  final int qty;

  CartItem({required this.product, this.qty = 1});

  double get subtotal => product.basePrice * qty;

  CartItem copyWith({int? qty}) {
    return CartItem(product: product, qty: qty ?? this.qty);
  }
}
