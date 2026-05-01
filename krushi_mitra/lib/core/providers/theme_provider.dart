import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const _key = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_key);
    if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
    _syncColors();
  }

  void _syncColors() {
    if (state == ThemeMode.dark) {
      AppColors.isDarkMode = true;
    } else if (state == ThemeMode.light) {
      AppColors.isDarkMode = false;
    } else {
      // For system, we'd need a context to be 100% accurate, 
      // but usually the app's build method handles the heavy lifting via themeProvider.
      // Default to true for Stitch feel if system is ambiguous.
      AppColors.isDarkMode = true; 
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    _syncColors();
    
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setString(_key, 'dark');
    } else if (mode == ThemeMode.light) {
      await prefs.setString(_key, 'light');
    } else {
      await prefs.remove(_key);
    }
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
