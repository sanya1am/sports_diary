import 'package:flutter/material.dart';
import 'design_tokens.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'TenorSans', // <- основной шрифт (family из pubspec.yaml)
  scaffoldBackgroundColor: DT.bg,
  primaryColor: DT.accentRed,
  colorScheme: ColorScheme.dark(
    primary: DT.accentRed,
    secondary: DT.accentGreen,
    background: DT.bg,
    surface: DT.surface,
    onPrimary: DT.textPrimary,
    onSurface: DT.textPrimary,
  ),

  // Typography — увеличенные размеры (подправь по вкусу)
  textTheme: TextTheme(
    displayLarge: const TextStyle(fontFamily: 'TenorSans', fontSize: 42, fontWeight: FontWeight.w700, color: DT.textPrimary), // H1
    headlineMedium: const TextStyle(fontFamily: 'TenorSans', fontSize: 30, fontWeight: FontWeight.w700, color: DT.textPrimary), // H2
    titleLarge: const TextStyle(fontFamily: 'TenorSans', fontSize: 26, fontWeight: FontWeight.w600, color: DT.textPrimary), // H3
    bodyLarge: const TextStyle(fontFamily: 'TenorSans', fontSize: 20, fontWeight: FontWeight.w400, color: DT.textPrimary),
    bodyMedium: const TextStyle(fontFamily: 'TenorSans', fontSize: 18, fontWeight: FontWeight.w400, color: DT.textSecondary),
    labelSmall: const TextStyle(fontFamily: 'TenorSans', fontSize: 14, fontWeight: FontWeight.w400, color: DT.muted),
  ),

  // AppBar
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    titleTextStyle: const TextStyle(fontFamily: 'TenorSans', fontSize: 24, fontWeight: FontWeight.w700, color: DT.textPrimary),
    iconTheme: const IconThemeData(color: DT.textPrimary),
  ),

  cardTheme: CardThemeData(
    color: DT.surface,
    elevation: 6,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DT.radiusMedium)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DT.accentGreen,
      foregroundColor: DT.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      textStyle: const TextStyle(fontFamily: 'TenorSans', fontWeight: FontWeight.w600),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: DT.accentRed.withOpacity(0.12)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontFamily: 'TenorSans'),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: const Color(0xFF101215),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    hintStyle: const TextStyle(color: DT.muted, fontFamily: 'TenorSans'),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: DT.accentRed,
    foregroundColor: DT.textPrimary,
    elevation: 6,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: DT.surface,
    selectedItemColor: DT.accentRed,
    unselectedItemColor: DT.textSecondary,
    showUnselectedLabels: false,
  ),

  iconTheme: const IconThemeData(color: DT.textPrimary),
);
