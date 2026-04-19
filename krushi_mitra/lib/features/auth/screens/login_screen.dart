import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      if (_isLogin) {
        await auth.signInWithEmail(_emailController.text, _passwordController.text);
      } else {
        await auth.signUpWithEmail(_emailController.text, _passwordController.text);
      }
      _navigateToHome();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInAnonymously();
      _navigateToHome();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.headerGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(child: Text('🌿', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Login to continue your journey' : 'Join thousands of Indian farmers',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Form
                  _buildTextField(_emailController, 'Email Address', Icons.email_outlined, false),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Password', Icons.lock_outline, true),
                  
                  const SizedBox(height: 32),
                  
                  // Login Button
                  GestureDetector(
                    onTap: _isLoading ? null : _handleAuth,
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.harvestGold.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: AppColors.onTertiary)
                          : Text(
                              _isLogin ? 'Login' : 'Sign Up',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onTertiary,
                              ),
                            ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Toggle Login/SignUp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? "Don't have an account? " : "Already have an account? ",
                        style: GoogleFonts.manrope(fontSize: 14, color: AppColors.onSurfaceVariant),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Login',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.outlineVariant.withOpacity(0.5))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: GoogleFonts.manrope(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ),
                      Expanded(child: Divider(color: AppColors.outlineVariant.withOpacity(0.5))),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Guest Login
                  GestureDetector(
                    onTap: _isLoading ? null : _handleGuestLogin,
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          'Continue as Guest',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.manrope(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
