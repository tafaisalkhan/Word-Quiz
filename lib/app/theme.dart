import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const background = Color(0xFFFDF3FF);
  const surface = Color(0xFFF3E2FF);
  const primary = Color(0xFF6A37D4);
  const secondary = Color(0xFFB00D6A);
  const tertiary = Color(0xFF0057BD);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    ).copyWith(primary: primary, secondary: secondary, tertiary: tertiary),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 16, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4),
    ),
  );
}
