// lib/screens/tabs/places_tab.dart
// List of places: tick visited, filter, edit, delete, open in Maps.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/place.dart';
import '../../providers/trip_content_provider.dart';
import '../../utils/maps_helper.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/empty_state.dart';
import '../place_form_screen.dart';

enum _PlaceFilter { all, mustVisit, notVisited }

class PlacesTab extends StatefulWidget {
  const PlacesTab({super.key});

  @override
  State<PlacesTab> createState() => _PlacesTabState();
}

class _PlacesTabState extends State<PlacesTab> {
  _PlaceFilter _filter = _PlaceFilter.all;

  Future<void> _openForm(BuildContext context, {Place? place}) async {
    final content = context.read<TripContentProvider>();
    final result = await Navigator.push<Place>(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceFormScreen(tripId: content.tripId, place: place),
      ),
    );
    if (result == null) return;
    if (place == null) {
      await content.addPlace(result);
    } else {
      await content.updatePlace(result);
    }
  }

  Future<void> _delete(BuildContext context, Place place) async {
    final content = context.read<TripContentProvider>();
    final ok = await confirmDialog(
      context,
      title: 'Delete place?',
      message: '"${place.name}" will be deleted.',
    );
    if (ok) await content.deletePlace(place.id!);
  }

  List<Place> _applyFilter(List<Place> all) {
    switch (_filter) {
      case _PlaceFilter.mustVisit:
        return all.where((p) => p.isMustVisit).toList();
      case _PlaceFilter.notVisited:
        return all.where((p) => !p.isVisited).toList();
      case _PlaceFilter.all:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<TripContentProvider>();
    final shown = _applyFilter(content.places);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add place'),
      ),
      body: content.places.isEmpty
          ? const EmptyState(
              icon: Icons.place_outlined,
              message: 'No places yet.\nAdd landmarks and must-visit spots.',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${content.visitedCount} of ${content.places.length} visited',
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: content.visitedCount / content.places.length,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _filter == _PlaceFilter.all,
                            onSelected: (_) =>
                                setState(() => _filter = _PlaceFilter.all),
                          ),
                          ChoiceChip(
                            label: const Text('Must-visit'),
                            selected: _filter == _PlaceFilter.mustVisit,
                            onSelected: (_) =>
                                setState(() => _filter = _PlaceFilter.mustVisit),
                          ),
                          ChoiceChip(
                            label: const Text('Not visited'),
                            selected: _filter == _PlaceFilter.notVisited,
                            onSelected: (_) => setState(
                                () => _filter = _PlaceFilter.notVisited),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: shown.isEmpty
                      ? const EmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          message: 'No places match this filter.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 96),
                          itemCount: shown.length,
                          itemBuilder: (context, i) =>
                              _buildPlaceCard(context, content, shown[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPlaceCard(
      BuildContext context, TripContentProvider content, Place place) {
    final details = [
      if ((place.city ?? '').isNotEmpty) place.city!,
      if ((place.category ?? '').isNotEmpty) place.category!,
    ].join(' • ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            isThreeLine: (place.note ?? '').isNotEmpty,
            leading: Checkbox(
              value: place.isVisited,
              onChanged: (_) => content.toggleVisited(place),
            ),
            title: Text(
              place.name,
              style: place.isVisited
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            subtitle: Text(
              [
                if (details.isNotEmpty) details,
                if ((place.note ?? '').isNotEmpty) place.note!,
              ].join('\n'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (place.isMustVisit)
                  const Icon(Icons.star, color: Colors.amber),
                IconButton(
                  icon: const Icon(Icons.map_outlined),
                  tooltip: 'Open in Maps',
                  onPressed: () => openInMaps(context, place),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _openForm(context, place: place);
                    if (v == 'delete') _delete(context, place);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            onTap: () => _openForm(context, place: place),
          ),
          if (place.photoPath != null)
            Image.file(
              File(place.photoPath!),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}