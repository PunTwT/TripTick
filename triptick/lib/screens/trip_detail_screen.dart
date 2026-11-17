// lib/screens/trip_detail_screen.dart
// PLACEHOLDER. It only proves that navigation and passing an id work.
// The real detail screen comes in Step 5.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/trip_provider.dart';

class TripDetailScreen extends StatefulWidget {
  final int tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late final Future<Trip?> _tripFuture;

  @override
  void initState() {
    super.initState();
    // We create the Future ONCE here. If we created it inside build(),
    // the database would be read again every time the screen redraws.
    _tripFuture = context.read<TripProvider>().getTripById(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip detail')),
      body: FutureBuilder<Trip?>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final trip = snapshot.data;
          if (trip == null) {
            return const Center(child: Text('Trip not found'));
          }
          return Center(
            child: Text(
              '${trip.name}\n(id: ${trip.id})',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        },
      ),
    );
  }
}