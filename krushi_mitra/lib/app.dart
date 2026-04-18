import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/language_selection_screen.dart';

class KrushiMitraApp extends StatelessWidget {
  const KrushiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krushi Mitra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // For now, always route to Onboarding/Language Selection.
      // Real app will check SharedPreferences or Provider for auth state.
      home: const LanguageSelectionScreen(),
    );
  }
}
