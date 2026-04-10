import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double vat;
  final double net;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    this.discount = 0,
    required this.vat,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row(context, 'Subtotal', subtotal),
            if (discount > 0) _row(context, 'Discount', -discount),
            _row(context, 'VAT (7%)', vat),
            const Divider(),
            _row(
              context,
              'Total',
              net,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    double amount, {
    TextStyle? style,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style ?? Theme.of(context).textTheme.bodyLarge),
          Text(
            '\u0E3F${amount.toStringAsFixed(2)}',
            style: style ?? Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
