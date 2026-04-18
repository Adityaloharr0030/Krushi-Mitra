import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (wrapped in try-catch to allow UI testing without config)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase not configured: $e");
  }

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  // Run App within ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: KrushiMitraApp(),
    ),
  );
}
