import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ─── Text Themes ───────────────────────────────────────────────
  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Plus Jakarta Sans for headlines (editorial voice)
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57, fontWeight: FontWeight.w700, color: AppColors.onSurface,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45, fontWeight: FontWeight.w700, color: AppColors.onSurface,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface,
        letterSpacing: 0.1,
      ),
      // Manrope for body (technical voice)
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant, letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant, letterSpacing: 0.5,
      ),
    );
  }

  // ─── Dark Theme (Primary) ──────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        inverseSurface: Color(0xFFD6E7D2),
        onInverseSurface: Color(0xFF253425),
        inversePrimary: Color(0xFF2A6B2C),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        surfaceTint: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      // ── AppBar ──────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceContainerLow,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      // ── Bottom Navigation Bar ────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedItemColor: AppColors.harvestGold,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      // ── Navigation Bar ───────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        indicatorColor: AppColors.harvestGold.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.harvestGold);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.manrope(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.harvestGold,
            );
          }
          return GoogleFonts.manrope(
            fontSize: 12, fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          );
        }),
      ),
      // ── Cards ────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      // ── Elevated Button ──────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tertiary,
          foregroundColor: AppColors.onTertiary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.manrope(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      // ── Floating Action Button ───────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.tertiary,
        foregroundColor: AppColors.onTertiary,
        elevation: 0,
        extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        shape: StadiumBorder(),
      ),
      // ── Input Decoration ─────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
        labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      // ── Chip ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHighest,
        selectedColor: AppColors.primaryContainer,
        labelStyle: GoogleFonts.manrope(
          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      // ── Divider ──────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 0,
        space: 0,
      ),
      // ── Icon ────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.onSurface, size: 24),
    );
  }

  // ─── Light Theme (Fallback) ────────────────────────────────────
  static ThemeData get lightTheme => darkTheme;

  // ── Gradient Helpers ──────────────────────────────────────────
  static LinearGradient get headerGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF00695C)],
  );

  static LinearGradient get goldGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEBC33E), Color(0xFFCDA722)],
  );

  static LinearGradient get cardGradientGreen => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
  );

  static LinearGradient get cardGradientBlue => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
  );

  static LinearGradient get cardGradientAmber => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE65100), Color(0xFFF57F17)],
  );

  static LinearGradient get cardGradientPurple => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
  );

  static LinearGradient get cardGradientTeal => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF006064), Color(0xFF00838F)],
  );

  static LinearGradient get cardGradientRed => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
  );

  static LinearGradient heroGlassGradient(Color start, Color end) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: const Alignment(1.0, 1.0),
        colors: [start, end],
        transform: const GradientRotation(135 * 3.14159 / 180),
      );
}
