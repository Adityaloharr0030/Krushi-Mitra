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
  static const _modelFallbacks = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-2.0-flash-lite',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
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
  }

  String get _currentModel => _modelFallbacks[_currentModelIndex % _modelFallbacks.length];

  GenerativeModel getModel({String? modelName, String? systemPrompt}) {
    if (_apiKeys.isEmpty) initialize();
    
    final apiKey = _apiKeys.isNotEmpty ? _apiKeys[_currentKeyIndex % _apiKeys.length] : '';
    final model = modelName ?? _currentModel;
    
    return GenerativeModel(
      model: model,
      apiKey: apiKey,
      systemInstruction: systemPrompt != null ? Content.system(systemPrompt) : null,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  void rotateKey() {
    if (_apiKeys.length > 1) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    }
  }

  void _rotateModel() {
    _currentModelIndex = (_currentModelIndex + 1) % _modelFallbacks.length;
    debugPrint('GeminiService: Switched to model: ${_currentModel}');
  }

  Future<T> runWithRetry<T>(
    Future<T> Function(GenerativeModel model) task, {
    int retries = 15,
    String? systemPrompt,
  }) async {
    int attempts = 0;
    int modelTries = 0;
    
    while (attempts < retries) {
      try {
        final model = getModel(systemPrompt: systemPrompt);
        debugPrint('GeminiService: Running task with model: $_currentModel (Key Index: $_currentKeyIndex)');
        return await task(model);
      } catch (e) {
        attempts++;
        final errorStr = e.toString();
        debugPrint('GeminiService: Attempt $attempts failed (model: $_currentModel, key: $_currentKeyIndex)');
        debugPrint('GeminiService Error Details: $errorStr');
        
        if (errorStr.contains('limit: 0') || errorStr.contains('not found') || errorStr.contains('not supported') || errorStr.contains('not available')) {
          _rotateModel();
          modelTries++;
          if (modelTries >= _modelFallbacks.length) {
            rotateKey();
            modelTries = 0;
          }
          await Future.delayed(const Duration(milliseconds: 500));
        } else if (errorStr.contains('429') || errorStr.contains('quota') || errorStr.contains('RESOURCE_EXHAUSTED')) {
          rotateKey();
          final waitSeconds = attempts * 3;
          debugPrint('GeminiService: Rate limited. Waiting ${waitSeconds}s...');
          await Future.delayed(Duration(seconds: waitSeconds));
        } else if (errorStr.contains('API key not valid')) {
          rotateKey();
        } else {
          _rotateModel();
          if (attempts >= retries) rethrow;
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    throw Exception('GeminiService: Failed after $retries retries');
  }
}
