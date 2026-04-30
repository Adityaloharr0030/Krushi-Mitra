import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Data Models for AI Responses
class CropDiagnosis {
  final String cropName;
  final String healthStatus; // 'healthy' or 'diseased'
  final String diseaseName;
  final String severity; // low, medium, high, severe
  final String symptoms;
  final String causes;
  final String treatmentOrganic;
  final String treatmentChemical;
  final String prevention;
  final double confidencePercent;

  CropDiagnosis({
    required this.cropName,
    required this.healthStatus,
    required this.diseaseName,
    required this.severity,
    required this.symptoms,
    required this.causes,
    required this.treatmentOrganic,
    required this.treatmentChemical,
    required this.prevention,
    this.confidencePercent = 85.0,
  });

  factory CropDiagnosis.fromJson(Map<String, dynamic> json) {
    return CropDiagnosis(
      cropName: json['crop_name'] ?? 'Unknown Crop',
      healthStatus: json['health_status'] ?? 'unknown',
      diseaseName: json['disease_name'] ?? 'None detected',
      severity: json['severity'] ?? 'low',
      symptoms: json['symptoms'] ?? '',
      causes: json['causes'] ?? '',
      treatmentOrganic: json['treatment_organic'] ?? '',
      treatmentChemical: json['treatment_chemical'] ?? '',
      prevention: json['prevention'] ?? '',
      confidencePercent: (json['confidence'] as num?)?.toDouble() ?? 85.0,
    );
  }

  bool get isHealthy => healthStatus.toLowerCase() == 'healthy';
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

  static const String _systemPrompt = '''You are Krushi Mitra, an expert agricultural assistant for Indian farmers. 
You have deep knowledge of:
- Crop diseases, pests, and deficiencies in Indian agriculture
- Farming techniques for crops like wheat, rice, cotton, sugarcane, soybean, onion, vegetables
- Soil health, fertilizer management (NPK, micronutrients)
- Irrigation methods and scheduling
- Government schemes: PM-KISAN, PMFBY, Soil Health Card, KCC, e-NAM
- Weather impact on farming decisions
- Organic and integrated pest management
- Maharashtra, UP, Punjab, MP, Rajasthan specific farming practices

ALWAYS:
- Respond in the user's chosen language (Hindi/Marathi/English)
- Give practical, actionable advice
- Keep language simple for farmers with low literacy
- Mention local product names/brands when relevant
- Provide dosages and quantities in practical units (kg/acre, ml/tank)
- Mention safety precautions when discussing pesticides
- Suggest both organic and chemical solutions when applicable''';

  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return;

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );

    _visionModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Analyze a crop image for disease detection using Gemini (FREE)
  Future<CropDiagnosis> analyzeCropImage(
    File imageFile,
    String language,
  ) async {
    if (_visionModel == null) initialize();
    
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

    final firstImage = await imageFile.readAsBytes();
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', firstImage),
      ])
    ];

    try {
      final response = await _visionModel!.generateContent(content);
      final responseText = response.text ?? '';
      final jsonStr = _extractJson(responseText);
      final Map<String, dynamic> jsonData = json.decode(jsonStr);
      return CropDiagnosis.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to analyze crop image with Gemini: $e');
    }
  }

  /// Send a chat message to the AI using Gemini (FREE)
  Future<String> chat(
    List<Map<String, dynamic>> history,
    String userMessage,
    String language,
  ) async {
    if (_model == null) initialize();

    final chatHistory = history.map((msg) {
      final role = msg['role'] == 'user' ? 'user' : 'model';
      return Content(role, [TextPart(msg['content'] as String)]);
    }).toList();

    final chat = _model!.startChat(history: chatHistory);
    
    try {
      final response = await chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'No response from AI';
    } catch (e) {
      throw Exception('Gemini Chat Error: $e');
    }
  }

  /// Check farmer's eligibility for a government scheme
  Future<String> checkSchemeEligibility(
    Map<String, dynamic> farmerProfile,
    Map<String, dynamic> scheme,
    String language,
  ) async {
    if (_model == null) initialize();

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
      throw Exception('Gemini Eligibility Check Error: $e');
    }
  }

  /// Get AI-generated daily farming tip
  Future<String> getDailyFarmingTip(
    String cropsList,
    String location,
    String season,
    String language,
  ) async {
    if (_model == null) initialize();

    final today = DateTime.now();
    final prompt = '''
Give ONE concise, practical farming tip for today (${today.day}/${today.month}).
Crops: $cropsList
Location: $location
Season: $season

The tip should be:
- Relevant to current season and date
- Actionable (something farmer can do today or this week)
- Maximum 3 sentences
- Include specific quantities/measurements if relevant

${_getLanguageInstruction(language)}''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Keep farming and stay safe!';
    } catch (e) {
      throw Exception('Gemini Daily Tip Error: $e');
    }
  }

  /// Analyze soil data and generate fertilizer recommendations
  Future<SoilRecommendation> analyzeSoil(
    Map<String, dynamic> soilData,
    String cropName,
    String language,
  ) async {
    if (_model == null) initialize();

    final prompt = '''
Analyze this soil data and provide fertilizer recommendations for $cropName.

Soil Data:
- Soil Type: ${soilData['soilType']}
- pH: ${soilData['ph'] ?? 'Not tested'}
- Nitrogen: ${soilData['nitrogen']} level
- Phosphorus: ${soilData['phosphorus']} level
- Potassium: ${soilData['potassium']} level
- Previous Crop: ${soilData['previousCrop'] ?? 'Unknown'}
- Field Area: ${soilData['areaAcres']} acres

Respond ONLY in this JSON format:
{
  "assessment": "Overall soil health assessment in 2-3 sentences",
  "fertilizers": "Exact quantities of Urea, DAP, MOP per acre with timing",
  "organic_amendments": "Organic matter, compost, green manure suggestions",
  "lime_recommendation": "Lime or sulfur application if pH needs correction",
  "micronutrients": "Zinc, Boron, Iron, Manganese if deficient",
  "next_steps": "Priority action plan as numbered list"
}

${_getLanguageInstruction(language)}
Return pure JSON only, no markdown.''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';
      final jsonStr = _extractJson(responseText);
      return SoilRecommendation.fromJson(json.decode(jsonStr));
    } catch (e) {
      throw Exception('Gemini Soil Analysis Error: $e');
    }
  }

  // --- Private Helpers ---

  String _getLanguageInstruction(String language) {
    switch (language) {
      case 'hi':
        return 'Respond in HINDI (हिन्दी) language. Use simple, everyday Hindi words.';
      case 'mr':
        return 'Respond in MARATHI (मराठी) language. Use simple Marathi words.';
      default:
        return 'Respond in ENGLISH. Use simple, easy-to-understand English.';
    }
  }

  String _extractJson(String text) {
    final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
    if (jsonMatch != null) return jsonMatch.group(1)!.trim();

    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1) {
      return text.substring(start, end + 1);
    }
    return text;
  }
}
