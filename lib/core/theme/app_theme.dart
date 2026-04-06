import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF5F8F6F);
  static const Color secondary = Color(0xFF7FB77E);
  static const Color backgroundTop = Color(0xFFE8F5E9);
  static const Color backgroundBottom = Color(0xFFF7FBF8);
  static const Color darkGreen = Color(0xFF2F5D44);
  static const Color card = Color(0xFFFFFFFF);
  static const Color mutedText = Color(0xFF8AA091);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: card,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkGreen,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: darkGreen,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGreen,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkGreen,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkGreen,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkGreen,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: mutedText,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 6,
        shadowColor: primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkGreen,
          side: BorderSide(color: primary.withOpacity(0.18)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: darkGreen,
        size: 22,
      ),
      dividerColor: const Color(0xFFE4ECE5),
    );
  }
}