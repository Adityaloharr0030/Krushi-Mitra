// 🌦️ Krushi Mitra Pro — Weather Forecast Updates
import React from 'react';
import { CloudRain, Sun, Cloud, Thermometer, Wind, Droplets, ShieldCheck, AlertCircle, Sparkles } from 'lucide-react';

export default function WeatherForecast({ weather, profile }) {
  if (!weather) {
    return (
      <div className="glass-panel animate-fade-in" style={{ padding: '40px', textAlign: 'center' }}>
        <p>Loading weather insights...</p>
      </div>
    );
  }

  const lang = profile.language || 'hi';
  const { temperature, feelsLike, condition, description, humidity, windSpeed, uvIndex, dailyForecasts, advisory } = weather;

  const getConditionIcon = (cond, size = 24) => {
    const c = (cond || '').toLowerCase();
    if (c.includes('rain') || c.includes('drizzle')) return <CloudRain size={size} style={{ color: 'var(--secondary-cyan)' }} />;
    if (c.includes('cloud')) return <Cloud size={size} style={{ color: '#94a3b8' }} />;
    return <Sun size={size} style={{ color: 'var(--accent-amber)' }} />;
  };

  const getDayName = (dayKey) => {
    const dayMap = {
      Sun: { hi: 'रविवार', mr: 'रविवार', en: 'Sunday' },
      Mon: { hi: 'सोमवार', mr: 'सोमवार', en: 'Monday' },
      Tue: { hi: 'मंगलवार', mr: 'मंगळवार', en: 'Tuesday' },
      Wed: { hi: 'बुधवार', mr: 'बुधवार', en: 'Wednesday' },
      Thu: { hi: 'गुरुवार', mr: 'गुरुवार', en: 'Thursday' },
      Fri: { hi: 'शुक्रवार', mr: 'शुक्रवार', en: 'Friday' },
      Sat: { hi: 'शनिवार', mr: 'शनिवार', en: 'Saturday' },
    };
    return dayMap[dayKey]?.[lang] || dayKey;
  };

  const getConditionTranslation = (cond) => {
    const condMap = {
      Rain: { hi: 'बारिश', mr: 'पाऊस', en: 'Rain' },
      Clear: { hi: 'साफ मौसम', mr: 'स्वच्छ आकाश', en: 'Sunny' },
      Clouds: { hi: 'बादल', mr: 'ढगाळ', en: 'Cloudy' }
    };
    return condMap[cond]?.[lang] || cond;
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Current Conditions Panel */}
      <div className="glass-panel" style={{ padding: '24px', display: 'flex', flexWrap: 'wrap', gap: '24px', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', gap: '20px', alignItems: 'center' }}>
          <div style={{ fontSize: '4.5rem', lineHeight: '1' }}>
            {condition === 'Rain' ? '🌧️' : condition === 'Clouds' ? '⛅' : '☀️'}
          </div>
          <div>
            <h1 style={{ fontSize: '3rem', fontWeight: '700', lineHeight: '1' }}>{temperature}°C</h1>
            <p style={{ textTransform: 'capitalize', color: 'var(--text-secondary)', marginTop: '4px', fontSize: '0.95rem' }}>
              {description} (Feels like {feelsLike}°C)
            </p>
            <p style={{ fontSize: '0.85rem', color: 'var(--primary-emerald)', fontWeight: '500', marginTop: '2px' }}>
              📍 {weather.cityName || profile.district}
            </p>
          </div>
        </div>

        {/* Indices Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', minWidth: '260px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ background: 'rgba(255,255,255,0.02)', padding: '8px', borderRadius: '8px' }}>
              <Droplets size={16} style={{ color: 'var(--secondary-cyan)' }} />
            </div>
            <div>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{lang === 'hi' ? 'आर्द्रता' : 'Humidity'}</span>
              <p style={{ fontSize: '0.9rem', fontWeight: '500' }}>{humidity}%</p>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ background: 'rgba(255,255,255,0.02)', padding: '8px', borderRadius: '8px' }}>
              <Wind size={16} style={{ color: 'var(--primary-emerald)' }} />
            </div>
            <div>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{lang === 'hi' ? 'हवा की गति' : 'Wind Speed'}</span>
              <p style={{ fontSize: '0.9rem', fontWeight: '500' }}>{windSpeed} km/h</p>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ background: 'rgba(255,255,255,0.02)', padding: '8px', borderRadius: '8px' }}>
              <Thermometer size={16} style={{ color: 'var(--accent-amber)' }} />
            </div>
            <div>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>UV Index</span>
              <p style={{ fontSize: '0.9rem', fontWeight: '500' }}>{uvIndex} / 10</p>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ background: 'rgba(255,255,255,0.02)', padding: '8px', borderRadius: '8px' }}>
              <CloudRain size={16} style={{ color: 'var(--secondary-cyan)' }} />
            </div>
            <div>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{lang === 'hi' ? 'बारिश की संभावना' : 'Rain Chance'}</span>
              <p style={{ fontSize: '0.9rem', fontWeight: '500' }}>{weather.rainChance}%</p>
            </div>
          </div>
        </div>
      </div>

      {/* Dynamic agricultural weather advisories */}
      <div 
        className="glass-panel" 
        style={{ 
          padding: '20px', 
          borderLeft: `4px solid ${advisory.safeToSpray ? 'var(--primary-emerald)' : 'var(--error)'}`, 
          background: advisory.safeToSpray ? 'rgba(16, 185, 129, 0.02)' : 'rgba(239, 68, 68, 0.02)'
        }}
      >
        <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', color: advisory.safeToSpray ? 'var(--primary-emerald)' : 'var(--error)' }}>
          {advisory.safeToSpray ? <ShieldCheck size={20} /> : <AlertCircle size={20} />}
          {advisory.title}
        </h3>
        <p style={{ fontSize: '0.95rem', lineHeight: '1.6' }}>{advisory.text}</p>
        
        <div style={{ display: 'flex', gap: '16px', marginTop: '16px', flexWrap: 'wrap' }}>
          <span className={`badge ${advisory.safeToSpray ? 'badge-emerald' : 'badge-danger'}`}>
            {advisory.safeToSpray ? '✓' : '✗'} {lang === 'hi' ? 'कीटनाशक छिड़काव: ' : 'Pesticide Spraying: '} {advisory.safeToSpray ? (lang === 'hi' ? 'सुरक्षित' : 'Safe') : (lang === 'hi' ? 'असुरक्षित' : 'Not Recommended')}
          </span>
          <span className={`badge ${advisory.safeToHarvest ? 'badge-emerald' : 'badge-danger'}`}>
            {advisory.safeToHarvest ? '✓' : '✗'} {lang === 'hi' ? 'फसल कटाई: ' : 'Crop Harvesting: '} {advisory.safeToHarvest ? (lang === 'hi' ? 'अनुकूल' : 'Safe') : (lang === 'hi' ? 'असुरक्षित' : 'Not Recommended')}
          </span>
        </div>
      </div>

      {/* 7-Day Forecast Grid */}
      <div>
        <h3 style={{ marginBottom: '16px', fontSize: '1.1rem' }}>
          📆 {lang === 'hi' ? '7-दिवसीय मौसम पूर्वानुमान' : lang === 'mr' ? '७-दिवसीय हवामान अंदाज' : '7-Day Weather Forecast'}
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(130px, 1fr))', gap: '16px' }}>
          {dailyForecasts.map((dayData, idx) => (
            <div 
              key={idx} 
              className="glass-panel" 
              style={{ 
                padding: '16px 12px', 
                textAlign: 'center', 
                display: 'flex', 
                flexDirection: 'column', 
                gap: '8px',
                alignItems: 'center',
                background: idx === 0 ? 'rgba(255,255,255,0.02)' : 'var(--glass-bg)',
                borderColor: idx === 0 ? 'var(--primary-emerald)' : 'var(--glass-border)'
              }}
            >
              <span style={{ fontSize: '0.85rem', color: idx === 0 ? 'var(--primary-emerald)' : 'var(--text-secondary)', fontWeight: idx === 0 ? '600' : '400' }}>
                {idx === 0 ? (lang === 'hi' ? 'आज' : lang === 'mr' ? 'आज' : 'Today') : getDayName(dayData.day)}
              </span>
              <div style={{ fontSize: '1.8rem', margin: '4px 0' }}>
                {dayData.condition === 'Rain' ? '🌧️' : dayData.condition === 'Clouds' ? '⛅' : '☀️'}
              </div>
              <span style={{ fontSize: '1.05rem', fontWeight: '600' }}>{dayData.temp}°C</span>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                {getConditionTranslation(dayData.condition)}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* AI Spraying/Irrigation Advisor */}
      <div className="glass-panel" style={{ padding: '20px' }}>
        <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--primary-emerald)', marginBottom: '8px' }}>
          <Sparkles size={16} />
          {lang === 'hi' ? 'एआई मौसम और सिंचाई सलाहकार' : 'AI Crop Water Advisor'}
        </h4>
        <p style={{ fontSize: '0.85rem', lineHeight: '1.6', color: 'var(--text-secondary)' }}>
          {lang === 'hi' 
            ? `आपकी फसल ${profile.cropsGrown?.join(', ') || 'Tomato'} को मिट्टी की नमी बनाए रखने के लिए वर्तमान तापमान (${temperature}°C) और आर्द्रता (${humidity}%) के आधार पर मध्यम सिंचाई की आवश्यकता है। अगले 3 दिनों में कोई भारी वर्षा नहीं होने के कारण जल निकासी सामान्य है।`
            : `Based on current temperature (${temperature}°C) and humidity (${humidity}%), your crops (${profile.cropsGrown?.join(', ') || 'Tomato'}) require moderate irrigation. No rain warnings indicate that chemical application remains highly efficient.`}
        </p>
      </div>

    </div>
  );
}
