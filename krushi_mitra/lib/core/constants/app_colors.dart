import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  
  static const Color secondaryAmber = Color(0xFFF9A825);
  static const Color secondaryLight = Color(0xFFFFD95A);
  static const Color secondaryDark = Color(0xFFC17900);

  // Background and Surfaces
  static const Color backgroundEarthy = Color(0xFFF5F5F0);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGreenLight = Color(0xFFE8F5E9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF424242);
  static const Color textHint = Color(0xFF757575);

  // Semantic
  static const Color error = Color(0xFFC62828);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF6C00);

  // Aliases for compatibility
  static const Color primary = primaryGreen;
  static const Color accent = secondaryAmber;
  static const Color primaryContainer = surfaceGreenLight;
  static const Color surfaceVariant = Color(0xFFEEF2EE);
}
