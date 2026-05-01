import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krushi_mitra/app.dart';
import 'package:krushi_mitra/features/auth/screens/auth_screens.dart';
import 'package:krushi_mitra/features/auth/screens/login_screen.dart';

void main() {
  group('Krushi Mitra UI Tests', () {
    testWidgets('App Boots to Splash Screen and Transitions', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: KrushiMitraApp(),
        ),
      );

      // Verify that the SplashScreen is the initial route
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('KRUSHI MITRA'), findsOneWidget);
      
      // Wait for the splash screen timer to finish (usually 2-3 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // After splash, it should transition to Login or Dashboard depending on mock state
      // We just need to ensure no timers are pending.
    });

    testWidgets('Login Screen Renders Correctly', (WidgetTester tester) async {
      // Directly pump the LoginScreen wrapped in necessary providers
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify Login Screen UI elements are present
      expect(find.text('WELCOME BACK'), findsOneWidget);
      expect(find.text('Login'), findsWidgets);
      
      // Verify Google Login Button exists
      expect(find.text('Sign in with Google'), findsOneWidget);
      
      // Verify switch to Sign Up mode works
      await tester.tap(find.text('New here? Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('JOIN US'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
