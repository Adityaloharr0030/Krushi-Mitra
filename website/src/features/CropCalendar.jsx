// 📅 Krushi Mitra Pro — Crop Calendar
import React, { useState } from 'react';
import { Calendar as CalendarIcon, CalendarClock, Sprout, Droplets, Scissors, ShieldAlert, ShoppingBag, CheckSquare, Square } from 'lucide-react';

export default function CropCalendar({ profile }) {
  const [selectedCrop, setSelectedCrop] = useState(profile.cropsGrown?.[0] || 'Tomato');
  const [sowingDate, setSowingDate] = useState(new Date().toISOString().split('T')[0]);
  const [checkedTasks, setCheckedTasks] = useState({});

  const lang = profile.language || 'hi';

  const formatText = (textHi, textEn) => {
    return lang === 'hi' ? textHi : textEn;
  };

  const cropSchedules = {
    Tomato: [
      { days: 0, icon: <Sprout size={16} />, title: "Sowing", titleHi: "नर्सरी बुवाई", desc: "Sow seeds in nursery beds with vermicompost.", descHi: "कोकोपीट और केंचुआ खाद मिलाकर प्रो-ट्रे या नर्सरी क्यारी में बुवाई करें।" },
      { days: 25, icon: <Sprout size={16} />, title: "Transplanting", titleHi: "पौध रोपण", desc: "Transplant 25-day seedlings to main field with spacing.", descHi: "मुख्य खेत में मेड़ बनाकर पौधों का रोपण करें। ड्रिप लैटरल स्थापित करें।" },
      { days: 35, icon: <Droplets size={16} />, title: "Irrigation & Staking", titleHi: "सिंचाई और सहारा देना", desc: "Stake plants with bamboo. Apply water through drip.", descHi: "टमाटर के पौधों को बांस और रस्सी के सहारे बांधें। हल्की सिंचाई करें।" },
      { days: 45, icon: <Scissors size={16} />, title: "First Pruning", titleHi: "छंटाई और खाद", desc: "Remove side suckers. Apply basal dose of NPK.", descHi: "निचली शाखाओं (सकर्स) की कटाई करें। 19:19:19 घुलनशील खाद दें।" },
      { days: 60, icon: <ShieldAlert size={16} />, title: "Pest monitoring", titleHi: "कीट निगरानी", desc: "Check for leaf miners/whiteflies. Spray neem oil.", descHi: "सफ़ेद मक्खी और फल छेदक कीटों के लिए फेरोमोन और पीले चिपचिपे कार्ड लगाएं।" },
      { days: 75, icon: <Droplets size={16} />, title: "Fruiting Spray", titleHi: "फल विकास सिंचाई", desc: "Apply Calcium Nitrate to prevent blossom end rot.", descHi: "कैल्शियम नाइट्रेट (2 ग्राम/लीटर) छिड़कें जिससे टमाटर गलने न पाएं।" },
      { days: 90, icon: <ShoppingBag size={16} />, title: "First Harvest", titleHi: "पहली तुड़ाई", desc: "Pick firm pink/red fruits for local mandi dispatch.", descHi: "बाजार भेजने के लिए थोड़े लाल-गुलाबी टमाटरों की पहली तुड़ाई शुरू करें।" }
    ],
    Wheat: [
      { days: 0, icon: <Sprout size={16} />, title: "Sowing", titleHi: "गेहूं बुवाई", desc: "Sow seeds with seed drill. Apply DAP basal dose.", descHi: "सीड ड्रिल से 4-5 सेमी गहराई पर बुवाई करें। प्रति एकड़ 50 किलो डीएपी दें।" },
      { days: 21, icon: <Droplets size={16} />, title: "CRI Stage Irrigation", titleHi: "ताज जड़ अवस्था सिंचाई", desc: "Most critical irrigation. Apply first split of Urea.", descHi: "अत्यंत महत्वपूर्ण प्रथम सिंचाई (CRI चरण)। प्रति एकड़ 40 किलो यूरिया डालें।" },
      { days: 45, icon: <Scissors size={16} />, title: "Tillering stage", titleHi: "कल्ले निकलने की सिंचाई", desc: "Second irrigation. Spray zinc sulphate if yellowing.", descHi: "कल्ले फूटने के दौरान दूसरी सिंचाई दें। पीलापन दिखने पर जिंक छिड़कें।" },
      { days: 65, icon: <ShieldAlert size={16} />, title: "Weed Control", titleHi: "खरपतवार नियंत्रण", desc: "Remove weeds manually or apply selective herbicide.", descHi: "मैन्युअल निराई करें या सकरी पत्ती वाले खरपतवारनाशक का छिड़काव करें।" },
      { days: 85, icon: <Droplets size={16} />, title: "Flowering Irrigation", titleHi: "फूल निकलने पर सिंचाई", desc: "Third critical irrigation during spike emergence.", descHi: "फूल (बालियां) आने के समय खेत में नमी सुनिश्चित करने के लिए सिंचाई करें।" },
      { days: 105, icon: <Droplets size={16} />, title: "Milk Stage Irrigation", titleHi: "दुग्ध अवस्था सिंचाई", desc: "Maintain light soil moisture for heavy grains.", descHi: "दाने में दूध भरने की अवस्था। हवा तेज होने पर शाम को सिंचाई करें।" },
      { days: 125, icon: <ShoppingBag size={16} />, title: "Harvesting", titleHi: "फसल कटाई", desc: "Harvest when ears turn yellow-brown and grains hard.", descHi: "जब बालियां पीली-सुनहरी और सूखी हो जाएं, तो कम्बाइन हार्वेस्टर से कटाई करें।" }
    ],
    Rice: [
      { days: 0, icon: <Sprout size={16} />, title: "Sowing Nursery", titleHi: "नर्सरी बुवाई", desc: "Raise seeds in wet nursery bed.", descHi: "गीली क्यारी विधि से धान की पौध तैयार करने के लिए बुवाई करें।" },
      { days: 25, icon: <Sprout size={16} />, title: "Transplanting", titleHi: "धान रोपाई", desc: "Transplant in puddled soil with 2-3 seedlings/hill.", descHi: "कद्दू (पडलिंग) किए हुए खेत में 20x10 सेमी दूरी पर पौध रोपाई करें।" },
      { days: 40, icon: <Droplets size={16} />, title: "Tillering Water", titleHi: "कल्ले फूटने पर पानी", desc: "Maintain 5 cm standing water in main fields.", descHi: "कल्ले फूटने के समय खेत में 3-5 सेमी पानी भरकर रखें।" }
    ]
  };

  const schedule = cropSchedules[selectedCrop] || cropSchedules.Tomato;

  const calculateDate = (days) => {
    const base = new Date(sowingDate);
    base.setDate(base.getDate() + days);
    return base.toLocaleDateString(lang === 'hi' ? 'hi-IN' : 'en-IN', {
      day: 'numeric',
      month: 'short',
      year: 'numeric'
    });
  };

  const toggleTask = (idx) => {
    const key = `${selectedCrop}_${sowingDate}_${idx}`;
    setCheckedTasks(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Header */}
      <div className="glass-panel" style={{ padding: '24px' }}>
        <h2 style={{ fontSize: '1.4rem', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <CalendarClock style={{ color: 'var(--primary-emerald)' }} />
          {formatText("फसल कैलेंडर - शेड्यूलर", "Crop Planting Calendar Scheduler")}
        </h2>
        <p style={{ color: 'var(--text-secondary)' }}>
          {formatText(
            "अपनी बुवाई की तिथि दर्ज करें और पूरी फसल अवधि के दौरान होने वाले कार्यों की चरण-दर-चरण समय-सारणी प्राप्त करें।",
            "Generate a custom crop timeline showing weeding, fertilizing, and watering checkpoints based on your sowing date."
          )}
        </p>
      </div>

      {/* Input row */}
      <div className="glass-panel" style={{ padding: '20px', display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
        <div style={{ flex: 1, minWidth: '200px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
            {formatText("फसल का नाम", "Crop Name")}
          </label>
          <select 
            value={selectedCrop} 
            onChange={(e) => setSelectedCrop(e.target.value)}
            className="form-input"
            style={{ padding: '12px' }}
          >
            {Object.keys(cropSchedules).map((crop, idx) => (
              <option key={idx} value={crop}>{crop}</option>
            ))}
          </select>
        </div>
        <div style={{ flex: 1, minWidth: '200px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
            {formatText("बुवाई की तारीख", "Sowing Date")}
          </label>
          <input 
            type="date" 
            value={sowingDate} 
            onChange={(e) => setSowingDate(e.target.value)}
            className="form-input"
          />
        </div>
      </div>

      {/* Visual Timeline Card */}
      <div className="glass-panel" style={{ padding: '24px', position: 'relative' }}>
        <h3 style={{ fontSize: '1.1rem', marginBottom: '24px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <CalendarIcon size={18} style={{ color: 'var(--primary-emerald)' }} />
          {formatText(`${selectedCrop} कार्य समय-सारणी`, `${selectedCrop} Sowing Milestone Timeline`)}
        </h3>

        {/* Vertical Timeline container */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', position: 'relative', paddingLeft: '24px' }}>
          
          {/* Vertical line indicator */}
          <div style={{ position: 'absolute', left: '7px', top: '10px', bottom: '10px', width: '2px', background: 'var(--border-outline)' }}></div>

          {schedule.map((step, idx) => {
            const isChecked = !!checkedTasks[`${selectedCrop}_${sowingDate}_${idx}`];
            
            return (
              <div 
                key={idx} 
                style={{ 
                  display: 'flex', 
                  gap: '16px', 
                  position: 'relative', 
                  alignItems: 'flex-start',
                  opacity: isChecked ? '0.6' : '1'
                }}
              >
                
                {/* Timeline node icon container */}
                <div 
                  style={{ 
                    position: 'absolute', 
                    left: '-24px', 
                    top: '4px',
                    width: '16px', 
                    height: '16px', 
                    borderRadius: '50%', 
                    background: isChecked ? 'var(--primary-emerald)' : 'var(--bg-surface)', 
                    border: `2px solid ${isChecked ? 'var(--primary-emerald)' : 'var(--border-outline)'}`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    zIndex: 2,
                    boxShadow: '0 0 8px rgba(0,0,0,0.5)'
                  }}
                >
                </div>

                {/* Main Card content */}
                <div 
                  className="glass-panel" 
                  style={{ 
                    flex: 1, 
                    padding: '16px', 
                    display: 'flex', 
                    justifyContent: 'space-between', 
                    alignItems: 'center', 
                    gap: '12px',
                    background: isChecked ? 'rgba(255,255,255,0.01)' : 'var(--glass-bg)',
                    borderColor: isChecked ? 'var(--glass-border)' : 'var(--border-outline)'
                  }}
                >
                  <div style={{ display: 'flex', gap: '14px', alignItems: 'flex-start' }}>
                    <div style={{ background: isChecked ? 'rgba(16, 185, 129, 0.05)' : 'var(--bg-surface-variant)', color: isChecked ? 'var(--primary-emerald)' : 'var(--text-secondary)', padding: '10px', borderRadius: '8px', flexShrink: 0 }}>
                      {step.icon}
                    </div>
                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
                        <h4 style={{ fontSize: '0.92rem', fontWeight: '600' }}>
                          {formatText(step.titleHi, step.title)}
                        </h4>
                        <span className="badge badge-cyan" style={{ fontSize: '0.7rem', padding: '2px 6px' }}>
                          {step.days === 0 ? formatText("बुवाई दिन", "Sowing Day") : formatText(`दिन ${step.days}`, `Day ${step.days}`)}
                        </span>
                      </div>
                      <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px', lineHeight: '1.4' }}>
                        {formatText(step.descHi, step.desc)}
                      </p>
                    </div>
                  </div>

                  <div style={{ textAlign: 'right', display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '8px', flexShrink: 0 }}>
                    <span style={{ fontSize: '0.8rem', color: 'var(--accent-amber)', fontWeight: '500' }}>
                      📅 {calculateDate(step.days)}
                    </span>
                    <button 
                      onClick={() => toggleTask(idx)}
                      style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: isChecked ? 'var(--primary-emerald)' : 'var(--text-disabled)' }}
                    >
                      {isChecked ? <CheckSquare size={20} /> : <Square size={20} />}
                    </button>
                  </div>

                </div>

              </div>
            );
          })}
        </div>
      </div>

    </div>
  );
}
