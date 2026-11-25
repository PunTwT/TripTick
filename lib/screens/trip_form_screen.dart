// lib/screens/trip_form_screen.dart
// One form for both "add" and "edit". If a trip is passed in, we are editing.
// The form does NOT save by itself: it returns the Trip to the caller
// with Navigator.pop, and the caller saves it through the provider.

import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../utils/constants.dart';
import '../utils/format_helper.dart';

class TripFormScreen extends StatefulWidget {
  final Trip? trip; // null = new trip

  const TripFormScreen({super.key, this.trip});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late String _status;
  late String _currency;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEdit => widget.trip != null;

  @override
  void initState() {
    super.initState();
    final t = widget.trip;
    _nameController = TextEditingController(text: t?.name ?? '');
    _countryController = TextEditingController(text: t?.country ?? '');
    _minController = TextEditingController(text: _numText(t?.budgetMin));
    _maxController = TextEditingController(text: _numText(t?.budgetMax));
    _status = t?.status ?? TripStatus.wishlist;
    _currency = t?.currency ?? kCurrencies.first;
    _startDate = t?.startDate;
    _endDate = t?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String _numText(double? v) {
    if (v == null) return '';
    return v % 1 == 0 ? v.toInt().toString() : v.toString();
  }

  double? _parse(String? text) =>
      double.tryParse((text ?? '').trim().replaceAll(',', ''));

  String? _validateOptionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final number = _parse(value);
    if (number == null) return 'Enter a number';
    if (number < 0) return 'Must be 0 or more';
    return null;
  }

  String? _validateMax(String? value) {
    final basic = _validateOptionalNumber(value);
    if (basic != null) return basic;
    final max = _parse(value);
    final min = _parse(_minController.text);
    if (max != null && min != null && max < min) {
      return 'Max must be at least the min';
    }
    return null;
  }

  Future<DateTime?> _pickDate(DateTime? initial) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after the start date')),
      );
      return;
    }

    // We build a NEW Trip (not copyWith) so that cleared fields become null.
    final trip = Trip(
      id: widget.trip?.id,
      name: _nameController.text.trim(),
      country: _countryController.text.trim(),
      status: _status,
      budgetMin: _parse(_minController.text),
      budgetMax: _parse(_maxController.text),
      currency: _currency,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.pop(context, trip);
  }

  Widget _dateTile({
    required String label,
    required DateTime? value,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: Text(label),
      subtitle: Text(value == null ? 'Not set' : formatDate(value)),
      trailing: value == null
          ? null
          : IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
      onTap: onPick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit destination' : 'New destination'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Trip name *',
                hintText: 'Example: Japan Spring 2027',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _countryController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Country *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a country'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final s in TripStatus.all)
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in {...kCurrencies, _currency})
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _currency = v ?? _currency),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Budget min',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateOptionalNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Budget max',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateMax,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _dateTile(
              label: 'Start date',
              value: _startDate,
              onPick: () async {
                final d = await _pickDate(_startDate);
                if (d != null) setState(() => _startDate = d);
              },
              onClear: () => setState(() => _startDate = null),
            ),
            _dateTile(
              label: 'End date',
              value: _endDate,
              onPick: () async {
                final d = await _pickDate(_endDate ?? _startDate);
                if (d != null) setState(() => _endDate = d);
              },
              onClear: () => setState(() => _endDate = null),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}