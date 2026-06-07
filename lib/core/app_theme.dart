import 'package:flutter/material.dart';

class AppColors {
  // آبی ملایم و کمرنگ‌تر (بدون گرادیانت)
  static const Color primary = Color(0xFF4A90E2); 
  static const Color background = Color(0xFFF5F7FA); // پس‌زمینه روشن
  static const Color surface = Color(0xFFFFFFFF); // کارت‌ها و شیت‌های سفید
  static const Color accent = Color(0xFF4A90E2); // دکمه‌ها و اکسنت
  static const Color textPrimary = Color(0xFF1A2E40);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color danger = Color(0xFFE74C3C);
  static const Color mattedGrey = Color(0xFFECF0F1); // برای پس‌زمینه تایمر
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Peyda',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(
            fontFamily: 'Peyda',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'Peyda',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontFamily: 'Peyda', fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}