import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/api_constants.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  int _currentKeyIndex = 0;
  final List<String> _apiKeys = [];
  
  // Model fallback chain — try each until one works
  // Using official names with models/ prefix for maximum compatibility
  static const _modelFallbacks = [
    'gemini-flash-latest',
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-3-flash-preview',
    'gemini-3.1-flash-lite-preview',
  ];
  int _currentModelIndex = 0;
  
  void initialize() {
    _apiKeys.clear();
    for (int i = 1; i <= 5; i++) {
      final key = dotenv.env['GEMINI_KEY_$i'];
      if (key != null && key.isNotEmpty && !key.contains('YOUR_') && key.length > 20) {
        _apiKeys.add(key.trim());
      }
    }
    debugPrint('GeminiService: Initialized with ${_apiKeys.length} valid keys');
    if (_apiKeys.isEmpty) {
      debugPrint('WARNING: No valid Gemini API keys found in .env!');
    }
  }

  String get _currentModel => _modelFallbacks[_currentModelIndex % _modelFallbacks.length];

  GenerativeModel getModel({String? modelName, String? systemPrompt}) {
    if (_apiKeys.isEmpty) initialize();
    
    final apiKey = _apiKeys.isNotEmpty ? _apiKeys[_currentKeyIndex % _apiKeys.length] : '';
    final model = modelName ?? _currentModel;
    
    // Ensure model name has 'models/' prefix if it doesn't already
    final formattedModel = model.startsWith('models/') ? model : 'models/$model';
    
    return GenerativeModel(
      model: formattedModel,
      apiKey: apiKey,
      systemInstruction: systemPrompt != null ? Content.system(systemPrompt) : null,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      ],
    );
  }

  void rotateKey() {
    if (_apiKeys.length > 1) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
      debugPrint('GeminiService: Rotated to Key Index $_currentKeyIndex');
    }
  }

  void _rotateModel() {
    _currentModelIndex = (_currentModelIndex + 1) % _modelFallbacks.length;
    debugPrint('GeminiService: Switched to model: $_currentModel');
  }

  Future<T> runWithRetry<T>(
    Future<T> Function(GenerativeModel model) task, {
    int retries = 12, // Increased retries to cover all keys
    String? systemPrompt,
  }) async {
    int attempts = 0;
    int modelTries = 0;
    
    while (attempts < retries) {
      try {
        // Quick connectivity check before making the call
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          throw const SocketException('No internet connection detected.');
        }

        final model = getModel(systemPrompt: systemPrompt);
        debugPrint('GeminiService: Running task with model: $_currentModel (Key Index: $_currentKeyIndex, Attempt: ${attempts + 1})');
        return await task(model);
      } catch (e) {
        attempts++;
        final errorStr = e.toString();
        debugPrint('GeminiService: Attempt $attempts failed. Error: $errorStr');
        
        // Handle specific error types
        if (errorStr.contains('SocketException') || errorStr.contains('network') || errorStr.contains('reset by peer')) {
          debugPrint('GeminiService: Network/Socket error. Retrying with delay...');
          if (attempts >= 5) {
             throw Exception('OFFLINE: Please check your internet connection.');
          }
          await Future.delayed(const Duration(seconds: 2));
        } else if (errorStr.contains('blocked') || errorStr.contains('403') || errorStr.contains('PermissionDenied')) {
          debugPrint('GeminiService: API Key Blocked or Permission Denied. Rotating Key...');
          rotateKey();
          await Future.delayed(const Duration(milliseconds: 500));
        } else if (errorStr.contains('limit: 0') || errorStr.contains('not found') || errorStr.contains('not supported') || errorStr.contains('not available')) {
          _rotateModel();
          modelTries++;
          if (modelTries >= _modelFallbacks.length) {
            rotateKey();
            modelTries = 0;
          }
          await Future.delayed(const Duration(milliseconds: 500));
        } else if (errorStr.contains('429') || errorStr.contains('quota') || errorStr.contains('RESOURCE_EXHAUSTED')) {
          rotateKey();
          final waitSeconds = (attempts % 3) + 1;
          debugPrint('GeminiService: Rate limited or Quota exceeded. Waiting ${waitSeconds}s...');
          await Future.delayed(Duration(seconds: waitSeconds));
        } else if (errorStr.contains('API key not valid') || errorStr.contains('401')) {
          debugPrint('GeminiService: API Key invalid. Rotating...');
          rotateKey();
        } else {
          // General fallback
          _rotateModel();
          if (attempts >= retries) rethrow;
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    throw Exception('AI_ERROR: Failed after $retries attempts. This might be due to heavy server load.');
  }
}
