// lib/screens/trip_detail_screen.dart
// The detail screen has 5 tabs. It creates a TripContentProvider so all
// tabs share the same data of this trip.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/trip_content_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import 'tabs/budget_tab.dart';
import 'tabs/itinerary_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/packing_tab.dart';
import 'tabs/places_tab.dart';
import 'trip_form_screen.dart';

class TripDetailScreen extends StatelessWidget {
  final int tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripContentProvider(tripId)..load(),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  Future<void> _edit(BuildContext context, Trip trip) async {
    final edited = await Navigator.push<Trip>(
      context,
      MaterialPageRoute(builder: (_) => TripFormScreen(trip: trip)),
    );
    if (edited == null || !context.mounted) return;
    await context.read<TripProvider>().updateTrip(edited);
    if (!context.mounted) return;
    await context.read<TripContentProvider>().load();
  }

  Future<void> _delete(BuildContext context, Trip trip) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete trip?',
      message: '"${trip.name}" and everything inside it will be deleted.',
    );
    if (!ok || !context.mounted) return;
    await context.read<TripProvider>().deleteTrip(trip.id!);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<TripContentProvider>();

    if (content.isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trip = content.trip;
    if (trip == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.error_outline, message: 'Trip not found'),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(trip.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => _edit(context, trip),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _delete(context, trip),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
              Tab(icon: Icon(Icons.place_outlined), text: 'Places'),
              Tab(icon: Icon(Icons.payments_outlined), text: 'Budget'),
              Tab(icon: Icon(Icons.checklist), text: 'Packing'),
              Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Itinerary'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OverviewTab(),
            PlacesTab(),
            BudgetTab(),
            PackingTab(),
            ItineraryTab(),
          ],
        ),
      ),
    );
  }
}