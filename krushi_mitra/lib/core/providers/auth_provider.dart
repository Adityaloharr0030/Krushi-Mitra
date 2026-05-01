import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'database_provider.dart';
import '../../data/models/farmer_model.dart';

// 1. Service Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 2. Auth State Provider (Reactive Stream)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// 3. Robust Profile Notifier
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<Farmer?>>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<Farmer?>> {
  final Ref _ref;
  StreamSubscription<User?>? _authSubscription;
  Timer? _safetyTimer;

  CurrentUserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // 1. Check current user immediately (Don't wait for stream)
    final initialUser = _ref.read(authServiceProvider).currentUser;
    if (initialUser != null) {
      debugPrint("Auth Init: Immediate user found: ${initialUser.uid}");
      fetchProfile(initialUser.uid);
    } else {
      debugPrint("Auth Init: No immediate user, waiting for stream...");
    }

    // 2. Listen to the stream for updates
    _authSubscription = _ref.read(authServiceProvider).authStateChanges.listen((user) {
      if (user != null) {
        debugPrint("Auth Stream: User detected: ${user.uid}");
        fetchProfile(user.uid);
      } else {
        debugPrint("Auth Stream: No user");
        state = const AsyncValue.data(null);
        _safetyTimer?.cancel();
      }
    }, onError: (e, st) {
      debugPrint("Auth Stream: Error: $e");
      state = AsyncValue.error(e, st);
    });

    // 3. Safety Timeout: If we are still loading after 7 seconds, something is wrong
    _safetyTimer = Timer(const Duration(seconds: 7), () {
      if (state.isLoading) {
        debugPrint("Auth Safety: Timeout reached, forcing guest/null state");
        // If we are still loading, check if a user appeared in the meantime
        final user = _ref.read(authServiceProvider).currentUser;
        if (user != null) {
          fetchProfile(user.uid);
        } else {
          state = const AsyncValue.data(null);
        }
      }
    });
  }

  Future<void> fetchProfile(String uid) async {
    // Only set loading if we don't have data already (prevent flicker)
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      final profile = await _ref.read(databaseServiceProvider).getFarmerProfile(uid);
      debugPrint("Profile Fetch: Success for ${profile?.name ?? 'New User'}");
      state = AsyncValue.data(profile);
      _safetyTimer?.cancel();
    } catch (e, st) {
      debugPrint("Profile Fetch: Error: $e");
      state = AsyncValue.error(e, st);
      _safetyTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _safetyTimer?.cancel();
    super.dispose();
  }
}

// 4. Profile Action Notifier (For Saving)
final profileActionProvider = StateNotifierProvider<ProfileActionNotifier, AsyncValue<void>>((ref) {
  return ProfileActionNotifier(ref);
});

class ProfileActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ProfileActionNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> saveProfile(Farmer farmer) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(databaseServiceProvider).saveFarmerProfile(farmer);
      // Re-trigger fetch in the main provider
      await _ref.read(currentUserProvider.notifier).fetchProfile(farmer.id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
