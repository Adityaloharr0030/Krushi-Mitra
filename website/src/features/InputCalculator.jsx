// 🧮 Krushi Mitra Pro — Input Calculator
import React, { useState } from 'react';
import { Calculator, Sprout, Hammer, Droplets, Info } from 'lucide-react';

export default function InputCalculator({ profile }) {
  const [acres, setAcres] = useState(parseFloat(profile.landSize || 1.0));
  const [selectedCrop, setSelectedCrop] = useState(profile.cropsGrown?.[0] || 'Tomato');

  const lang = profile.language || 'hi';

  const cropGuidelines = {
    Tomato: {
      seedRate: '150-200 grams / acre',
      nitrogen: '60 kg / acre',
      phosphorus: '40 kg / acre',
      potash: '60 kg / acre',
      waterNeeds: 'Moderate to High (Drip recommended)',
      fertilizerNote: 'Apply high potash during fruiting stage for shiny red skin.',
      seedNote: 'Sow in nursery beds; transplant 25-30 days old seedlings.'
    },
    Wheat: {
      seedRate: '40-50 kg / acre',
      nitrogen: '50 kg / acre',
      phosphorus: '25 kg / acre',
      potash: '15 kg / acre',
      waterNeeds: 'Critical during CRI (21 days) and flowering stages',
      fertilizerNote: 'Nitrogen split application is essential. First dose at 21 days.',
      seedNote: 'Sow at a depth of 4-5 cm using a seed drill for optimal growth.'
    },
    Rice: {
      seedRate: '15-20 kg / acre (Transplanting)',
      nitrogen: '48 kg / acre',
      phosphorus: '24 kg / acre',
      potash: '24 kg / acre',
      waterNeeds: 'High (Maintain 2-5cm standing water)',
      fertilizerNote: 'Apply Zinc Sulphate (10kg/acre) to prevent Khaira disease.',
      seedNote: 'Treat seeds with salt water to remove light, unviable grains.'
    },
    Cotton: {
      seedRate: '1.5-2.0 kg / acre (Bt Hybrid)',
      nitrogen: '40 kg / acre',
      phosphorus: '20 kg / acre',
      potash: '20 kg / acre',
      waterNeeds: 'Moderate; highly sensitive to logging',
      fertilizerNote: 'Spray Magnesium Sulphate (1%) during squaring if leaves redden.',
      seedNote: 'Delint seeds with sulphuric acid or cow dung slurry before sowing.'
    },
    Onion: {
      seedRate: '3.5-4.0 kg / acre',
      nitrogen: '40 kg / acre',
      phosphorus: '20 kg / acre',
      potash: '40 kg / acre',
      waterNeeds: 'Frequent light irrigations; stop 10 days before harvest',
      fertilizerNote: 'Sulphur (15kg/acre) is essential for bulb size and storage shelf-life.',
      seedNote: 'Raise in nursery; transplant after 6-8 weeks when pencil thick.'
    },
    Soyabean: {
      seedRate: '30-35 kg / acre',
      nitrogen: '10 kg / acre (Basal)',
      phosphorus: '30 kg / acre',
      potash: '15 kg / acre',
      waterNeeds: 'Critical during flowering and pod-filling stages',
      fertilizerNote: 'Treat seeds with Rhizobium culture to help nitrogen fixation.',
      seedNote: 'Sow at a depth of 3 cm. Sowing on ridges prevents root rot.'
    }
  };

  const currentRules = cropGuidelines[selectedCrop] || cropGuidelines.Tomato;

  // Calculate bags based on kg requirements (standard 50kg bags)
  const calcBags = (kg) => {
    return ((kg * acres) / 50).toFixed(1);
  };

  // Seed calculations
  const calculateSeeds = () => {
    const rateText = currentRules.seedRate;
    const rateNum = parseFloat(rateText);
    if (isNaN(rateNum)) return rateText;
    
    const isGrams = rateText.includes('grams');
    const total = rateNum * acres;
    return isGrams ? `${total.toFixed(0)} grams` : `${total.toFixed(1)} kg`;
  };

  const formatText = (textHi, textEn) => {
    return lang === 'hi' ? textHi : textEn;
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Header Info */}
      <div className="glass-panel" style={{ padding: '24px' }}>
        <h2 style={{ fontSize: '1.4rem', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Calculator style={{ color: 'var(--primary-emerald)' }} />
          {formatText("कृषि लागत कैलकुलेटर", "Agricultural Input Calculator")}
        </h2>
        <p style={{ color: 'var(--text-secondary)' }}>
          {formatText(
            "अपने खेत के क्षेत्रफल के आधार पर आवश्यक बीज, खाद (NPK) और दवाओं की सही मात्रा की गणना करें।",
            "Calculate seed rates, precise fertilizer bags (Urea, DAP, Potash), and water needs for your exact acreage."
          )}
        </p>
      </div>

      {/* Inputs panel */}
      <div className="glass-panel" style={{ padding: '20px', display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
        <div style={{ flex: 1, minWidth: '200px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
            {formatText("क्षेत्रफल (एकड़ में)", "Land Area (Acres)")}
          </label>
          <input 
            type="number" 
            value={acres} 
            onChange={(e) => setAcres(Math.max(0.1, parseFloat(e.target.value) || 0.1))}
            className="form-input"
            step="0.5"
            min="0.1"
          />
        </div>
        <div style={{ flex: 1, minWidth: '200px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
            {formatText("फसल चुनें", "Select Crop")}
          </label>
          <select 
            value={selectedCrop} 
            onChange={(e) => setSelectedCrop(e.target.value)}
            className="form-input"
            style={{ padding: '12px' }}
          >
            {Object.keys(cropGuidelines).map((crop, idx) => (
              <option key={idx} value={crop}>{crop}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Outputs Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(290px, 1fr))', gap: '20px' }}>
        
        {/* Seeds calculation */}
        <div className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <h3 style={{ fontSize: '1rem', color: 'var(--primary-emerald)', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Sprout size={20} />
            {formatText("बीज की मात्रा", "Required Seeds")}
          </h3>
          <div style={{ padding: '16px', background: 'rgba(2, 6, 23, 0.4)', borderRadius: '8px', textAlign: 'center' }}>
            <span style={{ fontSize: '1.8rem', fontWeight: '700', color: 'var(--text-primary)' }}>
              {calculateSeeds()}
            </span>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
              {formatText("कुल बीज दर प्रति एकड़:", "Recommended seed rate per acre:")} {currentRules.seedRate}
            </p>
          </div>
          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', display: 'flex', gap: '6px', alignItems: 'start' }}>
            <Info size={14} style={{ flexShrink: 0, marginTop: '2px' }} />
            <span>{currentRules.seedNote}</span>
          </div>
        </div>

        {/* Fertilizers calculation */}
        <div className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '12px', gridColumn: 'span 2' }}>
          <h3 style={{ fontSize: '1rem', color: 'var(--secondary-cyan)', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Hammer size={20} />
            {formatText("उर्वरक की मात्रा (50 किलोग्राम बैग में)", "Required Fertilizers (in 50kg Bags)")}
          </h3>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px' }}>
            <div style={{ padding: '14px', background: 'rgba(2, 6, 23, 0.4)', borderRadius: '8px', textAlign: 'center' }}>
              <span style={{ fontSize: '1.6rem', fontWeight: '700', color: 'var(--text-primary)' }}>
                {calcBags(parseFloat(currentRules.nitrogen))}
              </span>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '4px' }}>Urea (Nitrogen)</p>
            </div>
            <div style={{ padding: '14px', background: 'rgba(2, 6, 23, 0.4)', borderRadius: '8px', textAlign: 'center' }}>
              <span style={{ fontSize: '1.6rem', fontWeight: '700', color: 'var(--text-primary)' }}>
                {calcBags(parseFloat(currentRules.phosphorus))}
              </span>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '4px' }}>DAP (Phosphorus)</p>
            </div>
            <div style={{ padding: '14px', background: 'rgba(2, 6, 23, 0.4)', borderRadius: '8px', textAlign: 'center' }}>
              <span style={{ fontSize: '1.6rem', fontWeight: '700', color: 'var(--text-primary)' }}>
                {calcBags(parseFloat(currentRules.potash))}
              </span>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '4px' }}>MOP (Potash)</p>
            </div>
          </div>

          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', display: 'flex', gap: '6px', alignItems: 'start', marginTop: '4px' }}>
            <Info size={14} style={{ flexShrink: 0, marginTop: '2px' }} />
            <span>{currentRules.fertilizerNote}</span>
          </div>
        </div>

      </div>

      {/* Irrigation advice */}
      <div className="glass-panel" style={{ padding: '20px', display: 'flex', alignItems: 'center', gap: '16px' }}>
        <div style={{ background: 'var(--secondary-glow)', color: 'var(--secondary-cyan)', padding: '12px', borderRadius: '12px' }}>
          <Droplets size={28} />
        </div>
        <div>
          <h4 style={{ fontSize: '0.95rem', fontWeight: '600' }}>
            💧 {formatText("सिंचाई जल आवश्यकता", "Water Irrigation Guidelines")}
          </h4>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
            {currentRules.waterNeeds}
          </p>
        </div>
      </div>

    </div>
  );
}
