// lib/screens/tabs/itinerary_tab.dart
// Trip days. Each day has places assigned to it.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/itinerary_day.dart';
import '../../models/place.dart';
import '../../providers/trip_content_provider.dart';
import '../../utils/format_helper.dart';
import '../../widgets/dialogs.dart';

class ItineraryTab extends StatelessWidget {
  const ItineraryTab({super.key});

  Future<void> _addPlaceToDay(BuildContext context, ItineraryDay day) async {
    final content = context.read<TripContentProvider>();
    final candidates = content.places.where((p) => p.dayId != day.id).toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add places in the Places tab first')),
      );
      return;
    }

    final picked = await showModalBottomSheet<Place>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text('Choose a place',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (final p in candidates)
              ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(p.name),
                subtitle: Text(p.dayId == null
                    ? 'Not assigned yet'
                    : 'Now on Day ${content.dayById(p.dayId)?.dayNumber ?? '?'}'),
                onTap: () => Navigator.pop(ctx, p),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await content.setPlaceDay(picked, day.id);
  }

  Future<void> _dayMenu(
      BuildContext context, String action, ItineraryDay day) async {
    final content = context.read<TripContentProvider>();
    if (action == 'rename') {
      final text = await askText(
        context,
        title: 'Day ${day.dayNumber} title',
        label: 'Title (example: Arrive in Tokyo)',
        initial: day.title ?? '',
      );
      if (text != null) await content.renameDay(day, text);
    } else if (action == 'delete') {
      final ok = await confirmDialog(
        context,
        title: 'Delete Day ${day.dayNumber}?',
        message: 'The places on this day will stay in the trip.',
      );
      if (ok) await content.deleteDay(day.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<TripContentProvider>();
    final trip = content.trip!;
    final canGenerate = trip.startDate != null && trip.endDate != null;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: content.addDay,
        icon: const Icon(Icons.add),
        label: const Text('Add day'),
      ),
      body: content.days.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 72, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    const Text(
                      'No days yet.\nAdd a day, or create them from your trip dates.',
                      textAlign: TextAlign.center,
                    ),
                    if (canGenerate) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: content.generateDaysFromDates,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Create days from trip dates'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              children: [
                for (final day in content.days) _buildDayCard(context, content, day),
                if (content.unassignedPlaces.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Not assigned to a day',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final p in content.unassignedPlaces)
                                Chip(label: Text(p.name)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildDayCard(
      BuildContext context, TripContentProvider content, ItineraryDay day) {
    final dayPlaces = content.placesOfDay(day.id!);
    final subtitle = [
      if (day.date != null) formatDate(day.date),
      if ((day.title ?? '').isNotEmpty) day.title!,
    ].join(' • ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            ListTile(
              title: Text('Day ${day.dayNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: subtitle.isEmpty ? null : Text(subtitle),
              trailing: PopupMenuButton<String>(
                onSelected: (v) => _dayMenu(context, v, day),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Edit title')),
                  PopupMenuItem(value: 'delete', child: Text('Delete day')),
                ],
              ),
            ),
            for (final p in dayPlaces)
              ListTile(
                dense: true,
                leading: const Icon(Icons.place_outlined),
                title: Text(p.name),
                subtitle: (p.city ?? '').isEmpty ? null : Text(p.city!),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove from this day',
                  onPressed: () => content.setPlaceDay(p, null),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _addPlaceToDay(context, day),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add place'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}