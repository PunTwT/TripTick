// lib/screens/home_screen.dart
// The destination list: search box, status chips, country filter, sort menu.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/trip_card.dart';
import 'trip_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addTrip() async {
    final trip = await Navigator.push<Trip>(
      context,
      MaterialPageRoute(builder: (_) => const TripFormScreen()),
    );
    if (trip == null || !mounted) return;
    await context.read<TripProvider>().addTrip(trip);
  }

  Future<void> _deleteTrip(Trip trip) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete trip?',
      message:
          '"${trip.name}" and all its places, expenses, packing items and days will be deleted.',
    );
    if (!ok || !mounted) return;
    await context.read<TripProvider>().deleteTrip(trip.id!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TripTick'),
        actions: [
          PopupMenuButton<TripSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            initialValue: provider.sort,
            onSelected: provider.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: TripSort.newest, child: Text('Newest first')),
              PopupMenuItem(value: TripSort.name, child: Text('Name (A-Z)')),
              PopupMenuItem(
                  value: TripSort.startDate, child: Text('Start date')),
              PopupMenuItem(
                  value: TripSort.budget, child: Text('Budget (highest)')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearch(provider),
          _buildFilters(provider),
          Expanded(child: _buildList(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTrip,
        icon: const Icon(Icons.add),
        label: const Text('Add destination'),
      ),
    );
  }

  Widget _buildSearch(TripProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search name or country',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildFilters(TripProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: provider.statusFilter == null,
            onSelected: (_) => provider.setStatusFilter(null),
          ),
          for (final status in TripStatus.all)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(status),
                selected: provider.statusFilter == status,
                onSelected: (_) => provider.setStatusFilter(status),
              ),
            ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            // '' means "all countries" (a null value would not call onSelected).
            onSelected: (v) => provider.setCountryFilter(v.isEmpty ? null : v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: '', child: Text('All countries')),
              for (final c in provider.countries)
                PopupMenuItem(value: c, child: Text(c)),
            ],
            child: Chip(
              avatar: const Icon(Icons.public, size: 18),
              label: Text(provider.countryFilter ?? 'Country'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(TripProvider provider) {
    if (provider.isLoading && !provider.hasAnyTrips) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        message: 'Something went wrong:\n${provider.error}',
      );
    }
    if (!provider.hasAnyTrips) {
      return const EmptyState(
        icon: Icons.luggage_outlined,
        message:
            'No destinations yet.\nTap "Add destination" to start.\n(Settings has sample data.)',
      );
    }

    final trips = provider.trips;
    if (trips.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        message: 'No trips match your search or filters.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return TripCard(
          trip: trip,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.tripDetail,
            arguments: trip.id,
          ),
          onDelete: () => _deleteTrip(trip),
        );
      },
    );
  }
}