import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Icon(
                  Icons.agriculture,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Krushi Mitra',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primaryGreen,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your language / अपनी भाषा चुनें',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.surfaceWhite,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          lang['name']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.surfaceWhite
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to profile setup
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileSetupScreen(),
                      ),
                    );
                  },
                  child: const Text('Continue / आगे बढ़ें'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
