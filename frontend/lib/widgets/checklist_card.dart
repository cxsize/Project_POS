import 'package:flutter/material.dart';

import '../models/app_environment.dart';

class ChecklistCard extends StatelessWidget {
  const ChecklistCard({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Color(0x12000000),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bootstrap checklist',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _ChecklistRow(label: 'API base URL', value: environment.apiBaseUrl),
            const SizedBox(height: 12),
            _ChecklistRow(
              label: 'Local DB path',
              value: environment.localDatabasePath,
            ),
            const SizedBox(height: 12),
            _ChecklistRow(
              label: 'Registered Isar schemas',
              value: '${environment.registeredSchemaCount} pending POS-12',
            ),
            const SizedBox(height: 20),
            Text(
              'Next queued work',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('POS-12: register Isar entities and generate code.'),
            const SizedBox(height: 4),
            const Text('POS-16: wire login flow and secure JWT storage.'),
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: const Color(0xFF687672)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF16302B),
          ),
        ),
      ],
    );
  }
}
