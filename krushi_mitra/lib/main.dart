import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:krushi_mitra/core/services/ai_service.dart';
import 'package:krushi_mitra/core/services/market_service.dart';
import 'package:krushi_mitra/core/services/weather_service.dart';
import 'package:krushi_mitra/core/services/notification_service.dart';
import 'app.dart';

void main() async {
  // Use runZonedGuarded to catch all global errors and report to Crashlytics
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Load environment variables
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Dotenv load warning: $e. Ensure .env exists in root.");
    }
    
    // 2. Initialize Firebase (Fail-safe)
    try {
      debugPrint("Initializing Firebase...");
      await Firebase.initializeApp();
      
      // Initialize Analytics
      FirebaseAnalytics.instance.logAppOpen();
      
      // Initialize Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      
      // Enable Firestore offline persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint("Firebase services initialized successfully");
    } catch (e) {
      debugPrint("FIREBASE INITIALIZATION FAILED: $e");
      debugPrint("Check your google-services.json and internet connection.");
    }

    // 3. Initialize Notifications
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint("Notification init error: $e");
    }

    // 4. Initialize SharedPreferences
    try {
      await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint("Prefs init error: $e");
    }

    // 5. Initialize Core Services (Fail-safe)
    try {
      final aiService = AIService();
      if (dotenv.env['GEMINI_API_KEY'] != null) {
        aiService.initialize();
      }
      
      MarketService().initialize();
      WeatherService().initialize();
      debugPrint("System services initialized");
    } catch (e) {
      debugPrint("Service init warning: $e");
    }

    runApp(
      const ProviderScope(
        child: KrushiMitraApp(),
      ),
    );
  }, (error, stack) {
    // Record all uncaught errors to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    debugPrint("CRITICAL GLOBAL ERROR: $error");
  });
}
