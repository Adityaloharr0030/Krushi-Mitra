import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary & Secondary Brand Colors ─────────────────────────────
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  static const Color secondaryAmber = Color(0xFFF9A825);
  static const Color secondaryLight = Color(0xFFFFD95A);
  static const Color secondaryDark = Color(0xFFC17900);

  // ── Background and Surfaces ──────────────────────────────────────
  static const Color backgroundEarthy = Color(0xFFF5F5F0);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGreenLight = Color(0xFFE8F5E9);

  // ── Text Colors ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF424242);
  static const Color textHint = Color(0xFF757575);

  // ── Semantic ─────────────────────────────────────────────────────
  static const Color error = Color(0xFFC62828);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF6C00);

  // ── Primary Aliases ──────────────────────────────────────────────
  static const Color primary = primaryGreen;
  static const Color accent = secondaryAmber;
  static const Color primaryContainer = surfaceGreenLight;
  static const Color surfaceVariant = Color(0xFFEEF2EE);

  // ── Material 3 Semantic: Surface Hierarchy ───────────────────────
  static const Color background = backgroundEarthy;
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;
  static const Color surfaceContainerLow = Color(0xFFF1F1EC);
  static const Color surfaceContainer = Color(0xFFEBEBE6);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E3);
  static const Color surfaceContainerHighest = Color(0xFFDEDED9);

  // ── Outline ──────────────────────────────────────────────────────
  static const Color outlineVariant = Color(0xFFC4C4BA);

  // ── Tertiary / Gold Accent ───────────────────────────────────────
  static const Color tertiary = Color(0xFFFFB300);
  static const Color onTertiary = Color(0xFF3E2700);
  static const Color tertiaryContainer = Color(0xFFFFE082);
  static const Color harvestGold = Color(0xFFFFB300);

  // ── Secondary (M3) ──────────────────────────────────────────────
  static const Color secondary = secondaryAmber;
  static const Color secondaryContainer = Color(0xFFFFE082);

  // ── On-Primary ──────────────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Error Container ─────────────────────────────────────────────
  static const Color errorContainer = Color(0xFFFCE4EC);
  // ── Compatibility Aliases ───────────────────────────────────────
  static const Color surface = surfaceWhite;
  static const Color divider = outlineVariant;
}
