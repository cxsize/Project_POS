import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/service_providers.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_method_selector.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _method = 'cash';
  final _amountController = TextEditingController();
  final _refNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final order = ref.read(orderProvider).currentOrder;
      if (order != null) {
        _amountController.text = order.netAmount.toStringAsFixed(2);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refNoController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final cartSnapshot = List<CartItem>.from(ref.read(cartProvider));
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref
        .read(orderProvider.notifier)
        .submitPayment(
          _method,
          amount,
          refNo: _refNoController.text.isNotEmpty
              ? _refNoController.text
              : null,
        );

    if (!mounted) return;
    final state = ref.read(orderProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
      );
      return;
    }

    if (state.currentOrder?.paymentStatus == 'paid') {
      final order = state.currentOrder!;
      final change = state.change ?? 0;
      await _attemptAutoPrint(
        order: order,
        cartItems: cartSnapshot,
        change: change,
      );
      _showSuccessDialog(order: order, cartItems: cartSnapshot, change: change);
    }
  }

  Future<void> _attemptAutoPrint({
    required Order order,
    required List<CartItem> cartItems,
    required double change,
  }) async {
    final printerConfig = await ref.read(printerServiceProvider).loadConfig();
    if (!printerConfig.autoPrint || !printerConfig.isConfigured) {
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      await ref
          .read(printerServiceProvider)
          .printSaleReceipt(
            order: order,
            cartItems: cartItems,
            user: ref.read(authProvider).user!,
            changeAmount: change,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt printed successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Receipt print failed: $error')));
    }
  }

  void _showSuccessDialog({
    required Order order,
    required List<CartItem> cartItems,
    required double change,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        var isPrinting = false;
        String? printStatus;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 8),
                Text('Payment Complete'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (change > 0)
                  Text(
                    'Change: \u0E3F${change.toStringAsFixed(2)}',
                    style: Theme.of(ctx).textTheme.headlineMedium,
                  )
                else
                  const Text('Payment received successfully.'),
                const SizedBox(height: 12),
                Text('Order: ${order.orderNo}'),
                if (printStatus != null) ...[
                  const SizedBox(height: 12),
                  Text(printStatus!, style: Theme.of(ctx).textTheme.bodyMedium),
                ],
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: isPrinting
                    ? null
                    : () async {
                        setDialogState(() {
                          isPrinting = true;
                          printStatus = 'Printing receipt...';
                        });
                        try {
                          await ref
                              .read(printerServiceProvider)
                              .printSaleReceipt(
                                order: order,
                                cartItems: cartItems,
                                user: ref.read(authProvider).user!,
                                changeAmount: change,
                              );
                          if (!context.mounted) {
                            return;
                          }
                          setDialogState(() {
                            isPrinting = false;
                            printStatus = 'Receipt sent to printer.';
                          });
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          setDialogState(() {
                            isPrinting = false;
                            printStatus = 'Print failed: $error';
                          });
                        }
                      },
                icon: isPrinting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print),
                label: const Text('Print Receipt'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).clear();
                  ref.read(orderProvider.notifier).reset();
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('New Order'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.currentOrder;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(child: Text('No order found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Payment - ${order.orderNo}')),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OrderSummaryCard(
                subtotal: order.totalAmount,
                discount: order.discountAmount,
                vat: order.vatAmount,
                net: order.netAmount,
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              PaymentMethodSelector(
                selected: _method,
                onSelected: (m) => setState(() => _method = m),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount Received',
                  prefixText: '\u0E3F ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              if (_method != 'cash') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _refNoController,
                  decoration: const InputDecoration(
                    labelText: 'Reference No. (optional)',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: orderState.isLoading ? null : _pay,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: orderState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Payment',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
