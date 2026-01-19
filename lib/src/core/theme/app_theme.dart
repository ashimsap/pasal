import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme(Color seedColor, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: GoogleFonts.lato().fontFamily,
      scaffoldBackgroundColor: Colors.transparent, // Make scaffold background transparent
      cardColor: brightness == Brightness.light ? Colors.white : Colors.grey[850],
    );
  }
}
