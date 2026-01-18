import 'package:flutter/material.dart';

class AppColors {
  // Primary color
  static const Color primary = Color(0xFF1976D2); // A nice, strong blue

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5); // Off-white
  static const Color lightSurface = Colors.white;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSurface = Color(0xFF1C1C1E); // Dark grey for text

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212); // Recommended dark grey by Material 3
  static const Color darkSurface = Color(0xFF1E1E1E); // Slightly lighter grey for cards
  static const Color darkOnPrimary = Color(0xFF121212);
  static const Color darkOnSurface = Color(0xFFE4E4E6); // Light grey for text
}
