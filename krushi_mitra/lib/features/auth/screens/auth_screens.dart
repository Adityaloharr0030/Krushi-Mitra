import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../home/screens/main_screen.dart';
import '../../onboarding/screens/profile_setup_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _controller.forward();
    _checkAuth();
  }

  void _checkAuth() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.celestialGradient),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(top: -100, right: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)))),
            Positioned(bottom: -80, left: -80, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.03)))),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        boxShadow: [BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: Hero(
                        tag: 'app_logo',
                        child: Image.asset('assets/icons/app_icon.png', height: 80, width: 80,
                            errorBuilder: (_, __, ___) => const Icon(Icons.agriculture_rounded, size: 80, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Text('KRUSHI MITRA', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 6.0)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                          child: Text('CELESTIAL HARVEST', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.9), letterSpacing: 2.0)),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 28, height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(currentUserProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const LoginScreen();
        return profileState.when(
          data: (profile) {
            if (profile == null) return const ProfileSetupScreen();
            return const MainScreen();
          },
          loading: () => const SplashScreen(),
          error: (e, st) => const ProfileSetupScreen(),
        );
      },
      loading: () => const SplashScreen(),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Auth Error: $e')),
      ),
    );
  }
}
