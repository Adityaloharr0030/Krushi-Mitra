import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint("FATAL: FirebaseAuth.instance accessed before initialization: $e");
      rethrow;
    }
  }
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint("Starting Google Sign-In...");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("Google Sign-In: User cancelled the flow.");
        return null; // User cancelled
      }

      debugPrint("Google Sign-In: Getting authentication details...");
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint("Google Sign-In: Creating Firebase credential...");
      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("Google Sign-In: Signing into Firebase...");
      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint("Google Sign-In: Success for ${userCredential.user?.email}");
      return userCredential;
    } catch (e) {
      debugPrint("FATAL Google Auth Error: $e");
      if (e.toString().contains('7:')) {
        debugPrint("HINT: Error 7 usually means a network issue or missing SHA-1 in Firebase Console.");
      } else if (e.toString().contains('10:')) {
        debugPrint("HINT: Error 10 usually means a developer error (check SHA-1 or package name).");
      } else if (e.toString().contains('12500')) {
        debugPrint("HINT: Error 12500 usually means an internal error (check SHA-1 or google-services.json).");
      }
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Auth Error: $e");
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Auth Error: $e");
      rethrow;
    }
  }

  // Phone Authentication: Step 1 - Send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (rarely happens on all devices)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: onVerificationFailed,
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint("Phone Auth Error: $e");
      rethrow;
    }
  }

  // Phone Authentication: Step 2 - Sign in with OTP
  Future<UserCredential> signInWithPhoneNumber(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Phone Sign-in Error: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Guest Sign In (Anonymous Auth)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Auth Error: $e");
      rethrow;
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Auth Error: $e");
      rethrow;
    }
  }
}
