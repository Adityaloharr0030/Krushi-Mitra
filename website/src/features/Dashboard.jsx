// 🌾 Krushi Mitra Pro — Dashboard
import React, { useEffect, useState } from 'react';
import { getDailyFarmingTip } from '../services/ai';
import { CloudSun, IndianRupee, Sprout, ShoppingBag, ArrowUpRight, TrendingUp, AlertTriangle } from 'lucide-react';

export default function Dashboard({ profile, weather, diaryEntries, setTab, t }) {
  const [dailyTip, setDailyTip] = useState('Loading today\'s farming tip...');

  useEffect(() => {
    async function loadTip() {
      try {
        const cropsList = (profile.cropsGrown || []).join(', ') || 'Tomato';
        const tip = await getDailyFarmingTip(
          cropsList,
          `${profile.district || 'Nashik'}, ${profile.state || 'Maharashtra'}`,
          'Kharif',
          profile.language || 'hi',
          profile.apiKey
        );
        setDailyTip(tip);
      } catch (e) {
        setDailyTip('Make sure to inspect your tomato plants daily for early blight. Spray organic neem oil if humidity is high.');
      }
    }
    loadTip();
  }, [profile]);

  // Financial calculations
  const income = diaryEntries.filter(e => !e.isExpense).reduce((sum, e) => sum + parseFloat(e.cost || 0), 0);
  const expense = diaryEntries.filter(e => e.isExpense).reduce((sum, e) => sum + parseFloat(e.cost || 0), 0);
  const profit = income - expense;

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px', padding: '8px' }}>
      
      {/* Welcome Banner */}
      <div className="glass-panel" style={{ padding: '24px', background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.15) 0%, rgba(6, 182, 212, 0.05) 100%)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', marginBottom: '4px' }} className="text-gradient">
            {profile.language === 'hi' ? `नमस्ते, ${profile.name || 'किसान मित्र'}!` : profile.language === 'mr' ? `नमस्कार, ${profile.name || 'शेतकरी मित्र'}!` : `Welcome, ${profile.name || 'Farmer Friend'}!`}
          </h1>
          <p style={{ color: 'var(--text-secondary)' }}>
            {profile.language === 'hi' ? `${profile.district}, ${profile.state} के लिए दैनिक कृषि अपडेट` : profile.language === 'mr' ? `${profile.district}, ${profile.state} साठी दैनिक शेती अपडेट्स` : `Daily farming summary for ${profile.district}, ${profile.state}`}
          </p>
        </div>
        <div style={{ display: 'flex', gap: '12px' }}>
          <span className="badge badge-emerald" style={{ fontSize: '0.85rem', padding: '6px 12px' }}>
            <Sprout size={16} /> {profile.cropsGrown?.length || 0} {profile.language === 'hi' ? 'फसलें' : profile.language === 'mr' ? 'पिके' : 'Crops'}
          </span>
          <span className="badge badge-cyan" style={{ fontSize: '0.85rem', padding: '6px 12px' }}>
            {profile.language === 'hi' ? 'स्मार्ट एआई चालू' : profile.language === 'mr' ? 'स्मार्ट एआय सक्रिय' : 'AI Active'}
          </span>
        </div>
      </div>

      {/* AI Daily tip */}
      <div className="glass-panel" style={{ padding: '20px', borderLeft: '4px solid var(--primary-emerald)', background: 'rgba(16, 185, 129, 0.03)' }}>
        <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', color: 'var(--primary-emerald)' }}>
          <Sprout size={20} />
          {profile.language === 'hi' ? 'कृषि मित्र दैनिक सलाह' : profile.language === 'mr' ? 'कृषी मित्र दैनिक सल्ला' : 'Krushi Mitra Daily Advisory'}
        </h3>
        <p style={{ fontSize: '0.95rem', lineHeight: '1.6', color: 'var(--text-primary)' }}>{dailyTip}</p>
      </div>

      {/* Grid of Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '20px' }}>
        
        {/* Weather Card */}
        <div className="glass-panel" style={{ padding: '20px', position: 'relative', overflow: 'hidden' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px' }}>
            <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <CloudSun size={20} style={{ color: 'var(--secondary-cyan)' }} />
              {t.weather || 'Weather'}
            </h3>
            <button onClick={() => setTab('weather')} className="btn-secondary" style={{ padding: '4px 8px', borderRadius: '4px', fontSize: '0.75rem' }}>
              {profile.language === 'hi' ? 'विस्तार' : profile.language === 'mr' ? 'सविस्तर' : 'More'} <ArrowUpRight size={12} />
            </button>
          </div>
          {weather ? (
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div>
                <h1 style={{ fontSize: '2.5rem', fontWeight: '700', lineHeight: '1' }}>{weather.temperature}°C</h1>
                <p style={{ textTransform: 'capitalize', color: 'var(--text-secondary)', fontSize: '0.9rem', marginTop: '4px' }}>
                  {weather.description}
                </p>
                <div style={{ display: 'flex', gap: '12px', marginTop: '12px', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                  <span>💧 {weather.humidity}% Hum</span>
                  <span>🌬️ {weather.windSpeed} km/h</span>
                </div>
              </div>
              <div style={{ fontSize: '3rem' }}>
                {weather.condition === 'Rain' ? '🌧️' : weather.condition === 'Clouds' ? '⛅' : '☀️'}
              </div>
            </div>
          ) : (
            <p>Loading weather...</p>
          )}
          {weather?.advisory?.safeToSpray === false && (
            <div style={{ marginTop: '12px', background: 'rgba(239,68,68,0.1)', padding: '8px', borderRadius: '6px', fontSize: '0.8rem', display: 'flex', gap: '6px', alignItems: 'center', color: 'var(--error)', border: '1px solid rgba(239,68,68,0.15)' }}>
              <AlertTriangle size={14} /> {profile.language === 'hi' ? 'छिड़काव न करें: बारिश की चेतावनी' : profile.language === 'mr' ? 'फवारणी करू नका: पावसाचा अंदाज' : 'Do not spray: rain expected'}
            </div>
          )}
        </div>

        {/* Financial Summary Card */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px' }}>
            <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <IndianRupee size={20} style={{ color: 'var(--accent-amber)' }} />
              {t.diary || 'Diary Summary'}
            </h3>
            <button onClick={() => setTab('diary')} className="btn-secondary" style={{ padding: '4px 8px', borderRadius: '4px', fontSize: '0.75rem' }}>
              {profile.language === 'hi' ? 'खाता' : profile.language === 'mr' ? 'खाते' : 'Diary'} <ArrowUpRight size={12} />
            </button>
          </div>
          <div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>{profile.language === 'hi' ? 'कुल आय' : profile.language === 'mr' ? 'एकूण उत्पन्न' : 'Income'}:</span>
                <span style={{ color: 'var(--success)', fontWeight: '600' }}>₹{income.toLocaleString()}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>{profile.language === 'hi' ? 'कुल खर्च' : profile.language === 'mr' ? 'एकूण खर्च' : 'Expenses'}:</span>
                <span style={{ color: 'var(--error)', fontWeight: '600' }}>₹{expense.toLocaleString()}</span>
              </div>
              <hr style={{ borderColor: 'var(--border-outline)', opacity: '0.5' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '1rem', fontWeight: '600', marginTop: '4px' }}>
                <span>{profile.language === 'hi' ? 'शुद्ध लाभ' : profile.language === 'mr' ? 'निव्वळ नफा' : 'Net Balance'}:</span>
                <span style={{ color: profit >= 0 ? 'var(--primary-emerald)' : 'var(--error)' }}>
                  ₹{profit.toLocaleString()}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Crops & Land Card */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px' }}>
            <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Sprout size={20} style={{ color: 'var(--primary-emerald)' }} />
              {profile.language === 'hi' ? 'खेत और फसलें' : profile.language === 'mr' ? 'शेत आणि पिके' : 'Farm Profile'}
            </h3>
            <button onClick={() => setTab('profile')} className="btn-secondary" style={{ padding: '4px 8px', borderRadius: '4px', fontSize: '0.75rem' }}>
              {profile.language === 'hi' ? 'बदलें' : profile.language === 'mr' ? 'बदला' : 'Edit'} <ArrowUpRight size={12} />
            </button>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem' }}>
              <span style={{ color: 'var(--text-secondary)' }}>{profile.language === 'hi' ? 'कुल भूमि आकार' : profile.language === 'mr' ? 'एकूण शेत जमीन' : 'Land Size'}:</span>
              <span style={{ fontWeight: '500' }}>{profile.landSize} {profile.language === 'hi' ? 'एकड़' : profile.language === 'mr' ? 'एकर' : 'Acres'}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem' }}>
              <span style={{ color: 'var(--text-secondary)' }}>{profile.language === 'hi' ? 'सिंचाई व्यवस्था' : profile.language === 'mr' ? 'सिंचन प्रकार' : 'Irrigation'}:</span>
              <span style={{ fontWeight: '500' }}>{profile.irrigationSource || 'N/A'}</span>
            </div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px', marginTop: '6px' }}>
              {(profile.cropsGrown || []).map((crop, idx) => (
                <span key={idx} className="badge badge-emerald">🌾 {crop}</span>
              ))}
            </div>
          </div>
        </div>

      </div>

      {/* Quick Access Menu / Actions */}
      <div>
        <h3 style={{ marginBottom: '16px' }}>
          {profile.language === 'hi' ? 'त्वरित सेवाएँ' : profile.language === 'mr' ? 'त्वरित सेवा' : 'Quick Actions'}
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px' }}>
          
          <div className="glass-panel" onClick={() => setTab('ai_doctor')} style={{ padding: '16px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}>
            <div style={{ background: 'var(--primary-glow)', color: 'var(--primary-emerald)', padding: '10px', borderRadius: '10px' }}>
              <Sprout size={24} />
            </div>
            <div>
              <h4 style={{ fontSize: '0.95rem' }}>{t.ai_doctor || 'Crop Doctor'}</h4>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                {profile.language === 'hi' ? 'रोग पहचानें' : profile.language === 'mr' ? 'रोग ओळखा' : 'Diagnose pests & diseases'}
              </p>
            </div>
          </div>

          <div className="glass-panel" onClick={() => setTab('chatbot')} style={{ padding: '16px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}>
            <div style={{ background: 'var(--secondary-glow)', color: 'var(--secondary-cyan)', padding: '10px', borderRadius: '10px' }}>
              <TrendingUp size={24} />
            </div>
            <div>
              <h4 style={{ fontSize: '0.95rem' }}>{t.chatbot || 'Chatbot'}</h4>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                {profile.language === 'hi' ? 'सवाल पूछें' : profile.language === 'mr' ? 'प्रश्न विचारा' : 'Ask questions in local lang'}
              </p>
            </div>
          </div>

          <div className="glass-panel" onClick={() => setTab('mandi_prices')} style={{ padding: '16px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}>
            <div style={{ background: 'rgba(245, 158, 11, 0.1)', color: 'var(--accent-amber)', padding: '10px', borderRadius: '10px' }}>
              <IndianRupee size={24} />
            </div>
            <div>
              <h4 style={{ fontSize: '0.95rem' }}>{t.mandi_prices || 'Mandi Prices'}</h4>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                {profile.language === 'hi' ? 'लाइव भाव देखें' : profile.language === 'mr' ? 'थेट बाजार भाव' : 'Live crop market prices'}
              </p>
            </div>
          </div>

          <div className="glass-panel" onClick={() => setTab('marketplace')} style={{ padding: '16px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}>
            <div style={{ background: 'rgba(16, 185, 129, 0.1)', color: 'var(--primary-emerald)', padding: '10px', borderRadius: '10px' }}>
              <ShoppingBag size={24} />
            </div>
            <div>
              <h4 style={{ fontSize: '0.95rem' }}>{t.marketplace || 'Marketplace'}</h4>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                {profile.language === 'hi' ? 'फसलें खरीदें/बेचें' : profile.language === 'mr' ? 'पीक खरेदी/विक्री' : 'Direct trade with buyers'}
              </p>
            </div>
          </div>

        </div>
      </div>

    </div>
  );
}
