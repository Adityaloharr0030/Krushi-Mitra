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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      if (_isLogin) {
        await auth.signInWithEmail(_emailController.text.trim(), _passwordController.text);
      } else {
        await auth.signUpWithEmail(_emailController.text.trim(), _passwordController.text);
      }
      _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e.toString()), style: GoogleFonts.manrope()),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInAnonymously();
      _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.manrope()),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter your email first', style: GoogleFonts.manrope()),
          backgroundColor: AppColors.surfaceContainerHigh,
        ),
      );
      return;
    }
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email', style: GoogleFonts.manrope()),
            backgroundColor: AppColors.primaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e.toString()), style: GoogleFonts.manrope()),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  String _friendlyError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email.';
    if (error.contains('wrong-password')) return 'Incorrect password. Try again.';
    if (error.contains('email-already-in-use')) return 'Email already registered. Try logging in.';
    if (error.contains('weak-password')) return 'Password too weak. Use at least 6 characters.';
    if (error.contains('invalid-email')) return 'Invalid email address.';
    if (error.contains('network-request-failed')) return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glow circles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withOpacity(0.06),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: AppTheme.headerGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(child: Text('🌿', style: TextStyle(fontSize: 40))),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _isLogin ? 'Welcome Back' : 'Join Krushi Mitra',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin
                          ? 'Login to manage your farm'
                          : 'Join thousands of Indian farmers',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email
                    _buildEmailField(),
                    const SizedBox(height: 16),

                    // Password
                    _buildPasswordField(),

                    // Forgot Password
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 16),

                    // Primary button
                    GestureDetector(
                      onTap: _isLoading ? null : _handleAuth,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: _isLoading ? null : AppTheme.goldGradient,
                          color: _isLoading ? AppColors.surfaceContainerHigh : null,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isLoading
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.harvestGold.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: AppColors.onTertiary)
                              : Text(
                                  _isLogin ? 'Login' : 'Create Account',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onTertiary,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin ? 'Sign Up' : 'Login',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.outlineVariant.withOpacity(0.4))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.outlineVariant.withOpacity(0.4))),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Guest login
                    GestureDetector(
                      onTap: _isLoading ? null : _handleGuestLogin,
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('👤', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Text(
                                'Continue as Guest',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.manrope(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: 'Email Address',
        prefixIcon: const Icon(Icons.email_outlined, size: 20),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      style: GoogleFonts.manrope(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: AppColors.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (!_isLogin && v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }
}
