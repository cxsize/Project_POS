import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(qty: updated[index].qty + 1);
      state = updated;
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void incrementQty(String productId) {
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(qty: item.qty + 1);
      }
      return item;
    }).toList();
  }

  void decrementQty(String productId) {
    final item = state.firstWhere((i) => i.product.id == productId);
    if (item.qty <= 1) {
      removeItem(productId);
    } else {
      state = state.map((i) {
        if (i.product.id == productId) {
          return i.copyWith(qty: i.qty - 1);
        }
        return i;
      }).toList();
    }
  }

  void clear() => state = [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.subtotal);
});

final cartVatProvider = Provider<double>((ref) {
  return ref.watch(cartTotalProvider) * 0.07;
});

final cartNetProvider = Provider<double>((ref) {
  return ref.watch(cartTotalProvider) + ref.watch(cartVatProvider);
});
