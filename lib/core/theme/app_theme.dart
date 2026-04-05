import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand color — deep teal/blue for trust/financial feel
  static const primaryColor = Color(0xFF1A6B72);
  static const primaryColorDark = Color(0xFF0F4A50);

  // Semantic colors
  static const gainColor = Color(0xFF22C55E); // green for positive returns
  static const lossColor = Color(0xFFEF4444); // red for negative/losses
  static const neutralColor = Color(0xFF6B7280); // gray for neutral

  // Surface colors
  static const surfaceLight = Color(0xFFF8FAFC);
  static const cardLight = Color(0xFFFFFFFF);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
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
        // typography: slightly larger for financial readability
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
