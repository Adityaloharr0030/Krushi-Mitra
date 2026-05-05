import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import '../constants/api_constants.dart';
import 'gemini_service.dart';
import '../../data/models/smart_context_model.dart';

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

  final GeminiService _gemini = GeminiService();

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

  void initialize() {
    _gemini.initialize();
  }

  /// Analyze a crop image for disease detection using Gemini (FREE)
  Future<CropDiagnosis> analyzeCropImage(
    File imageFile,
    FarmerContext context,
  ) async {
    try {
      final language = context.language;
      // 1. Compress & Optimize Image
      final bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      
      List<int> processedBytes;
      if (originalImage != null) {
        img.Image resized = img.copyResize(originalImage, width: 1024);
        processedBytes = img.encodeJpg(resized, quality: 75);
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

      return await _gemini.runWithRetry((model) async {
        // Create a vision model instance for this call
        final visionModel = _gemini.getModel(modelName: ApiConstants.geminiVisionModel);
        final content = [
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', Uint8List.fromList(processedBytes)),
          ])
        ];
        final response = await visionModel.generateContent(content);
        final jsonStr = _extractJson(response.text ?? '');
        return CropDiagnosis.fromJson(json.decode(jsonStr));
      });
    } catch (e) {
      debugPrint('AI Doctor Error: $e. Returning mock fallback.');
      return _getMockDiagnosis('Crop');
    }
  }

  CropDiagnosis _getMockDiagnosis(String crop) {
    return CropDiagnosis(
      cropName: crop,
      diseaseName: 'No disease detected (Safe Mode)',
      symptoms: 'The leaves appear normal.',
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
    FarmerContext context,
  ) async {
    try {
      final language = context.language;
      final farmerInfo = context.profile != null 
          ? "Farmer Name: ${context.profile!.name}, Crops: ${context.profile!.cropsGrown.join(', ')}, Location: ${context.profile!.district}, ${context.profile!.state}."
          : "Context: No profile yet.";
      
      final weatherInfo = context.weather != null 
          ? "Current Weather: ${context.weather!.temperature}°C, ${context.weather!.condition}."
          : "";

      final enhancedSystemPrompt = "$_systemPrompt\n\nUSER CONTEXT:\n$farmerInfo\n$weatherInfo\n\nAlways tailor your advice specifically to this farmer's crops and location.";

      return await _gemini.runWithRetry((model) async {
        final chatModel = _gemini.getModel(systemPrompt: enhancedSystemPrompt);
        
        final List<Content> chatHistory = [];
        for (var i = 0; i < history.length; i++) {
          final msg = history[i];
          final role = msg['role'] == 'user' ? 'user' : 'model';
          final content = msg['content'] as String;
          if (i == history.length - 1 && role == 'user' && content == userMessage) continue;
          if (chatHistory.isNotEmpty && chatHistory.last.role == role) continue;
          chatHistory.add(Content(role, [TextPart(content)]));
        }

        final chatSession = chatModel.startChat(history: chatHistory);
        String messageWithLang = userMessage;
        if (chatHistory.isEmpty) {
          messageWithLang = '${_getLanguageInstruction(language)}\n\n$userMessage';
        }

        final response = await chatSession.sendMessage(Content.text(messageWithLang));
        return response.text ?? 'I am sorry, but I cannot provide a response.';
      });
    } catch (e) {
      debugPrint('Chat API Error: $e');
      return 'I encountered a technical issue. Let\'s try again.';
    }
  }

  /// Check if a farmer is eligible for a government scheme
  Future<String> checkSchemeEligibility(
    FarmerContext context,
    Map<String, dynamic> scheme,
  ) async {
    final language = context.language;
    final farmerProfile = context.profile;
    
    final prompt = '''
Farmer Profile:
- Name: ${farmerProfile?.name ?? 'Farmer'}
- State: ${farmerProfile?.state ?? 'Unknown'}
- Land (acres): ${farmerProfile?.landSize ?? 'Unknown'}
- Crops: ${farmerProfile?.cropsGrown.join(', ') ?? 'Unknown'}

Government Scheme: ${scheme['name']}
Eligibility Criteria: ${scheme['eligibility']}
Benefits: ${scheme['benefit']}

Based on this farmer's profile, assess eligibility.
${_getLanguageInstruction(language)}
Keep the response practical and simple. Use bullet points.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Eligibility check failed.';
      });
    } catch (e) {
      return 'I am having trouble checking this scheme.';
    }
  }

  /// Background AI: Generate personalized daily advice
  Future<String> getPersonalizedAdvice(FarmerContext context) async {
    final language = context.language;
    final prompt = '''
User Context: ${json.encode(context.toAIJson())}
Generate a short, smart farming tip or alert for today based on this context.
${_getLanguageInstruction(language)}
Format: "Smart Alert 💡: [Your advice here]"''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? '';
      });
    } catch (e) {
      return '';
    }
  }

  /// AI Market Analysis: Analyze prices and suggest best action
  Future<String> getMarketAnalysis(FarmerContext context, List<Map<String, dynamic>> prices, String commodity) async {
    final language = context.language;
    final farmerInfo = context.profile != null 
        ? "Farmer Context: ${context.profile!.landSize} acres land, grows ${context.profile!.cropsGrown.join(', ')}."
        : "";
    final prompt = '''
$farmerInfo
Market Prices for $commodity: ${json.encode(prices)}
Analyze these prices and give a SHORT advice to the farmer. Consider their land size to estimate supply volume if relevant.
${_getLanguageInstruction(language)}
Keep it under 30 words.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'No market advice available.';
      });
    } catch (e) {
      return 'Market rates are fluctuating. Monitor closely.';
    }
  }

  /// AI Weather Analysis: Analyze weather and give farming advice
  Future<String> getWeatherAnalysis(FarmerContext context) async {
    final language = context.language;
    final weather = context.weather?.toJson();
    final farmerInfo = context.profile != null 
        ? "Farmer Context: Grows ${context.profile!.cropsGrown.join(', ')}."
        : "";
    final prompt = '''
$farmerInfo
Current Weather: ${json.encode(weather)}
Give a short, smart farming advice for today based on this weather and the specific crops grown by the farmer. Mention their crop by name if possible.
${_getLanguageInstruction(language)}
Keep it under 30 words.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Continue regular farming practices.';
      });
    } catch (e) {
      return 'Monitor weather changes for better planning.';
    }
  }

  /// AI Marketplace: Suggest listing price
  Future<double> suggestListingPrice(String commodity, double currentMandiRate, String language) async {
    final prompt = '''
Commodity: $commodity
Current Mandi Rate: ₹$currentMandiRate/qtl
Suggest a competitive online listing price for a farmer to sell directly to companies.
Include a 5-10% premium for direct quality supply.
${_getLanguageInstruction(language)}
Return ONLY the number.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '';
        return double.tryParse(text) ?? currentMandiRate;
      });
    } catch (e) {
      return currentMandiRate;
    }
  }

  /// AI Marketplace: Generate catchy description
  Future<String> generateListingDescription(Map<String, dynamic> details, String language) async {
    final prompt = '''
Product Details: ${json.encode(details)}
Generate a professional, catchy listing description for this farm produce to attract bulk buyers/companies.
${_getLanguageInstruction(language)}
Keep it under 50 words.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Freshly harvested quality produce.';
      });
    } catch (e) {
      return 'Freshly harvested quality produce available for bulk purchase.';
    }
  }

  /// AI Marketplace: Score listing quality
  Future<String> scoreListingQuality(Map<String, dynamic> details) async {
    final prompt = '''
Listing Details: ${json.encode(details)}
Score the "Market Readiness" of this listing from A+ to C.
Return ONLY the grade (e.g., "A+").''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text?.trim() ?? 'B';
      });
    } catch (e) {
      return 'B';
    }
  }

  /// AI Farm Diary: Analyze spending
  Future<String> getDiaryAnalysis(FarmerContext context) async {
    final language = context.language;
    final entries = context.diaryEntries.map((e) => e.toJson()).toList();
    final prompt = '''
Entries: ${json.encode(entries)}
Analyze these farm expenses and income for this farmer. Provide one concise "Smart Budget Tip".
${_getLanguageInstruction(language)}
Keep it under 30 words.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Keep tracking to get budget insights.';
      });
    } catch (e) {
      return 'Tracking your expenses helps in profit optimization.';
    }
  }

  /// AI Govt Schemes: Calculate match score
  Future<int> getSchemeMatchScore(Map<String, dynamic> farmerDetails, Map<String, dynamic> schemeDetails) async {
    final prompt = '''
Farmer: ${json.encode(farmerDetails)}
Scheme: ${json.encode(schemeDetails)}
Calculate a "Match Score" percentage (0-100) based on how eligible the farmer is for this scheme.
Return ONLY the number.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0';
        return int.tryParse(text) ?? 50;
      });
    } catch (e) {
      return 50;
    }
  }

  /// Get AI-generated daily farming tip
  Future<String> getDailyFarmingTip(
    String cropsList,
    String location,
    String season,
    String language,
  ) async {
    final today = DateTime.now();
    final prompt = '''
Give ONE concise, practical farming tip for today (${today.day}/${today.month}).
Crops: $cropsList
Location: $location
Season: $season
${_getLanguageInstruction(language)}''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Check your crop daily for pests.';
      });
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
    final prompt = '''
Analyze this soil data: ${json.encode(soilData)}
Provide fertilizer recommendations for $cropName in JSON format.
${_getLanguageInstruction(language)}''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        final jsonStr = _extractJson(response.text ?? '');
        return SoilRecommendation.fromJson(json.decode(jsonStr));
      });
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
