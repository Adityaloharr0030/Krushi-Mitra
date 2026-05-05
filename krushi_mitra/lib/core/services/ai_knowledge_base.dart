class AIKnowledgeBase {
  // ─── EXPERT RULES BY CROP ───
  static const Map<String, Map<String, dynamic>> cropExpertRules = {
    'Tomato': {
      'critical_stages': ['Seedling', 'Flowering', 'Fruit Setting', 'Harvesting'],
      'pests': ['Fruit Borer', 'Whitefly', 'Leaf Miner'],
      'diseases': ['Early Blight', 'Late Blight', 'Bacterial Wilt'],
      'nutrients': 'High Potassium required during fruiting; Calcium prevents Blossom End Rot.',
      'water': 'Consistent moisture needed; irregular watering causes fruit cracking.',
    },
    'Wheat': {
      'critical_stages': ['CRI (Crown Root Initiation)', 'Tillering', 'Jointing', 'Flowering', 'Milk Stage'],
      'pests': ['Aphids', 'Termites', 'Pink Borer'],
      'diseases': ['Yellow Rust', 'Brown Rust', 'Karnal Bunt'],
      'nutrients': 'Nitrogen split application is key; first dose at 21 days.',
      'water': 'CRI stage (21 days after sowing) is the most critical for irrigation.',
    },
    'Cotton': {
      'critical_stages': ['Squaring', 'Flowering', 'Boll Development', 'Boll Opening'],
      'pests': ['Pink Bollworm', 'Jassids', 'Whitefly'],
      'diseases': ['Root Rot', 'Bacterial Blight', 'Para Wilt'],
      'nutrients': 'Magnesium deficiency causes reddening of leaves (Lalya).',
      'water': 'Sensitive to waterlogging; needs good drainage.',
    },
    'Onion': {
      'critical_stages': ['Seedling', 'Transplanting', 'Bulb Initiation', 'Bulb Development'],
      'pests': ['Thrips', 'Onion Maggot'],
      'diseases': ['Purple Blotch', 'Downy Mildew'],
      'nutrients': 'Sulphur is critical for bulb pungency and storage life.',
      'water': 'Stop irrigation 10-15 days before harvest for better shelf life.',
    },
    'Rice': {
      'critical_stages': ['Nursery', 'Tillering', 'Panicle Initiation', 'Flowering', 'Grain Filling'],
      'pests': ['Stem Borer', 'Brown Plant Hopper (BPH)', 'Leaf Folder'],
      'diseases': ['Blast', 'Bacterial Leaf Blight (BLB)', 'Sheath Blight'],
      'nutrients': 'Zinc deficiency (Khaira disease) is common; use Zinc Sulphate.',
      'water': 'Maintain 2-5 cm standing water during tillering to flowering.',
    },
    'Chilli': {
      'critical_stages': ['Vegetative', 'Flowering', 'Fruit Set', 'Fruit Ripening'],
      'pests': ['Thrips', 'Mites', 'Aphids'],
      'diseases': ['Dieback', 'Anthracnose', 'Leaf Curl Virus'],
      'nutrients': 'High requirement for Nitrogen and Potash; avoid excess water.',
      'water': 'Sensitive to waterlogging; flowering stage is most sensitive to drought.',
    },
    'Soyabean': {
      'critical_stages': ['Germination', 'Flowering', 'Pod Formation', 'Pod Filling'],
      'pests': ['Girdle Beetle', 'Semilooper', 'Tobacco Caterpillar'],
      'diseases': ['Yellow Mosaic Virus (YMV)', 'Root Rot', 'Rust'],
      'nutrients': 'Seed treatment with Rhizobium and PSB is essential for Nitrogen fixation.',
      'water': 'Needs consistent moisture during flowering and pod filling.',
    },
  };

  // ─── FEW-SHOT EXAMPLES ───
  static const List<Map<String, String>> fewShotExamples = [
    {
      'query': 'मेरे टमाटर के पत्तों पर पीले धब्बे दिख रहे हैं और वे सूख रहे हैं। क्या करूँ?',
      'response': '''यह **अगेती झुलसा (Early Blight)** के लक्षण हो सकते हैं। 
1. **जैविक उपचार**: नीम का तेल (5 मिली/लीटर) और बेकिंग सोडा (2 ग्राम/लीटर) का घोल बनाकर छिड़काव करें।
2. **रासायनिक उपचार**: **Mancozeb 75 WP (Dithane M-45)** 2.5 ग्राम प्रति लीटर पानी में मिलाकर छिड़काव करें।
⚠️ ध्यान दें: प्रभावित पत्तों को तोड़कर खेत से दूर नष्ट कर दें। शाम के समय छिड़काव करें।'''
    },
    {
      'query': 'How to increase wheat yield in late sowing?',
      'response': '''For late-sown **Wheat** (after Dec 15):
1. **Variety**: Use late-sowing varieties like PBW 373 or WH 1105.
2. **Seed Rate**: Increase seed rate by 25% (use 125-150 kg/acre).
3. **Spacing**: Reduce row spacing to 18 cm.
4. **Fertilizer**: Apply 25% more Phosphorus; use Zinc Sulphate (10kg/acre) for better tillering.
💧 Ensure the first irrigation at **21 days (CRI stage)** without fail.'''
    }
  ];

  // ─── GENERAL EXPERT GUIDELINES ───
  static const String expertGuidelines = '''
- If humidity is >80%, warn about fungal diseases like Downy Mildew or Blight.
- If temperature is >40°C, recommend early morning/late evening irrigation and warn against daytime spraying.
- Always recommend Soil Testing before suggesting high doses of DAP/Urea.
- Promote Integrated Pest Management (IPM): Pheromone traps, Sticky traps, and Beneficial insects.
- Units used should be local: Acre (एकड़), Bigha (बीघा - specify state), Quintal (क्विंटल), Pump (15 Liters).
''';

  static String getKnowledgeBrief(List<String> userCrops) {
    final buf = StringBuffer('FARMING EXPERT KNOWLEDGE:\n');
    for (var crop in userCrops) {
      final rules = cropExpertRules[crop];
      if (rules != null) {
        buf.writeln("- $crop: ${rules['nutrients']} Critical stages: ${(rules['critical_stages'] as List).join(', ')}.");
      }
    }
    buf.writeln('\nGUIDELINES: $expertGuidelines');
    return buf.toString();
  }

  static String getFewShotContext() {
    return fewShotExamples.map((ex) => "User: ${ex['query']}\nKrushi Mitra: ${ex['response']}").join('\n\n');
  }

  // ─── OFFLINE INTELLIGENCE ENGINE ───
  static String getOfflineAdvice(String query, List<String> crops, String location) {
    final lowerQuery = query.toLowerCase();
    
    // 1. Check for specific terms (Glossary)
    if (lowerQuery.contains('urea')) {
      return "🧪 **Offline Advisor: Urea**\n\nUrea is a Nitrogen-rich fertilizer (46% N). It promotes green vegetative growth.\n\n**Usage**: Best applied as a top-dressing. Avoid applying on dry soil; always irrigate after application for best results.";
    }
    if (lowerQuery.contains('dap')) {
      return "🧪 **Offline Advisor: DAP**\n\nDiammonium Phosphate (DAP) provides Nitrogen (18%) and Phosphorus (46%).\n\n**Usage**: Essential for root development. Best applied at the time of sowing (basal dose).";
    }
    if (lowerQuery.contains('npk')) {
      return "🧪 **Offline Advisor: NPK**\n\nNPK contains Nitrogen (growth), Phosphorus (roots), and Potassium (strength/yield).\n\n**Tip**: Use NPK 19:19:19 for general growth and 0:0:50 (SOP) during grain/fruit filling.";
    }
    if (lowerQuery.contains('price') || lowerQuery.contains('market') || lowerQuery.contains('mandi')) {
      return "💰 **Offline Advisor: Market**\n\nI can't fetch LIVE prices right now, but generally, Mandi prices for $location follow seasonal trends. Check the 'Market Prices' section in the app to see the last cached data.";
    }
    if (lowerQuery.contains('soil')) {
      return "🌱 **Offline Advisor: Soil Health**\n\nHealthy soil is the foundation of farming. \n\n**Advice**: Conduct a soil test every 2 years. Use organic manure (FYM) to improve soil structure and water retention.";
    }

    // 2. Crop-specific logic
    String? detectedCrop;
    for (var crop in crops) {
      if (lowerQuery.contains(crop.toLowerCase())) {
        detectedCrop = crop;
        break;
      }
    }
    
    detectedCrop ??= crops.isNotEmpty ? crops.first : 'General Farming';
    final rules = cropExpertRules[detectedCrop];

    if (rules != null) {
      if (lowerQuery.contains('pests') || lowerQuery.contains('insect') || lowerQuery.contains('keeda')) {
        return "🛠️ **Offline Advisor ($detectedCrop)**\n\nCommon pests: ${(rules['pests'] as List).join(', ')}.\n\n**Organic Control**: Use 5ml Neem Oil per liter of water.\n**Note**: AI analysis is offline. Please try again later for image-based diagnosis.";
      }
      if (lowerQuery.contains('disease') || lowerQuery.contains('problem') || lowerQuery.contains('illness')) {
        return "🛠️ **Offline Advisor ($detectedCrop)**\n\nCommon diseases: ${(rules['diseases'] as List).join(', ')}.\n\n**Advice**: Avoid waterlogging and ensure proper spacing. Remove and burn infected plants.\n**Note**: Operating in low-data mode.";
      }
      if (lowerQuery.contains('water') || lowerQuery.contains('irrigation')) {
        return "🛠️ **Offline Advisor ($detectedCrop)**\n\n**Watering Advice**: ${rules['water']}\n\n**Critical Stages**: ${(rules['critical_stages'] as List).join(', ')}.";
      }
      if (lowerQuery.contains('nutrient') || lowerQuery.contains('fertilizer') || lowerQuery.contains('khat')) {
        return "🛠️ **Offline Advisor ($detectedCrop)**\n\n**Nutrient Advice**: ${rules['nutrients']}\n\n**Tip**: Always apply fertilizers based on crop stage.";
      }
      
      return "🛠️ **Offline Advisor ($detectedCrop)**\n\n**Quick Insights**:\n- **Nutrients**: ${rules['nutrients']}\n- **Watering**: ${rules['water']}\n- **Critical Stages**: ${(rules['critical_stages'] as List).join(', ')}\n\nI am using my internal expert database. Please check your internet for full AI Assistant capabilities.";
    }

    return "🛠️ **Offline Advisor**\n\nI'm currently in low-data mode. For $location, ensure you are following the seasonal crop calendar. \n\n**General Tip**: Use yellow sticky traps for monitoring pests and ensure your soil has enough organic matter. \n\nPlease check your internet connection to enable full AI responses.";
  }
}
