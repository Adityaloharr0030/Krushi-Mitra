import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import '../constants/api_constants.dart';

class CropDiagnosis {
  final String cropName;
  final String diseaseName;
  final String symptoms;
  final String treatmentOrganic;
  final String treatmentChemical;
  final double confidencePercent;
  final String severity;
  final bool isHealthy;
  final String prevention;
  final String causes;

  CropDiagnosis({
    required this.cropName,
    required this.diseaseName,
    required this.symptoms,
    required this.treatmentOrganic,
    required this.treatmentChemical,
    required this.confidencePercent,
    required this.severity,
    required this.isHealthy,
    required this.prevention,
    required this.causes,
  });

  factory CropDiagnosis.fromJson(Map<String, dynamic> json) {
    return CropDiagnosis(
      cropName: json['crop_name'] ?? 'Unknown Crop',
      diseaseName: json['disease_name'] ?? 'Healthy',
      symptoms: json['symptoms'] ?? 'No symptoms detected.',
      treatmentOrganic: json['treatment_organic'] ?? 'None',
      treatmentChemical: json['treatment_chemical'] ?? 'None',
      confidencePercent: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity'] ?? 'Low',
      isHealthy: json['health_status']?.toString().toLowerCase() == 'healthy',
      prevention: json['prevention'] ?? 'Maintain regular care.',
      causes: json['causes'] ?? 'N/A',
    );
  }
}

class SoilRecommendation {
  final String assessment;
  final String fertilizers;
  final String organicAmendments;
  final String limeRecommendation;
  final String micronutrients;
  final String nextSteps;

  SoilRecommendation({
    required this.assessment,
    required this.fertilizers,
    required this.organicAmendments,
    required this.limeRecommendation,
    required this.micronutrients,
    required this.nextSteps,
  });

  factory SoilRecommendation.fromJson(Map<String, dynamic> json) {
    return SoilRecommendation(
      assessment: json['assessment'] ?? '',
      fertilizers: json['fertilizers'] ?? '',
      organicAmendments: json['organic_amendments'] ?? '',
      limeRecommendation: json['lime_recommendation'] ?? '',
      micronutrients: json['micronutrients'] ?? '',
      nextSteps: json['next_steps'] ?? '',
    );
  }
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  GenerativeModel? _model;
  GenerativeModel? _visionModel;

  static const String _systemPrompt = '''You are Krushi Mitra, a premium, friendly agricultural expert helping Indian farmers.
Your goal is to provide SIMPLIFIED, PRACTICAL, and ACTIONABLE advice.

CRITICAL FORMATTING GUIDELINES FOR GOOD-LOOKING OUTPUT:
1. ALWAYS format your responses using rich Markdown.
2. Use **bold text** for important terms, crop names, diseases, and key actions.
3. Use bullet points (`-`) or numbered lists (`1.`) for steps and recommendations.
4. Use emojis to make the text engaging and friendly (e.g., 🌾, 💧, 🐛, 💰, 🚜).
5. Add a brief, encouraging conclusion at the end.

CONTENT GUIDELINES:
- Use very simple language. Avoid complex scientific jargon.
- Keep answers SHORT and DIRECT. A busy farmer needs quick solutions.
- If a disease is detected, give exactly 1 organic and 1 chemical solution.
- When talking about quantities, use common units like "एक एकड़" (one acre) or "एक पंप" (one pump/15L tank).

Respond in the user's language (Hindi/Marathi/English) as requested.
If you don't know something, simply say: "I am not completely sure. Please consult your local agriculture officer. 🏢"''';

  bool initialize() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        debugPrint('GEMINI_API_KEY is empty in .env');
        return false;
      }

      _model = GenerativeModel(
        model: ApiConstants.geminiModel,
        apiKey: apiKey,
        systemInstruction: Content.system(_systemPrompt),
      );

      _visionModel = GenerativeModel(
        model: ApiConstants.geminiVisionModel,
        apiKey: apiKey,
      );
      
      debugPrint('AIService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('AIService initialization failed: $e');
      return false;
    }
  }

  /// Analyze a crop image for disease detection using Gemini (FREE)
  Future<CropDiagnosis> analyzeCropImage(
    File imageFile,
    String language,
  ) async {
    if (_visionModel == null) {
      if (!initialize()) {
        debugPrint('AIService: Vision model not initialized. Safe Mock.');
        return _getMockDiagnosis('Wheat');
      }
    }
    
    try {
      // 1. Compress & Optimize Image
      final bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      
      List<int> processedBytes;
      if (originalImage != null) {
        // Resize to max 1024px for faster upload
        img.Image resized = img.copyResize(originalImage, width: 1024);
        processedBytes = img.encodeJpg(resized, quality: 75);
        debugPrint('AIService: Image optimized from ${bytes.length} to ${processedBytes.length} bytes');
      } else {
        processedBytes = bytes;
      }

      final languageInstruction = _getLanguageInstruction(language);
      final prompt = '''Analyze this crop photo carefully. Respond ONLY in valid JSON format.

$languageInstruction

Provide your analysis as JSON with these exact keys:
{
  "crop_name": "Name of the crop identified",
  "health_status": "healthy OR diseased OR deficient",
  "disease_name": "Disease/pest/deficiency name (None if healthy)",
  "severity": "low OR medium OR high OR severe",
  "confidence": 85,
  "symptoms": "Visible symptoms described simply",
  "causes": "What causes this issue",
  "treatment_organic": "Organic/natural treatment with quantities",
  "treatment_chemical": "Chemical treatment with product names and dosage",
  "prevention": "How to prevent this in future"
}

Do NOT include markdown formatting. Return pure JSON only.''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(processedBytes)),
        ])
      ];

      final response = await _visionModel!.generateContent(content);
      final responseText = response.text ?? '';
      final jsonStr = _extractJson(responseText);
      final Map<String, dynamic> jsonData = json.decode(jsonStr);
      return CropDiagnosis.fromJson(jsonData);
    } catch (e) {
      debugPrint('AI Doctor Error: $e. Returning mock fallback.');
      return _getMockDiagnosis('Crop');
    }
  }

  CropDiagnosis _getMockDiagnosis(String crop) {
    return CropDiagnosis(
      cropName: crop,
      diseaseName: 'No disease detected (Safe Mode)',
      symptoms: 'The leaves appear normal. (Check API Key for real analysis)',
      treatmentOrganic: 'Continue regular organic manuring.',
      treatmentChemical: 'No chemical treatment needed.',
      confidencePercent: 95.0,
      severity: 'Low',
      isHealthy: true,
      prevention: 'Regular monitoring',
      causes: 'Healthy growth',
    );
  }

  /// Chat functionality with full context
  Future<String> chat(
    List<Map<String, dynamic>> history,
    String userMessage,
    String language,
  ) async {
    if (_model == null) {
      if (!initialize()) return 'I am sorry, my connection is offline. Please check your API key.';
    }

    try {
      final List<Content> chatHistory = [];
      for (var i = 0; i < history.length; i++) {
        final msg = history[i];
        final role = msg['role'] == 'user' ? 'user' : 'model';
        final content = msg['content'] as String;
        if (i == history.length - 1 && role == 'user' && content == userMessage) continue;
        if (chatHistory.isNotEmpty && chatHistory.last.role == role) continue;
        chatHistory.add(Content(role, [TextPart(content)]));
      }

      final chat = _model!.startChat(history: chatHistory);
      String messageWithLang = userMessage;
      if (chatHistory.isEmpty) {
        messageWithLang = '${_getLanguageInstruction(language)}\n\n$userMessage';
      }

      final response = await chat.sendMessage(Content.text(messageWithLang));
      return response.text ?? 'I am sorry, but I cannot provide a response. Try rephrasing?';
    } catch (e) {
      debugPrint('Chat API Error: $e');
      if (e.toString().contains('403')) return 'My knowledge is currently limited. (API Key Forbidden)';
      if (e.toString().contains('quota')) return 'I am resting for a minute. (Quota Exceeded)';
      return 'I encountered a technical issue. Let\'s try again.';
    }
  }

  /// Check if a farmer is eligible for a government scheme
  Future<String> checkSchemeEligibility(
    Map<String, dynamic> farmerProfile,
    Map<String, dynamic> scheme,
    String language,
  ) async {
    if (_model == null) {
      if (!initialize()) return 'I cannot check eligibility right now.';
    }

    final prompt = '''
Farmer Profile:
- Name: ${farmerProfile['name']}
- State: ${farmerProfile['state']}
- District: ${farmerProfile['district']}
- Land (acres): ${farmerProfile['landAcres']}
- Crops: ${farmerProfile['crops']?.join(', ')}

Government Scheme: ${scheme['name']}
Eligibility Criteria: ${scheme['eligibility']}
Benefits: ${scheme['benefit']}

Based on this farmer's profile, assess:
1. Is this farmer ELIGIBLE for this scheme?
2. What specific steps should they follow?
3. What documents do they need?
4. Where should they apply?

${_getLanguageInstruction(language)}
Keep the response practical and simple. Use bullet points.''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Eligibility check failed.';
    } catch (e) {
      return 'I am having trouble checking this scheme. Please try again.';
    }
  }

  /// Get AI-generated daily farming tip
  Future<String> getDailyFarmingTip(
    String cropsList,
    String location,
    String season,
    String language,
  ) async {
    if (_model == null) {
      if (!initialize()) return 'Regularly monitor your crops for pests.';
    }

    final today = DateTime.now();
    final prompt = '''
Give ONE concise, practical farming tip for today (${today.day}/${today.month}).
Crops: $cropsList
Location: $location
Season: $season
${_getLanguageInstruction(language)}''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Check your crop daily for pests.';
    } catch (e) {
      return 'Regularly monitor your crops for healthy growth.';
    }
  }

  /// Analyze soil data and generate fertilizer recommendations
  Future<SoilRecommendation> analyzeSoil(
    Map<String, dynamic> soilData,
    String cropName,
    String language,
  ) async {
    if (_model == null) {
      if (!initialize()) throw Exception('AI offline.');
    }

    final prompt = '''
Analyze this soil data and provide fertilizer recommendations for $cropName in JSON.
${_getLanguageInstruction(language)}''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';
      final jsonStr = _extractJson(responseText);
      return SoilRecommendation.fromJson(json.decode(jsonStr));
    } catch (e) {
      throw Exception('Soil Analysis Error: $e');
    }
  }

  String _getLanguageInstruction(String language) {
    switch (language) {
      case 'hi': return 'Respond in HINDI (हिन्दी). Simple words only.';
      case 'mr': return 'Respond in MARATHI (मराठी). Simple words only.';
      default: return 'Respond in ENGLISH. Simple words only.';
    }
  }

  String _extractJson(String text) {
    String cleaned = text;
    if (cleaned.contains('```')) {
      final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(cleaned);
      if (jsonMatch != null) cleaned = jsonMatch.group(1)!.trim();
    }
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start != -1 && end != -1) return cleaned.substring(start, end + 1);
    return cleaned;
  }
}
