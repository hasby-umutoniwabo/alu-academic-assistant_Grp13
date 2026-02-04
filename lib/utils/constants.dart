import 'package:flutter/material.dart';

class ALUColors {
  static const Color navy = Color(0xFF0D1B2A);
  static const Color darkBlue = Color(0xFF1B2838);
  static const Color gold = Color(0xFFE8B931);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF43A047);
  static const Color lightGrey = Color(0xFFB0BEC5);
}

// Global app theme using ALU branding
final ThemeData aluTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: ALUColors.navy,
  primaryColor: ALUColors.gold,
  cardTheme: CardTheme(
    color: ALUColors.darkBlue,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);
elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ALUColors.gold,
      foregroundColor: ALUColors.navy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
   inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ALUColors.navy,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: ALUColors.gold),
    ),
    labelStyle: const TextStyle(color: ALUColors.lightGrey),
  ),
);