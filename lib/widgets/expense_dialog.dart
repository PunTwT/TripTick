// lib/widgets/expense_dialog.dart
// Dialog to add or edit one expense. Returns the Expense with Navigator.pop.

import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/constants.dart';
import '../utils/format_helper.dart';

class ExpenseDialog extends StatefulWidget {
  final int tripId;
  final Expense? expense; // null = new

  const ExpenseDialog({super.key, required this.tripId, this.expense});

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountController = TextEditingController(
      text: e == null ? '' : (e.amount % 1 == 0 ? e.amount.toInt().toString() : e.amount.toString()),
    );
    _noteController = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? kExpenseCategories.first;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount =
        double.parse(_amountController.text.trim().replaceAll(',', ''));
    final note = _noteController.text.trim();

    Navigator.pop(
      context,
      Expense(
        id: widget.expense?.id,
        tripId: widget.tripId,
        category: _category,
        amount: amount,
        note: note.isEmpty ? null : note,
        date: _date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense == null ? 'Add expense' : 'Edit expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in {...kExpenseCategories, _category})
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount *'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim().replaceAll(',', ''));
                  if (n == null) return 'Enter a number';
                  if (n <= 0) return 'Must be more than 0';
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event),
                label: Text(formatDate(_date)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}