import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../home/screens/main_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLogin = true;
  bool _isPhoneLogin = false;
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  String _verificationId = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      if (_isPhoneLogin) {
        if (!_isOtpSent) {
          await _sendOtp();
        } else {
          await _verifyOtp();
        }
      } else {
        if (_isLogin) {
          await auth.signInWithEmail(_emailController.text.trim(), _passwordController.text);
        } else {
          await auth.signUpWithEmail(_emailController.text.trim(), _passwordController.text);
        }
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e.toString()), style: GoogleFonts.manrope()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    // Ensure phone number has country code
    final fullNumber = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
    
    await ref.read(authServiceProvider).verifyPhoneNumber(
      phoneNumber: fullNumber,
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
      },
      onVerificationFailed: (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Failed: ${e.message}'), backgroundColor: AppColors.error),
        );
      },
    );
  }

  Future<void> _verifyOtp() async {
    await ref.read(authServiceProvider).signInWithPhoneNumber(
      _verificationId,
      _otpController.text.trim(),
    );
    _navigateToHome();
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final credential = await ref.read(authServiceProvider).signInWithGoogle();
      if (credential != null) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  String _friendlyError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email.';
    if (error.contains('wrong-password')) return 'Incorrect password. Try again.';
    if (error.contains('email-already-in-use')) return 'Email already registered.';
    if (error.contains('invalid-phone-number')) return 'The provided phone number is not valid.';
    if (error.contains('invalid-verification-code')) return 'Invalid OTP. Please check and try again.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primaryEmerald.withValues(alpha: 0.15), Colors.transparent],
                ),
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
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.celestialGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(child: Text('🌾', style: TextStyle(fontSize: 40))),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isLogin ? 'WELCOME BACK' : 'JOIN US',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primaryEmerald,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isPhoneLogin 
                        ? (_isOtpSent ? 'Verify OTP' : 'Phone Login')
                        : (_isLogin ? 'Login' : 'Create Account'),
                      style: GoogleFonts.outfit(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_isPhoneLogin) ...[
                      if (!_isOtpSent) _buildPhoneField() else _buildOtpField(),
                    ] else ...[
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                    ],
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _isLoading ? null : _handleAuth,
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: _isLoading ? null : AppTheme.celestialGradient,
                          color: _isLoading ? AppColors.textSecondary : null,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : Text(
                                  _isPhoneLogin 
                                    ? (_isOtpSent ? 'Verify & Login' : 'Send OTP')
                                    : (_isLogin ? 'Login' : 'Sign Up'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin ? 'New here? Sign Up' : 'Already have an account? Login'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildGoogleButton(),
                    const SizedBox(height: 16),
                    
                    if (!_isPhoneLogin)
                      _buildAlternativeAuthButton(
                        Icons.phone_android_rounded, 
                        'Continue with Phone Number', 
                        () => setState(() {
                          _isPhoneLogin = true;
                          _isOtpSent = false;
                        })
                      )
                    else
                      _buildAlternativeAuthButton(
                        Icons.email_outlined, 
                        'Continue with Email', 
                        () => setState(() {
                          _isPhoneLogin = false;
                          _isOtpSent = false;
                        })
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

  Widget _buildGoogleButton() {
    return _buildAlternativeAuthButton(
      Icons.g_mobiledata_rounded, 
      'Continue with Google', 
      _handleGoogleLogin,
      iconColor: Colors.red,
    );
  }

  Widget _buildAlternativeAuthButton(IconData icon, String label, VoidCallback onTap, {Color? iconColor}) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor ?? AppColors.primaryEmerald, size: 28),
              const SizedBox(width: 12),
              Text(
                label, 
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter 10 digit number',
        prefixIcon: Icon(Icons.phone_android_rounded),
        prefixText: '+91 ',
      ),
      validator: (v) => (v == null || v.isEmpty || v.length < 10) ? 'Enter valid number' : null,
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Enter OTP',
        prefixIcon: Icon(Icons.message_rounded),
      ),
      validator: (v) => (v == null || v.isEmpty || v.length < 6) ? 'Enter 6-digit OTP' : null,
    );
  }
}
