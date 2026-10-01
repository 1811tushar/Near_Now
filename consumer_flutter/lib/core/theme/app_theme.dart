
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

class AppTheme {
  AppTheme._();

  /// Subtle elevation used across cards/chips instead of a flat 1px
  /// hairline border — matches the approved mockups (Home, Category,
  /// Product Detail, Cart, Profile).
  static List<BoxShadow> get cardDepth => [
        BoxShadow(
          color: AppColors.ink.withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: AppColors.ink.withOpacity(0.06),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static ThemeData get lightTheme {
    final base = GoogleFonts.manropeTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.meadow,
        primary: AppColors.meadow,
        secondary: AppColors.citrus,
        error: AppColors.error,
        surface: AppColors.card,
        brightness: Brightness.light,
      ),
      textTheme: base.copyWith(
        displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.ink),
        headlineMedium: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
        headlineSmall: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
        titleMedium: GoogleFonts.manrope(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.ink),
        bodyLarge: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
        bodyMedium: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.inkSoft),
        labelSmall: GoogleFonts.manrope(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.inkSoft),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.meadow,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 13.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.meadow,
          side: const BorderSide(color: AppColors.meadow, width: 1.4),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button - 2),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: AppColors.line, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: AppColors.line, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.meadow, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        backgroundColor: AppColors.card,
        selectedColor: AppColors.meadow,
        labelStyle: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700),
        side: BorderSide.none,
      ),
    );
  }
}
