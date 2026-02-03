/// App theme configuration with Digital ABCs branding
/// WCAG 2.1 AAA compliant with rounded corners and soft shadows

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============================================
  // Digital ABCs Brand Colors
  // ============================================

  // Primary Colors
  static const Color navy = Color(0xFF1E3A8A); // Headers, navigation, core brand
  static const Color purple = Color(0xFF7C3AED); // Highlights, secondary accents
  static const Color lightBlue = Color(0xFF60A5FA); // Secondary backgrounds

  // Neutral Colors
  static const Color black = Color(0xFF000000); // Text
  static const Color grey = Color(0xFF6B7280); // Body text, backgrounds
  static const Color white = Color(0xFFFFFFFF); // Base

  // Accent Colors
  static const Color green = Color(0xFF10B981); // CTA, Success - "Go" signals
  static const Color red = Color(0xFFDC2626); // Errors, warnings, alerts only

  // Derived Colors for UI
  static const Color primaryColor = navy;
  static const Color primaryLightColor = lightBlue;
  static const Color primaryDarkColor = Color(0xFF1E2A5E);
  static const Color secondaryColor = purple;
  static const Color accentColor = green;

  // Semantic colors
  static const Color successColor = green;
  static const Color warningColor = Color(0xFFF59E0B); // Amber for warnings
  static const Color errorColor = red;
  static const Color infoColor = lightBlue;

  // Background colors
  static const Color backgroundLight = Color(0xFFF9FAFB); // Very light grey
  static const Color backgroundDark = Color(0xFF111827); // Dark navy-grey
  static const Color surfaceLight = white;
  static const Color surfaceDark = Color(0xFF1F2937);

  // ============================================
  // UI Constants - Rounded corners, soft shadows
  // ============================================

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Soft shadows for approachable feel
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ];

  // ============================================
  // Light Theme
  // ============================================

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
      primaryColor: navy,
      scaffoldBackgroundColor: highContrast ? white : backgroundLight,
      colorScheme: ColorScheme.light(
        primary: navy,
        onPrimary: white,
        primaryContainer: lightBlue.withOpacity(0.2),
        onPrimaryContainer: navy,
        secondary: purple,
        onSecondary: white,
        secondaryContainer: purple.withOpacity(0.1),
        onSecondaryContainer: purple,
        tertiary: green,
        onTertiary: white,
        tertiaryContainer: green.withOpacity(0.1),
        onTertiaryContainer: green,
        surface: highContrast ? white : surfaceLight,
        onSurface: black,
        surfaceContainerHighest: grey.withOpacity(0.1),
        error: red,
        onError: white,
        outline: grey.withOpacity(0.3),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: highContrast ? white : surfaceLight,
        foregroundColor: navy,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: navy,
        ),
      ),
      cardTheme: CardTheme(
        elevation: highContrast ? 0 : 0, // Using shadows instead
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: highContrast
              ? const BorderSide(color: black, width: 2)
              : BorderSide(color: grey.withOpacity(0.1)),
        ),
        color: surfaceLight,
      ),
      // Primary CTA buttons - Green for "Go" actions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: white,
          minimumSize: const Size(48, 48), // WCAG touch target
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Secondary buttons - Navy outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(
            color: navy,
            width: highContrast ? 2 : 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // Text buttons - Purple for highlights
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: purple,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // Floating action button - Green CTA
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: green,
        foregroundColor: white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: grey.withOpacity(0.3),
            width: highContrast ? 2 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: grey.withOpacity(0.3),
            width: highContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: navy,
            width: highContrast ? 3 : 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: red,
            width: highContrast ? 2 : 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: red,
            width: highContrast ? 3 : 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.inter(color: grey),
        hintStyle: GoogleFonts.inter(color: grey.withOpacity(0.7)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: grey.withOpacity(0.1),
        selectedColor: purple.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: navy,
        unselectedLabelColor: grey,
        indicatorColor: navy,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: navy,
        unselectedItemColor: grey,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: highContrast ? black : grey.withOpacity(0.2),
        thickness: highContrast ? 2 : 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: highContrast ? black : grey,
        size: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navy,
        contentTextStyle: GoogleFonts.inter(
          color: white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: navy,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadiusLarge),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: purple,
        linearTrackColor: grey.withOpacity(0.2),
        circularTrackColor: grey.withOpacity(0.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return green;
          return grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return green.withOpacity(0.3);
          }
          return grey.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return green;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return green;
          return grey;
        }),
      ),
    );
  }

  // ============================================
  // Dark Theme
  // ============================================

  static ThemeData darkTheme({
    bool highContrast = false,
    double fontSize = 1.0,
  }) {
    final textTheme = _buildTextTheme(
      brightness: Brightness.dark,
      highContrast: highContrast,
      fontSizeMultiplier: fontSize,
    );

    // Lighter variants for dark mode
    const darkPurple = Color(0xFF9F67FF);
    const darkLightBlue = Color(0xFF7CB9FF);
    const darkGreen = Color(0xFF34D399);
    const darkRed = Color(0xFFF87171);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkLightBlue,
      scaffoldBackgroundColor: highContrast ? black : backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: darkLightBlue,
        onPrimary: black,
        primaryContainer: navy.withOpacity(0.3),
        onPrimaryContainer: darkLightBlue,
        secondary: darkPurple,
        onSecondary: black,
        secondaryContainer: purple.withOpacity(0.2),
        onSecondaryContainer: darkPurple,
        tertiary: darkGreen,
        onTertiary: black,
        tertiaryContainer: green.withOpacity(0.2),
        onTertiaryContainer: darkGreen,
        surface: highContrast ? black : surfaceDark,
        onSurface: white,
        surfaceContainerHighest: white.withOpacity(0.1),
        error: darkRed,
        onError: black,
        outline: white.withOpacity(0.2),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: highContrast ? black : surfaceDark,
        foregroundColor: white,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: highContrast
              ? const BorderSide(color: white, width: 2)
              : BorderSide(color: white.withOpacity(0.1)),
        ),
        color: surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          foregroundColor: black,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkLightBlue,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(
            color: darkLightBlue,
            width: highContrast ? 2 : 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPurple,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkGreen,
        foregroundColor: black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: white.withOpacity(0.2),
            width: highContrast ? 2 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: white.withOpacity(0.2),
            width: highContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: darkLightBlue,
            width: highContrast ? 3 : 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: darkRed,
            width: highContrast ? 2 : 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(
            color: darkRed,
            width: highContrast ? 3 : 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.inter(color: white.withOpacity(0.7)),
        hintStyle: GoogleFonts.inter(color: white.withOpacity(0.5)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: white.withOpacity(0.1),
        selectedColor: darkPurple.withOpacity(0.3),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: darkLightBlue,
        unselectedLabelColor: white.withOpacity(0.6),
        indicatorColor: darkLightBlue,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: darkLightBlue,
        unselectedItemColor: white.withOpacity(0.6),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: highContrast ? white : white.withOpacity(0.1),
        thickness: highContrast ? 2 : 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: highContrast ? white : white.withOpacity(0.8),
        size: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark,
        contentTextStyle: GoogleFonts.inter(
          color: white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadiusLarge),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkPurple,
        linearTrackColor: white.withOpacity(0.2),
        circularTrackColor: white.withOpacity(0.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkGreen;
          return white.withOpacity(0.6);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkGreen.withOpacity(0.3);
          }
          return white.withOpacity(0.2);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkGreen;
          return white.withOpacity(0.6);
        }),
      ),
    );
  }

  // ============================================
  // Typography - Inter for body, Roboto Mono for code
  // ============================================

  static TextTheme _buildTextTheme({
    required Brightness brightness,
    required bool highContrast,
    required double fontSizeMultiplier,
  }) {
    final baseColor = brightness == Brightness.light
        ? (highContrast ? black : const Color(0xFF111827))
        : (highContrast ? white : const Color(0xFFF9FAFB));

    final secondaryColor = brightness == Brightness.light
        ? (highContrast ? black : grey)
        : (highContrast ? white : const Color(0xFF9CA3AF));

    return TextTheme(
      // Display styles - for hero sections
      displayLarge: GoogleFonts.inter(
        fontSize: 57 * fontSizeMultiplier,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45 * fontSizeMultiplier,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),

      // Headlines - Semi-Bold or Bold
      headlineLarge: GoogleFonts.inter(
        fontSize: 32 * fontSizeMultiplier,
        fontWeight: FontWeight.w700,
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

      // Titles - Medium or Semi-Bold
      titleLarge: GoogleFonts.inter(
        fontSize: 22 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.1,
      ),

      // Body text - Regular, 16-18px base
      bodyLarge: GoogleFonts.inter(
        fontSize: 18 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.15,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.4,
        height: 1.5,
      ),

      // Labels - for buttons, chips, etc.
      labelLarge: GoogleFonts.inter(
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  // ============================================
  // Roboto Mono for tech/code elements
  // ============================================

  static TextStyle get codeStyle => GoogleFonts.robotoMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: navy,
      );

  static TextStyle codeStyleDark() => GoogleFonts.robotoMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: lightBlue,
      );

  // ============================================
  // Brand-specific helper methods
  // ============================================

  /// Get the appropriate color for health scores
  static Color getHealthScoreColor(int score) {
    if (score >= 80) return green;
    if (score >= 60) return const Color(0xFF84CC16); // lime
    if (score >= 40) return warningColor;
    if (score >= 20) return const Color(0xFFF97316); // orange
    return red;
  }

  /// Get the appropriate color for risk levels
  static Color getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return red;
      case 'medium':
      case 'moderate':
        return warningColor;
      case 'low':
        return green;
      default:
        return grey;
    }
  }

  /// Standard card decoration with soft shadow
  static BoxDecoration cardDecoration({
    Color? color,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? surfaceLight,
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      boxShadow: hasShadow ? softShadow : null,
    );
  }

  /// Gradient for headers and hero sections
  static LinearGradient get brandGradient => const LinearGradient(
        colors: [navy, purple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Light gradient for backgrounds
  static LinearGradient get lightGradient => LinearGradient(
        colors: [
          lightBlue.withOpacity(0.1),
          purple.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
