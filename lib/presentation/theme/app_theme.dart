import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setLightTheme() {
    state = ThemeMode.light;
  }

  void setDarkTheme() {
    state = ThemeMode.dark;
  }
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF199A8E), // New primary color
    scaffoldBackgroundColor: const Color(0xFFF2F2F2), // Slightly adjusted scaffold color
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF199A8E), // Matching app bar
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF199A8E), // New primary
      secondary: Color(0xFF44D62C), // New secondary
      surface: Colors.white,
      background: Color(0xFFF2F2F2),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1EBEA5), // Lighter primary for dark mode
    scaffoldBackgroundColor: const Color(0xFF1A1A1A), // Dark scaffold
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1EBEA5), // Lighter primary for dark mode
      secondary: Color(0xFF56F942), // Lighter secondary for dark mode
      surface: Color(0xFF242424), // Darker surface
      background: Color(0xFF1A1A1A),
    ),
  );
}
