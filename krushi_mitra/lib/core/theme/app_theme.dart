import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // --- Stitch Dark Gradients ---
  static LinearGradient get celestialGradient => const LinearGradient(
    colors: [AppColors.primaryEmerald, AppColors.neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get luxuryGradient => LinearGradient(
    colors: [AppColors.background, AppColors.surfaceVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Stitch Glassmorphism Decorations ---
  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration glassDecoration({double opacity = 0.1}) => BoxDecoration(
    color: AppColors.surface.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.glassBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // --- Stitch Dark Theme ---
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryEmerald,
        brightness: Brightness.dark,
        primary: AppColors.primaryEmerald,
        secondary: AppColors.neonCyan,
        surface: const Color(0xFF0F172A),
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: const Color(0xFF020617),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFF8FAFC), letterSpacing: -1.2),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFF8FAFC), letterSpacing: -0.8),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFFF8FAFC)),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFFF8FAFC)),
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFFF8FAFC)),
        bodyLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: const Color(0xFFF8FAFC), height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8), height: 1.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0F172A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }

  // --- Stitch Light Theme ---
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryEmerald,
        brightness: Brightness.light,
        primary: AppColors.primaryEmerald,
        secondary: AppColors.neonCyan,
        surface: Colors.white,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), letterSpacing: -1.2),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), letterSpacing: -0.8),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
        bodyLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: const Color(0xFF0F172A), height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400, color: const Color(0xFF475569), height: 1.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          shadowColor: AppColors.primaryEmerald.withValues(alpha: 0.3),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }
}
