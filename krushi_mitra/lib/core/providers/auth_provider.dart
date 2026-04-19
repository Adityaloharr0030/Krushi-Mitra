import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// Provides the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Stream of Firebase Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provides the current user info
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// Logic to check if it's the user's first time opening the app (Onboarding)
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(true) {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('is_first_time') ?? true;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
    state = false;
  }
}
