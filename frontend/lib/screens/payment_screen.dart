import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../models/cart_item.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/service_providers.dart';
import '../services/thermal_printer_service.dart';
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
  bool _isPrinting = false;

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
      _showSuccessDialog(state.change ?? 0);
    }
  }

  void _showSuccessDialog(double change) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Payment Complete'),
          ],
        ),
        content: change > 0
            ? Text(
                'Change: \u0E3F${change.toStringAsFixed(2)}',
                style: Theme.of(ctx).textTheme.headlineMedium,
              )
            : const Text('Payment received successfully.'),
        actions: [
          OutlinedButton.icon(
            onPressed: _isPrinting ? null : _printReceipt,
            icon: _isPrinting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print),
            label: Text(_isPrinting ? 'Printing...' : 'Print Receipt'),
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
  }

  Future<void> _printReceipt() async {
    final order = ref.read(orderProvider).currentOrder;
    if (order == null) {
      return;
    }

    final target = await _showPrinterTargetPicker();
    if (target == null || !mounted) {
      return;
    }

    final cartItems = ref.read(cartProvider);
    final lineItems = cartItems.map(_mapLineItem).toList(growable: false);
    if (lineItems.isEmpty) {
      _showSnack('Unable to print: cart items are empty.', isError: true);
      return;
    }

    final paidAmount =
        double.tryParse(_amountController.text) ?? order.netAmount;
    final auth = ref.read(authProvider);
    final job = ReceiptPrintJob(
      orderNo: order.orderNo,
      createdAt: order.createdAt,
      staffLabel: auth.user?.username ?? auth.user?.id ?? '-',
      paymentMethod: _method,
      items: lineItems,
      subtotal: order.totalAmount,
      discount: order.discountAmount,
      vat: order.vatAmount,
      netTotal: order.netAmount,
      amountReceived: paidAmount,
      change: ref.read(orderProvider).change ?? 0,
    );

    setState(() => _isPrinting = true);
    try {
      await ref
          .read(thermalPrinterServiceProvider)
          .printReceipt(job: job, target: target);
      if (mounted) {
        _showSnack('Receipt sent to printer.');
      }
    } on UnsupportedError catch (error) {
      _showSnack(error.message ?? error.toString(), isError: true);
    } catch (error) {
      _showSnack('Print failed: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  ReceiptLineItem _mapLineItem(CartItem item) {
    return ReceiptLineItem(
      name: item.product.name,
      qty: item.qty,
      unitPrice: item.product.basePrice,
      subtotal: item.subtotal,
    );
  }

  Future<PrinterTarget?> _showPrinterTargetPicker() async {
    var mode = _PrinterMode.network;
    final hostController = TextEditingController(text: '192.168.1.100');
    final portController = TextEditingController(text: '9100');
    final bluetoothController = TextEditingController();

    return showDialog<PrinterTarget>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Print Receipt'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedButton<_PrinterMode>(
                      segments: const [
                        ButtonSegment<_PrinterMode>(
                          value: _PrinterMode.network,
                          label: Text('LAN'),
                          icon: Icon(Icons.lan),
                        ),
                        ButtonSegment<_PrinterMode>(
                          value: _PrinterMode.bluetooth,
                          label: Text('Bluetooth'),
                          icon: Icon(Icons.bluetooth),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (selection) {
                        setDialogState(() => mode = selection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (mode == _PrinterMode.network) ...[
                      TextField(
                        controller: hostController,
                        decoration: const InputDecoration(
                          labelText: 'Printer host',
                          hintText: 'e.g. 192.168.1.50',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: portController,
                        decoration: const InputDecoration(labelText: 'Port'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ] else ...[
                      TextField(
                        controller: bluetoothController,
                        decoration: const InputDecoration(
                          labelText: 'Bluetooth device address',
                          hintText: 'e.g. AA:BB:CC:DD:EE:FF',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (mode == _PrinterMode.network) {
                      final host = hostController.text.trim();
                      final port =
                          int.tryParse(portController.text.trim()) ?? 9100;
                      if (host.isEmpty) {
                        return;
                      }
                      Navigator.of(
                        dialogContext,
                      ).pop(NetworkPrinterTarget(host: host, port: port));
                      return;
                    }

                    final address = bluetoothController.text.trim();
                    if (address.isEmpty) {
                      return;
                    }
                    Navigator.of(
                      dialogContext,
                    ).pop(BluetoothPrinterTarget(deviceAddress: address));
                  },
                  child: const Text('Print'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
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

enum _PrinterMode { network, bluetooth }
