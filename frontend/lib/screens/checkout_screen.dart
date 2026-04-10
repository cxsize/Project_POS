import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/cart_item_row.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/product_tile.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'payment_screen.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final cartVat = ref.watch(cartVatProvider);
    final cartNet = ref.watch(cartNetProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('POS - ${auth.user?.username ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Order History',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              ref.read(cartProvider.notifier).clear();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel — product grid
          Expanded(
            flex: 65,
            child: Column(
              children: [
                const CategoryFilterBar(),
                Expanded(child: _ProductGrid()),
              ],
            ),
          ),
          // Right panel — cart
          Container(
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            flex: 35,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text('Cart',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      Text('${cart.length} items',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Tap products to add'))
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (_, i) {
                            final item = cart[i];
                            return CartItemRow(
                              item: item,
                              onIncrement: () => ref
                                  .read(cartProvider.notifier)
                                  .incrementQty(item.product.id),
                              onDecrement: () => ref
                                  .read(cartProvider.notifier)
                                  .decrementQty(item.product.id),
                              onRemove: () => ref
                                  .read(cartProvider.notifier)
                                  .removeItem(item.product.id),
                            );
                          },
                        ),
                ),
                if (cart.isNotEmpty) ...[
                  OrderSummaryCard(
                    subtotal: cartTotal,
                    vat: cartVat,
                    net: cartNet,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                ref.read(cartProvider.notifier).clear(),
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(orderProvider.notifier)
                                  .submitOrder(cart);
                              if (!context.mounted) return;
                              final orderState = ref.read(orderProvider);
                              if (orderState.currentOrder != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const PaymentScreen()),
                                );
                              } else if (orderState.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(orderState.error!),
                                      backgroundColor: Colors.red),
                                );
                              }
                            },
                            child: const Text('Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      data: (_) => GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final product = products[i];
          return ProductTile(
            product: product,
            onTap: () => ref.read(cartProvider.notifier).addItem(product),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading products: $e')),
    );
  }
}
