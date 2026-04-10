import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MethodButton(
          icon: Icons.payments,
          label: 'Cash',
          value: 'cash',
          selected: selected,
          onTap: onSelected,
        ),
        const SizedBox(width: 12),
        _MethodButton(
          icon: Icons.qr_code,
          label: 'QR',
          value: 'qr',
          selected: selected,
          onTap: onSelected,
        ),
        const SizedBox(width: 12),
        _MethodButton(
          icon: Icons.credit_card,
          label: 'Card',
          value: 'credit_card',
          selected: selected,
          onTap: onSelected,
        ),
      ],
    );
  }
}

class _MethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _MethodButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(value),
          child: Container(
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
