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

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLogin = true;
  bool _isPhoneLogin = false;
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  String _verificationId = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _switchMode() {
    _slideController.reset();
    _slideController.forward();
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
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
          final cred = await auth.signUpWithEmail(_emailController.text.trim(), _passwordController.text);
          if (cred?.user != null && _nameController.text.trim().isNotEmpty) {
            await cred!.user!.updateDisplayName(_nameController.text.trim());
          }
        }
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(_friendlyError(e.toString()), style: GoogleFonts.plusJakartaSans(fontSize: 13))),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    final fullNumber = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
    await ref.read(authServiceProvider).verifyPhoneNumber(
      phoneNumber: fullNumber,
      onCodeSent: (verificationId) {
        setState(() { _verificationId = verificationId; _isOtpSent = true; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to $fullNumber'), backgroundColor: AppColors.primaryEmerald, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      },
      onVerificationFailed: (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${e.message}'), backgroundColor: AppColors.error));
      },
    );
  }

  Future<void> _verifyOtp() async {
    await ref.read(authServiceProvider).signInWithPhoneNumber(_verificationId, _otpController.text.trim());
    _navigateToHome();
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final credential = await ref.read(authServiceProvider).signInWithGoogle();
      if (credential != null) _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e.toString())), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter your email first', style: GoogleFonts.plusJakartaSans()), backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      return;
    }
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset link sent to $email'), backgroundColor: AppColors.primaryEmerald, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e.toString())), backgroundColor: AppColors.error));
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  String _friendlyError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email.';
    if (error.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (error.contains('email-already-in-use')) return 'This email is already registered. Try logging in.';
    if (error.contains('invalid-phone-number')) return 'Please enter a valid phone number.';
    if (error.contains('invalid-verification-code')) return 'Invalid OTP. Please check and try again.';
    if (error.contains('weak-password')) return 'Password is too weak. Use at least 6 characters.';
    if (error.contains('invalid-email')) return 'Please enter a valid email address.';
    if (error.contains('too-many-requests')) return 'Too many attempts. Please wait and try again.';
    if (error.contains('network-request-failed')) return 'Network error. Check your internet connection.';
    return 'Something went wrong. Please try again.';
  }

  int get _passwordStrength {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 6) score++;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) score++;
    return score;
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s <= 1) return AppColors.error;
    if (s <= 2) return AppColors.warning;
    if (s <= 3) return AppColors.accentAmber;
    return AppColors.success;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s == 0) return '';
    if (s <= 1) return 'Weak';
    if (s <= 2) return 'Fair';
    if (s <= 3) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background decorations
          Positioned(top: -120, left: -80, child: _glowCircle(350, AppColors.primaryEmerald.withValues(alpha: 0.08))),
          Positioned(bottom: -100, right: -100, child: _glowCircle(300, AppColors.neonCyan.withValues(alpha: 0.06))),
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          _buildLogo(),
                          const SizedBox(height: 32),
                          // Title
                          _buildTitle(),
                          const SizedBox(height: 8),
                          Text(
                            _isPhoneLogin
                                ? (_isOtpSent ? 'Enter the 6-digit code sent to your phone' : 'We\'ll send you a verification code')
                                : (_isLogin ? 'Welcome back to your farming companion' : 'Start your smart farming journey'),
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),
                          // Form fields
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildFormFields(),
                          ),
                          const SizedBox(height: 24),
                          // Primary button
                          _buildPrimaryButton(),
                          // Forgot password
                          if (!_isPhoneLogin && _isLogin) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _forgotPassword,
                              child: Text('Forgot Password?',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryEmerald)),
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Toggle login/signup
                          if (!_isPhoneLogin)
                            TextButton(
                              onPressed: _switchMode,
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary),
                                  children: [
                                    TextSpan(text: _isLogin ? 'New here? ' : 'Already have an account? '),
                                    TextSpan(
                                      text: _isLogin ? 'Create Account' : 'Login',
                                      style: TextStyle(color: AppColors.primaryEmerald, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          // Divider
                          _buildDivider(),
                          const SizedBox(height: 20),
                          // Social buttons
                          _buildGoogleButton(),
                          const SizedBox(height: 12),
                          _buildPhoneToggleButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: 88, height: 88,
        decoration: BoxDecoration(
          gradient: AppTheme.celestialGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset('assets/icons/app_icon.png', width: 72, height: 72, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.agriculture_rounded, size: 48, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          _isLogin ? 'WELCOME BACK' : 'JOIN KRUSHI MITRA',
          style: GoogleFonts.plusJakartaSans(color: AppColors.primaryEmerald, letterSpacing: 2.5, fontWeight: FontWeight.w800, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Text(
          _isPhoneLogin ? (_isOtpSent ? 'Verify OTP' : 'Phone Login') : (_isLogin ? 'Sign In' : 'Create Account'),
          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    if (_isPhoneLogin) {
      return Column(
        key: const ValueKey('phone'),
        children: [!_isOtpSent ? _buildPhoneField() : _buildOtpField()],
      );
    }
    return Column(
      key: ValueKey(_isLogin ? 'login' : 'signup'),
      children: [
        if (!_isLogin) ...[
          _buildField(_nameController, 'Full Name', Icons.person_outline_rounded,
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null),
          const SizedBox(height: 14),
        ],
        _buildField(_emailController, 'Email Address', Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Enter a valid email';
              return null;
            }),
        const SizedBox(height: 14),
        _buildPasswordField(),
        if (!_isLogin && _passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPasswordStrengthBar(),
        ],
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
      validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      onChanged: (_) { if (!_isLogin) setState(() {}); },
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Enter your password';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildPasswordStrengthBar() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passwordStrength / 5,
              backgroundColor: AppColors.surfaceVariant,
              color: _strengthColor,
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(_strengthLabel, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: _strengthColor)),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(labelText: 'Phone Number', hintText: '10 digit number', prefixIcon: Icon(Icons.phone_android_rounded, size: 20), prefixText: '+91 '),
      validator: (v) => (v == null || v.isEmpty || v.length < 10) ? 'Enter valid 10-digit number' : null,
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 8),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Enter OTP',
        prefixIcon: const Icon(Icons.sms_rounded, size: 20),
        counterText: '',
        hintText: '• • • • • •',
        hintStyle: GoogleFonts.outfit(fontSize: 24, color: AppColors.textSecondary.withValues(alpha: 0.3)),
      ),
      validator: (v) => (v == null || v.isEmpty || v.length < 6) ? 'Enter 6-digit OTP' : null,
    );
  }

  Widget _buildPrimaryButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleAuth,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppTheme.celestialGradient,
          color: _isLoading ? AppColors.textSecondary : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isLoading ? [] : [BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(
                  _isPhoneLogin ? (_isOtpSent ? 'Verify & Login' : 'Send OTP') : (_isLogin ? 'Sign In' : 'Create Account'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.outline.withValues(alpha: 0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ),
        Expanded(child: Divider(color: AppColors.outline.withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return _socialButton(
      onTap: _handleGoogleLogin,
      icon: Container(
        width: 22, height: 22,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Center(child: Text('G', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.red.shade600))),
      ),
      label: 'Continue with Google',
    );
  }

  Widget _buildPhoneToggleButton() {
    if (!_isPhoneLogin) {
      return _socialButton(
        onTap: () => setState(() { _isPhoneLogin = true; _isOtpSent = false; _slideController.reset(); _slideController.forward(); }),
        icon: Icon(Icons.phone_android_rounded, color: AppColors.primaryEmerald, size: 22),
        label: 'Continue with Phone',
      );
    }
    return _socialButton(
      onTap: () => setState(() { _isPhoneLogin = false; _isOtpSent = false; _slideController.reset(); _slideController.forward(); }),
      icon: Icon(Icons.email_outlined, color: AppColors.primaryEmerald, size: 22),
      label: 'Continue with Email',
    );
  }

  Widget _socialButton({required VoidCallback onTap, required Widget icon, required String label}) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
