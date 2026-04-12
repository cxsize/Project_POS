import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
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
  late final FocusNode _scannerFocusNode;
  String _scannerBuffer = '';
  DateTime? _lastScannerKeyAt;
  static const _scannerCharacterGap = Duration(milliseconds: 90);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(productSearchQueryProvider),
    );
    _scannerFocusNode = FocusNode(debugLabel: 'checkout-scanner-focus');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scannerFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scannerFocusNode.dispose();
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
      _setSearchQuery('');
      _resetScannerBuffer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${product.name} to cart'),
          duration: const Duration(milliseconds: 900),
        ),
      );
      return;
    }

    _setSearchQuery(barcode);
    _resetScannerBuffer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'No exact SKU match for "$barcode". Showing local search results.',
        ),
      ),
    );
  }

  void _setSearchQuery(String value) {
    if (_searchController.text != value) {
      _searchController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    ref.read(productSearchQueryProvider.notifier).state = value;
  }

  void _resetScannerBuffer() {
    _scannerBuffer = '';
    _lastScannerKeyAt = null;
  }

  KeyEventResult _handleScannerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final barcode = _scannerBuffer.trim();
      if (barcode.isEmpty) {
        return KeyEventResult.ignored;
      }

      _resetScannerBuffer();
      unawaited(_handleBarcodeSubmit(barcode));
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _setSearchQuery('');
      _resetScannerBuffer();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_scannerBuffer.isEmpty) {
        return KeyEventResult.ignored;
      }

      _scannerBuffer = _scannerBuffer.substring(0, _scannerBuffer.length - 1);
      _lastScannerKeyAt = DateTime.now();
      _setSearchQuery(_scannerBuffer);
      return KeyEventResult.handled;
    }

    final character = event.character;
    if (character == null ||
        character.isEmpty ||
        character.trim().isEmpty ||
        character.length != 1) {
      return KeyEventResult.ignored;
    }

    final now = DateTime.now();
    if (_lastScannerKeyAt == null ||
        now.difference(_lastScannerKeyAt!) > _scannerCharacterGap) {
      _scannerBuffer = '';
    }

    _lastScannerKeyAt = now;
    _scannerBuffer += character;
    _setSearchQuery(_scannerBuffer);
    return KeyEventResult.handled;
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
    final orderState = ref.watch(orderProvider);

    return Focus(
      focusNode: _scannerFocusNode,
      autofocus: true,
      onKeyEvent: _handleScannerKey,
      child: Scaffold(
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 960;

            if (isCompact) {
              return Column(
                children: [
                  Expanded(child: _buildCatalogPanel(context)),
                  Container(height: 1, color: Theme.of(context).dividerColor),
                  SizedBox(
                    height: 360,
                    child: _CartPanel(
                      cart: cart,
                      cartTotal: cartTotal,
                      cartVat: cartVat,
                      cartNet: cartNet,
                      isSubmitting: orderState.isLoading,
                      onClear: () => ref.read(cartProvider.notifier).clear(),
                      onCheckout: () => _checkout(cart),
                      onIncrement: (item) => ref
                          .read(cartProvider.notifier)
                          .incrementQty(item.product.id),
                      onDecrement: (item) => ref
                          .read(cartProvider.notifier)
                          .decrementQty(item.product.id),
                      onRemove: (item) => ref
                          .read(cartProvider.notifier)
                          .removeItem(item.product.id),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 65, child: _buildCatalogPanel(context)),
                Container(width: 1, color: Theme.of(context).dividerColor),
                Expanded(
                  flex: 35,
                  child: _CartPanel(
                    cart: cart,
                    cartTotal: cartTotal,
                    cartVat: cartVat,
                    cartNet: cartNet,
                    isSubmitting: orderState.isLoading,
                    onClear: () => ref.read(cartProvider.notifier).clear(),
                    onCheckout: () => _checkout(cart),
                    onIncrement: (item) => ref
                        .read(cartProvider.notifier)
                        .incrementQty(item.product.id),
                    onDecrement: (item) => ref
                        .read(cartProvider.notifier)
                        .decrementQty(item.product.id),
                    onRemove: (item) => ref
                        .read(cartProvider.notifier)
                        .removeItem(item.product.id),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCatalogPanel(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 144),
            Expanded(child: _ProductGrid(onRefresh: _refreshCatalog)),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withAlpha(16),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const CategoryFilterBar(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Material(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Barcode / Product Search',
                              hintText:
                                  'Type product name, SKU, or scan barcode',
                              prefixIcon: const Icon(Icons.qr_code_scanner),
                              suffixIcon: IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _setSearchQuery('');
                                  _resetScannerBuffer();
                                  _scannerFocusNode.requestFocus();
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ),
                            textInputAction: TextInputAction.search,
                            onTapOutside: (_) =>
                                _scannerFocusNode.requestFocus(),
                            onChanged: (value) => _setSearchQuery(value),
                            onSubmitted: _handleBarcodeSubmit,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Scanner ready. HID scans auto-fill this field and press enter to match a SKU.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkout(List<CartItem> cart) async {
    await ref.read(orderProvider.notifier).submitOrder(cart);
    if (!mounted) {
      return;
    }

    final orderState = ref.read(orderProvider);
    if (orderState.currentOrder != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PaymentScreen()));
    } else if (orderState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderState.error!), backgroundColor: Colors.red),
      );
    }
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

class _CartPanel extends StatelessWidget {
  const _CartPanel({
    required this.cart,
    required this.cartTotal,
    required this.cartVat,
    required this.cartNet,
    required this.isSubmitting,
    required this.onClear,
    required this.onCheckout,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final List<CartItem> cart;
  final double cartTotal;
  final double cartVat;
  final double cartNet;
  final bool isSubmitting;
  final VoidCallback onClear;
  final Future<void> Function() onCheckout;
  final void Function(CartItem item) onIncrement;
  final void Function(CartItem item) onDecrement;
  final void Function(CartItem item) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              Text('Cart', style: theme.textTheme.titleLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${cart.length} items',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
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
                      onIncrement: () => onIncrement(item),
                      onDecrement: () => onDecrement(item),
                      onRemove: () => onRemove(item),
                    );
                  },
                ),
        ),
        if (cart.isNotEmpty) ...[
          OrderSummaryCard(subtotal: cartTotal, vat: cartVat, net: cartNet),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : onClear,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : onCheckout,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
