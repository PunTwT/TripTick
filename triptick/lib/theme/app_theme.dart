// lib/theme/app_theme.dart
// One place for the look of the whole app. To change the colors of TripTick,
// we only change this file.

import 'package:flutter/material.dart';

class AppTheme {
  // The "seed" color. Material 3 builds a full color palette from it.
  static const Color _seedColor = Colors.teal;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );
}