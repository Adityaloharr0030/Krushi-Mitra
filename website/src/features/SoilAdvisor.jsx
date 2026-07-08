// 🌱 Krushi Mitra Pro — Soil Health Advisor
import React, { useState } from 'react';
import { chat } from '../services/ai';
import { Sprout, BarChart2, ShieldCheck, Sparkles, RefreshCw, AlertTriangle } from 'lucide-react';

export default function SoilAdvisor({ profile, apiKey }) {
  const [nitrogen, setNitrogen] = useState('22'); // Low N
  const [phosphorus, setPhosphorus] = useState('18'); // Medium P
  const [potassium, setPotassium] = useState('140'); // Optimum K
  const [ph, setPh] = useState('6.2'); // Slightly acidic
  
  const [report, setReport] = useState('');
  const [loading, setLoading] = useState(false);

  const lang = profile.language || 'hi';

  const formatText = (textHi, textEn) => {
    return lang === 'hi' ? textHi : textEn;
  };

  const getPHStatus = (val) => {
    const v = parseFloat(val);
    if (v < 5.5) return { label: formatText("अत्यंत अम्लीय", "Strongly Acidic"), color: 'var(--error)' };
    if (v < 6.5) return { label: formatText("हल्का अम्लीय", "Slightly Acidic"), color: 'var(--accent-amber)' };
    if (v <= 7.5) return { label: formatText("उदासीन (उत्तम)", "Neutral (Ideal)"), color: 'var(--primary-emerald)' };
    if (v <= 8.5) return { label: formatText("हल्का क्षारीय", "Slightly Alkaline"), color: 'var(--accent-amber)' };
    return { label: formatText("अत्यंत क्षारीय", "Strongly Alkaline"), color: 'var(--error)' };
  };

  const getNutrientStatus = (val, type) => {
    const v = parseFloat(val);
    if (type === 'N') {
      if (v < 20) return { label: formatText("कम", "Low"), color: 'var(--error)' };
      if (v < 40) return { label: formatText("मध्यम", "Medium"), color: 'var(--accent-amber)' };
      return { label: formatText("पर्याप्त", "Optimum"), color: 'var(--primary-emerald)' };
    }
    if (type === 'P') {
      if (v < 15) return { label: formatText("कम", "Low"), color: 'var(--error)' };
      if (v < 30) return { label: formatText("मध्यम", "Medium"), color: 'var(--accent-amber)' };
      return { label: formatText("पर्याप्त", "Optimum"), color: 'var(--primary-emerald)' };
    }
    // K
    if (v < 120) return { label: formatText("कम", "Low"), color: 'var(--error)' };
    if (v < 280) return { label: formatText("मध्यम", "Medium"), color: 'var(--accent-amber)' };
    return { label: formatText("पर्याप्त", "Optimum"), color: 'var(--primary-emerald)' };
  };

  // Pre-load soil tests
  const loadPreset = (type) => {
    setReport('');
    if (type === 'sandy') {
      setNitrogen('12');
      setPhosphorus('9');
      setPotassium('90');
      setPh('5.2');
    } else {
      setNitrogen('35');
      setPhosphorus('26');
      setPotassium('290');
      setPh('7.8');
    }
  };

  const handleGenerateReport = async () => {
    setLoading(true);
    setReport('');
    try {
      const prompt = `SOIL LAB DATA REPORT (2026):
- Nitrogen (N): ${nitrogen} kg/acre (Range: Low < 100, Med 100-200, High > 200) - absolute lab extractable
- Phosphorus (P): ${phosphorus} kg/acre
- Potassium (K): ${potassium} kg/acre
- Soil pH: ${ph}
- Crops Grown: ${profile.cropsGrown?.join(', ') || 'Tomato'}

TASK: Generate a customized fertilizer NPK application report.
- Assess the soil pH and suggest corrections (e.g. lime for acidic, gypsum/sulphur for alkaline).
- Give exact fertilizer dosage adjustments for ${profile.cropsGrown?.join(', ') || 'Tomato'} (e.g., increase DAP, decrease Urea).
- Recommend 2 organic practices (compost, green manuring) to improve soil structure.
- Keep it under 6 lines. Respond in ${profile.language === 'hi' ? 'Hindi' : 'English'}.`;

      const response = await chat([], prompt, { profile }, apiKey);
      setReport(response);
    } catch (e) {
      setReport("⚠️ Failed to generate soil recommendation. Please configure your API key.");
    } finally {
      setLoading(false);
    }
  };

  const renderMarkdown = (text) => {
    return text.split('\n').map((line, idx) => {
      let content = line;
      content = content.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
      const isHeader = content.startsWith('### ');
      const isBullet = content.trim().startsWith('* ') || content.trim().startsWith('- ');

      if (isHeader) {
        return <h4 key={idx} style={{ color: 'var(--primary-emerald)', margin: '14px 0 6px', fontSize: '0.95rem' }} dangerouslySetInnerHTML={{ __html: content.substring(4) }} />;
      }
      if (isBullet) {
        return <li key={idx} style={{ marginLeft: '16px', listStyleType: 'disc', fontSize: '0.82rem', marginBottom: '4px' }} dangerouslySetInnerHTML={{ __html: content.trim().substring(2) }} />;
      }
      return <p key={idx} style={{ fontSize: '0.82rem', marginBottom: '6px', lineHeight: '1.5' }} dangerouslySetInnerHTML={{ __html: content }} />;
    });
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Header */}
      <div className="glass-panel" style={{ padding: '24px' }}>
        <h2 style={{ fontSize: '1.4rem', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Sprout style={{ color: 'var(--primary-emerald)' }} />
          {formatText("मृदा सलाहकार — मिट्टी परीक्षण", "Soil Advisor & Health Recommendations")}
        </h2>
        <p style={{ color: 'var(--text-secondary)' }}>
          {formatText(
            "अपने खेत की मिट्टी के परीक्षण मान (N, P, K और pH) दर्ज करें और उर्वरक नियंत्रण तथा मृदा सुधार सलाह प्राप्त करें।",
            "Enter your soil test metrics to determine nutrient deficits and receive organic amendments advice."
          )}
        </p>
      </div>

      {/* Main split */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px', alignItems: 'start' }}>
        
        {/* Input parameters */}
        <div className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--border-outline)', paddingBottom: '10px' }}>
            <h3 style={{ fontSize: '1rem' }}>🧪 {formatText("परीक्षण डेटा दर्ज करें", "Enter Soil Test Values")}</h3>
            <div style={{ display: 'flex', gap: '6px' }}>
              <button onClick={() => loadPreset('sandy')} className="btn-secondary" style={{ fontSize: '0.7rem', padding: '4px 8px' }}>
                {formatText("अम्लीय बलुई", "Acidic Sandy")}
              </button>
              <button onClick={() => loadPreset('clayey')} className="btn-secondary" style={{ fontSize: '0.7rem', padding: '4px 8px' }}>
                {formatText("क्षारीय काली", "Alkaline Clay")}
              </button>
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>
                Nitrogen (N) (kg/acre)
              </label>
              <input type="number" value={nitrogen} onChange={(e) => setNitrogen(e.target.value)} className="form-input" style={{ padding: '8px 12px' }} />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>
                Phosphorus (P) (kg/acre)
              </label>
              <input type="number" value={phosphorus} onChange={(e) => setPhosphorus(e.target.value)} className="form-input" style={{ padding: '8px 12px' }} />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>
                Potassium (K) (kg/acre)
              </label>
              <input type="number" value={potassium} onChange={(e) => setPotassium(e.target.value)} className="form-input" style={{ padding: '8px 12px' }} />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>
                Soil pH (1 - 14)
              </label>
              <input type="number" value={ph} onChange={(e) => setPh(e.target.value)} className="form-input" style={{ padding: '8px 12px' }} step="0.1" min="1" max="14" />
            </div>
          </div>

          <button onClick={handleGenerateReport} className="btn-primary" style={{ width: '100%', justifyContent: 'center', marginTop: '6px' }}>
            <Sparkles size={16} /> {formatText("एआई मृदा रिपोर्ट प्राप्त करें", "Generate AI Soil Report")}
          </button>
        </div>

        {/* Diagnostic Scales & AI Recommendations */}
        <div className="glass-panel" style={{ padding: '24px', minHeight: '340px' }}>
          
          {!report && !loading && (
            <div>
              <h3 style={{ fontSize: '1rem', borderBottom: '1px solid var(--border-outline)', paddingBottom: '10px', marginBottom: '16px' }}>
                📊 {formatText("प्राथमिक पोषक तत्व संकेतक", "Nutrient Level Indicators")}
              </h3>
              
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.82rem', marginBottom: '4px' }}>
                    <span>Nitrogen (N)</span>
                    <span style={{ color: getNutrientStatus(nitrogen, 'N').color, fontWeight: '600' }}>
                      {getNutrientStatus(nitrogen, 'N').label}
                    </span>
                  </div>
                  <div style={{ width: '100%', height: '8px', background: 'var(--border-outline)', borderRadius: '4px', overflow: 'hidden' }}>
                    <div style={{ width: `${Math.min(100, (parseFloat(nitrogen) / 60) * 100)}%`, height: '100%', background: getNutrientStatus(nitrogen, 'N').color }}></div>
                  </div>
                </div>

                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.82rem', marginBottom: '4px' }}>
                    <span>Phosphorus (P)</span>
                    <span style={{ color: getNutrientStatus(phosphorus, 'P').color, fontWeight: '600' }}>
                      {getNutrientStatus(phosphorus, 'P').label}
                    </span>
                  </div>
                  <div style={{ width: '100%', height: '8px', background: 'var(--border-outline)', borderRadius: '4px', overflow: 'hidden' }}>
                    <div style={{ width: `${Math.min(100, (parseFloat(phosphorus) / 45) * 100)}%`, height: '100%', background: getNutrientStatus(phosphorus, 'P').color }}></div>
                  </div>
                </div>

                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.82rem', marginBottom: '4px' }}>
                    <span>Potassium (K)</span>
                    <span style={{ color: getNutrientStatus(potassium, 'K').color, fontWeight: '600' }}>
                      {getNutrientStatus(potassium, 'K').label}
                    </span>
                  </div>
                  <div style={{ width: '100%', height: '8px', background: 'var(--border-outline)', borderRadius: '4px', overflow: 'hidden' }}>
                    <div style={{ width: `${Math.min(100, (parseFloat(potassium) / 350) * 100)}%`, height: '100%', background: getNutrientStatus(potassium, 'K').color }}></div>
                  </div>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'rgba(255,255,255,0.01)', border: '1px solid var(--glass-border)', padding: '12px', borderRadius: '8px', marginTop: '10px' }}>
                  <div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Soil pH Rating</span>
                    <h4 style={{ fontSize: '0.9rem' }}>{getPHStatus(ph).label}</h4>
                  </div>
                  <span style={{ fontSize: '1.5rem', fontWeight: '700', color: getPHStatus(ph).color }}>{ph}</span>
                </div>
              </div>
            </div>
          )}

          {loading && (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '260px', gap: '16px' }}>
              <div style={{ width: '30px', height: '30px', border: '3px solid var(--border-outline)', borderTopColor: 'var(--primary-emerald)', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Analyzing chemical compositions...</p>
            </div>
          )}

          {report && (
            <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <h3 style={{ fontSize: '1rem', borderBottom: '1px solid var(--border-outline)', paddingBottom: '10px', color: 'var(--primary-emerald)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <ShieldCheck size={20} /> {formatText("मृदा विश्लेषण रिपोर्ट", "Soil Health Advisor Report")}
              </h3>
              <div style={{ display: 'flex', gap: '12px', background: 'rgba(255,255,255,0.01)', border: '1px solid var(--glass-border)', padding: '8px 12px', borderRadius: '8px', fontSize: '0.78rem', color: 'var(--text-secondary)' }}>
                <span>N: {nitrogen}</span> | <span>P: {phosphorus}</span> | <span>K: {potassium}</span> | <span>pH: {ph}</span>
              </div>
              <div style={{ marginTop: '6px' }}>
                {renderMarkdown(report)}
              </div>
              <button onClick={() => setReport('')} className="btn-secondary" style={{ alignSelf: 'flex-start', fontSize: '0.8rem', padding: '6px 12px', marginTop: '12px' }}>
                <RefreshCw size={12} /> {formatText("पुनः जाँच करें", "Reset View")}
              </button>
            </div>
          )}

        </div>

      </div>

    </div>
  );
}
