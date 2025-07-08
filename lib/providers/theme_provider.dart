import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      print('Error loading theme: $e');
      // Fallback to light theme
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = state == ThemeMode.dark;
      state = isDark ? ThemeMode.light : ThemeMode.dark;
      await prefs.setBool(_themeKey, !isDark);
    } catch (e) {
      print('Error saving theme: $e');
      // Still toggle the theme even if saving fails
      final isDark = state == ThemeMode.dark;
      state = isDark ? ThemeMode.light : ThemeMode.dark;
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);
