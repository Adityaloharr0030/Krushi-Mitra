const functions = require("firebase-functions");
const axios = require("axios");

// This function acts as a secure proxy to the Anthropic Claude API.
// IMPORTANT: Set your Anthropic API key in Firebase environment config:
// firebase functions:config:set anthropic.key="YOUR_API_KEY"

exports.askKrushiMitra = functions.https.onCall(async (data, context) => {
    // 1. Validate request
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'You must be logged in to use the AI Doctor.'
        );
    }

    const { text, language, image_base64, crop } = data;

    if (!text && !image_base64) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Must provide either text or image query.'
        );
    }

    // 2. Fetch API Key from environment
    const apiKey = functions.config().anthropic.key;
    if (!apiKey) {
        throw new functions.https.HttpsError(
            'internal',
            'API key not configured.'
        );
    }

    // 3. Construct System Prompt
    const systemPrompt = `You are Krushi Mitra, a friendly and knowledgeable agricultural assistant for Indian farmers. You speak in simple, respectful language. You are expert in:
- All Indian crops (wheat, rice, sugarcane, cotton, vegetables, fruits, pulses)
- Crop diseases and pest management
- Government agriculture schemes and subsidies
- Organic and chemical farming methods
- Soil health and irrigation
- Market and selling advice
Always respond in ${language || "English"}. Use bullet points and short sentences. Avoid technical jargon. When diagnosing from a photo, be specific but honest about uncertainty. Always end with one encouraging line for the farmer.
${crop ? `The farmer is asking about their ${crop} crop.` : ""}`;

    // 4. Construct Message Payload
    let content = [];
    
    if (image_base64) {
        content.push({
            type: "image",
            source: {
                type: "base64",
                media_type: "image/jpeg", // Assuming flutter compresses to JPEG
                data: image_base64,
            }
        });
    }

    if (text) {
        content.push({
            type: "text",
            text: text
        });
    }

    try {
        // 5. Call Anthropic API
        const response = await axios.post('https://api.anthropic.com/v1/messages', {
            model: 'claude-3-5-sonnet-20241022',
            max_tokens: 1024,
            system: systemPrompt,
            messages: [
                {
                    role: 'user',
                    content: content
                }
            ]
        }, {
            headers: {
                'x-api-key': apiKey,
                'anthropic-version': '2023-06-01',
                'content-type': 'application/json'
            }
        });

        // 6. Return response to Flutter client
        return {
            response: response.data.content[0].text,
        };

    } catch (error) {
        console.error("Claude API Error:", error.response ? error.response.data : error.message);
        throw new functions.https.HttpsError(
            'internal',
            'Failed to get a response from the AI Doctor. Please try again later.'
        );
    }
});
