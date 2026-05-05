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
  
  void initialize() {
    _apiKeys.clear();
    for (int i = 1; i <= 5; i++) {
      final key = dotenv.env['GEMINI_KEY_$i'];
      if (key != null && key.isNotEmpty && !key.contains('YOUR_')) {
        _apiKeys.add(key.trim());
      }
    }
    debugPrint('GeminiService: Initialized with ${_apiKeys.length} keys');
  }

  GenerativeModel getModel({String? modelName, String? systemPrompt}) {
    if (_apiKeys.isEmpty) initialize();
    
    final apiKey = _apiKeys.isNotEmpty ? _apiKeys[_currentKeyIndex] : '';
    
    return GenerativeModel(
      model: modelName ?? ApiConstants.geminiModel,
      apiKey: apiKey,
      systemInstruction: systemPrompt != null ? Content.system(systemPrompt) : null,
    );
  }

  void rotateKey() {
    if (_apiKeys.length > 1) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
      debugPrint('GeminiService: Rotated to key index $_currentKeyIndex');
    }
  }

  Future<T> runWithRetry<T>(Future<T> Function(GenerativeModel model) task, {int retries = 3}) async {
    int attempts = 0;
    while (attempts < retries) {
      try {
        final model = getModel();
        return await task(model);
      } catch (e) {
        attempts++;
        debugPrint('GeminiService: Error on attempt $attempts: $e');
        if (e.toString().contains('429') || e.toString().contains('quota') || e.toString().contains('limit')) {
          rotateKey();
        } else if (attempts >= retries) {
          rethrow;
        }
      }
    }
    throw Exception('GeminiService: Failed after $retries retries');
  }
}
