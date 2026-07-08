// 📈 Krushi Mitra Pro Market Prices Service

const STATES = [
  'Maharashtra', 'Uttar Pradesh', 'Madhya Pradesh', 'Punjab', 'Rajasthan',
  'Gujarat', 'Karnataka', 'Andhra Pradesh', 'Tamil Nadu', 'Haryana',
];

const DISTRICTS_BY_STATE = {
  'Maharashtra': ['Pune', 'Nashik', 'Aurangabad', 'Latur', 'Amravati', 'Nagpur', 'Kolhapur', 'Satara', 'Solapur'],
  'Uttar Pradesh': ['Lucknow', 'Agra', 'Varanasi', 'Kanpur', 'Meerut', 'Allahabad'],
  'Punjab': ['Amritsar', 'Ludhiana', 'Patiala', 'Jalandhar', 'Bathinda'],
  'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Ujjain', 'Sagar'],
  'Rajasthan': ['Jaipur', 'Jodhpur', 'Kota', 'Udaipur', 'Bikaner'],
  'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar'],
};

// Realistic Mandi Price templates (Kharif/Rabi seasons)
function getOfflineMarketData(state = 'Maharashtra', commodity = '') {
  const today = new Date();
  const dateStr = `${String(today.getDate()).padStart(2, '0')}/${String(today.getMonth() + 1).padStart(2, '0')}/${today.getFullYear()}`;
  
  const tempDate = new Date();
  tempDate.setDate(today.getDate() - 1);
  const yesterdayStr = `${String(tempDate.getDate()).padStart(2, '0')}/${String(tempDate.getMonth() + 1).padStart(2, '0')}/${tempDate.getFullYear()}`;

  const resolvedState = state || 'Maharashtra';

  const allPrices = [
    { commodity: 'Wheat', variety: 'Lokwan', state: resolvedState, district: 'Nashik', market: 'Lasalgaon', minPrice: 2275, maxPrice: 2700, modalPrice: 2500, date: dateStr },
    { commodity: 'Wheat', variety: 'Sharbati', state: resolvedState, district: 'Pune', market: 'Pune', minPrice: 2400, maxPrice: 2850, modalPrice: 2650, date: dateStr },
    { commodity: 'Onion', variety: 'Red', state: resolvedState, district: 'Nashik', market: 'Pimpalgaon', minPrice: 800, maxPrice: 1600, modalPrice: 1200, date: dateStr },
    { commodity: 'Onion', variety: 'White', state: resolvedState, district: 'Nashik', market: 'Lasalgaon', minPrice: 900, maxPrice: 1800, modalPrice: 1350, date: yesterdayStr },
    { commodity: 'Tomato', variety: 'Hybrid', state: resolvedState, district: 'Pune', market: 'Pune', minPrice: 1000, maxPrice: 2200, modalPrice: 1600, date: dateStr },
    { commodity: 'Tomato', variety: 'Local', state: resolvedState, district: 'Satara', market: 'Satara', minPrice: 800, maxPrice: 1800, modalPrice: 1300, date: yesterdayStr },
    { commodity: 'Cotton', variety: 'Medium Staple', state: resolvedState, district: 'Amravati', market: 'Amravati', minPrice: 6620, maxPrice: 7500, modalPrice: 7080, date: dateStr },
    { commodity: 'Soyabean', variety: 'Yellow', state: resolvedState, district: 'Latur', market: 'Latur', minPrice: 4200, maxPrice: 4800, modalPrice: 4550, date: dateStr },
    { commodity: 'Rice', variety: 'Basmati', state: resolvedState, district: 'Kolhapur', market: 'Kolhapur', minPrice: 3800, maxPrice: 4500, modalPrice: 4150, date: dateStr },
    { commodity: 'Gram', variety: 'Desi', state: resolvedState, district: 'Latur', market: 'Latur', minPrice: 5230, maxPrice: 5800, modalPrice: 5500, date: yesterdayStr },
    { commodity: 'Maize', variety: 'Yellow', state: resolvedState, district: 'Aurangabad', market: 'Aurangabad', minPrice: 1962, maxPrice: 2300, modalPrice: 2120, date: dateStr },
    { commodity: 'Potato', variety: 'Jyoti', state: resolvedState, district: 'Pune', market: 'Pune', minPrice: 1200, maxPrice: 1800, modalPrice: 1500, date: dateStr },
    { commodity: 'Jowar', variety: 'Maldandi', state: resolvedState, district: 'Solapur', market: 'Solapur', minPrice: 3180, maxPrice: 3600, modalPrice: 3400, date: dateStr },
  ];

  if (commodity) {
    const term = commodity.toLowerCase();
    const filtered = allPrices.filter(p => p.commodity.toLowerCase().includes(term));
    return filtered.length > 0 ? filtered : allPrices.slice(0, 5);
  }

  return allPrices;
}

export function getPriceTrend(commodity) {
  const trends = {
    'Wheat':    [2420, 2450, 2480, 2465, 2500, 2510, 2500],
    'Onion':    [1350, 1280, 1200, 1150, 1180, 1220, 1200],
    'Tomato':   [1200, 1350, 1500, 1580, 1620, 1550, 1600],
    'Cotton':   [6950, 7000, 7050, 7020, 7080, 7100, 7080],
    'Soyabean': [4300, 4350, 4400, 4450, 4500, 4520, 4550],
    'Rice':     [3950, 4000, 4050, 4080, 4100, 4120, 4150],
    'Gram':     [5350, 5400, 5420, 5450, 5480, 5500, 5500],
    'Maize':    [2000, 2020, 2050, 2080, 2100, 2110, 2120],
    'Potato':   [1600, 1550, 1520, 1500, 1480, 1500, 1500],
    'Jowar':    [3200, 3250, 3300, 3350, 3380, 3400, 3400],
  };
  return trends[commodity] || [2200, 2230, 2260, 2280, 2300, 2310, 2300];
}

export async function fetchMarketPrices(state = 'Maharashtra', commodity = '', forceAI = false, apiKey = '') {
  if (forceAI && apiKey) {
    try {
      const today = new Date();
      const dateStr = `${String(today.getDate()).padStart(2, '0')}/${String(today.getMonth() + 1).padStart(2, '0')}/${today.getFullYear()}`;
      
      const prompt = `You are a real-time mandi prices data engine for Indian agriculture.
Current Date: ${dateStr}
State: ${state}
Target Commodity: ${commodity || 'All'}

TASK: Generate 8 highly realistic Mandi price entries for different markets/districts in ${state} for the crop ${commodity || 'Wheat'}. 
Ensure:
- The districts and markets are real, active locations in ${state}.
- The variety corresponds to real local varieties.
- The min, max, and modal prices are aligned with current Indian market prices and MSP rates.
- The prices should differ slightly from market to market. Modal price must be between min_price and max_price.

Respond ONLY with a valid JSON array of objects (no markdown, no backticks):
[
  {
    "commodity": "${commodity || 'Wheat'}",
    "variety": "Lokwan",
    "state": "${state}",
    "district": "District Name",
    "market": "Market Name",
    "min_price": 2400.0,
    "max_price": 2700.0,
    "modal_price": 2550.0,
    "arrival_date": "${dateStr}"
  }
]`;

      const model = "gemini-1.5-flash";
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
      });

      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
      
      let cleaned = text.trim();
      if (cleaned.includes('```')) {
        const match = /```(?:json)?\s*([\s\S]*?)```/i.exec(cleaned);
        if (match) cleaned = match[1].trim();
      }

      const list = JSON.parse(cleaned);
      return list.map(item => ({
        commodity: item.commodity,
        variety: item.variety,
        state: item.state,
        district: item.district,
        market: item.market,
        minPrice: parseFloat(item.min_price),
        maxPrice: parseFloat(item.max_price),
        modalPrice: parseFloat(item.modal_price),
        date: item.arrival_date
      }));
    } catch (e) {
      console.warn("AI prices generation failed, returning simulated dataset:", e);
      return getOfflineMarketData(state, commodity);
    }
  }

  // Local/Offline Mode
  return getOfflineMarketData(state, commodity);
}

export function getAvailableStates() {
  return STATES;
}

export function getDistricts(state) {
  return DISTRICTS_BY_STATE[state] || ['All Districts'];
}
