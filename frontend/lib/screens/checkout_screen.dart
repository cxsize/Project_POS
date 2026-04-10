import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/service_providers.dart';
import '../widgets/cart_item_row.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/product_tile.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'payment_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(productSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshCatalog() async {
    await ref.read(productServiceProvider).syncCatalog();
    ref.invalidate(categoriesProvider);
    ref.invalidate(filteredProductsProvider);
  }

  Future<void> _handleBarcodeSubmit(String rawValue) async {
    final barcode = rawValue.trim();
    if (barcode.isEmpty) {
      return;
    }

    final product = await ref
        .read(productServiceProvider)
        .findProductByBarcode(barcode);
    if (!mounted) {
      return;
    }

    if (product != null) {
      ref.read(cartProvider.notifier).addItem(product);
      _searchController.clear();
      ref.read(productSearchQueryProvider.notifier).state = '';
      return;
    }

    ref.read(productSearchQueryProvider.notifier).state = barcode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'No exact SKU match for "$barcode". Showing local search results.',
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    ref.read(cartProvider.notifier).clear();
    ref.read(productSearchQueryProvider.notifier).state = '';
    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.sync),
            tooltip: 'Refresh Catalog',
            onPressed: _refreshCatalog,
          ),
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
            onPressed: _logout,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 65,
            child: Column(
              children: [
                const CategoryFilterBar(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search products or scan barcode',
                      hintText: 'Type product name or SKU',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productSearchQueryProvider.notifier).state =
                              '';
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(productSearchQueryProvider.notifier).state =
                          value;
                    },
                    onSubmitted: _handleBarcodeSubmit,
                  ),
                ),
                Expanded(child: _ProductGrid(onRefresh: _refreshCatalog)),
              ],
            ),
          ),
          Container(width: 1, color: Theme.of(context).dividerColor),
          Expanded(
            flex: 35,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(
                        'Cart',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Text(
                        '${cart.length} items',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
                              if (!context.mounted) {
                                return;
                              }

                              final orderState = ref.read(orderProvider);
                              if (orderState.currentOrder != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PaymentScreen(),
                                  ),
                                );
                              } else if (orderState.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(orderState.error!),
                                    backgroundColor: Colors.red,
                                  ),
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
  const _ProductGrid({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final hasFilters = ref.watch(hasActiveProductFiltersProvider);

    return productsAsync.when(
      data: (products) => RefreshIndicator(
        onRefresh: onRefresh,
        child: products.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 320,
                    child: Center(
                      child: Text(
                        hasFilters
                            ? 'No products matched your local search.'
                            : 'No products available yet. Pull to refresh.',
                      ),
                    ),
                  ),
                ],
              )
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final product = products[i];
                  return ProductTile(
                    product: product,
                    onTap: () =>
                        ref.read(cartProvider.notifier).addItem(product),
                  );
                },
              ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading products: $e')),
    );
  }
}
