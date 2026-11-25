// lib/widgets/trip_card.dart

import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../utils/format_helper.dart';

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

  IconData get _statusIcon {
    switch (trip.status) {
      case TripStatus.completed:
        return Icons.check_circle_outline;
      case TripStatus.planned:
        return Icons.event_available;
      default:
        return Icons.favorite_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        isThreeLine: true,
        leading: CircleAvatar(child: Icon(_statusIcon)),
        title: Text(trip.name),
        subtitle: Text(
          '${trip.country} • ${trip.status}\n'
          '${dateRangeText(trip.startDate, trip.endDate)}\n'
          '${budgetText(trip.budgetMin, trip.budgetMax, trip.currency)}',
        ),
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