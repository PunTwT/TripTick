// lib/providers/theme_provider.dart
// Remembers if the user wants light, dark, or the phone's setting.
// For now it only lives in memory. In Step 14 we will save it with
// shared_preferences so it is remembered after the app closes.

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // follow the phone by default

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return; // nothing changed, no need to redraw
    _themeMode = mode;
    notifyListeners(); // tells every widget that listens: "redraw yourself"
  }
}