// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'providers/theme_provider.dart';
import 'providers/trip_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If notifications fail for any reason, the app must still start.
  try {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermission();
  } catch (e) {
    debugPrint('Notification setup failed: $e');
  }

  runApp(const TripTickApp());
}

class TripTickApp extends StatelessWidget {
  const TripTickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => TripProvider()..loadTrips()),
      ],
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