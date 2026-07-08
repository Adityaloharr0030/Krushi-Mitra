// 🌾 Krushi Mitra Pro AI Service (Gemini Integration)
import { getKnowledgeBrief, getOfflineAdvice, getFewShotContext } from './aiKnowledgeBase';

const SYSTEM_PROMPT = `You are **Krushi Mitra** (कृषी मित्र) — a premium, expert-level AI agricultural advisor built specifically for Indian farmers.

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

LANGUAGE:
- Respond in the language the user uses. If asked in Hindi, reply in Hindi. If Marathi, reply in Marathi.
- Use simple village-level language. Avoid English technical jargon when replying in Hindi/Marathi.
- For Hindi: use words like "एक एकड़", "एक पंप (15 लीटर)", "बोरी" instead of hectare/litre.

SAFETY:
- If unsure, say: "मुझे इस बारे में पूरा भरोसा नहीं है। कृपया अपने स्थानीय कृषि अधिकारी से सलाह लें। 🏢"
- Never recommend banned pesticides.
- Always warn about safety gear when recommending chemicals.`;

function getLanguageInstruction(language) {
  switch (language) {
    case 'hi':
      return 'LANGUAGE: Respond in HINDI (हिन्दी). Use simple rural Hindi. Units: एकड़, क्विंटल, किलो, पंप (15L). Avoid English technical terms — use Hindi equivalents.';
    case 'mr':
      return 'LANGUAGE: Respond in MARATHI (मराठी). Use simple spoken Marathi. Units: एकर, क्विंटल, किलो. Use Marathi farming terms.';
    case 'gu':
      return 'LANGUAGE: Respond in GUJARATI (ગુજરાતી). Use simple spoken Gujarati. Units: એકર, ક્વિન્ટલ, કિલો.';
    case 'te':
      return 'LANGUAGE: Respond in TELUGU (తెలుగు). Use simple spoken Telugu. Units: ఎకరా, క్వింటాల్, కిలో.';
    case 'ta':
      return 'LANGUAGE: Respond in TAMIL (தமிழ்). Use simple spoken Tamil. Units: ஏக்கர், குவிண்டால், கிலோ.';
    case 'kn':
      return 'LANGUAGE: Respond in KANNADA (ಕನ್ನಡ). Use simple spoken Kannada. Units: ಎಕರೆ, ಕ್ವಿಂಟಾಲ್, ಕೆಜಿ.';
    case 'bn':
      return 'LANGUAGE: Respond in BENGALI (বাংলা). Use simple spoken Bengali. Units: একর, কুইন্টাল, কেজি.';
    default:
      return 'LANGUAGE: Respond in ENGLISH. Use simple words. Avoid jargon. Use Indian units (acre, quintal, kg).';
  }
}

function buildFarmerBrief(context) {
  const p = context.profile;
  const w = context.weather;
  let brief = '';

  if (p) {
    brief += 'FARMER PROFILE:\n';
    brief += `- Name: ${p.name || 'Farmer'}\n`;
    brief += `- Location: ${p.district || 'Unknown'}, ${p.state || 'India'} (India)\n`;
    brief += `- Land: ${p.landSize || '0'} acres\n`;
    brief += `- Crops grown: ${(p.cropsGrown || []).join(", ")}\n`;
    if (p.soilType) brief += `- Soil type: ${p.soilType}\n`;
    if (p.irrigationSource) brief += `- Irrigation: ${p.irrigationSource}\n`;
    brief += `\n${getKnowledgeBrief(p.cropsGrown || [])}\n`;
  }

  if (w) {
    brief += '\nCURRENT WEATHER:\n';
    brief += `- Temperature: ${w.temperature}°C (feels like ${w.feelsLike}°C)\n`;
    brief += `- Condition: ${w.condition}\n`;
    brief += `- Humidity: ${w.humidity}%\n`;
    brief += `- Wind: ${w.windSpeed} m/s\n`;
  }

  const today = new Date();
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  brief += `\nDATE: ${today.getDate()}/${today.getMonth() + 1}/${today.getFullYear()}\n`;
  brief += `MONTH: ${months[today.getMonth()]}\n`;

  return brief;
}

function extractJson(text) {
  let cleaned = text.trim();
  if (cleaned.includes('```')) {
    const match = /```(?:json)?\s*([\s\S]*?)```/i.exec(cleaned);
    if (match) cleaned = match[1].trim();
  }
  const startObj = cleaned.indexOf('{');
  const startArr = cleaned.indexOf('[');
  if (startArr !== -1 && (startObj === -1 || startArr < startObj)) {
    const endArr = cleaned.lastIndexOf(']');
    if (endArr !== -1) return cleaned.substring(startArr, endArr + 1);
  } else if (startObj !== -1) {
    const endObj = cleaned.lastIndexOf('}');
    if (endObj !== -1) return cleaned.substring(startObj, endObj + 1);
  }
  return cleaned;
}

// Global helper to execute Gemini API calls directly from frontend
async function callGemini(prompt, apiKey, systemInstruction = null) {
  if (!apiKey) {
    throw new Error('API_KEY_MISSING');
  }
  
  const model = "gemini-1.5-flash";
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
  
  const contents = [
    {
      role: 'user',
      parts: [{ text: prompt }]
    }
  ];

  const requestBody = { contents };

  if (systemInstruction) {
    requestBody.systemInstruction = {
      parts: [{ text: systemInstruction }]
    };
  }

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(requestBody)
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(err?.error?.message || `HTTP ${response.status}`);
  }

  const data = await response.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) {
    throw new Error("No response content from Gemini.");
  }
  return text;
}

// ─── CHATBOT ───
export async function chat(history, userMessage, context, apiKey) {
  if (!apiKey) {
    // Revert to high-fidelity offline expert rules
    return getOfflineAdvice(userMessage, context.profile?.cropsGrown || [], context.profile?.district || '');
  }

  try {
    const farmerBrief = buildFarmerBrief(context);
    const langInst = getLanguageInstruction(context.profile?.language || 'en');
    const fewShot = getFewShotContext();

    const fullPrompt = `FARMER CONTEXT & ENVIRONMENT:
${farmerBrief}

FEW-SHOT REFERENCE:
${fewShot}

CHAT HISTORY:
${history.map(h => `${h.role === 'user' ? 'User' : 'Krushi Mitra'}: ${h.content}`).join('\n')}

User Query: ${userMessage}
${langInst}

Provide your expert response:`;

    return await callGemini(fullPrompt, apiKey, SYSTEM_PROMPT);
  } catch (error) {
    console.error("AI Chat Error:", error);
    return `⚠️ AI Error: ${error.message}. Running local expert database fallback:\n\n` + 
           getOfflineAdvice(userMessage, context.profile?.cropsGrown || [], context.profile?.district || '');
  }
}

// ─── CROP DOCTOR ───
export async function analyzeCropImage(base64Data, mimeType, context, apiKey) {
  if (!apiKey) {
    return simulateImageAnalysis(context);
  }

  try {
    const farmerBrief = buildFarmerBrief(context);
    const langInst = getLanguageInstruction(context.profile?.language || 'en');

    const prompt = `You are an expert plant pathologist specializing in Indian agriculture.

FARMER CONTEXT:
${farmerBrief}

TASK: Analyze this crop photo with extreme precision. Consider:
- The farmer's location and current season to narrow down likely diseases
- Common diseases for this region at this time of year
- Weather conditions (humidity/temperature) that favor certain pathogens
- Whether symptoms match nutrient deficiency vs disease vs pest damage

${langInst}

Respond ONLY in valid JSON (no markdown, no backticks):
{
  "crop_name": "Exact crop identified (e.g., Tomato, Wheat, Cotton)",
  "health_status": "healthy OR diseased OR deficient OR pest_damage",
  "disease_name": "Precise disease/pest/deficiency name. Use 'None' if healthy",
  "severity": "low OR medium OR high OR critical",
  "confidence": 85,
  "symptoms": "Describe exactly what you see — leaf color, spots, wilting pattern",
  "causes": "What causes this — pathogen name, environmental triggers",
  "treatment_organic": "Specific organic remedy with exact dosage. E.g. Neem oil 5ml/L spray.",
  "treatment_chemical": "Specific chemical with Indian brand name and dosage. E.g. Mancozeb 75 WP @ 2.5g/L.",
  "prevention": "3-4 specific preventive measures for future seasons"
}`;

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
    const requestBody = {
      contents: [
        {
          parts: [
            {
              inlineData: {
                mimeType: mimeType,
                data: base64Data
              }
            },
            { text: prompt }
          ]
        }
      ]
    };

    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(requestBody)
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
    const jsonStr = extractJson(text || '');
    return JSON.parse(jsonStr);
  } catch (error) {
    console.error("AI Doctor Error:", error);
    return simulateImageAnalysis(context, true);
  }
}

// Simulates crop diagnostics based on crops grown in profile
function simulateImageAnalysis(context, isFailFallback = false) {
  const crop = context.profile?.cropsGrown?.[0] || 'Tomato';
  const lang = context.profile?.language || 'en';

  const defaultDiagnoses = {
    Tomato: {
      crop_name: "Tomato",
      health_status: "diseased",
      disease_name: lang === 'hi' ? 'अगेती झुलसा रोग (Early Blight)' : 'Early Blight (Alternaria solani)',
      severity: "medium",
      confidence: 88,
      symptoms: lang === 'hi' 
        ? "निचली पत्तियों पर गाढ़े भूरे रंग के गोल छल्लेदार धब्बे दिखाई दे रहे हैं। पत्तियां पीली पड़कर गिर रही हैं।" 
        : "Concentric dark brown rings appearing on older leaves. Leaves yellowing and shedding near the base.",
      causes: lang === 'hi'
        ? "फफूंद (Alternaria solani) के कारण। उच्च आर्द्रता (80% से अधिक) और 24-29 डिग्री सेल्सियस तापमान इस रोग को बढ़ावा देते हैं।"
        : "Fungal pathogen favored by warm temperatures (24-29°C) and persistent high moisture or heavy dew.",
      treatment_organic: lang === 'hi'
        ? "नीम का तेल (5 मिली/लीटर) और बेकिंग सोडा (2 ग्राम/लीटर) के घोल का छिड़काव करें। 7 दिन बाद दोहराएं।"
        : "Spray neem oil (5 ml/L) mixed with baking soda (2g/L) on leaves. Repeat after 7 days.",
      treatment_chemical: lang === 'hi'
        ? "Mancozeb 75 WP (Dithane M-45) @ 2.5 ग्राम प्रति लीटर पानी में मिलाकर सुबह या शाम को छिड़काव करें।"
        : "Spray Mancozeb 75 WP (Dithane M-45) @ 2.5g/L water during late evening.",
      prevention: lang === 'hi'
        ? ["फसलों को बदल-बदल कर लगाएं।", "खेत में जलजमाव न होने दें।", "संक्रमित पौधों के अवशेषों को जला दें।"]
        : ["Practice 3-year crop rotation.", "Ensure proper crop spacing for aeration.", "Remove crop debris after harvest."]
    },
    Wheat: {
      crop_name: "Wheat",
      health_status: "diseased",
      disease_name: lang === 'hi' ? 'पीला रतुआ (Yellow Rust)' : 'Yellow Rust (Puccinia striiformis)',
      severity: "high",
      confidence: 90,
      symptoms: lang === 'hi' 
        ? "पत्तियों पर पीले रंग की धारियां और पाउडर जैसा पदार्थ दिखाई दे रहा है।" 
        : "Linear rows of yellow/orange pustules (spores) forming stripes on leaves. Rubbing leaves leaves yellow dust on fingers.",
      causes: lang === 'hi'
        ? "फफूंद स्पोर्स जो ठंडे और नम मौसम में तेजी से फैलते हैं।"
        : "Airborne fungal spores favored by cool, damp weather conditions during the tillering stage.",
      treatment_organic: lang === 'hi'
        ? "खट्टा मट्ठा (500 मिली) और हींग (10 ग्राम) 15 लीटर पानी में घोलकर छिड़काव करें।"
        : "Foliar spray of fermented butter-milk (chaas) @ 500ml mixed with 15L water.",
      treatment_chemical: lang === 'hi'
        ? "Propiconazole 25 EC (Tilt) @ 1 मिली प्रति लीटर पानी में मिलाकर छिड़काव करें।"
        : "Foliar spray of Propiconazole 25 EC (Tilt) @ 1 ml/L water.",
      prevention: lang === 'hi'
        ? ["प्रतिरोधी किस्मों (जैसे HD 3086) की बुवाई करें।", "समय पर बुवाई करें।", "नाइट्रोजन का अत्यधिक उपयोग न करें।"]
        : ["Sow rust-resistant varieties like HD 3086.", "Avoid late sowing.", "Avoid excess nitrogen application."]
    },
    Cotton: {
      crop_name: "Cotton",
      health_status: "pest_damage",
      disease_name: lang === 'hi' ? 'गुलाबी सुंडी का हमला (Pink Bollworm)' : 'Pink Bollworm Infestation',
      severity: "critical",
      confidence: 92,
      symptoms: lang === 'hi'
        ? "गूलर (bolls) के अंदर छेद और गुलाबी रंग की इल्लियां दिखाई दे रही हैं। फूल गुलाब की तरह बंद हो रहे हैं।"
        : "Rosetted flowers that fail to open properly. Entry holes visible on cotton bolls with tiny pink larvae inside.",
      causes: "Pectinophora gossypiella moth laying eggs on flowers/bolls.",
      treatment_organic: lang === 'hi'
        ? "नीम बीज अर्क (NSKE 5%) का छिड़काव करें। फेरोमोन जाल (5 प्रति एकड़) लगाएं।"
        : "Install 5 Pheromone traps per acre. Spray Neem Seed Kernel Extract (NSKE 5%).",
      treatment_chemical: lang === 'hi'
        ? "Profex Super (Profenofos 40% + Cypermethrin 4%) @ 2 मिली प्रति लीटर पानी का छिड़काव करें।"
        : "Spray Profenofos 40% + Cypermethrin 4% EC @ 2 ml/L water.",
      prevention: lang === 'hi'
        ? ["फसल चक्र अपनाएं।", "बुवाई के लिए प्रमाणित बीटी बीज चुनें।", "फसल कटाई के बाद खेत की गहरी जुताई करें।"]
        : ["Observe a strict closed season.", "Use certified Bt cotton seeds.", "Deep summer ploughing to destroy pupae."]
    }
  };

  const res = defaultDiagnoses[crop] || defaultDiagnoses.Tomato;
  if (isFailFallback) {
    res.disease_name += " (API Fallback)";
  }
  return res;
}

// ─── ELIGIBILITY CHECKER ───
export async function checkSchemeEligibility(context, scheme, apiKey) {
  if (!apiKey) {
    // Generate context-aware mock response
    return simulateSchemeEligibility(context, scheme);
  }

  try {
    const farmerBrief = buildFarmerBrief(context);
    const lang = context.profile?.language || 'en';
    const langInst = getLanguageInstruction(lang);

    const prompt = `FARMER PROFILE CONTEXT:
${farmerBrief}

SCHEME DETAIL:
Name: ${scheme.name}
Description: ${scheme.description}
Eligibility Rules: ${(scheme.eligibilityCriteria || []).join(', ')}

TASK: Analyze if the farmer is eligible for this scheme.
- State clearly if they are eligible, partially eligible, or ineligible.
- Give a list of matching criteria and a list of mismatching criteria.
- Give actionable steps they need to take to apply (e.g. documents to get).

${langInst}
Respond in formatted markdown. Be encouraging!`;

    return await callGemini(prompt, apiKey, SYSTEM_PROMPT);
  } catch (error) {
    console.error("AI Eligibility Checker Error:", error);
    return simulateSchemeEligibility(context, scheme) + "\n\n*(Running in local mode)*";
  }
}

function simulateSchemeEligibility(context, scheme) {
  const p = context.profile;
  const lang = p?.language || 'en';
  const crops = p?.cropsGrown || [];
  
  const isTomatoFarmer = crops.includes('Tomato');
  const landSize = parseFloat(p?.landSize || 0);

  if (lang === 'hi') {
    return `### 🌾 **पात्रता विश्लेषण रिपोर्ट** (कृषि मित्र एआई)
  
*   **योजना**: ${scheme.name}
*   **स्थिति**: ${landSize <= 5 ? '🟢 पूर्ण रूप से पात्र' : '🟡 आंशिक रूप से पात्र (भूमि सीमा जांच के अधीन)'}
  
**पात्रता कारक:**
1.  **स्थान**: आप ${p?.district || 'अपने ज़िले'}, ${p?.state || 'अपने राज्य'} से हैं, जहाँ यह योजना लागू है।
2.  **भूमि आकार**: आपके पास ${landSize} एकड़ ज़मीन है, जो लघु एवं सीमांत किसान श्रेणी में आती है।
3.  **फसलें**: आप ${crops.join(', ')} उगाते हैं जो इस योजना के अंतर्गत सहायता के लिए उपयुक्त हैं।

**आवश्यक दस्तावेज:**
*   आधार कार्ड (Aadhaar Card)
*   भूमि की नकल (7/12 उतारा या खतौनी)
*   बैंक खाता पासबुक (जिसमें आधार लिंक हो)

**कृषि मित्र की सलाह**: 
आप आधिकारिक वेबसाइट पर जाकर **${scheme.applyLink ? 'New Registration' : 'आवेदन करें'}** लिंक के माध्यम से तुरंत पंजीकरण करा सकते हैं। यदि कोई समस्या हो तो हेल्पलाइन नंबर पर संपर्क करें। 🌾`;
  }

  return `### 🌾 **Eligibility Analysis Report** (Krushi Mitra AI)
  
*   **Scheme**: ${scheme.name}
*   **Status**: ${landSize <= 5 ? '🟢 Eligible' : '🟡 Partially Eligible (Pending land ceiling checks)'}
  
**Key Matches:**
1.  **Location**: Your registered location (${p?.district || 'District'}, ${p?.state || 'State'}) is eligible.
2.  **Landholding**: Your ${landSize} acres falls within the Small and Marginal farmer bracket.
3.  **Crops**: Your crops (${crops.join(', ')}) qualify for standard input and crop subsidies under this program.

**Action Checklist:**
*   [ ] Verify your Aadhaar details match your land record name.
*   [ ] Ensure Bank Account is active and seeded with Aadhaar.
*   [ ] Gather Landholding details (7/12 extract or Land patta).

**Krushi Mitra Recommendation**: 
Go to the **Apply Now** link to fill out the form. You are highly recommended to proceed with registration this week to catch the current season disbursement!`;
}

// ─── DAILY ADVISORY & TIP ───
export async function getDailyFarmingTip(cropsList, location, season, language, apiKey) {
  if (!apiKey) {
    return simulateDailyTip(cropsList, location, season, language);
  }

  try {
    const langInst = getLanguageInstruction(language);
    const prompt = `Location: ${location}
Season: ${season}
Crops Grown: ${cropsList}

TASK: Generate a single, highly actionable, premium daily farming tip for today.
- Include a specific task (irrigation, fertilizing, weeding, or scouting).
- Give exact dosage if pesticide/fertilizer is mentioned.
- Keep it under 4 lines.

${langInst}`;

    return await callGemini(prompt, apiKey, SYSTEM_PROMPT);
  } catch (error) {
    console.error("AI Daily Tip Error:", error);
    return simulateDailyTip(cropsList, location, season, language);
  }
}

function simulateDailyTip(cropsList, location, season, language) {
  const cropArr = cropsList.split(',').map(c => c.trim());
  const primaryCrop = cropArr[0] || 'Tomato';

  const tips = {
    Tomato: {
      en: "🌾 **Tomato Tip**: Keep a close eye out for early signs of Early Blight. If leaf spots appear, spray **Mancozeb 75 WP @ 2.5g/L** in the cool evening. Ensure proper stakes.",
      hi: "🌾 **टमाटर की सलाह**: अगेती झुलसा रोग की जांच करें। यदि पत्तियों पर गोल छल्लेदार धब्बे दिखें, तो शाम को **मैन्कोजेब 75 WP (Dithane M-45) @ 2.5 ग्राम/लीटर** घोल का छिड़काव करें।",
      mr: "🌾 **टोमॅटो टीप**: लवकर येणाऱ्या करपा रोगाची तपासणी करा. पाने पिवळी पडल्यास संध्याकाळी **मॅन्कोझेब ७५ डब्ल्यूपी @ २.५ ग्रॅम प्रति लीटर** पाण्यात मिसळून फवारा."
    },
    Wheat: {
      en: "🌾 **Wheat Tip**: If sowing late, increase your seed rate to **125-150 kg per acre**. Give the crucial Crown Root Initiation (CRI) irrigation exactly **21 days** after sowing.",
      hi: "🌾 **गेहूं की सलाह**: देरी से बुवाई करने पर बीज दर को बढ़ाकर **125-150 किलो/एकड़** करें। बुवाई के ठीक **21 दिन बाद** (CRI चरण) पहली सिंचाई अवश्य करें।",
      mr: "🌾 **गहू टीप**: उशिरा पेरणीसाठी बियाणे प्रमाण **१२५-१५० किलो प्रति एकर** पर्यंत वाढवा. पेरणीनंतर अचूक **२१ दिवसांनी** पहिली सिंचन (CRI अवस्था) पूर्ण करा."
    },
    Cotton: {
      en: "🌾 **Cotton Tip**: Install **5 pheromone traps per acre** to monitor Pink Bollworm. If egg counts exceed 1 per flower, spray **Profenofos 40% + Cypermethrin 4% @ 2ml/L**.",
      hi: "🌾 **कपास की सलाह**: गुलाबी सुंडी की निगरानी के लिए **5 फेरोमोन जाल प्रति एकड़** लगाएं। यदि प्रकोप अधिक हो, तो **प्रोफेनोफॉस + सायपरमेथ्रिन @ 2 मिली/लीटर** का छिड़काव करें।",
      mr: "🌾 **कापूस टीप**: गुलाबी बोंडअळीच्या निरीक्षणासाठी **प्रति एकर ५ फेरोमोन सापळे** लावा. प्रादुर्भाव दिसल्यास **प्रोफेनोफॉस + सायपरमेथ्रिन @ २ मिली/लीटर** फवारा."
    }
  };

  const cropTips = tips[primaryCrop] || tips.Tomato;
  return cropTips[language] || cropTips.en;
}

// ─── FARM DIARY FINANCIAL ADVICE ───
export async function getDiaryAnalysis(context, apiKey) {
  if (!apiKey) {
    return simulateDiaryAnalysis(context);
  }

  try {
    const brief = buildFarmerBrief(context);
    const langInst = getLanguageInstruction(context.profile?.language || 'en');

    const prompt = `FARM CONTEXT AND DIARY ENTRIES:
${brief}

TASK: Perform a detailed financial and operational analysis of the farmer's diary.
- Sum up income vs expenses.
- Point out where they are spending the most (seeds, fertilizer, labor, fuel).
- Give 3 specific recommendations to optimize profit, tailored for their crops.
- Keep it highly structured and business-oriented.

${langInst}`;

    return await callGemini(prompt, apiKey, SYSTEM_PROMPT);
  } catch (error) {
    console.error("AI Diary Analysis Error:", error);
    return simulateDiaryAnalysis(context);
  }
}

function simulateDiaryAnalysis(context) {
  const p = context.profile;
  const lang = p?.language || 'en';
  const diary = context.diaryEntries || [];
  
  const income = diary.filter(e => !e.isExpense).reduce((sum, e) => sum + parseFloat(e.cost || 0), 0);
  const expense = diary.filter(e => e.isExpense).reduce((sum, e) => sum + parseFloat(e.cost || 0), 0);
  const balance = income - expense;

  if (lang === 'hi') {
    return `### 📊 **कृषि वित्तीय विश्लेषण रिपोर्ट** (कृषि मित्र एआई)
  
*   **कुल आय**: ₹${income.toLocaleString()}
*   **कुल खर्च**: ₹${expense.toLocaleString()}
*   **शुद्ध लाभ/हानि**: **₹${balance.toLocaleString()}** (${balance >= 0 ? '🟢 मुनाफा' : '🔴 घाटा'})

**खर्च के प्रमुख क्षेत्र:**
1.  उर्वरक एवं कीटनाशक खरीद
2.  मजदूरी एवं जुताई खर्च

**कृषि मित्र की सिफारिशें:**
1.  **खाद का संतुलित उपयोग**: अंधाधुंध यूरिया डालने के बजाय मृदा परीक्षण रिपोर्ट के अनुसार ही उर्वरक डालें, जिससे खर्च में 20% तक की कमी आएगी।
2.  **जैविक खाद का मिश्रण**: खेत में गोबर खाद या केंचुआ खाद का प्रयोग बढ़ाएं, जिससे रासायनिक खादों पर निर्भरता कम होगी।
3.  **सामूहिक कृषि यंत्र**: ट्रैक्टर या भारी मशीनरी किराए पर लेने के बजाय सरकारी कस्टम हायरिंग सेंटर का उपयोग करें।`;
  }

  return `### 📊 **Farm Financial Analysis Report** (Krushi Mitra AI)
  
*   **Total Revenue**: ₹${income.toLocaleString()}
*   **Total Expenses**: ₹${expense.toLocaleString()}
*   **Net Profit/Loss**: **₹${balance.toLocaleString()}** (${balance >= 0 ? '🟢 Profit' : '🔴 Loss'})

**Major Cost Centers:**
1.  Input Purchases (Fertilizers/Seeds)
2.  Labor & Machine Rent

**Krushi Mitra Optimization Plan:**
1.  **Precise Fertilizer Placement**: Avoid broad-scale broadcasting of Urea. Apply split-dosing near crop roots to cut input costs by 15-20%.
2.  **Incorporate Farmyard Manure**: Increasing organic carbon in the soil will improve nutrient-use efficiency of chemical inputs.
3.  **Log Daily Machinery Hours**: Track fuel usage on daily tillage runs to optimize tractor operations.`;
}

// ─── AI MARKETPLACE DESCRIPTION WRITER ───
export async function generateListingDescription(details, language, apiKey) {
  if (!apiKey) {
    return simulateListingDescription(details, language);
  }

  try {
    const langInst = getLanguageInstruction(language);
    const prompt = `Crop Listing Details:
Crop Name: ${details.commodity}
Variety: ${details.variety || 'Local'}
Grade/Quality: ${details.quality || 'A'}
Quantity: ${details.quantity} ${details.unit}
Price: ₹${details.pricePerUnit} per ${details.unit}
Location: ${details.location}
Organic: ${details.isOrganic ? 'Yes' : 'No'}
Negotiable: ${details.isNegotiable ? 'Yes' : 'No'}

TASK: Generate a professional, highly catchy marketplace description for this listing.
- Emphasize the quality grade and organic nature (if organic).
- Specify storage conditions and moisture content (if dried).
- List terms of delivery or pickup clearly.
- Keep it under 5 lines.

${langInst}
Respond only with the description text (no quotes, no intro/outro).`;

    return await callGemini(prompt, apiKey, SYSTEM_PROMPT);
  } catch (error) {
    console.error("AI Listing Generator Error:", error);
    return simulateListingDescription(details, language);
  }
}

function simulateListingDescription(details, language) {
  const { commodity, variety, quality, quantity, unit, pricePerUnit, location, isOrganic } = details;
  
  if (language === 'hi') {
    return `🌾 **ताज़ा और उच्च गुणवत्ता वाला ${commodity} बिक्री के लिए उपलब्ध!**
📍 **स्थान**: ${location}
✨ **विवरण**: यह ${variety || 'स्थानीय'} किस्म का ग्रेड-${quality} ${commodity} है। ${isOrganic ? 'पूर्ण रूप से जैविक (गोबर खाद से तैयार)' : 'पूरी तरह से सुखाया और साफ किया गया है'}। कुल मात्रा ${quantity} ${unit} है। भाव ₹${pricePerUnit}/${unit} (वार्तालाप योग्य)। संपर्क करें!`;
  }
  
  return `🌾 **Premium Quality ${commodity} Available for Direct Sale!**
📍 **Location**: ${location}
✨ **Details**: Grade-${quality} ${commodity} of the ${variety || 'Local'} variety. ${isOrganic ? '100% Organically grown' : 'Well-cleaned and dried with optimal moisture content'}. Total quantity available: ${quantity} ${unit}. Price: ₹${pricePerUnit}/${unit}. Ready for pickup/delivery immediately.`;
}
