
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Spacing constants for consistent UI
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Border radius constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 24.0;

  static ThemeData get theme {
    // Vibrant Material 3 ColorScheme for gamified app
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFF6F61), // Vibrant coral
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFD4CC),
      onPrimaryContainer: Color(0xFF330C00),
      secondary: Color(0xFF8BC34A), // Bright green
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFC8F0C2),
      onSecondaryContainer: Color(0xFF002200),
      tertiary: Color(0xFF9C27B0), // Purple for gamification accents
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF3DAFF),
      onTertiaryContainer: Color(0xFF2E004D),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFFFFBFE),
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: Color(0xFFE6E1E5),
      onSurfaceVariant: Color(0xFF49454F),
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFFFB4A9),
      surfaceTint: Color(0xFFFF6F61),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      // Normalized typography with Google Fonts Lato
      textTheme: GoogleFonts.latoTextTheme(Typography.material2021().black).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ).copyWith(
        // Custom overrides for gamified style
        headlineLarge: GoogleFonts.lato(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.lato(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineSmall: GoogleFonts.lato(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.lato(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleSmall: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelMedium: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelSmall: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spacingLarge, vertical: spacingMedium),
          elevation: 2,
        ),
      ),
      // Card theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        margin: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingSmall),
        color: colorScheme.surface,
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      ),
    );
  }
}
