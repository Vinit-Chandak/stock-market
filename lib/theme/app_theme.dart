import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Muted, elegant color palette
  static const Color background = Color(0xFF0F1118);
  static const Color surface = Color(0xFF181B25);
  static const Color surfaceLight = Color(0xFF1F2330);
  static const Color cardBorder = Color(0xFF2A2E3D);
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8E91A4);
  static const Color textTertiary = Color(0xFF5A5D6E);
  static const Color accent = Color(0xFF6C72F6);
  static const Color accentLight = Color(0xFF8B8FF8);
  static const Color profit = Color(0xFF34D399);
  static const Color profitBg = Color(0xFF0D2E23);
  static const Color loss = Color(0xFFF87171);
  static const Color lossBg = Color(0xFF2E1315);
  static const Color divider = Color(0xFF252838);

  static Color pnlColor(double value) => value >= 0 ? profit : loss;
  static Color pnlBgColor(double value) => value >= 0 ? profitBg : lossBg;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: accentLight,
        error: loss,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            color: textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          titleLarge: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: TextStyle(
            color: textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return GoogleFonts.inter(
            color: textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return const IconThemeData(color: textTertiary, size: 22);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
