import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import 'auth_screens.dart';
import 'login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'AI Crop Doctor',
      subtitle: 'Identify pests and diseases instantly with your camera. Get organic and chemical remedies in seconds.',
      icon: '🌿',
      color: AppColors.primary,
    ),
    OnboardingItem(
      title: 'Live Mandi Rates',
      subtitle: 'Stay ahead of the market. Track commodity prices across APMCs and see real-time price trends.',
      icon: '📈',
      color: AppColors.harvestGold,
    ),
    OnboardingItem(
      title: 'Smart Weather',
      subtitle: 'Precision weather alerts tailored for your farm. Receive AI-driven farming advisories based on local climate.',
      icon: '🌤️',
      color: AppColors.deepTeal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _items[_currentPage].color.withOpacity(0.15),
                  AppColors.background,
                  AppColors.background,
                ],
              ),
            ),
          ),

          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_items[index]);
            },
          ),

          // Bottom Controls
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _items.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: _items[_currentPage].color,
                    dotColor: AppColors.surfaceContainerHighest,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                  ),
                ),
                const SizedBox(height: 48),
                _buildMainButton(),
                const SizedBox(height: 16),
                if (_currentPage < _items.length - 1)
                  TextButton(
                    onPressed: () => _finishOnboarding(),
                    child: Text(
                      'Skip Tour',
                      style: GoogleFonts.manrope(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.2),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.icon,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    final isLast = _currentPage == _items.length - 1;
    return GestureDetector(
      onTap: () {
        if (isLast) {
          _finishOnboarding();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        }
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: _items[_currentPage].color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _items[_currentPage].color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isLast ? 'Get Started' : 'Continue',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _finishOnboarding() {
     ref.read(onboardingProvider.notifier).completeOnboarding();
     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (_) => const LoginScreen()),
     );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
