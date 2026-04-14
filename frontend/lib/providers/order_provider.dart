import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

class OrderState {
  final Order? currentOrder;
  final double? change;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.currentOrder,
    this.change,
    this.isLoading = false,
    this.error,
  });
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref ref;

  OrderNotifier(this.ref) : super(const OrderState());

  Future<void> submitOrder(List<CartItem> items) async {
    state = const OrderState(isLoading: true);
    try {
      final auth = ref.read(authProvider);
      final order = await ref
          .read(orderServiceProvider)
          .createOrder(
            branchId: auth.user!.branchId ?? auth.user!.id,
            staffId: auth.user!.id,
            items: items,
          );
      state = OrderState(currentOrder: order);
    } catch (e) {
      state = OrderState(error: e.toString());
    }
  }

  Future<void> submitPayment(
    String method,
    double amount, {
    String? refNo,
  }) async {
    state = OrderState(currentOrder: state.currentOrder, isLoading: true);
    try {
      final result = await ref
          .read(orderServiceProvider)
          .addPayment(
            orderId: state.currentOrder!.id,
            orderNo: state.currentOrder!.orderNo,
            method: method,
            amountReceived: amount,
            refNo: refNo,
          );
      state = OrderState(currentOrder: result.order, change: result.change);
    } catch (e) {
      state = OrderState(currentOrder: state.currentOrder, error: e.toString());
    }
  }

  void reset() => state = const OrderState();
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>(
  (ref) => OrderNotifier(ref),
);

final orderHistoryProvider = FutureProvider<List<Order>>((ref) {
  return ref.read(orderServiceProvider).getOrders();
});
