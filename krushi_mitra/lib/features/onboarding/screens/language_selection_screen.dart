import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_setup_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'hi', 'name': 'हिन्दी', 'nativeName': 'Hindi'},
    {'code': 'mr', 'name': 'मराठी', 'nativeName': 'Marathi'},
    {'code': 'gu', 'name': 'ગુજરાતી', 'nativeName': 'Gujarati'},
    {'code': 'pa', 'name': 'ਪੰਜਾਬੀ', 'nativeName': 'Punjabi'},
    {'code': 'ta', 'name': 'தமிழ்', 'nativeName': 'Tamil'},
    {'code': 'te', 'name': 'తెలుగు', 'nativeName': 'Telugu'},
    {'code': 'kn', 'name': 'ಕನ್ನಡ', 'nativeName': 'Kannada'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCloud,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.celestialGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 80,
                    color: AppColors.primaryEmerald,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Krushi Mitra',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                      fontSize: 28,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'CHOOSE YOUR LANGUAGE\nअपनी भाषा चुनें',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  letterSpacing: 1.5,
                  fontSize: 12,
                  color: AppColors.primaryEmerald,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLanguage == lang['code'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = lang['code']!;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryEmerald.withValues(alpha: 0.1)
                              : AppColors.surfaceWhite,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryEmerald
                                : AppColors.outlineVariant.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang['name']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primaryEmerald
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (lang['nativeName'] != lang['name'])
                              Text(
                                lang['nativeName']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.primaryEmerald.withValues(alpha: 0.7)
                                      : AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileSetupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppTheme.celestialGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Text(
                          'Continue / आगे बढ़ें',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
