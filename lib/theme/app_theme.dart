import 'package:flutter/material.dart';

/// App theme colors and constants
class AppTheme {
  // Primary color (app icon color) - Deep Purple Accent
  static const Color primary = Color(0xFF7C4DFF); // deepPurpleAccent hex
  
  // Lighter shade of primary for inactive states
  static const Color primaryLight = Color(0xFFB39DDB); // lighter purple
  
  // Accent color - same as primary (purple)
  static const Color accent = Color(0xFF7C4DFF);
  
  // Get theme data
  static ThemeData getTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: Color(0xFF1A1A1A),
      ),
    );
  }
}
