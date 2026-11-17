// lib/screens/home_screen.dart
// TEMPORARY version, only to test Provider, navigation and theme.
// In Step 5 we replace it with the real destination list (status filters,
// add/edit form).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/trip.dart';
import '../providers/theme_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch = "listen": this screen redraws when TripProvider changes.
    final tripProvider = context.watch<TripProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TripTick'),
        actions: [
          IconButton(
            tooltip: 'Toggle dark mode',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            // context.read = "just use it once": no redraw needed here.
            onPressed: () => context
                .read<ThemeProvider>()
                .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
      body: _buildBody(context, tripProvider),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add sample trip',
        // Temporary: adds a fake trip so we can test. Step 5 opens a form.
        onPressed: () {
          final number = tripProvider.trips.length + 1;
          context.read<TripProvider>().addTrip(
                Trip(name: 'Sample trip $number', country: 'Japan'),
              );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TripProvider provider) {
    if (provider.isLoading && provider.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        message: 'Something went wrong:\n${provider.error}',
      );
    }
    if (provider.trips.isEmpty) {
      return const EmptyState(
        icon: Icons.luggage_outlined,
        message: 'No trips yet.\nTap + to add one.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: provider.trips.length,
      itemBuilder: (context, index) {
        final trip = provider.trips[index];
        return TripCard(
          trip: trip,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.tripDetail,
            arguments: trip.id, // send the id to the next screen
          ),
          onDelete: () => context.read<TripProvider>().deleteTrip(trip.id!),
        );
      },
    );
  }
}