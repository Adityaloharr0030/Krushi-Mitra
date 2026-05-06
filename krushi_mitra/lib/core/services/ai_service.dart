import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import '../constants/api_constants.dart';
import 'gemini_service.dart';
import 'ai_knowledge_base.dart';
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

  // ─── INDIAN AGRICULTURE KNOWLEDGE BASE ───
  static String get _currentSeason {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 9) return 'Kharif (Monsoon season — June to September)';
    if (month >= 10 && month <= 2) return 'Rabi (Winter season — October to February)';
    return 'Zaid (Summer season — March to May)';
  }



  static String get _currentMonth => [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][DateTime.now().month];

  static String _buildFarmerBrief(FarmerContext context) {
    final p = context.profile;
    final w = context.weather;
    final buf = StringBuffer();

    if (p != null) {
      buf.writeln('FARMER PROFILE:');
      buf.writeln('- Name: ${p.name}');
      buf.writeln('- Location: ${p.district}, ${p.state} (India)');
      buf.writeln('- Land: ${p.landSize} acres');
      buf.writeln('- Crops grown: ${p.cropsGrown.join(", ")}');
      if (p.soilType != null) buf.writeln('- Soil type: ${p.soilType}');
      if (p.irrigationSource != null) buf.writeln('- Irrigation: ${p.irrigationSource}');
      
      // Inject Expert Knowledge for their crops
      buf.writeln('\n${AIKnowledgeBase.getKnowledgeBrief(p.cropsGrown)}');
    }

    if (w != null) {
      buf.writeln('\nCURRENT WEATHER:');
      buf.writeln('- Temperature: ${w.temperature}°C (feels like ${w.feelsLike}°C)');
      buf.writeln('- Condition: ${w.condition}');
      buf.writeln('- Humidity: ${w.humidity}%');
      buf.writeln('- Wind: ${w.windSpeed} m/s');
    }

    buf.writeln('\nSEASON: $_currentSeason');
    buf.writeln('MONTH: $_currentMonth');
    buf.writeln('DATE: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');

    if (context.marketPrices.isNotEmpty) {
      buf.writeln('\nRECENT MARKET PRICES:');
      for (final mp in context.marketPrices.take(5)) {
        buf.writeln('- ${mp.commodity}: ₹${mp.modalPrice}/qtl at ${mp.market}');
      }
    }

    if (context.diaryEntries.isNotEmpty) {
      final income = context.diaryEntries.where((e) => !e.isExpense).fold(0.0, (s, e) => s + e.cost);
      final expense = context.diaryEntries.where((e) => e.isExpense).fold(0.0, (s, e) => s + e.cost);
      buf.writeln('\nFARM FINANCIALS: Income ₹${income.toStringAsFixed(0)}, Expenses ₹${expense.toStringAsFixed(0)}');
      buf.writeln('Last activity: ${context.diaryEntries.first.activity}');
    }

    return buf.toString();
  }

  // ─── MASTER SYSTEM PROMPT ───
  static const String _systemPrompt = '''You are **Krushi Mitra** (कृषी मित्र) — a premium, expert-level AI agricultural advisor built specifically for Indian farmers.

YOUR IDENTITY:
- You are a trusted farming companion, not a generic chatbot.
- You have deep knowledge of Indian agriculture: crop cycles, regional soil types, monsoon patterns, government schemes (PM-KISAN, PMFBY, KCC), mandi systems, MSP rates, and organic/integrated farming.
- You combine traditional Indian farming wisdom (like neem-based pest control, crop rotation with pulses, vermicompost) with modern scientific methods.

REASONING MANDATE:
Before providing any advice, internally reason through the problem:
1. **Analyze Growth Stage**: Determine the crop's probable growth stage based on the current month and season.
2. **Environmental Assessment**: Consider how current weather (humidity, temperature, wind) impacts the issue or the effectiveness of the solution.
3. **Knowledge Integration**: Cross-reference the user's query with the expert rules for their specific crops.
4. **Prioritize Impact**: Identify the single most critical and immediate action the farmer needs to take.

RESPONSE QUALITY RULES:
1. Be CONCISE but COMPLETE. Farmers are busy — give actionable answers, not essays.
2. Use **bold** for crop names, disease names, chemical names, and key numbers.
3. Use bullet points and numbered lists for steps.
4. Include specific quantities: "**2-3 ml per litre**" not "some amount".
5. Include specific product names available in India: "**Thiamethoxam 25 WG (Actara)**" not "a systemic insecticide".
6. Use emojis sparingly but effectively: 🌾 for crops, 💧 for irrigation, 🐛 for pests, 💰 for prices, 🌡️ for weather, ⚠️ for warnings.
7. Always mention the **best time to act** (morning/evening, which month, before/after rain).
8. When relevant, give both **organic/desi** AND **chemical** solutions.
9. End with ONE encouraging line.

WHAT MAKES YOU SMART:
- You adapt advice to the farmer's EXACT location, crops, soil type, and current season.
- You factor in current weather when recommending spraying, irrigation, or harvesting.
- You know Indian market dynamics — when to sell, when to store, which mandi pays more.
- You proactively warn about upcoming risks (pest season, frost, heavy rain forecast).

LANGUAGE:
- Respond in the language the user uses. If asked in Hindi, reply in Hindi. If Marathi, reply in Marathi.
- Use simple village-level language. Avoid English technical jargon when replying in Hindi/Marathi.
- For Hindi: use words like "एक एकड़", "एक पंप (15 लीटर)", "बोरी" instead of hectare/litre.

SAFETY:
- If unsure, say: "मुझे इस बारे में पूरा भरोसा नहीं है। कृपया अपने स्थानीय कृषि अधिकारी से सलाह लें। 🏢"
- Never recommend banned pesticides (Endosulfan, Monocrotophos on vegetables, etc.)
- Always warn about safety gear when recommending chemicals.''';

  void initialize() {
    _gemini.initialize();
  }

  // ─── CROP DISEASE DIAGNOSIS ───
  Future<CropDiagnosis> analyzeCropImage(File imageFile, FarmerContext context) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      List<int> processedBytes;
      if (originalImage != null) {
        img.Image resized = img.copyResize(originalImage, width: 1024);
        processedBytes = img.encodeJpg(resized, quality: 75);
      } else {
        processedBytes = bytes;
      }

      final farmerBrief = _buildFarmerBrief(context);
      final langInst = _getLanguageInstruction(context.language);
      final prompt = '''You are an expert plant pathologist specializing in Indian agriculture.

FARMER CONTEXT:
$farmerBrief

TASK: Analyze this crop photo with extreme precision. Consider:
- The farmer's location and current season to narrow down likely diseases
- Common diseases for this region at this time of year
- Weather conditions (humidity/temperature) that favor certain pathogens
- Whether symptoms match nutrient deficiency vs disease vs pest damage

$langInst

Respond ONLY in valid JSON (no markdown, no backticks):
{
  "crop_name": "Exact crop identified (e.g., Tomato, Wheat, Cotton)",
  "health_status": "healthy OR diseased OR deficient OR pest_damage",
  "disease_name": "Precise disease/pest/deficiency name (e.g., Late Blight, Nitrogen Deficiency, Whitefly Attack). Use 'None' if healthy",
  "severity": "low OR medium OR high OR critical",
  "confidence": 85,
  "symptoms": "Describe exactly what you see — leaf color, spots, wilting pattern, affected parts",
  "causes": "What causes this — pathogen name, environmental triggers, nutrient lack",
  "treatment_organic": "Specific organic remedy with exact dosage. Example: Neem oil 5ml/L spray at 7-day interval. Include preparation method if relevant",
  "treatment_chemical": "Specific chemical with Indian brand name and dosage. Example: Mancozeb 75 WP (Dithane M-45) @ 2.5g/L foliar spray. Include PHI (pre-harvest interval)",
  "prevention": "3-4 specific preventive measures for future seasons"
}''';

      debugPrint('AI Doctor: Processing image, size: ${processedBytes.length} bytes');

      return await _gemini.runWithRetry((model) async {
        final content = [
          Content('user', [
            DataPart('image/jpeg', Uint8List.fromList(processedBytes)),
            TextPart(prompt),
          ])
        ];
        final response = await model.generateContent(content);
        final jsonStr = _extractJson(response.text ?? '');
        return CropDiagnosis.fromJson(json.decode(jsonStr));
      });
    } catch (e) {
      debugPrint('AI Doctor Error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('OFFLINE')) {
        return _getMockDiagnosis('Crop', isOffline: true);
      }
      return _getMockDiagnosis('Crop', isOffline: false);
    }
  }

  CropDiagnosis _getMockDiagnosis(String crop, {bool isOffline = false}) {
    final rules = AIKnowledgeBase.cropExpertRules[crop];
    final diseases = rules != null ? (rules['diseases'] as List).join(', ') : 'unknown issues';
    
    return CropDiagnosis(
      cropName: crop,
      diseaseName: isOffline ? 'Offline Diagnostic Mode' : 'AI Service Unavailable',
      isHealthy: false,
      severity: 'Unknown',
      confidencePercent: 0.0,
      symptoms: isOffline 
          ? 'Could not analyze photo — please check your internet connection and try again.'
          : 'The AI service is currently busy or under maintenance. Using local knowledge base.',
      causes: 'Common issues for $crop at this stage include: $diseases.',
      treatmentOrganic: rules != null ? 'Apply 5ml Neem Oil per liter of water as a general preventive measure.' : 'Maintain regular watering and monitor for pests.',
      treatmentChemical: 'Seek advice from a local Krishi Kendra if symptoms persist.',
      prevention: 'Ensure proper spacing, balanced fertilization, and crop rotation.',
    );
  }

  // ─── SMART CHAT ───
  Future<String> chat(List<Map<String, dynamic>> history, String userMessage, FarmerContext context) async {
    try {
      final farmerBrief = _buildFarmerBrief(context);
      final fewShot = AIKnowledgeBase.getFewShotContext();
      
      final enhancedSystemPrompt = '''$_systemPrompt

═══ LIVE FARMER CONTEXT ═══
$farmerBrief
═══════════════════════════

═══ EXPERT EXAMPLES (FEW-SHOT) ═══
$fewShot
══════════════════════════════════

IMPORTANT: Use this context to personalize EVERY answer. Mention their crops by name, reference their location's climate, and factor in current weather when giving advice. If they ask about a crop they don't grow, still answer but note it's not in their current profile.''';

      return await _gemini.runWithRetry(
        (model) async {
          final List<Content> chatHistory = [];
          for (var i = 0; i < history.length; i++) {
            final msg = history[i];
            final role = msg['role'] == 'user' ? 'user' : 'model';
            final content = msg['content'] as String;
            if (i == history.length - 1 && role == 'user' && content == userMessage) continue;
            if (chatHistory.isNotEmpty && chatHistory.last.role == role) continue;
            chatHistory.add(Content(role, [TextPart(content)]));
          }

          final chatSession = model.startChat(history: chatHistory);
          String messageWithLang = userMessage;
          if (chatHistory.isEmpty) {
            messageWithLang = '${_getLanguageInstruction(context.language)}\n\n$userMessage';
          }
          
          final response = await chatSession.sendMessage(Content.text(messageWithLang));
          return response.text ?? 'I could not generate a response. Please try again.';
        },
        systemPrompt: enhancedSystemPrompt,
      );
    } catch (e) {
      debugPrint('Chat API Error: $e');
      final errorStr = e.toString();
      final crops = context.profile?.cropsGrown ?? [];
      final location = '${context.profile?.district ?? ""}, ${context.profile?.state ?? "India"}';
      
      if (errorStr.contains('OFFLINE')) {
        return AIKnowledgeBase.getOfflineAdvice(userMessage, crops, location);
      }
      
      return '🤖 **AI Service Update**\n\nI am currently experiencing high traffic or a temporary outage. I will continue to assist you using my internal knowledge base where possible.\n\n${AIKnowledgeBase.getOfflineAdvice(userMessage, crops, location)}';
    }
  }

  // ─── SCHEME ELIGIBILITY ───
  Future<String> checkSchemeEligibility(FarmerContext context, Map<String, dynamic> scheme) async {
    final farmerBrief = _buildFarmerBrief(context);
    final langInst = _getLanguageInstruction(context.language);
    final prompt = '''You are an expert on Indian government agricultural schemes.

$farmerBrief

SCHEME DETAILS:
- Name: ${scheme['name']}
- Eligibility: ${scheme['eligibility']}
- Benefits: ${scheme['benefit']}

TASK: Analyze this farmer's eligibility for this scheme. Provide:
1. **Eligibility Status**: ✅ Likely Eligible / ⚠️ Partially Eligible / ❌ Not Eligible
2. **Why**: Specific reasons based on their land size, location, and crops
3. **How to Apply**: Step-by-step process (mention nearest office, documents needed)
4. **Documents Needed**: Aadhaar, land records (7/12 extract), bank passbook, etc.
5. **Deadline/Timeline**: If known

$langInst
Keep it practical and actionable. Use bullet points.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Could not check eligibility. Please try again.';
      });
    } catch (e) {
      return '⚠️ Unable to check eligibility right now. Please ensure internet connectivity and try again.';
    }
  }

  // ─── PERSONALIZED DAILY ADVICE ───
  Future<String> getPersonalizedAdvice(FarmerContext context) async {
    final farmerBrief = _buildFarmerBrief(context);
    final langInst = _getLanguageInstruction(context.language);
    final prompt = '''You are Krushi Mitra giving a smart daily farming tip.

$farmerBrief

TASK: Generate ONE hyper-personalized farming insight for TODAY. Consider:
- What farming activity is most critical THIS WEEK for their specific crops in this season?
- Does the current weather create any opportunity or risk?
- Any market timing advice based on current prices?
- Any pest/disease that typically appears in this region during $_currentMonth?

FORMAT: Start with an emoji, then a bold title, then 1-2 sentences of advice.
Example: "🌡️ **Heat Alert for Onion Crop** — With 38°C expected, irrigate your onion field early morning. Mulch with dry grass to retain soil moisture."

$langInst
Maximum 40 words. Be specific to THEIR crops and location, not generic.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? '';
      });
    } catch (e) {
      return '';
    }
  }

  // ─── MARKET ANALYSIS ───
  Future<String> getMarketAnalysis(FarmerContext context, List<Map<String, dynamic>> prices, String commodity) async {
    final farmerBrief = _buildFarmerBrief(context);
    final langInst = _getLanguageInstruction(context.language);
    final prompt = '''You are a mandi market analyst for Indian farmers.

$farmerBrief

MARKET DATA for $commodity:
${json.encode(prices)}

TASK: Give a SHORT, actionable market insight:
1. Is the price trending UP or DOWN compared to season average?
2. Should the farmer SELL NOW, HOLD, or WAIT?
3. Which mandi from the data offers the best rate?
4. If they have ${context.profile?.landSize ?? 2} acres, estimate their potential revenue.

$langInst
Maximum 35 words. Be decisive — "Sell now" or "Hold for 2 weeks" — not vague.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Monitor prices closely.';
      });
    } catch (e) {
      return '📊 Market data is loading. Check back shortly.';
    }
  }

  // ─── WEATHER ANALYSIS ───
  Future<String> getWeatherAnalysis(FarmerContext context) async {
    final farmerBrief = _buildFarmerBrief(context);
    final langInst = _getLanguageInstruction(context.language);
    final prompt = '''You are a weather-smart farming advisor.

$farmerBrief

TASK: Give ONE weather-based farming action for TODAY. Consider:
- Should they irrigate, spray, harvest, or hold off based on conditions?
- Is it safe to apply pesticide/fertilizer? (rain forecast = don't spray)
- Temperature impact on their specific crops
- Wind speed impact on spraying effectiveness

$langInst
Maximum 35 words. Mention their crop by name. Be specific: "Don't spray today" or "Perfect day for sowing".''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Continue regular farming practices.';
      });
    } catch (e) {
      final w = context.weather;
      final crops = context.profile?.cropsGrown ?? ["crops"];
      if (w != null) {
        if (w.condition.toLowerCase().contains('rain')) {
          return "🌧️ Rain alert: Avoid spraying pesticides or fertilizer today for your ${crops.first}.";
        }
        if (w.windSpeed > 5) {
          return "🌬️ High winds (${w.windSpeed}m/s): Not suitable for spraying today. Delay for better efficiency.";
        }
        if (w.temperature > 38) {
          return "🔥 High Heat: Irrigate your ${crops.first} early morning or late evening. Avoid heavy field work in daytime.";
        }
      }
      return '🌤️ Farming Advice: Ensure proper irrigation and monitor crops for pests.';
    }
  }

  // ─── MARKETPLACE: PRICE SUGGESTION ───
  Future<double> suggestListingPrice(String commodity, double currentMandiRate, String language) async {
    final prompt = '''You are an agricultural market pricing expert in India.

Commodity: $commodity
Current Mandi Rate: ₹$currentMandiRate per quintal
Season: $_currentSeason

TASK: Suggest an optimal direct-sale listing price. Consider:
- Direct farmer-to-buyer eliminates middlemen (5-15% premium is fair)
- Quality premium for sorted, graded produce
- Current season supply-demand dynamics
- Don't price too high (buyers won't respond) or too low (farmer loses)

Return ONLY a number (the price in rupees per quintal). No text, no symbols.''';

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

  // ─── MARKETPLACE: LISTING DESCRIPTION ───
  Future<String> generateListingDescription(Map<String, dynamic> details, String language) async {
    final langInst = _getLanguageInstruction(language);
    final prompt = '''You are a copywriter for an Indian agricultural marketplace app.

Product: ${json.encode(details)}
Season: $_currentSeason

TASK: Write a professional, trust-building listing description that will attract bulk buyers and export companies. Include:
- Quality highlights (freshness, grade, moisture content if grain)
- Packaging/delivery readiness
- Farm-direct advantage (no middleman, traceable source)
- Urgency trigger ("limited stock", "harvested this week")

$langInst
Keep it 30-40 words. Professional tone, not salesy. No emojis.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Premium quality farm-fresh produce. Direct from farmer. Bulk orders welcome.';
      });
    } catch (e) {
      return 'Farm-fresh, quality-checked produce available for direct purchase. Competitive pricing for bulk buyers.';
    }
  }

  // ─── MARKETPLACE: QUALITY SCORE ───
  Future<String> scoreListingQuality(Map<String, dynamic> details) async {
    final prompt = '''Score this marketplace listing for "Market Readiness" on a scale of A+ to C.

Listing: ${json.encode(details)}

Scoring criteria:
- A+: Complete info, competitive price, high-demand crop, good quantity
- A: Good info, reasonable price, decent quantity
- B: Missing some details, average pricing
- C: Incomplete, overpriced, or very low quantity

Return ONLY the grade letter (e.g., "A+" or "B"). Nothing else.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text?.trim() ?? 'B';
        // Clean to just the grade
        if (text.contains('A+')) return 'A+';
        if (text.contains('A')) return 'A';
        if (text.contains('B')) return 'B';
        return 'B';
      });
    } catch (e) {
      return 'B';
    }
  }

  // ─── FARM DIARY ANALYSIS ───
  Future<String> getDiaryAnalysis(FarmerContext context) async {
    final farmerBrief = _buildFarmerBrief(context);
    final langInst = _getLanguageInstruction(context.language);
    final entries = context.diaryEntries.map((e) => e.toJson()).toList();
    final prompt = '''You are a farm financial advisor.

$farmerBrief

FARM DIARY ENTRIES:
${json.encode(entries)}

TASK: Analyze their farm economics and give ONE smart budget insight:
- Are they overspending on any category (seeds, fertilizer, labour)?
- Is their income-to-expense ratio healthy?
- One specific cost-saving tip relevant to their crops and region
- Compare to typical costs per acre for their crop type

$langInst
Maximum 35 words. Be specific with numbers, not vague.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Keep tracking expenses for better insights.';
      });
    } catch (e) {
      return '📒 Track your expenses regularly to optimize farm profitability.';
    }
  }

  // ─── SCHEME MATCH SCORE ───
  Future<int> getSchemeMatchScore(Map<String, dynamic> farmerDetails, Map<String, dynamic> schemeDetails) async {
    final prompt = '''Calculate eligibility match percentage (0-100) for this farmer-scheme pair.

Farmer: ${json.encode(farmerDetails)}
Scheme: ${json.encode(schemeDetails)}

Consider: land size limits, state eligibility, crop type requirements, income criteria.
Return ONLY a number between 0 and 100. Nothing else.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0';
        final score = int.tryParse(text) ?? 50;
        return score.clamp(0, 100);
      });
    } catch (e) {
      return 50;
    }
  }

  // ─── DAILY FARMING TIP ───
  Future<String> getDailyFarmingTip(String cropsList, String location, String season, String language) async {
    final langInst = _getLanguageInstruction(language);
    final today = DateTime.now();
    final prompt = '''You are Krushi Mitra giving today's farming tip.

Date: ${today.day}/${today.month}/${today.year}
Location: $location (India)
Season: $_currentSeason
Crops: $cropsList

TASK: Give ONE specific, practical tip that is relevant for THIS exact week of the year. Consider:
- What pest typically emerges now in this region?
- What nutrient application is due for these crops at this growth stage?
- Any cultural practice (weeding, earthing up, pruning) that's timely?
- Market timing — should they prepare for upcoming harvest season?

$langInst
Start with an emoji. Maximum 30 words. Ultra-specific, not generic.''';

    try {
      return await _gemini.runWithRetry((model) async {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? '🌾 Monitor your crops daily for healthy growth.';
      });
    } catch (e) {
      return '🌾 Regular crop monitoring prevents major losses. Check your field today.';
    }
  }

  // ─── SOIL ANALYSIS ───
  Future<SoilRecommendation> analyzeSoil(Map<String, dynamic> soilData, String cropName, String language) async {
    final langInst = _getLanguageInstruction(language);
    final prompt = '''You are an expert soil scientist specializing in Indian agriculture.

Soil Test Data: ${json.encode(soilData)}
Target Crop: $cropName
Season: $_currentSeason

TASK: Provide detailed, actionable fertilizer recommendations. Consider:
- NPK ratio required for $cropName at this growth stage
- Soil pH adjustments needed
- Micronutrient deficiencies common in Indian soils (Zinc, Boron, Iron)
- Split application schedule (basal dose vs top dressing)
- Organic alternatives (vermicompost, green manure, biofertilizers like Rhizobium/PSB)

$langInst

Respond in valid JSON only (no markdown):
{
  "assessment": "Overall soil health assessment in 2 lines",
  "fertilizers": "Specific NPK recommendation with quantities per acre and timing",
  "organic_amendments": "Organic alternatives with quantities and application method",
  "lime_recommendation": "Lime/gypsum need based on pH. Say 'Not needed' if pH is optimal",
  "micronutrients": "Specific micronutrient sprays with dosage (e.g., ZnSO4 5kg/acre)",
  "next_steps": "When to retest soil and 2 key actions to take this week"
}''';

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

  // ─── HELPERS ───
  String _getLanguageInstruction(String language) {
    switch (language) {
      case 'hi':
        return 'LANGUAGE: Respond in HINDI (हिन्दी). Use simple rural Hindi. Units: एकड़, क्विंटल, किलो, पंप (15L). Avoid English technical terms — use Hindi equivalents.';
      case 'mr':
        return 'LANGUAGE: Respond in MARATHI (मराठी). Use simple spoken Marathi. Units: एकर, क्विंटल, किलो. Use Marathi farming terms.';
      default:
        return 'LANGUAGE: Respond in ENGLISH. Use simple words. Avoid jargon. Use Indian units (acre, quintal, kg).';
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
