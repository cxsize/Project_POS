import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 52,
      child: categoriesAsync.when(
        data: (categories) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: const Text('All'),
                selected: selected == null,
                onSelected: (_) =>
                    ref.read(selectedCategoryProvider.notifier).select(null),
              ),
            ),
            ...categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat.name),
                  selected: selected == cat.id,
                  onSelected: (_) =>
                      ref.read(selectedCategoryProvider.notifier).select(
                          cat.id),
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
