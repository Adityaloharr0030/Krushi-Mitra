// 🐛 Krushi Mitra Pro — AI Crop Doctor
import React, { useState } from 'react';
import { analyzeCropImage } from '../services/ai';
import { Upload, HelpCircle, CheckCircle, AlertTriangle, ShieldCheck, Zap, Sparkles } from 'lucide-react';

export default function AIDoctor({ profile, apiKey }) {
  const [imagePreview, setImagePreview] = useState(null);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  // File Upload Handler
  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    setError(null);
    const reader = new FileReader();
    reader.onloadend = () => {
      setImagePreview(reader.result);
      runDiagnosis(reader.result.split(',')[1], file.type);
    };
    reader.readAsDataURL(file);
  };

  // Run Diagnosis Service
  const runDiagnosis = async (base64, mimeType) => {
    setLoading(true);
    setResult(null);
    try {
      const diagnosis = await analyzeCropImage(
        base64,
        mimeType,
        { profile },
        apiKey
      );
      setResult(diagnosis);
    } catch (e) {
      console.error(e);
      setError("Failed to analyze image. Ensure your API key is correct.");
    } finally {
      setLoading(false);
    }
  };

  // Preset trigger (makes it extremely easy to demo)
  const triggerPreset = (cropType) => {
    setError(null);
    setLoading(true);
    setResult(null);

    // Mocking image selection based on crop
    const presetImages = {
      Tomato: 'https://images.unsplash.com/photo-1595855759920-86582396756a?q=80&w=500&auto=format&fit=crop',
      Wheat: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=500&auto=format&fit=crop',
      Cotton: 'https://images.unsplash.com/photo-1594761053050-b112507d189f?q=80&w=500&auto=format&fit=crop'
    };

    setImagePreview(presetImages[cropType]);

    setTimeout(async () => {
      try {
        const dummyBase64 = "DUMMY_BASE_64";
        const res = await analyzeCropImage(
          dummyBase64,
          'image/jpeg',
          { profile: { ...profile, cropsGrown: [cropType] } },
          apiKey
        );
        setResult(res);
      } catch (err) {
        setError("Preset load failed.");
      } finally {
        setLoading(false);
      }
    }, 1200);
  };

  const getSeverityColor = (sev) => {
    const s = (sev || '').toLowerCase();
    if (s === 'low') return 'badge-emerald';
    if (s === 'medium') return 'badge-cyan';
    if (s === 'high') return 'badge-amber';
    return 'badge-danger';
  };

  const lang = profile.language || 'hi';

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Description Header */}
      <div className="glass-panel" style={{ padding: '24px' }}>
        <h2 style={{ fontSize: '1.4rem', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '10px' }}>
          <Sparkles style={{ color: 'var(--primary-emerald)' }} />
          {lang === 'hi' ? 'एआई फसल डॉक्टर — रोग पहचान' : lang === 'mr' ? 'एआय पीक डॉक्टर — रोग निदान' : 'AI Crop Doctor — Disease Diagnosis'}
        </h2>
        <p style={{ color: 'var(--text-secondary)' }}>
          {lang === 'hi' 
            ? 'अपनी बीमार फसल की एक स्पष्ट फोटो अपलोड करें या एआई को उसकी बीमारी, जैविक और रासायनिक उपचार जानने के लिए निर्देशित करें।' 
            : lang === 'mr'
            ? 'तुमच्या आजारी पिकाचा फोटो अपलोड करा आणि एआयद्वारे रोगाचे निदान करून त्याचे उपाय मिळवा.'
            : 'Upload a clear photograph of your crop leaf or infected area to receive diagnostic insights, causes, and treatment methods.'}
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px', alignItems: 'start' }}>
        
        {/* Upload Container */}
        <div className="glass-panel" style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '20px', textAlign: 'center' }}>
          
          <div 
            style={{ 
              border: '2px dashed var(--border-outline)', 
              borderRadius: '12px', 
              padding: '40px 20px', 
              position: 'relative', 
              cursor: 'pointer',
              background: 'rgba(2, 6, 23, 0.2)',
              transition: 'all var(--transition-fast)'
            }}
            onMouseOver={(e) => e.currentTarget.style.borderColor = 'var(--primary-emerald)'}
            onMouseOut={(e) => e.currentTarget.style.borderColor = 'var(--border-outline)'}
          >
            <input 
              type="file" 
              accept="image/*" 
              onChange={handleImageChange}
              style={{ 
                position: 'absolute', 
                top: 0, left: 0, width: '100%', height: '100%', 
                opacity: 0, cursor: 'pointer' 
              }} 
            />
            {imagePreview ? (
              <img 
                src={imagePreview} 
                alt="Upload Preview" 
                style={{ maxWidth: '100%', maxHeight: '220px', borderRadius: '8px', objectFit: 'cover' }} 
              />
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px' }}>
                <Upload size={48} style={{ color: 'var(--text-secondary)' }} />
                <div>
                  <p style={{ fontWeight: '500' }}>
                    {lang === 'hi' ? 'फोटो अपलोड करने के लिए क्लिक करें' : lang === 'mr' ? 'फोटो निवडण्यासाठी क्लिक करा' : 'Click or Drag photo here'}
                  </p>
                  <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    PNG, JPG or JPEG up to 5MB
                  </p>
                </div>
              </div>
            )}
          </div>

          {/* Quick Preset Buttons */}
          <div style={{ textAlign: 'left' }}>
            <h4 style={{ fontSize: '0.9rem', marginBottom: '10px', color: 'var(--text-secondary)' }}>
              💡 {lang === 'hi' ? 'त्वरित डेमो परीक्षण (बिना फोटो के)' : lang === 'mr' ? 'त्वरित डेमो चाचणी (फोटोशिवाय)' : 'Or Test with Demo Presets (No Upload Required):'}
            </h4>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              <button onClick={() => triggerPreset('Tomato')} className="btn-secondary" style={{ fontSize: '0.8rem', padding: '6px 12px' }}>
                🍅 {lang === 'hi' ? 'टमाटर झुलसा' : lang === 'mr' ? 'टोमॅटो करपा' : 'Tomato Blight'}
              </button>
              <button onClick={() => triggerPreset('Cotton')} className="btn-secondary" style={{ fontSize: '0.8rem', padding: '6px 12px' }}>
                🐛 {lang === 'hi' ? 'कपास गुलाबी सुंडी' : lang === 'mr' ? 'कापूस बोंडअळी' : 'Cotton Bollworm'}
              </button>
              <button onClick={() => triggerPreset('Wheat')} className="btn-secondary" style={{ fontSize: '0.8rem', padding: '6px 12px' }}>
                🌾 {lang === 'hi' ? 'गेहूं रतुआ' : lang === 'mr' ? 'गहू तांबेरा' : 'Wheat Rust'}
              </button>
            </div>
          </div>

        </div>

        {/* Diagnostic Results Sheet */}
        <div className="glass-panel" style={{ padding: '24px', minHeight: '380px', display: 'flex', flexDirection: 'column', justifyContent: result || loading || error ? 'flex-start' : 'center', alignItems: result || loading || error ? 'stretch' : 'center' }}>
          
          {loading && (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '16px', minHeight: '300px' }}>
              <div style={{ width: '40px', height: '40px', border: '3px solid var(--border-outline)', borderTopColor: 'var(--primary-emerald)', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
              <style>{`@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }`}</style>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                {lang === 'hi' ? 'एआई डॉक्टर आपकी पत्ती का विश्लेषण कर रहा है...' : lang === 'mr' ? 'एआय डॉक्टर पानावरील रोगाचे विश्लेषण करत आहे...' : 'AI Doctor is diagnosing crop pathogen...'}
              </p>
            </div>
          )}

          {error && (
            <div style={{ color: 'var(--error)', textAlign: 'center', padding: '20px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px' }}>
              <AlertTriangle size={40} />
              <p>{error}</p>
            </div>
          )}

          {!loading && !result && !error && (
            <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px 20px' }}>
              <HelpCircle size={48} style={{ margin: '0 auto 16px', opacity: '0.5' }} />
              <h3 style={{ marginBottom: '8px' }}>
                {lang === 'hi' ? 'कोई रिपोर्ट उपलब्ध नहीं' : lang === 'mr' ? 'अहवाल उपलब्ध नाही' : 'No Diagnosis Report Yet'}
              </h3>
              <p style={{ fontSize: '0.85rem' }}>
                {lang === 'hi' ? 'एक फोटो अपलोड करें या एआई डॉक्टर रिपोर्ट देखने के लिए डेमो बटन पर क्लिक करें।' : lang === 'mr' ? 'फोटो अपलोड करा किंवा चाचणी करण्यासाठी डेमो बटणावर क्लिक करा.' : 'Upload a photo or click a demo preset button to generate the diagnostics report.'}
              </p>
            </div>
          )}

          {/* Diagnosis Data Sheet */}
          {result && (
            <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px', paddingBottom: '12px', borderBottom: '1px solid var(--border-outline)' }}>
                <div>
                  <span className="badge badge-cyan" style={{ marginBottom: '4px' }}>🌾 {result.crop_name}</span>
                  <h3 style={{ fontSize: '1.2rem', color: 'var(--text-primary)' }}>{result.disease_name}</h3>
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <span className={`badge ${getSeverityColor(result.severity)}`}>
                    ⚠️ {result.severity.toUpperCase()}
                  </span>
                  <span className="badge badge-emerald">
                    <ShieldCheck size={12} /> {result.confidence}% {lang === 'hi' ? 'सटीकता' : 'Confidence'}
                  </span>
                </div>
              </div>

              <div>
                <h4 style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>
                  🔍 {lang === 'hi' ? 'लक्षण' : lang === 'mr' ? 'लक्षणे' : 'Symptoms'}
                </h4>
                <p style={{ fontSize: '0.9rem', color: 'var(--text-primary)' }}>{result.symptoms}</p>
              </div>

              <div>
                <h4 style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>
                  🔬 {lang === 'hi' ? 'कारण' : lang === 'mr' ? 'कारणे' : 'Causes'}
                </h4>
                <p style={{ fontSize: '0.9rem', color: 'var(--text-primary)' }}>{result.causes}</p>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div style={{ background: 'rgba(16, 185, 129, 0.05)', padding: '12px', borderRadius: '8px', border: '1px solid rgba(16, 185, 129, 0.15)' }}>
                  <h4 style={{ fontSize: '0.85rem', color: 'var(--primary-emerald)', marginBottom: '6px', fontWeight: '600' }}>
                    🌿 {lang === 'hi' ? 'जैविक उपचार' : lang === 'mr' ? 'सेंद्रिय उपाय' : 'Organic Remedy'}
                  </h4>
                  <p style={{ fontSize: '0.85rem', color: 'var(--text-primary)' }}>{result.treatment_organic}</p>
                </div>
                <div style={{ background: 'rgba(6, 182, 212, 0.05)', padding: '12px', borderRadius: '8px', border: '1px solid rgba(6, 182, 212, 0.15)' }}>
                  <h4 style={{ fontSize: '0.85rem', color: 'var(--secondary-cyan)', marginBottom: '6px', fontWeight: '600' }}>
                    🧪 {lang === 'hi' ? 'रासायनिक उपचार' : lang === 'mr' ? 'रासायनिक उपाय' : 'Chemical Remedy'}
                  </h4>
                  <p style={{ fontSize: '0.85rem', color: 'var(--text-primary)' }}>{result.treatment_chemical}</p>
                </div>
              </div>

              <div>
                <h4 style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  🛡️ {lang === 'hi' ? 'बचाव के तरीके' : lang === 'mr' ? 'प्रतिबंधात्मक उपाय' : 'Prevention'}
                </h4>
                <ul style={{ fontSize: '0.85rem', paddingLeft: '20px', color: 'var(--text-primary)' }}>
                  {(result.prevention || []).map((step, idx) => (
                    <li key={idx} style={{ marginBottom: '4px' }}>{step}</li>
                  ))}
                </ul>
              </div>

            </div>
          )}

        </div>

      </div>

    </div>
  );
}
