import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand color — deep teal/blue for trust/financial feel
  static const primaryColor = Color(0xFF1A6B72);
  static const primaryColorDark = Color(0xFF0F4A50);

  // Semantic colors (light mode defaults).
  static const gainColor = Color(0xFF22C55E);
  static const lossColor = Color(0xFFEF4444);
  static const neutralColor = Color(0xFF6B7280);

  // Brighter variants for dark mode to keep contrast against dark surfaces.
  static const gainColorDark = Color(0xFF4ADE80);
  static const lossColorDark = Color(0xFFF87171);
  static const neutralColorDark = Color(0xFF9CA3AF);

  // Surface colors
  static const surfaceLight = Color(0xFFF8FAFC);
  static const cardLight = Color(0xFFFFFFFF);

  /// Returns the P&L green for the current brightness.
  static Color gainFor(Brightness b) =>
      b == Brightness.dark ? gainColorDark : gainColor;

  /// Returns the P&L red for the current brightness.
  static Color lossFor(Brightness b) =>
      b == Brightness.dark ? lossColorDark : lossColor;

  static Color neutralFor(Brightness b) =>
      b == Brightness.dark ? neutralColorDark : neutralColor;

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      cardTheme: const CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
