// lib/screens/tabs/packing_tab.dart
// Packing list with a progress bar.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_content_provider.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/empty_state.dart';

class PackingTab extends StatelessWidget {
  const PackingTab({super.key});

  Future<void> _addItem(BuildContext context) async {
    final content = context.read<TripContentProvider>();
    final name = await askText(
      context,
      title: 'Add packing item',
      label: 'Item (example: Passport)',
    );
    if (name == null || name.isEmpty) return;
    await content.addPackingItem(name);
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<TripContentProvider>();
    final total = content.packingItems.length;
    final packed = content.packedCount;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: total == 0
          ? const EmptyState(
              icon: Icons.checklist,
              message: 'Your packing list is empty.\nTap "Add item".',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packed == total
                            ? 'All packed! 🎉'
                            : '$packed of $total packed',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: packed / total,
                        minHeight: 10,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: total,
                    itemBuilder: (context, i) {
                      final item = content.packingItems[i];
                      return CheckboxListTile(
                        value: item.isPacked,
                        onChanged: (_) => content.togglePacked(item),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          item.name,
                          style: item.isPacked
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough)
                              : null,
                        ),
                        secondary: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => content.deletePackingItem(item.id!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}