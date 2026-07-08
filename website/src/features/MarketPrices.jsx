// 📈 Krushi Mitra Pro — Market Mandi Prices
import React, { useState, useEffect } from 'react';
import { fetchMarketPrices, getPriceTrend, getAvailableStates } from '../services/market';
import { chat } from '../services/ai';
import { Search, MapPin, TrendingUp, TrendingDown, DollarSign, BarChart2, Sparkles, RefreshCw } from 'lucide-react';

export default function MarketPrices({ profile, apiKey }) {
  const [selectedState, setSelectedState] = useState(profile.state || 'Maharashtra');
  const [selectedCommodity, setSelectedCommodity] = useState(profile.cropsGrown?.[0] || 'Wheat');
  const [prices, setPrices] = useState([]);
  const [loading, setLoading] = useState(false);
  
  // AI analysis state
  const [aiAnalysis, setAiAnalysis] = useState('');
  const [loadingAI, setLoadingAI] = useState(false);

  const states = getAvailableStates();
  const commodities = ['Wheat', 'Onion', 'Tomato', 'Cotton', 'Soyabean', 'Rice', 'Gram', 'Maize', 'Potato', 'Jowar'];

  const loadPrices = async (stateVal, commodityVal) => {
    setLoading(true);
    setAiAnalysis('');
    try {
      const data = await fetchMarketPrices(stateVal, commodityVal, false, apiKey);
      setPrices(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPrices(selectedState, selectedCommodity);
  }, [selectedState, selectedCommodity]);

  // Generate price trend details
  const trendData = getPriceTrend(selectedCommodity);
  const maxTrendVal = Math.max(...trendData);
  const minTrendVal = Math.min(...trendData);
  const deltaVal = maxTrendVal - minTrendVal || 1;

  // AI market analysis advisor
  const handleMarketAnalysis = async () => {
    setLoadingAI(true);
    try {
      // Recreate custom market prompt
      const prompt = `FARM CONTEXT: State: ${selectedState}, Target: ${selectedCommodity}
RECENT PRICES IN MARKETS:
${prices.map(p => `- ${p.market} (${p.district}): ₹${p.modalPrice}/qtl`).join('\n')}

TASK: Provide a brief market forecast for ${selectedCommodity} in ${selectedState} for 2026.
- Should the farmer SELL now or HOLD their stock?
- Predict price movement in the next 15-30 days.
- Mention current MSP if known (e.g. Wheat MSP around ₹2275-2425/qtl).
- Keep it under 6 lines. Respond in ${profile.language === 'hi' ? 'Hindi' : 'English'}.`;

      const response = await chat([], prompt, { profile }, apiKey);
      setAiAnalysis(response);
    } catch (e) {
      setAiAnalysis("⚠️ Failed to generate AI analysis. Check your internet connection.");
    } finally {
      setLoadingAI(false);
    }
  };

  const getPriceDirection = () => {
    const len = trendData.length;
    if (len < 2) return true;
    return trendData[len - 1] >= trendData[len - 2];
  };

  const isUp = getPriceDirection();
  const lang = profile.language || 'hi';

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Header Info */}
      <div className="glass-panel" style={{ padding: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.4rem', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <BarChart2 style={{ color: 'var(--primary-emerald)' }} />
            {lang === 'hi' ? 'लाइव मंडी भाव' : lang === 'mr' ? 'थेट बाजार भाव' : 'Live Mandi Prices'}
          </h2>
          <p style={{ color: 'var(--text-secondary)' }}>
            {lang === 'hi' ? 'विभिन्न राज्यों और मंडियों के लिए कृषि उपज का लाइव रेट देखें' : lang === 'mr' ? 'विविध राज्यातील व बाजार समितीतील पिकांचे दर तपासा' : 'Track crop prices and market arrivals across Indian districts in real-time.'}
          </p>
        </div>
        <button onClick={() => loadPrices(selectedState, selectedCommodity)} className="btn-secondary" style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
          <RefreshCw size={14} /> {lang === 'hi' ? 'ताज़ा करें' : 'Refresh'}
        </button>
      </div>

      {/* Filters row */}
      <div className="glass-panel" style={{ padding: '20px', display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
        <div style={{ flex: 1, minWidth: '200px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
            {lang === 'hi' ? 'राज्य चुनें' : 'Select State'}
          </label>
          <select 
            value={selectedState} 
            onChange={(e) => setSelectedState(e.target.value)}
            className="form-input"
            style={{ padding: '10px 12px' }}
          >
            {states.map((st, i) => <option key={i} value={st}>{st}</option>)}
          </select>
        </div>
        <div style={{ flex: 1, minWidth: '200px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
            {lang === 'hi' ? 'फसल चुनें' : 'Select Commodity'}
          </label>
          <select 
            value={selectedCommodity} 
            onChange={(e) => setSelectedCommodity(e.target.value)}
            className="form-input"
            style={{ padding: '10px 12px' }}
          >
            {commodities.map((c, i) => <option key={i} value={c}>{c}</option>)}
          </select>
        </div>
      </div>

      {/* Main layout grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px' }}>
        
        {/* Mandi list */}
        <div className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <h3 style={{ fontSize: '1rem', borderBottom: '1px solid var(--border-outline)', paddingBottom: '10px' }}>
            📍 {selectedState} {lang === 'hi' ? 'की प्रमुख मंडियां' : 'Market Rates'}
          </h3>
          
          {loading ? (
            <div style={{ display: 'flex', justifyContent: 'center', padding: '40px' }}>
              <div style={{ width: '30px', height: '30px', border: '2px solid var(--border-outline)', borderTopColor: 'var(--primary-emerald)', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', maxHeight: '420px', overflowY: 'auto', paddingRight: '4px' }}>
              {prices.map((item, idx) => (
                <div 
                  key={idx} 
                  style={{ 
                    padding: '12px', 
                    background: 'rgba(255,255,255,0.01)', 
                    border: '1px solid var(--glass-border)', 
                    borderRadius: '8px',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}
                >
                  <div>
                    <h4 style={{ fontSize: '0.9rem', color: 'var(--text-primary)' }}>{item.market}</h4>
                    <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', gap: '4px', marginTop: '2px' }}>
                      <MapPin size={12} /> {item.district} | {item.variety}
                    </p>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <h4 style={{ fontSize: '1rem', color: 'var(--primary-emerald)', fontWeight: '600' }}>₹{item.modalPrice}/q</h4>
                    <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
                      ₹{item.minPrice} - ₹{item.maxPrice}
                    </p>
                  </div>
                </div>
              ))}
              {prices.length === 0 && (
                <p style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '20px' }}>
                  No active market entries found.
                </p>
              )}
            </div>
          )}
        </div>

        {/* Charts & AI advisor */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          
          {/* Visual SVG Trend line chart */}
          <div className="glass-panel" style={{ padding: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <div>
                <h4 style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
                  {lang === 'hi' ? '7-दिवसीय मूल्य प्रवृत्ति' : '7-Day Price Trend'}
                </h4>
                <h3 style={{ fontSize: '1.2rem', display: 'flex', alignItems: 'center', gap: '6px', marginTop: '2px' }}>
                  {selectedCommodity}
                  {isUp ? (
                    <span style={{ color: 'var(--success)', fontSize: '0.8rem', display: 'flex', alignItems: 'center', gap: '2px' }}>
                      <TrendingUp size={14} /> +{Math.round(((trendData[6] - trendData[0]) / trendData[0]) * 100)}%
                    </span>
                  ) : (
                    <span style={{ color: 'var(--error)', fontSize: '0.8rem', display: 'flex', alignItems: 'center', gap: '2px' }}>
                      <TrendingDown size={14} /> -{Math.round(((trendData[0] - trendData[6]) / trendData[0]) * 100)}%
                    </span>
                  )}
                </h3>
              </div>
              <div style={{ textAlign: 'right' }}>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Avg Modal Rate</span>
                <p style={{ fontSize: '1.1rem', fontWeight: '600', color: 'var(--primary-emerald)' }}>
                  ₹{trendData[trendData.length - 1]}/qtl
                </p>
              </div>
            </div>

            {/* Render clean glowing SVG line chart */}
            <div style={{ position: 'relative', height: '140px', width: '100%', margin: '10px 0' }}>
              <svg viewBox="0 0 700 140" style={{ width: '100%', height: '100%', overflow: 'visible' }}>
                <defs>
                  <linearGradient id="chartGlow" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--primary-emerald)" stopOpacity="0.4"/>
                    <stop offset="100%" stopColor="var(--primary-emerald)" stopOpacity="0.0"/>
                  </linearGradient>
                </defs>
                
                {/* SVG Grid lines */}
                <line x1="0" y1="10" x2="700" y2="10" stroke="var(--border-outline)" strokeOpacity="0.3" strokeDasharray="4 4" />
                <line x1="0" y1="70" x2="700" y2="70" stroke="var(--border-outline)" strokeOpacity="0.3" strokeDasharray="4 4" />
                <line x1="0" y1="130" x2="700" y2="130" stroke="var(--border-outline)" strokeOpacity="0.3" strokeDasharray="4 4" />

                {/* Draw Area path under line */}
                <path
                  d={`
                    M 0 140 
                    L 0 ${130 - ((trendData[0] - minTrendVal) / deltaVal) * 110} 
                    L 116 ${130 - ((trendData[1] - minTrendVal) / deltaVal) * 110} 
                    L 233 ${130 - ((trendData[2] - minTrendVal) / deltaVal) * 110} 
                    L 350 ${130 - ((trendData[3] - minTrendVal) / deltaVal) * 110} 
                    L 466 ${130 - ((trendData[4] - minTrendVal) / deltaVal) * 110} 
                    L 583 ${130 - ((trendData[5] - minTrendVal) / deltaVal) * 110} 
                    L 700 ${130 - ((trendData[6] - minTrendVal) / deltaVal) * 110} 
                    L 700 140 Z
                  `}
                  fill="url(#chartGlow)"
                />

                {/* Draw Main Path line */}
                <path
                  d={`
                    M 0 ${130 - ((trendData[0] - minTrendVal) / deltaVal) * 110}
                    C 58 ${130 - ((trendData[0] - minTrendVal) / deltaVal) * 110}, 58 ${130 - ((trendData[1] - minTrendVal) / deltaVal) * 110}, 116 ${130 - ((trendData[1] - minTrendVal) / deltaVal) * 110}
                    C 174 ${130 - ((trendData[1] - minTrendVal) / deltaVal) * 110}, 174 ${130 - ((trendData[2] - minTrendVal) / deltaVal) * 110}, 233 ${130 - ((trendData[2] - minTrendVal) / deltaVal) * 110}
                    C 291 ${130 - ((trendData[2] - minTrendVal) / deltaVal) * 110}, 291 ${130 - ((trendData[3] - minTrendVal) / deltaVal) * 110}, 350 ${130 - ((trendData[3] - minTrendVal) / deltaVal) * 110}
                    C 408 ${130 - ((trendData[3] - minTrendVal) / deltaVal) * 110}, 408 ${130 - ((trendData[4] - minTrendVal) / deltaVal) * 110}, 466 ${130 - ((trendData[4] - minTrendVal) / deltaVal) * 110}
                    C 524 ${130 - ((trendData[4] - minTrendVal) / deltaVal) * 110}, 524 ${130 - ((trendData[5] - minTrendVal) / deltaVal) * 110}, 583 ${130 - ((trendData[5] - minTrendVal) / deltaVal) * 110}
                    C 641 ${130 - ((trendData[5] - minTrendVal) / deltaVal) * 110}, 641 ${130 - ((trendData[6] - minTrendVal) / deltaVal) * 110}, 700 ${130 - ((trendData[6] - minTrendVal) / deltaVal) * 110}
                  `}
                  fill="none"
                  stroke="var(--primary-emerald)"
                  strokeWidth="3.5"
                  strokeLinecap="round"
                />

                {/* Point circles */}
                {trendData.map((val, i) => {
                  const cx = i * 116.6;
                  const cy = 130 - ((val - minTrendVal) / deltaVal) * 110;
                  return (
                    <g key={i}>
                      <circle cx={cx} cy={cy} r="6" fill="var(--bg-surface)" stroke="var(--primary-emerald)" strokeWidth="2.5" />
                      {i === 6 && (
                        <circle cx={cx} cy={cy} r="12" fill="none" stroke="var(--primary-emerald)" strokeWidth="1" strokeOpacity="0.5" className="animate-ping" />
                      )}
                    </g>
                  );
                })}
              </svg>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
              <span>D1</span>
              <span>D2</span>
              <span>D3</span>
              <span>D4</span>
              <span>D5</span>
              <span>D6</span>
              <span>Today</span>
            </div>
          </div>

          {/* AI price forecast advisory */}
          <div className="glass-panel" style={{ padding: '20px', borderLeft: '4px solid var(--secondary-cyan)' }}>
            <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--secondary-cyan)', marginBottom: '10px' }}>
              <Sparkles size={16} />
              {lang === 'hi' ? 'एआई बाजार दर पूर्वानुमान' : lang === 'mr' ? 'एआय बाजार दर अंदाज' : 'AI Mandi Price Forecast'}
            </h4>
            
            {aiAnalysis ? (
              <p style={{ fontSize: '0.85rem', lineHeight: '1.6', color: 'var(--text-primary)' }}>
                {aiAnalysis}
              </p>
            ) : loadingAI ? (
              <div style={{ display: 'flex', gap: '10px', alignItems: 'center', padding: '10px 0' }}>
                <div style={{ width: '16px', height: '16px', border: '2px solid var(--border-outline)', borderTopColor: 'var(--secondary-cyan)', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Analyzing market dynamics...</span>
              </div>
            ) : (
              <div>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '12px' }}>
                  {lang === 'hi' ? 'इस फसल की आवक, मांग और एमएसपी के आधार पर 15-30 दिन का भाव पूर्वानुमान प्राप्त करें।' : 'Analyze recent arrivals and MSP parameters to generate a price projection.'}
                </p>
                <button onClick={handleMarketAnalysis} className="btn-primary" style={{ padding: '8px 14px', fontSize: '0.8rem' }}>
                  {lang === 'hi' ? 'पूर्वानुमान प्राप्त करें' : 'Generate Forecast'}
                </button>
              </div>
            )}
          </div>

        </div>

      </div>

    </div>
  );
}
