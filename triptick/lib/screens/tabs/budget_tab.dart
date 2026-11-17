// lib/screens/tabs/budget_tab.dart
// Actual expenses compared with the expected budget range.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/trip_content_provider.dart';
import '../../utils/format_helper.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_dialog.dart';

class BudgetTab extends StatelessWidget {
  const BudgetTab({super.key});

  Future<void> _openDialog(BuildContext context, {Expense? expense}) async {
    final content = context.read<TripContentProvider>();
    final result = await showDialog<Expense>(
      context: context,
      builder: (_) => ExpenseDialog(tripId: content.tripId, expense: expense),
    );
    if (result == null) return;
    if (expense == null) {
      await content.addExpense(result);
    } else {
      await content.updateExpense(result);
    }
  }

  Future<void> _delete(BuildContext context, Expense expense) async {
    final content = context.read<TripContentProvider>();
    final ok = await confirmDialog(
      context,
      title: 'Delete expense?',
      message: '${expense.category}: ${formatMoney(expense.amount)}',
    );
    if (ok) await content.deleteExpense(expense.id!);
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<TripContentProvider>();
    final trip = content.trip!;
    final spent = content.totalSpent;
    final maxBudget = trip.budgetMax;
    final scheme = Theme.of(context).colorScheme;

    // Message under the progress bar.
    String status;
    Color statusColor = scheme.primary;
    if (maxBudget == null) {
      status = 'No maximum budget set. Edit the trip to add one.';
      statusColor = scheme.outline;
    } else if (spent > maxBudget) {
      status = 'Over budget by ${formatMoney(spent - maxBudget)} ${trip.currency}';
      statusColor = scheme.error;
    } else {
      status = '${formatMoney(maxBudget - spent)} ${trip.currency} left of the maximum';
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected: ${budgetText(trip.budgetMin, trip.budgetMax, trip.currency)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Spent: ${formatMoney(spent)} ${trip.currency}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (maxBudget == null || maxBudget == 0)
                        ? 0.0
                        : (spent / maxBudget).clamp(0.0, 1.0).toDouble(),
                    minHeight: 10,
                    color: statusColor,
                  ),
                  const SizedBox(height: 8),
                  Text(status, style: TextStyle(color: statusColor)),
                ],
              ),
            ),
          ),
          if (content.spentByCategory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final entry in content.spentByCategory.entries)
                  Chip(label: Text('${entry.key}: ${formatMoney(entry.value)}')),
              ],
            ),
          ],
          const SizedBox(height: 8),
          if (content.expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                message: 'No expenses yet.\nTap "Add expense" to log one.',
              ),
            )
          else
            for (final e in content.expenses)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
                  title: Text('${formatMoney(e.amount)} ${trip.currency}'),
                  subtitle: Text(
                    [e.category, formatDate(e.date), if ((e.note ?? '').isNotEmpty) e.note!]
                        .join(' • '),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(context, e),
                  ),
                  onTap: () => _openDialog(context, expense: e),
                ),
              ),
        ],
      ),
    );
  }
}