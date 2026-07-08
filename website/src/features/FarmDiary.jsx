// 📓 Krushi Mitra Pro — Farm Diary
import React, { useState } from 'react';
import { getDiaryAnalysis } from '../services/ai';
import { BookOpen, Plus, IndianRupee, Trash2, TrendingUp, Sparkles, CheckCircle } from 'lucide-react';

export default function FarmDiary({ diaryEntries, setDiaryEntries, profile, apiKey }) {
  const [activity, setActivity] = useState('');
  const [cost, setCost] = useState('');
  const [isExpense, setIsExpense] = useState(true);
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);

  // AI advisory state
  const [aiReport, setAiReport] = useState('');
  const [loadingAI, setLoadingAI] = useState(false);

  const lang = profile.language || 'hi';

  const formatText = (textHi, textEn) => {
    return lang === 'hi' ? textHi : textEn;
  };

  const handleAddEntry = (e) => {
    e.preventDefault();
    if (!activity.trim() || !cost) return;

    const newEntry = {
      id: Date.now().toString(),
      activity: activity.trim(),
      cost: parseFloat(cost),
      isExpense: isExpense,
      date: date
    };

    const updated = [newEntry, ...diaryEntries];
    setDiaryEntries(updated);
    localStorage.setItem('krushi_diary_entries', JSON.stringify(updated));

    // Reset inputs
    setActivity('');
    setCost('');
    setAiReport('');
  };

  const handleDeleteEntry = (id) => {
    const updated = diaryEntries.filter(entry => entry.id !== id);
    setDiaryEntries(updated);
    localStorage.setItem('krushi_diary_entries', JSON.stringify(updated));
    setAiReport('');
  };

  // Sums
  const income = diaryEntries.filter(e => !e.isExpense).reduce((sum, e) => sum + parseFloat(e.cost || 0), 0);
  const expense = diaryEntries.filter(e => e.isExpense).reduce((sum, e) => sum + parseFloat(e.cost || 0), 0);
  const totalBalance = income - expense;

  const handleGetAdvisory = async () => {
    setLoadingAI(true);
    setAiReport('');
    try {
      const response = await getDiaryAnalysis({ profile, diaryEntries }, apiKey);
      setAiReport(response);
    } catch (e) {
      setAiReport("⚠️ Failed to generate financial analysis. Please configure your API key.");
    } finally {
      setLoadingAI(false);
    }
  };

  const renderMarkdown = (text) => {
    return text.split('\n').map((line, idx) => {
      let content = line;
      content = content.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
      const isHeader = content.startsWith('### ');
      const isBullet = content.trim().startsWith('* ') || content.trim().startsWith('- ');
      const isBoldLine = content.startsWith('**');

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
          <BookOpen style={{ color: 'var(--primary-emerald)' }} />
          {formatText("फार्म डायरी - बहीखाता", "Farm Diary & Accounting")}
        </h2>
        <p style={{ color: 'var(--text-secondary)' }}>
          {formatText(
            "अपने दैनिक कृषि कार्यों, खर्चों और आय का हिसाब रखें और एआई वित्तीय सलाह प्राप्त करें।",
            "Record your daily farming operations, fertilizer costs, seed purchases, and crop sale revenues."
          )}
        </p>
      </div>

      {/* Financial Overview Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '16px' }}>
        <div className="glass-panel" style={{ padding: '16px', borderLeft: '4px solid var(--success)' }}>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{formatText("कुल आय", "Total Income")}</span>
          <h2 style={{ fontSize: '1.5rem', color: 'var(--success)', marginTop: '4px' }}>₹{income.toLocaleString()}</h2>
        </div>
        <div className="glass-panel" style={{ padding: '16px', borderLeft: '4px solid var(--error)' }}>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{formatText("कुल खर्च", "Total Expenses")}</span>
          <h2 style={{ fontSize: '1.5rem', color: 'var(--error)', marginTop: '4px' }}>₹{expense.toLocaleString()}</h2>
        </div>
        <div className="glass-panel" style={{ padding: '16px', borderLeft: `4px solid ${totalBalance >= 0 ? 'var(--primary-emerald)' : 'var(--error)'}` }}>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{formatText("शुद्ध लाभ/हानि", "Net Profit/Loss")}</span>
          <h2 style={{ fontSize: '1.5rem', color: totalBalance >= 0 ? 'var(--primary-emerald)' : 'var(--error)', marginTop: '4px' }}>
            ₹{totalBalance.toLocaleString()}
          </h2>
        </div>
      </div>

      {/* Main layout split */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px', alignItems: 'start' }}>
        
        {/* Form and entries list */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          
          {/* Add Entry Form */}
          <div className="glass-panel" style={{ padding: '20px' }}>
            <h3 style={{ fontSize: '1rem', marginBottom: '14px' }}>
              ✍️ {formatText("नया लेनदेन जोड़ें", "Add New Log Entry")}
            </h3>
            <form onSubmit={handleAddEntry} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              
              <div style={{ display: 'flex', gap: '10px' }}>
                <button 
                  type="button" 
                  onClick={() => setIsExpense(true)}
                  className="btn-secondary" 
                  style={{ flex: 1, justifyContent: 'center', borderColor: isExpense ? 'var(--error)' : 'var(--border-outline)', background: isExpense ? 'rgba(239, 68, 68, 0.05)' : 'transparent' }}
                >
                  🔴 {formatText("खर्च", "Expense")}
                </button>
                <button 
                  type="button" 
                  onClick={() => setIsExpense(false)}
                  className="btn-secondary" 
                  style={{ flex: 1, justifyContent: 'center', borderColor: !isExpense ? 'var(--success)' : 'var(--border-outline)', background: !isExpense ? 'rgba(34, 197, 94, 0.05)' : 'transparent' }}
                >
                  🟢 {formatText("आय", "Income")}
                </button>
              </div>

              <div>
                <input 
                  type="text" 
                  placeholder={isExpense ? formatText("जैसे: यूरिया खाद, ट्रैक्टर जुताई, मजदूर", "E.g., Urea Fertilizer, Tillage labor") : formatText("जैसे: गेहूं बिक्री, टमाटर बिक्री", "E.g., Tomato harvest sale, Cotton selling")}
                  value={activity}
                  onChange={(e) => setActivity(e.target.value)}
                  className="form-input"
                  required
                />
              </div>

              <div style={{ display: 'flex', gap: '10px' }}>
                <input 
                  type="number" 
                  placeholder={formatText("राशि (₹)", "Amount (₹)")}
                  value={cost}
                  onChange={(e) => setCost(e.target.value)}
                  className="form-input"
                  style={{ flex: 2 }}
                  min="1"
                  required
                />
                <input 
                  type="date" 
                  value={date}
                  onChange={(e) => setDate(e.target.value)}
                  className="form-input"
                  style={{ flex: 3 }}
                  required
                />
              </div>

              <button type="submit" className="btn-primary" style={{ width: '100%', justifyContent: 'center', marginTop: '4px' }}>
                <Plus size={18} /> {formatText("डायरी में सहेजें", "Add Entry")}
              </button>
            </form>
          </div>

          {/* Entries list */}
          <div className="glass-panel" style={{ padding: '20px', maxHeight: '350px', overflowY: 'auto' }}>
            <h3 style={{ fontSize: '1rem', marginBottom: '12px' }}>
              📋 {formatText("हालिया लेनदेन सूची", "Transaction Ledger")}
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {diaryEntries.map((entry) => (
                <div 
                  key={entry.id}
                  style={{ 
                    display: 'flex', 
                    justifyContent: 'space-between', 
                    alignItems: 'center', 
                    padding: '10px 12px', 
                    background: 'rgba(255,255,255,0.01)', 
                    border: '1px solid var(--glass-border)',
                    borderRadius: '8px'
                  }}
                >
                  <div>
                    <h4 style={{ fontSize: '0.85rem', color: 'var(--text-primary)' }}>{entry.activity}</h4>
                    <span style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>{entry.date}</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <span style={{ fontSize: '0.9rem', fontWeight: '600', color: entry.isExpense ? 'var(--error)' : 'var(--success)' }}>
                      {entry.isExpense ? '-' : '+'}₹{entry.cost.toLocaleString()}
                    </span>
                    <button 
                      onClick={() => handleDeleteEntry(entry.id)}
                      style={{ background: 'transparent', border: 'none', color: 'var(--text-disabled)', cursor: 'pointer' }}
                      onMouseOver={(e) => e.currentTarget.style.color = 'var(--error)'}
                      onMouseOut={(e) => e.currentTarget.style.color = 'var(--text-disabled)'}
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                </div>
              ))}
              {diaryEntries.length === 0 && (
                <p style={{ textAlign: 'center', color: 'var(--text-secondary)', fontSize: '0.85rem', padding: '20px' }}>
                  {formatText("डायरी खाली है। पहला कार्य जोड़ें!", "No logs recorded yet. Add your first operation!")}
                </p>
              )}
            </div>
          </div>

        </div>

        {/* AI Financial Advisor */}
        <div className="glass-panel" style={{ padding: '24px', minHeight: '380px' }}>
          <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--primary-emerald)', borderBottom: '1px solid var(--border-outline)', paddingBottom: '12px', marginBottom: '16px' }}>
            <Sparkles size={20} />
            {formatText("एआई वित्तीय स्वास्थ्य रिपोर्ट", "AI Financial Advisory")}
          </h3>

          {aiReport ? (
            <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {renderMarkdown(aiReport)}
              <button onClick={handleGetAdvisory} className="btn-secondary" style={{ marginTop: '16px', alignSelf: 'flex-start', fontSize: '0.8rem', padding: '6px 12px' }}>
                <RefreshCw size={12} /> {formatText("पुनः विश्लेषण करें", "Re-Analyze")}
              </button>
            </div>
          ) : loadingAI ? (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '260px', gap: '16px' }}>
              <div style={{ width: '30px', height: '30px', border: '3px solid var(--border-outline)', borderTopColor: 'var(--primary-emerald)', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Analyzing farm expenses ledger...</p>
            </div>
          ) : (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-secondary)' }}>
              <TrendingUp size={48} style={{ margin: '0 auto 16px', opacity: '0.5' }} />
              <p style={{ fontSize: '0.85rem', marginBottom: '16px', lineHeight: '1.6' }}>
                {formatText(
                  "एआई आपके खर्चों और आय के बहीखाते का ऑडिट करेगा, और आपको मुनाफे बढ़ाने के लिए 3 विशिष्ट उपाय सुझाएगा।",
                  "AI will audit your transaction log to find high expense leakages and suggest profit-maximizing steps."
                )}
              </p>
              <button 
                onClick={handleGetAdvisory} 
                disabled={diaryEntries.length === 0}
                className="btn-primary" 
                style={{ padding: '8px 16px', fontSize: '0.82rem' }}
              >
                {formatText("वित्तीय विश्लेषण करें", "Run Financial Analysis")}
              </button>
            </div>
          )}
        </div>

      </div>

    </div>
  );
}
