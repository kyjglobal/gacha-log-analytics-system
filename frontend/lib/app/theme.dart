import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF080B12);
  static const surface = Color(0xFF111722);
  static const surfaceHigh = Color(0xFF192130);
  static const border = Color(0xFF273145);
  static const primary = Color(0xFF8B5CF6);
  static const secondary = Color(0xFF22D3EE);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFFB7185);
  static const text = Color(0xFFF4F7FB);
  static const muted = Color(0xFF94A3B8);
}

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: AppColors.text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: AppColors.muted, height: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        hintStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
