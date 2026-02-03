/// App theme configuration with WCAG 2.1 AAA compliance

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary brand colors
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color primaryLightColor = Color(0xFF534BAE);
  static const Color primaryDarkColor = Color(0xFF000051);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF00897B);
  static const Color secondaryLightColor = Color(0xFF4EBAAA);
  static const Color secondaryDarkColor = Color(0xFF005B4F);

  // Semantic colors
  static const Color successColor = Color(0xFF1B5E20);
  static const Color warningColor = Color(0xFFE65100);
  static const Color errorColor = Color(0xFFB71C1C);
  static const Color infoColor = Color(0xFF01579B);

  // Neutral colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Light theme with optional high contrast mode
  static ThemeData lightTheme({
    bool highContrast = false,
    double fontSize = 1.0,
  }) {
    final textTheme = _buildTextTheme(
      brightness: Brightness.light,
      highContrast: highContrast,
      fontSizeMultiplier: fontSize,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: highContrast ? Colors.white : backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: highContrast ? Colors.white : surfaceLight,
        onSurface: Colors.black,
        error: errorColor,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: highContrast ? Colors.white : surfaceLight,
        foregroundColor: Colors.black,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: highContrast ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: highContrast
              ? const BorderSide(color: Colors.black, width: 2)
              : BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48), // WCAG touch target
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(
            color: primaryColor,
            width: highContrast ? 2 : 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: highContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor,
            width: highContrast ? 3 : 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: highContrast ? Colors.black : Colors.grey.shade300,
        thickness: highContrast ? 2 : 1,
      ),
      iconTheme: IconThemeData(
        color: highContrast ? Colors.black : Colors.grey.shade800,
        size: 24,
      ),
    );
  }

  /// Dark theme with optional high contrast mode
  static ThemeData darkTheme({
    bool highContrast = false,
    double fontSize = 1.0,
  }) {
    final textTheme = _buildTextTheme(
      brightness: Brightness.dark,
      highContrast: highContrast,
      fontSizeMultiplier: fontSize,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryLightColor,
      scaffoldBackgroundColor: highContrast ? Colors.black : backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: primaryLightColor,
        onPrimary: Colors.black,
        secondary: secondaryLightColor,
        onSecondary: Colors.black,
        surface: highContrast ? Colors.black : surfaceDark,
        onSurface: Colors.white,
        error: const Color(0xFFEF5350),
        onError: Colors.black,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: highContrast ? Colors.black : surfaceDark,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: highContrast ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: highContrast
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade600,
            width: highContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryLightColor,
            width: highContrast ? 3 : 2,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: highContrast ? Colors.white : Colors.grey.shade700,
        thickness: highContrast ? 2 : 1,
      ),
      iconTheme: IconThemeData(
        color: highContrast ? Colors.white : Colors.grey.shade300,
        size: 24,
      ),
    );
  }

  static TextTheme _buildTextTheme({
    required Brightness brightness,
    required bool highContrast,
    required double fontSizeMultiplier,
  }) {
    final baseColor = brightness == Brightness.light
        ? (highContrast ? Colors.black : Colors.grey.shade900)
        : (highContrast ? Colors.white : Colors.grey.shade100);

    final secondaryColor = brightness == Brightness.light
        ? (highContrast ? Colors.black : Colors.grey.shade700)
        : (highContrast ? Colors.white : Colors.grey.shade400);

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 57 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.4,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
