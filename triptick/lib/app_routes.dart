// lib/app_routes.dart
// All screen names (routes) in one place.
// Other files write AppRoutes.home instead of the text '/', so a typing
// mistake becomes a Dart error instead of a crash while the app runs.

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/trip_detail_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String tripDetail = '/trip';

  // Flutter calls this function every time we use Navigator.pushNamed.
  // "settings.arguments" is the extra data we send (for example a trip id).
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case tripDetail:
        final tripId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => TripDetailScreen(tripId: tripId),
        );
      case home:
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}