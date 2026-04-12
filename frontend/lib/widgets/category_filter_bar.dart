import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_provider.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    final theme = Theme.of(context);

    return SizedBox(
      height: 64,
      child: categoriesAsync.when(
        data: (categories) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: const Text('All'),
                selected: selected == null,
                labelStyle: theme.textTheme.labelLarge,
                onSelected: (_) =>
                    ref.read(selectedCategoryProvider.notifier).state = null,
              ),
            ),
            ...categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat.name),
                  selected: selected == cat.id,
                  labelStyle: theme.textTheme.labelLarge,
                  onSelected: (_) =>
                      ref.read(selectedCategoryProvider.notifier).state =
                          cat.id,
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
