// lib/widgets/trip_card.dart
// One row in the trips list. It only draws things: it receives the trip
// and two functions (onTap, onDelete) from the screen.

import 'package:flutter/material.dart';

import '../models/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.flight_takeoff)),
        title: Text(trip.name),
        subtitle: Text('${trip.country} • ${trip.status}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete',
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}