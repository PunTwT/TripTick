// lib/main.dart
// The real entry point of TripTick.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'providers/theme_provider.dart';
import 'providers/trip_provider.dart';
import 'theme/app_theme.dart';

void main() {
  // Needed because plugins (sqflite) are used before runApp().
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TripTickApp());
}

class TripTickApp extends StatelessWidget {
  const TripTickApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider puts our providers ABOVE MaterialApp,
    // so every screen in the app can find them.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ..loadTrips() = create the provider, then load trips right away.
        ChangeNotifierProvider(create: (_) => TripProvider()..loadTrips()),
      ],
      // Consumer rebuilds only MaterialApp when the theme mode changes.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'TripTick',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}