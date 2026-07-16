import 'package:flutter/material.dart';

class TomoriColors {
  static const green = Color(0xFF5D8644);
  static const deepGreen = Color(0xFF24402D);
  static const leaf = Color(0xFF8FA877);
  static const cream = Color(0xFFF7F3EA);
  static const paper = Color(0xFFFFFCF5);
  static const line = Color(0xFFE5DECF);
  static const lightGreen = Color(0xFFE9F0DE);
  static const lamp = Color(0xFFC9A84B);
  static const text = Color(0xFF273327);
}

class TomoriTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TomoriColors.green,
        brightness: Brightness.light,
        surface: TomoriColors.cream,
      ),
      scaffoldBackgroundColor: TomoriColors.cream,
      fontFamily: 'sans',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, height: 1.35, fontWeight: FontWeight.w700, color: TomoriColors.text),
        headlineMedium: TextStyle(fontSize: 21, height: 1.45, fontWeight: FontWeight.w700, color: TomoriColors.text),
        titleLarge: TextStyle(fontSize: 18, height: 1.45, fontWeight: FontWeight.w700, color: TomoriColors.text),
        titleMedium: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w700, color: TomoriColors.text),
        bodyLarge: TextStyle(fontSize: 16, height: 1.7, color: TomoriColors.text),
        bodyMedium: TextStyle(fontSize: 14, height: 1.65, color: TomoriColors.text),
        bodySmall: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF5F685B)),
      ),
    );
  }
}
