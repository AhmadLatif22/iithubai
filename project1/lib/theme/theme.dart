import 'package:flutter/material.dart';

final ThemeData citrusTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: MaterialColor(
      0xFFFFA726, // Orange as the primary swatch
      {
        50: Color(0xFFFFF3E0),
        100: Color(0xFFFFE0B2),
        200: Color(0xFFFFCC80),
        300: Color(0xFFFFB74D),
        400: Color(0xFFFFA726),
        500: Color(0xFFFF9800),
        600: Color(0xFFFB8C00),
        700: Color(0xFFF57C00),
        800: Color(0xFFEF6C00),
        900: Color(0xFFE65100),
      },
    ),
    accentColor: const Color(0xFF66BB6A), // Fresh green as the accent color
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFFFFBEA), // Soft yellow background
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFA726), // Orange AppBar
    foregroundColor: Colors.white, // White text/icons
    elevation: 0, // Flat AppBar design
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2E7D32), // Dark green for headlines
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2E7D32), // Dark green for medium headlines
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2E7D32),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.black87, // Default body text
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.black54, // Secondary text
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white, // Button text
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF66BB6A), // Green button
      foregroundColor: Colors.white, // White text
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFF9800)), // Orange border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF66BB6A)), // Green border
    ),
    labelStyle: const TextStyle(color: Color(0xFF2E7D32)), // Dark green label
  ),
);
