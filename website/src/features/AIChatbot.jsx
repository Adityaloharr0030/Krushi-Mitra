// 💬 Krushi Mitra Pro — AI Chatbot
import React, { useState, useRef, useEffect } from 'react';
import { chat } from '../services/ai';
import { Send, Bot, User, Mic, Sparkles, RefreshCw } from 'lucide-react';

export default function AIChatbot({ profile, weather, diaryEntries, t }) {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: profile.language === 'hi' 
        ? 'प्रणाम! मैं आपका **कृषि मित्र** हूँ। आप मुझसे खेती-बाड़ी, फसल सुरक्षा, खाद और मंडी भाव से जुड़ा कोई भी सवाल पूछ सकते हैं।' 
        : profile.language === 'mr'
        ? 'नमस्कार! मी आपला **कृषी मित्र** आहे. आपण मला शेती, खते, कीटकनाशके आणि बाजार भाव याबद्दल काहीही विचारू शकता.'
        : 'Hello! I am your **Krushi Mitra** assistant. Ask me anything about crop protection, fertilizer dosage, mandi prices, or weather advisories.'
    }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  
  const messagesEndRef = useRef(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = async (textToSend) => {
    const text = (textToSend || input).trim();
    if (!text) return;

    if (!textToSend) setInput('');

    // Add user message
    const userMsg = { role: 'user', content: text };
    setMessages(prev => [...prev, userMsg]);
    setLoading(true);

    try {
      // Build chat history matching service specifications
      const history = messages
        .filter(m => m.role !== 'assistant' || m.content.length < 500) // prune very long messages to save tokens
        .map(m => ({
          role: m.role,
          content: m.content
        }));

      const context = {
        profile,
        weather,
        diaryEntries
      };

      const responseText = await chat(history, text, context, profile.apiKey);
      
      setMessages(prev => [...prev, { role: 'assistant', content: responseText }]);
    } catch (e) {
      console.error(e);
      setMessages(prev => [...prev, { role: 'assistant', content: "⚠️ Sorry, I encountered an error connecting to the AI brain. Please verify your Gemini API key in settings or try again." }]);
    } finally {
      setLoading(false);
    }
  };

  // Simulated Voice Input
  const handleMicClick = () => {
    if (isRecording) return;
    setIsRecording(true);
    
    const voicePresets = {
      en: "What is the recommended dose of Urea for 1 acre of wheat?",
      hi: "एक एकड़ गेहूं के लिए यूरिया की अनुशंसित मात्रा क्या है?",
      mr: "एक एकर गव्हासाठी युरियाचे किती प्रमाण वापरावे?"
    };

    setTimeout(() => {
      setInput(voicePresets[profile.language] || voicePresets.en);
      setIsRecording(false);
    }, 1500);
  };

  const quickChips = {
    en: [
      "What is the best fertilizer for Tomato?",
      "How to treat Yellow Rust in Wheat?",
      "Suggest organic pesticide for whitefly",
      "Explain crop rotation advantages"
    ],
    hi: [
      "टमाटर के लिए सबसे अच्छा उर्वरक क्या है?",
      "गेहूं में पीला रतुआ का इलाज कैसे करें?",
      "सफ़ेद मक्खी के लिए जैविक कीटनाशक बताइए",
      "फसल चक्र के लाभ समझाएं"
    ],
    mr: [
      "टोमॅटोसाठी सर्वोत्तम खत कोणते आहे?",
      "गव्हावरील तांबेरा रोगाचे नियंत्रण कसे करावे?",
      "पांढऱ्या माशीसाठी सेंद्रिय कीटकनाशक सांगा",
      "पीक फेरपालटाचे फायदे स्पष्ट करा"
    ]
  };

  const chips = quickChips[profile.language] || quickChips.en;

  const renderMarkdown = (text) => {
    // Simple bold/bullet formatter to keep interface premium without heavy MD compiler
    const lines = text.split('\n');
    return lines.map((line, idx) => {
      let content = line;
      
      // Formatting bold (**text**)
      const boldRegex = /\*\*(.*?)\*\*/g;
      content = content.replace(boldRegex, '<strong>$1</strong>');

      // Check for bullet list
      const isBullet = content.trim().startsWith('* ') || content.trim().startsWith('- ');
      const isWarning = content.includes('⚠️');

      if (isBullet) {
        return (
          <li 
            key={idx} 
            dangerouslySetInnerHTML={{ __html: content.trim().substring(2) }} 
            style={{ marginLeft: '16px', listStyleType: 'disc', marginBottom: '4px' }} 
          />
        );
      }

      return (
        <p 
          key={idx} 
          dangerouslySetInnerHTML={{ __html: content }} 
          style={{ 
            marginBottom: '8px', 
            minHeight: '1.2em', 
            color: isWarning ? '#f59e0b' : 'inherit'
          }} 
        />
      );
    });
  };

  return (
    <div className="glass-panel animate-fade-in" style={{ height: 'calc(100vh - 120px)', display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      
      {/* Top Header info */}
      <div style={{ padding: '16px 20px', borderBottom: '1px solid var(--border-outline)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'rgba(2, 6, 23, 0.2)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ background: 'var(--primary-glow)', color: 'var(--primary-emerald)', padding: '8px', borderRadius: '10px' }}>
            <Bot size={20} />
          </div>
          <div>
            <h3 style={{ fontSize: '1rem', fontWeight: '600' }}>Krushi Mitra AI</h3>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
              {profile.apiKey ? 'Connected to Gemini Cloud' : 'Running in Local Expert Database Mode'}
            </p>
          </div>
        </div>
        <button 
          onClick={() => setMessages([{ role: 'assistant', content: messages[0].content }])} 
          className="btn-secondary" 
          style={{ padding: '6px 12px', fontSize: '0.75rem', display: 'flex', gap: '6px', alignItems: 'center' }}
        >
          <RefreshCw size={12} /> {profile.language === 'hi' ? 'साफ करें' : 'Reset'}
        </button>
      </div>

      {/* Messages Scroll viewport */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '20px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
        {messages.map((msg, idx) => {
          const isBot = msg.role === 'assistant';
          return (
            <div 
              key={idx} 
              style={{ 
                display: 'flex', 
                gap: '12px', 
                alignSelf: isBot ? 'flex-start' : 'flex-end',
                maxWidth: '80%',
                flexDirection: isBot ? 'row' : 'row-reverse'
              }}
            >
              {/* Avatar */}
              <div 
                style={{ 
                  width: '32px', 
                  height: '32px', 
                  borderRadius: '8px', 
                  display: 'flex', 
                  alignItems: 'center', 
                  justifyContent: 'center',
                  background: isBot ? 'var(--primary-glow)' : 'var(--secondary-glow)',
                  color: isBot ? 'var(--primary-emerald)' : 'var(--secondary-cyan)',
                  flexShrink: 0
                }}
              >
                {isBot ? <Bot size={16} /> : <User size={16} />}
              </div>

              {/* Message bubble */}
              <div 
                style={{ 
                  background: isBot ? 'rgba(255, 255, 255, 0.02)' : 'var(--bg-surface-variant)',
                  border: isBot ? '1px solid var(--glass-border)' : '1px solid var(--border-outline)',
                  padding: '12px 16px',
                  borderRadius: isBot ? '0px 16px 16px 16px' : '16px 0px 16px 16px',
                  fontSize: '0.9rem',
                  lineHeight: '1.6',
                  color: 'var(--text-primary)'
                }}
              >
                {renderMarkdown(msg.content)}
              </div>
            </div>
          );
        })}

        {loading && (
          <div style={{ display: 'flex', gap: '12px', alignSelf: 'flex-start' }}>
            <div style={{ width: '32px', height: '32px', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyText: 'center', background: 'var(--primary-glow)', color: 'var(--primary-emerald)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Bot size={16} />
            </div>
            <div style={{ background: 'rgba(255, 255, 255, 0.02)', border: '1px solid var(--glass-border)', padding: '12px 16px', borderRadius: '0px 16px 16px 16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div style={{ width: '6px', height: '6px', background: 'var(--primary-emerald)', borderRadius: '50%', animation: 'bounce 1s infinite alternate' }}></div>
              <div style={{ width: '6px', height: '6px', background: 'var(--primary-emerald)', borderRadius: '50%', animation: 'bounce 1s infinite alternate 0.2s' }}></div>
              <div style={{ width: '6px', height: '6px', background: 'var(--primary-emerald)', borderRadius: '50%', animation: 'bounce 1s infinite alternate 0.4s' }}></div>
              <style>{`@keyframes bounce { from { transform: translateY(0); } to { transform: translateY(-4px); } }`}</style>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Suggested chips panel */}
      {messages.length === 1 && (
        <div style={{ padding: '0 20px 16px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <Sparkles size={12} style={{ color: 'var(--accent-amber)' }} />
            {profile.language === 'hi' ? 'सुझाए गए प्रश्न:' : profile.language === 'mr' ? 'सुचवलेले प्रश्न:' : 'Common Questions:'}
          </p>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
            {chips.map((chip, idx) => (
              <button 
                key={idx} 
                onClick={() => handleSend(chip)}
                className="btn-secondary" 
                style={{ fontSize: '0.78rem', padding: '6px 12px', borderRadius: '20px', border: '1px solid var(--glass-border)' }}
              >
                {chip}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Input Form Footer */}
      <div style={{ padding: '16px 20px', borderTop: '1px solid var(--border-outline)', background: 'rgba(2, 6, 23, 0.4)', display: 'flex', gap: '12px', alignItems: 'center' }}>
        <button 
          onClick={handleMicClick}
          className={`btn-secondary ${isRecording ? 'animate-pulse' : ''}`}
          style={{ 
            padding: '12px', 
            borderRadius: '50%', 
            flexShrink: 0,
            borderColor: isRecording ? 'var(--error)' : 'var(--border-outline)',
            color: isRecording ? 'var(--error)' : 'inherit',
            background: isRecording ? 'rgba(239,68,68,0.1)' : 'var(--bg-surface-variant)'
          }}
          title="Simulate Voice Input"
        >
          <Mic size={20} />
        </button>
        
        <input 
          type="text" 
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleSend()}
          placeholder={isRecording ? (profile.language === 'hi' ? "सुन रहा हूँ..." : "Listening...") : (profile.language === 'hi' ? "अपना सवाल यहाँ लिखें..." : profile.language === 'mr' ? "आपला प्रश्न येथे लिहा..." : "Ask a farming question...")}
          disabled={loading || isRecording}
          className="form-input"
          style={{ flex: 1 }}
        />

        <button 
          onClick={() => handleSend()}
          disabled={loading || !input.trim() || isRecording}
          className="btn-primary"
          style={{ padding: '12px', borderRadius: '50%', flexShrink: 0 }}
        >
          <Send size={20} />
        </button>
      </div>

    </div>
  );
}
