import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/ai_service.dart';
import 'core/services/weather_service.dart';
import 'core/services/market_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file: $e");
  }

  // Initialize Firebase — fully awaited with error handling.
  // If google-services.json is missing, app still launches in offline/mock mode.
  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    firebaseAvailable = true;
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase not configured — running in offline/mock mode: $e");
  }

  // Initialize SharedPreferences — wrapped so a plugin issue won't crash the app
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint("SharedPreferences init failed (non-fatal): $e");
  }

  // Initialize core services — each wrapped individually
  try {
    AIService().initialize();
  } catch (e) {
    debugPrint("AIService init failed: $e");
  }

  try {
    WeatherService().initialize();
  } catch (e) {
    debugPrint("WeatherService init failed: $e");
  }

  try {
    MarketService().initialize();
  } catch (e) {
    debugPrint("MarketService init failed: $e");
  }

  // Only initialize NotificationService (Firebase Messaging) if Firebase is available
  if (firebaseAvailable) {
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint("NotificationService init failed: $e");
    }
  } else {
    debugPrint("Skipping NotificationService — Firebase not available");
  }

  // Run App within ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: KrushiMitraApp(),
    ),
  );
}
