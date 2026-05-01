import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDarkMode = true;

  // --- Dynamic Color Getters ---
  static Color get background => isDarkMode ? const Color(0xFF020617) : const Color(0xFFF1F5F9);
  static Color get surface => isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  static Color get surfaceVariant => isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  
  static Color get textPrimary => isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondary => isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textDisabled => isDarkMode ? const Color(0xFF475569) : const Color(0xFF94A3B8);
  
  static Color get outline => isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
  static Color get glassBorder => isDarkMode ? const Color(0x33FFFFFF) : const Color(0x1A0F172A);

  // --- Shared Vibrant Accents (Stitch) ---
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color accentAmber = Color(0xFFF59E0B);

  // --- Semantic Colors ---
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // --- Material 3 Mappings ---
  static const Color primary = primaryEmerald;
  static const Color secondary = neonCyan;
  static const Color onPrimary = Colors.white;
  
  static Color get onSurface => textPrimary;
  static Color get onSurfaceVariant => textSecondary;
  
  // Legacy Aliases for compatibility
  static Color get backgroundMidnight => background;
  static Color get surfaceObsidian => surface;
  static Color get backgroundCloud => background;
  static Color get surfaceWhite => surface;
  static Color get textHighEmphasis => textPrimary;
  static Color get textMediumEmphasis => textSecondary;
  static Color get outlineVariant => outline;
  static Color get textHint => textDisabled;

  static Color get surfaceContainerLow => isDarkMode ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
  static Color get surfaceContainer => isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9);
  static Color get surfaceContainerHigh => isDarkMode ? const Color(0xFF374151) : const Color(0xFFE2E8F0);
  static Color get surfaceContainerHighest => isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1);
  
  static const Color primaryContainer = Color(0xFF064E3B);
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color secondarySlate = Color(0xFF1E293B);
  
  static const Color primaryLight = primaryEmerald;
  static const Color primaryDark = Color(0xFF059669);
}
