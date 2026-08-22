import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Neubrutalism tema tanımlaması
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.buttonPrimary,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.buttonSecondary,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        headlineLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
