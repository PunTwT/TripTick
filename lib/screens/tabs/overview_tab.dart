// lib/screens/tabs/overview_tab.dart
// Trip info, status switch and progress summary (places, packing, budget).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trip.dart';
import '../../providers/trip_content_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/format_helper.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<TripContentProvider>();
    final trip = content.trip!;
    final maxBudget = trip.budgetMax;
    final hasReminder =
        trip.startDate != null && trip.status != TripStatus.completed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(trip.country, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            for (final s in TripStatus.all)
              ButtonSegment<String>(value: s, label: Text(s)),
          ],
          selected: {trip.status},
          onSelectionChanged: (selection) async {
            await context
                .read<TripProvider>()
                .updateTrip(trip.copyWith(status: selection.first));
            if (!context.mounted) return;
            await context.read<TripContentProvider>().load();
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Travel period'),
                subtitle: Text(dateRangeText(trip.startDate, trip.endDate)),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Expected budget'),
                subtitle: Text(
                    budgetText(trip.budgetMin, trip.budgetMax, trip.currency)),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Reminder'),
                subtitle: Text(hasReminder
                    ? '1 day before the trip, at 09:00'
                    : 'Set a start date to get a reminder'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Progress', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _ProgressRow(
          icon: Icons.place_outlined,
          label: 'Places visited',
          text: '${content.visitedCount} / ${content.places.length}',
          value: content.places.isEmpty
              ? 0.0
              : content.visitedCount / content.places.length,
        ),
        _ProgressRow(
          icon: Icons.checklist,
          label: 'Packed',
          text: '${content.packedCount} / ${content.packingItems.length}',
          value: content.packingItems.isEmpty
              ? 0.0
              : content.packedCount / content.packingItems.length,
        ),
        _ProgressRow(
          icon: Icons.payments_outlined,
          label: 'Spent',
          text: '${formatMoney(content.totalSpent)} ${trip.currency}',
          value: (maxBudget == null || maxBudget == 0)
              ? 0.0
              : (content.totalSpent / maxBudget).clamp(0.0, 1.0).toDouble(),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final double value;

  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(label), Text(text)],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: value, minHeight: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}