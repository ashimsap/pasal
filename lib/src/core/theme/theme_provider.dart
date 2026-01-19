import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'themeMode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_key);
    if (themeName != null) {
      try {
        state = ThemeMode.values.byName(themeName);
      } catch (e) {
        state = ThemeMode.system;
      }
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    if (state == themeMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, themeMode.name);
    state = themeMode;
  }
}
