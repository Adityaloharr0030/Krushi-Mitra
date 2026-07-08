// 👤 Krushi Mitra Pro — Profile & Settings Settings
import React, { useState, useEffect } from 'react';
import { getAvailableStates, getDistricts } from '../services/market';
import { User, MapPin, Sprout, Languages, Key, Camera, Check, Shield } from 'lucide-react';

export default function Profile({ profile, setProfile, onSave, langT }) {
  const [name, setName] = useState(profile.name || 'Aditya Lohar');
  const [state, setState] = useState(profile.state || 'Maharashtra');
  const [district, setDistrict] = useState(profile.district || 'Nashik');
  const [landSize, setLandSize] = useState(profile.landSize || '4.5');
  const [selectedCrops, setSelectedCrops] = useState(profile.cropsGrown || ['Tomato', 'Wheat']);
  const [soilType, setSoilType] = useState(profile.soilType || 'Black Clayey');
  const [irrigationSource, setIrrigationSource] = useState(profile.irrigationSource || 'Drip Irrigation');
  const [language, setLanguage] = useState(profile.language || 'hi');
  const [apiKey, setApiKey] = useState(profile.apiKey || '');
  const [avatar, setAvatar] = useState(profile.avatar || null);

  const states = getAvailableStates();
  const districts = getDistricts(state);

  const cropsOptions = ['Tomato', 'Wheat', 'Cotton', 'Onion', 'Rice', 'Chilli', 'Soyabean'];
  const soils = ['Sandy', 'Clayey', 'Black Clayey', 'Red Sandy', 'Loamy'];
  const irrigations = ['Drip Irrigation', 'Sprinkler System', 'Well/Borewell', 'Canal Water', 'Rain-fed'];

  useEffect(() => {
    // When state changes, reset district to first available
    const available = getDistricts(state);
    if (available.length > 0 && !available.includes(district)) {
      setDistrict(available[0]);
    }
  }, [state]);

  const handleCropToggle = (crop) => {
    if (selectedCrops.includes(crop)) {
      setSelectedCrops(selectedCrops.filter(c => c !== crop));
    } else {
      setSelectedCrops([...selectedCrops, crop]);
    }
  };

  const handleAvatarChange = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onloadend = () => {
      setAvatar(reader.result);
    };
    reader.readAsDataURL(file);
  };

  const handleFormSubmit = (e) => {
    e.preventDefault();
    const updated = {
      name,
      state,
      district,
      landSize,
      cropsGrown: selectedCrops,
      soilType,
      irrigationSource,
      language,
      apiKey: apiKey.trim(),
      avatar
    };
    setProfile(updated);
    localStorage.setItem('krushi_profile', JSON.stringify(updated));
    if (onSave) onSave();
  };

  return (
    <form onSubmit={handleFormSubmit} className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Header */}
      <div className="glass-panel" style={{ padding: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.4rem', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <User style={{ color: 'var(--primary-emerald)' }} />
            {langT.profile || 'Profile Settings'}
          </h2>
          <p style={{ color: 'var(--text-secondary)' }}>
            {language === 'hi' ? 'अपने कृषि विवरण, भाषा प्राथमिकता और एआई क्रेडेंशियल प्रबंधित करें।' : 'Manage your farm metrics, localized preferences, and secure Gemini API credentials.'}
          </p>
        </div>
        <button type="submit" className="btn-primary" style={{ padding: '10px 24px' }}>
          <Check size={18} /> {language === 'hi' ? 'सेटिंग्स सहेजें' : 'Save Settings'}
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px', alignItems: 'start' }}>
        
        {/* Farm Config card */}
        <div className="glass-panel" style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <h3 style={{ fontSize: '1.05rem', borderBottom: '1px solid var(--border-outline)', paddingBottom: '10px' }}>
            🌾 {language === 'hi' ? 'कृषि प्रोफाइल विवरण' : 'Farm Details'}
          </h3>

          {/* Avatar upload */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{ position: 'relative', width: '70px', height: '70px', borderRadius: '50%', overflow: 'hidden', border: '2px solid var(--primary-emerald)', background: 'var(--bg-surface-variant)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {avatar ? (
                <img src={avatar} alt="Profile" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              ) : (
                <User size={32} style={{ color: 'var(--text-secondary)' }} />
              )}
              <label style={{ position: 'absolute', bottom: 0, left: 0, right: 0, height: '24px', background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
                <Camera size={12} style={{ color: 'white' }} />
                <input type="file" accept="image/*" onChange={handleAvatarChange} style={{ display: 'none' }} />
              </label>
            </div>
            <div>
              <h4 style={{ fontSize: '0.9rem' }}>{language === 'hi' ? 'किसान का फोटो' : 'Profile Photo'}</h4>
              <p style={{ fontSize: '0.72rem', color: 'var(--text-secondary)' }}>{language === 'hi' ? 'फोटो बदलने के लिए कैमरा आइकन दबाएं' : 'Click camera to change'}</p>
            </div>
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>{language === 'hi' ? 'किसान का नाम' : 'Farmer Name'}</label>
            <input type="text" value={name} onChange={(e) => setName(e.target.value)} className="form-input" required />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>State</label>
              <select value={state} onChange={(e) => setState(e.target.value)} className="form-input" style={{ padding: '10px' }}>
                {states.map((st, i) => <option key={i} value={st}>{st}</option>)}
              </select>
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>District</label>
              <select value={district} onChange={(e) => setDistrict(e.target.value)} className="form-input" style={{ padding: '10px' }}>
                {districts.map((d, i) => <option key={i} value={d}>{d}</option>)}
              </select>
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>Land Size (Acres)</label>
              <input type="number" value={landSize} onChange={(e) => setLandSize(e.target.value)} className="form-input" step="0.1" required />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>Soil Type</label>
              <select value={soilType} onChange={(e) => setSoilType(e.target.value)} className="form-input" style={{ padding: '10px' }}>
                {soils.map((sl, i) => <option key={i} value={sl}>{sl}</option>)}
              </select>
            </div>
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>Irrigation Source</label>
            <select value={irrigationSource} onChange={(e) => setIrrigationSource(e.target.value)} className="form-input" style={{ padding: '10px' }}>
              {irrigations.map((ir, i) => <option key={i} value={ir}>{ir}</option>)}
            </select>
          </div>

        </div>

        {/* API settings card */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          
          {/* Languages card */}
          <div className="glass-panel" style={{ padding: '24px' }}>
            <h3 style={{ fontSize: '1.05rem', borderBottom: '1px solid var(--border-outline)', paddingBottom: '10px', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Languages size={18} style={{ color: 'var(--secondary-cyan)' }} />
              {language === 'hi' ? 'भाषा सेटिंग' : 'Language Preferences'}
            </h3>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              <button 
                type="button" 
                onClick={() => setLanguage('en')}
                className="btn-secondary" 
                style={{ fontSize: '0.8rem', padding: '6px 12px', borderColor: language === 'en' ? 'var(--secondary-cyan)' : 'var(--border-outline)', background: language === 'en' ? 'rgba(6, 182, 212, 0.05)' : 'transparent' }}
              >
                English
              </button>
              <button 
                type="button" 
                onClick={() => setLanguage('hi')}
                className="btn-secondary" 
                style={{ fontSize: '0.8rem', padding: '6px 12px', borderColor: language === 'hi' ? 'var(--secondary-cyan)' : 'var(--border-outline)', background: language === 'hi' ? 'rgba(6, 182, 212, 0.05)' : 'transparent' }}
              >
                हिंदी (Hindi)
              </button>
              <button 
                type="button" 
                onClick={() => setLanguage('mr')}
                className="btn-secondary" 
                style={{ fontSize: '0.8rem', padding: '6px 12px', borderColor: language === 'mr' ? 'var(--secondary-cyan)' : 'var(--border-outline)', background: language === 'mr' ? 'rgba(6, 182, 212, 0.05)' : 'transparent' }}
              >
                मराठी (Marathi)
              </button>
              <button 
                type="button" 
                onClick={() => setLanguage('gu')}
                className="btn-secondary" 
                style={{ fontSize: '0.8rem', padding: '6px 12px', borderColor: language === 'gu' ? 'var(--secondary-cyan)' : 'var(--border-outline)', background: language === 'gu' ? 'rgba(6, 182, 212, 0.05)' : 'transparent' }}
              >
                ગુજરાતી (Gujarati)
              </button>
              <button 
                type="button" 
                onClick={() => setLanguage('te')}
                className="btn-secondary" 
                style={{ fontSize: '0.8rem', padding: '6px 12px', borderColor: language === 'te' ? 'var(--secondary-cyan)' : 'var(--border-outline)', background: language === 'te' ? 'rgba(6, 182, 212, 0.05)' : 'transparent' }}
              >
                తెలుగు (Telugu)
              </button>
              <button 
                type="button" 
                onClick={() => setLanguage('ta')}
                className="btn-secondary" 
                style={{ fontSize: '0.8rem', padding: '6px 12px', borderColor: language === 'ta' ? 'var(--secondary-cyan)' : 'var(--border-outline)', background: language === 'ta' ? 'rgba(6, 182, 212, 0.05)' : 'transparent' }}
              >
                தமிழ் (Tamil)
              </button>
              <button 
                type="button" 
                onClick={() => setLanguage('kn')}
                className="btn-secondary" 
                style={{ fontSize: '0.8rem', padding: '6px 12px', borderColor: language === 'kn' ? 'var(--secondary-cyan)' : 'var(--border-outline)', background: language === 'kn' ? 'rgba(6, 182, 212, 0.05)' : 'transparent' }}
              >
                ಕನ್ನಡ (Kannada)
              </button>
              <button 
                type="button" 
                onClick={() => setLanguage('bn')}
                className="btn-secondary" 
                style={{ fontSize: '0.8rem', padding: '6px 12px', borderColor: language === 'bn' ? 'var(--secondary-cyan)' : 'var(--border-outline)', background: language === 'bn' ? 'rgba(6, 182, 212, 0.05)' : 'transparent' }}
              >
                বাংলা (Bengali)
              </button>
            </div>
          </div>

          {/* API credentials card */}
          <div className="glass-panel" style={{ padding: '24px' }}>
            <h3 style={{ fontSize: '1.05rem', borderBottom: '1px solid var(--border-outline)', paddingBottom: '10px', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Key size={18} style={{ color: 'var(--accent-amber)' }} />
              {language === 'hi' ? 'सुरक्षित एआई क्रेडेंशियल' : 'AI API Configuration'}
            </h3>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>Gemini API Key</label>
                <input 
                  type="password" 
                  value={apiKey} 
                  onChange={(e) => setApiKey(e.target.value)} 
                  placeholder="AIzaSy..." 
                  className="form-input" 
                />
              </div>

              <div style={{ display: 'flex', gap: '8px', background: 'rgba(245, 158, 11, 0.05)', padding: '12px', borderRadius: '8px', border: '1px solid rgba(245, 158, 11, 0.15)', fontSize: '0.78rem', color: 'var(--text-secondary)', lineHeight: '1.4' }}>
                <Shield size={18} style={{ color: 'var(--accent-amber)', flexShrink: 0, marginTop: '2px' }} />
                <span>
                  {language === 'hi' 
                    ? 'कुंजी स्थानीय रूप से सहेजी जाती है और कभी भी सर्वर पर साझा नहीं की जाती है। यदि कोई कुंजी खाली छोड़ी जाती है, तो ऐप स्वचालित रूप से सिमुलेशन मोड पर काम करता है।' 
                    : 'Your API key is stored locally in your browser cache and is never sent to any intermediate server. If empty, the app runs in fallback demo mode.'}
                </span>
              </div>
            </div>
          </div>

          {/* Crops Grown Multi-select */}
          <div className="glass-panel" style={{ padding: '24px' }}>
            <h3 style={{ fontSize: '1.05rem', borderBottom: '1px solid var(--border-outline)', paddingBottom: '10px', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Sprout size={18} style={{ color: 'var(--primary-emerald)' }} />
              {language === 'hi' ? 'उगाई जाने वाली फसलें' : 'Crops Sown'}
            </h3>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              {cropsOptions.map((crop, idx) => {
                const isSelected = selectedCrops.includes(crop);
                return (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => handleCropToggle(crop)}
                    className={isSelected ? "btn-primary" : "btn-secondary"}
                    style={{ 
                      fontSize: '0.8rem', 
                      padding: '6px 12px',
                      background: isSelected ? undefined : 'transparent'
                    }}
                  >
                    {crop}
                  </button>
                );
              })}
            </div>
          </div>

        </div>

      </div>

    </form>
  );
}
