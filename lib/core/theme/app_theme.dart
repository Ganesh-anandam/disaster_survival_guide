// lib/core/theme/app_theme.dart
// ============================================================
// Defines the complete dark-mode, high-contrast design system
// optimized for OLED screens and low-literacy users under stress.
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // ---- Background ----
  static const Color background = Color(0xFF000000);      // Pure OLED black
  static const Color surface = Color(0xFF0D0D0D);         // Elevated surface
  static const Color surfaceVariant = Color(0xFF1A1A1A);  // Card background
  static const Color border = Color(0xFF2A2A2A);          // Dividers

  // ---- Semantic Colors ----
  static const Color emergency = Color(0xFFFF1744);       // RED: Critical
  static const Color emergencyDark = Color(0xFF8B0000);   // RED dark
  static const Color emergencyGlow = Color(0x55FF1744);   // RED glow

  static const Color alert = Color(0xFFFFD600);           // YELLOW: Alert
  static const Color alertDark = Color(0xFFB8A000);       // YELLOW dark
  static const Color alertGlow = Color(0x55FFD600);       // YELLOW glow

  static const Color resource = Color(0xFF2979FF);        // BLUE: Resources
  static const Color resourceDark = Color(0xFF0D47A1);    // BLUE dark
  static const Color resourceGlow = Color(0x552979FF);    // BLUE glow

  static const Color safe = Color(0xFF00E676);            // GREEN: Safe
  static const Color safeDark = Color(0xFF00600A);        // GREEN dark
  static const Color safeGlow = Color(0x5500E676);        // GREEN glow

  // ---- Text ----
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF606060);

  // ---- SOS Button ----
  static const Color sosPrimary = Color(0xFFFF1744);
  static const Color sosSecondary = Color(0xFFFF6B6B);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.emergency,
      secondary: AppColors.alert,
      tertiary: AppColors.resource,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textPrimary,
    ),
    fontFamily: 'Rajdhani',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Rajdhani',
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Rajdhani',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.2,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Rajdhani',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.0,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Rajdhani',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Rajdhani',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(88, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    ),
  );
}
