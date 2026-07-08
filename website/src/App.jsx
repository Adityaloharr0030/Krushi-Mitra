// 🌾 Krushi Mitra Pro — Main App React Framework
import React, { useState, useEffect } from 'react';
import { getSimulatedWeather } from './services/weather';

// Features imports
import Dashboard from './features/Dashboard';
import AIDoctor from './features/AIDoctor';
import AIChatbot from './features/AIChatbot';
import MarketPrices from './features/MarketPrices';
import WeatherForecast from './features/WeatherForecast';
import GovtSchemes from './features/GovtSchemes';
import InputCalculator from './features/InputCalculator';
import FarmDiary from './features/FarmDiary';
import SoilAdvisor from './features/SoilAdvisor';
import CropCalendar from './features/CropCalendar';
import Community from './features/Community';
import Marketplace from './features/Marketplace';
import Profile from './features/Profile';

// Icons
import { 
  LayoutDashboard, Sprout, Bot, BarChart2, CloudSun, Landmark, 
  Calculator, BookOpen, Layers, CalendarClock, MessageSquare, 
  ShoppingBag, User, Menu, X 
} from 'lucide-react';

const TRANSLATIONS = {
  en: {
    dashboard: "Dashboard",
    ai_doctor: "AI Crop Doctor",
    chatbot: "AI Chatbot",
    mandi_prices: "Market Prices",
    weather: "Weather Updates",
    schemes: "Govt Schemes",
    calculator: "Input Calculator",
    diary: "Farm Diary",
    soil: "Soil Advisor",
    calendar: "Crop Calendar",
    community: "Community Feed",
    marketplace: "Marketplace",
    profile: "Profile Settings",
  },
  hi: {
    dashboard: "डैशबोर्ड",
    ai_doctor: "एआई फसल डॉक्टर",
    chatbot: "एआई चैटबॉट",
    mandi_prices: "मंडी भाव",
    weather: "मौसम की जानकारी",
    schemes: "सरकारी योजनाएं",
    calculator: "लागत कैलकुलेटर",
    diary: "फार्म डायरी",
    soil: "मिट्टी सलाहकार",
    calendar: "फसल कैलेंडर",
    community: "किसान मंच",
    marketplace: "फसल बाजार",
    profile: "प्रोफ़ाइल सेटिंग",
  },
  mr: {
    dashboard: "डॅशबोर्ड",
    ai_doctor: "एआय पीक डॉक्टर",
    chatbot: "एआय चॅटबॉट",
    mandi_prices: "बाजार भाव",
    weather: "हवामान अंदाज",
    schemes: "शासकीय योजना",
    calculator: "खर्च कॅल्क्युलेटर",
    diary: "शेत डायरी",
    soil: "माती सल्लागार",
    calendar: "पीक कॅलेंडर",
    community: "शेतकरी मंच",
    marketplace: "पीक बाजार",
    profile: "प्रोफाईल सेटिंग",
  },
  gu: {
    dashboard: "ડૅશબોર્ડ",
    ai_doctor: "એઆઈ પાક ડૉક્ટર",
    chatbot: "એઆઈ ચેટબોટ",
    mandi_prices: "બજાર ભાવો",
    weather: "હવામાન અપડેટ્સ",
    schemes: "સરકારી યોજનાઓ",
    calculator: "ખર્ચ કેલ્ક્યુલેટર",
    diary: "ખેતી ડાયરી",
    soil: "જમીન સલાહકાર",
    calendar: "પાક કેલેન્ડર",
    community: "ખેડૂત મંચ",
    marketplace: "પાક બજાર",
    profile: "પ્રોફાઇલ સેટિંગ્સ",
  },
  te: {
    dashboard: "డ్యాష్‌బోర్డ్",
    ai_doctor: "ఏఐ పంట డాక్టర్",
    chatbot: "ఏఐ చాట్‌బాట్",
    mandi_prices: "మార్కెట్ ధరలు",
    weather: "వాతావరణ అప్‌డేట్స్",
    schemes: "ప్రభుత్వ పథకాలు",
    calculator: "ఖర్చుల కాలిక్యులేటర్",
    diary: "వ్యవసాయ డైరీ",
    soil: "నేల సలహాదారు",
    calendar: "పంట క్యాలెండర్",
    community: "రైతు వేదిక",
    marketplace: "పంట మార్కెట్",
    profile: "ప్రొఫైల్ సెట్టింగులు",
  },
  ta: {
    dashboard: "டாஷ்போர்டு",
    ai_doctor: "ஏஐ பயிர் மருத்துவர்",
    chatbot: "ஏஐ சாட்பாட்",
    mandi_prices: "சந்தை விலைகள்",
    weather: "வானிலை தகவல்கள்",
    schemes: "அரசு திட்டங்கள்",
    calculator: "உள்ளீடு கால்குலேட்டர்",
    diary: "விவசாய நாட்குறிப்பு",
    soil: "மண் ஆலோசகர்",
    calendar: "பயிர் காலண்டர்",
    community: "விவசாயிகள் மன்றம்",
    marketplace: "பயிர் சந்தை",
    profile: "சுயவிவர அமைப்புகள்",
  },
  kn: {
    dashboard: "ಡ್ಯಾಶ್‌ಬೋರ್ಡ್",
    ai_doctor: "ಎಐ ಬೆಳೆ ವೈದ್ಯ",
    chatbot: "ಎಐ ಚಾಟ್‌ಬಾಟ್",
    mandi_prices: "ಮಾರುಕಟ್ಟೆ ದರಗಳು",
    weather: "ಹವಾಮಾನ ಮಾಹಿತಿ",
    schemes: "ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು",
    calculator: "ವೆಚ್ಚ ಕ್ಯಾಲ್ಕುಲೇಟರ್",
    diary: "ಕೃಷಿ ದಿನಚರಿ",
    soil: "ಮಣ್ಣು ಸಲಹೆಗಾರ",
    calendar: "ಬೆಳೆ ಕ್ಯಾಲೆಂಡರ್",
    community: "ರೈತ ಸಂಘ",
    marketplace: "ಬೆಳೆ ಮಾರುಕಟ್ಟೆ",
    profile: "ಪ್ರೊಫೈಲ್ ಸೆಟ್ಟಿಂಗ್ಸ್",
  },
  bn: {
    dashboard: "ড্যাশবোর্ড",
    ai_doctor: "এআই ফসল ডাক্তার",
    chatbot: "এআই চ্যাটবট",
    mandi_prices: "বাজার দর",
    weather: "আবহাওয়া আপডেট",
    schemes: "সরকারি প্রকল্প",
    calculator: "খরচ ক্যালকুলেটর",
    diary: "খামার ডায়েরি",
    soil: "মাটি উপদেষ্টা",
    calendar: "ফসল ক্যালেন্ডার",
    community: "কৃষক ফোরাম",
    marketplace: "ফসল বাজার",
    profile: "প্রোফাইল সেটিংস",
  }
};

const DEFAULT_PROFILE = {
  name: 'Aditya Lohar',
  state: 'Maharashtra',
  district: 'Nashik',
  landSize: '4.5',
  cropsGrown: ['Tomato', 'Wheat'],
  soilType: 'Black Clayey',
  irrigationSource: 'Drip Irrigation',
  language: 'hi',
  apiKey: '',
  avatar: null
};

const INITIAL_DIARY = [
  { id: '1', activity: 'Bought Vermicompost Fertilizer', cost: 1200, isExpense: true, date: '2026-07-06' },
  { id: '2', activity: 'Sowed Premium Tomato Seeds', cost: 850, isExpense: true, date: '2026-07-07' },
  { id: '3', activity: 'Sold Onion harvest at Pimpalgaon Mandi', cost: 24000, isExpense: false, date: '2026-07-08' }
];

const INITIAL_COMMUNITY = [
  {
    id: 'post_1',
    author: 'Ramesh Patil',
    location: 'Nashik, Maharashtra',
    content: 'मेरे प्याज की पत्तियों के सिरे पीले पड़ रहे हैं और वे सूख रहे हैं। क्या यह थ्रिप्स का हमला है? कोई जैविक उपचार बताएं। 🧅',
    tag: 'Pests',
    imageUrl: 'https://images.unsplash.com/photo-1508747703725-719ae2c226e1?q=80&w=500&auto=format&fit=crop',
    likes: 12,
    date: '8 Jul',
    comments: [
      { id: 'c1', author: 'Aditya Lohar', content: 'हाँ रमेश जी, थ्रिप्स के लिए ५ मिली नीम का तेल प्रति लीटर पानी में मिलाकर शाम को छिड़कें। लाभ मिलेगा।', date: 'Just now' }
    ]
  },
  {
    id: 'post_2',
    author: 'Hitesh More',
    location: 'Pune, Maharashtra',
    content: 'Today is perfect weather for wheat sowing. Sowing HD 3086 variety today. Praying for a bountiful harvest! 🌾🙏',
    tag: 'General',
    imageUrl: null,
    likes: 24,
    date: '7 Jul',
    comments: []
  }
];

const INITIAL_LISTINGS = [
  {
    id: 'list_1',
    farmerName: 'Ramesh Patil',
    commodity: 'Onion',
    variety: 'Red',
    quantity: 120,
    unit: 'Quintal',
    pricePerUnit: 1350,
    quality: 'A',
    location: 'Lasalgaon, Maharashtra',
    description: 'Grade-A Red onions, well-cured, low moisture content. Ready for immediate load and dispatch.',
    imageUrl: 'https://images.unsplash.com/photo-1508747703725-719ae2c226e1?q=80&w=500&auto=format&fit=crop',
    phoneNumber: '9876543210',
    isOrganic: true,
    isNegotiable: true,
    deliveryAvailable: true,
    isVerified: true,
    dateListed: '08-07-2026'
  },
  {
    id: 'list_2',
    farmerName: 'Hitesh More',
    commodity: 'Tomato',
    variety: 'Hybrid',
    quantity: 80,
    unit: 'Quintal',
    pricePerUnit: 1800,
    quality: 'A+',
    location: 'Pune, Maharashtra',
    description: 'Fresh organic hybrid tomatoes. Solid texture, uniform red grading. Best for long-distance shipping.',
    imageUrl: 'https://images.unsplash.com/photo-1595855759920-86582396756a?q=80&w=500&auto=format&fit=crop',
    phoneNumber: '8765432109',
    isOrganic: true,
    isNegotiable: false,
    deliveryAvailable: true,
    isVerified: true,
    dateListed: '07-07-2026'
  }
];

export default function KrushiMitraApp() {
  // --- States ---
  const [profile, setProfile] = useState(() => {
    const cached = localStorage.getItem('krushi_profile');
    return cached ? JSON.parse(cached) : DEFAULT_PROFILE;
  });

  const [weather, setWeather] = useState(null);
  const [diaryEntries, setDiaryEntries] = useState(() => {
    const cached = localStorage.getItem('krushi_diary_entries');
    return cached ? JSON.parse(cached) : INITIAL_DIARY;
  });

  const [communityPosts, setCommunityPosts] = useState(() => {
    const cached = localStorage.getItem('krushi_community_posts');
    return cached ? JSON.parse(cached) : INITIAL_COMMUNITY;
  });

  const [listings, setListings] = useState(() => {
    const cached = localStorage.getItem('krushi_marketplace_listings');
    return cached ? JSON.parse(cached) : INITIAL_LISTINGS;
  });

  const [tab, setTab] = useState('dashboard');
  const [toastMessage, setToastMessage] = useState('');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Load weather when district changes
  useEffect(() => {
    async function loadWeather() {
      const data = await getSimulatedWeather(profile.district);
      setWeather(data);
    }
    loadWeather();
  }, [profile.district]);

  // Toast Helper
  const triggerToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3000);
  };

  const t = TRANSLATIONS[profile.language || 'en'];

  // Sidebar navigation options
  const sidebarItems = [
    { key: 'dashboard', label: t.dashboard, icon: <LayoutDashboard size={20} /> },
    { key: 'ai_doctor', label: t.ai_doctor, icon: <Sprout size={20} /> },
    { key: 'chatbot', label: t.chatbot, icon: <Bot size={20} /> },
    { key: 'mandi_prices', label: t.mandi_prices, icon: <BarChart2 size={20} /> },
    { key: 'weather', label: t.weather, icon: <CloudSun size={20} /> },
    { key: 'schemes', label: t.schemes, icon: <Landmark size={20} /> },
    { key: 'calculator', label: t.calculator, icon: <Calculator size={20} /> },
    { key: 'diary', label: t.diary, icon: <BookOpen size={20} /> },
    { key: 'soil', label: t.soil, icon: <Layers size={20} /> },
    { key: 'calendar', label: t.calendar, icon: <CalendarClock size={20} /> },
    { key: 'community', label: t.community, icon: <MessageSquare size={20} /> },
    { key: 'marketplace', label: t.marketplace, icon: <ShoppingBag size={20} /> },
    { key: 'profile', label: t.profile, icon: <User size={20} /> },
  ];

  return (
    <div style={{ display: 'flex', width: '100%', height: '100vh', background: 'var(--bg-obsidian)', overflow: 'hidden' }}>
      
      {/* Toast popup */}
      {toastMessage && (
        <div style={{ position: 'fixed', top: '24px', right: '24px', background: 'var(--primary-emerald)', color: 'white', padding: '12px 24px', borderRadius: '8px', zIndex: 1000, boxShadow: '0 8px 24px rgba(16, 185, 129, 0.4)', fontWeight: '500', animation: 'fadeIn 0.2s' }}>
          {toastMessage}
        </div>
      )}

      {/* --- Sidebar Navigation (Desktop) --- */}
      <div 
        className="glass-panel" 
        style={{ 
          width: '260px', 
          height: 'calc(100vh - 24px)', 
          margin: '12px',
          padding: '20px 10px',
          display: 'flex', 
          flexDirection: 'column', 
          justifyContent: 'space-between',
          flexShrink: 0,
          borderRight: '1px solid var(--glass-border)'
        }}
      >
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', overflowY: 'auto' }}>
          {/* Logo */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '0 10px 10px', borderBottom: '1px solid var(--border-outline)' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '36px', height: '36px', borderRadius: '10px', background: 'linear-gradient(135deg, var(--primary-emerald), var(--secondary-cyan))', color: 'white', fontSize: '1.2rem', fontWeight: 'bold' }}>
              K
            </div>
            <div>
              <h2 style={{ fontSize: '1rem', fontWeight: 'bold', letterSpacing: '0.05em' }}>
                KRUSHI MITRA
              </h2>
              <span style={{ fontSize: '0.65rem', color: 'var(--secondary-cyan)', fontWeight: '600', letterSpacing: '0.1em', textTransform: 'uppercase' }}>
                Pro Companion
              </span>
            </div>
          </div>

          {/* Quick Language Changer (Desktop) */}
          <div style={{ padding: '0 10px' }}>
            <select
              value={profile.language}
              onChange={(e) => {
                const newLang = e.target.value;
                const updatedProfile = { ...profile, ...{ language: newLang } };
                setProfile(updatedProfile);
                localStorage.setItem('krushi_profile', JSON.stringify(updatedProfile));
                triggerToast(`Language switched to ${e.target.options[e.target.selectedIndex].text}! 🌾`);
              }}
              className="form-input"
              style={{
                padding: '6px 10px',
                fontSize: '0.8rem',
                background: 'rgba(2, 6, 23, 0.4)',
                borderColor: 'var(--border-outline)',
                color: 'var(--text-primary)',
                borderRadius: '8px',
                cursor: 'pointer',
                width: '100%'
              }}
            >
              <option value="en">🇺🇸 English</option>
              <option value="hi">🇮🇳 हिंदी (Hindi)</option>
              <option value="mr">🇮🇳 मराठी (Marathi)</option>
              <option value="gu">🇮🇳 ગુજરાતી (Gujarati)</option>
              <option value="te">🇮🇳 తెలుగు (Telugu)</option>
              <option value="ta">🇮🇳 தமிழ் (Tamil)</option>
              <option value="kn">🇮🇳 ಕನ್ನಡ (Kannada)</option>
              <option value="bn">🇮🇳 বাংলা (Bengali)</option>
            </select>
          </div>

          {/* Navigation Links */}
          <nav style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            {sidebarItems.map((item) => {
              const active = tab === item.key;
              return (
                <button
                  key={item.key}
                  onClick={() => setTab(item.key)}
                  className="btn-secondary"
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    width: '100%',
                    padding: '10px 14px',
                    background: active ? 'linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(6, 182, 212, 0.03) 100%)' : 'transparent',
                    borderColor: active ? 'var(--primary-emerald)' : 'transparent',
                    color: active ? 'var(--text-primary)' : 'var(--text-secondary)',
                    fontWeight: active ? '600' : '400',
                    justifyContent: 'flex-start'
                  }}
                >
                  <span style={{ color: active ? 'var(--primary-emerald)' : 'inherit' }}>
                    {item.icon}
                  </span>
                  <span style={{ fontSize: '0.85rem' }}>{item.label}</span>
                </button>
              );
            })}
          </nav>
        </div>

        {/* Download App CTA (Desktop Sidebar) */}
        <div style={{ padding: '0 10px', marginBottom: '8px' }}>
          <a 
            href="/Krushi_Mitra_Pro.apk" 
            download="Krushi_Mitra_Pro.apk"
            onClick={() => {
              triggerToast(
                profile.language === 'hi' ? "कृषि मित्र प्रो एपीके डाउनलोड हो रहा है..." :
                profile.language === 'mr' ? "कृषी मित्र प्रो एपीके डाउनलोड होत आहे..." :
                "Downloading Krushi Mitra Pro APK... 📲"
              );
            }}
            className="btn-primary" 
            style={{ 
              width: '100%', 
              justifyContent: 'center', 
              fontSize: '0.8rem', 
              padding: '10px',
              background: 'linear-gradient(135deg, var(--primary-emerald), var(--secondary-cyan))',
              boxShadow: '0 4px 12px rgba(16, 185, 129, 0.2)'
            }}
          >
            📲 {
              profile.language === 'hi' ? "ऐप डाउनलोड करें" : 
              profile.language === 'mr' ? "अॅप डाउनलोड करा" : 
              "Download App"
            }
          </a>
        </div>

        {/* Footer author */}
        <div style={{ padding: '10px', borderTop: '1px solid var(--border-outline)', fontSize: '0.72rem', color: 'var(--text-disabled)', textAlign: 'center' }}>
          Made with ❤️ for Indian Farmers 🌾
        </div>
      </div>

      {/* --- Mobile Top Header --- */}
      <div 
        style={{ 
          display: 'none', 
          flexDirection: 'column', 
          width: '100%' 
        }} 
        className="mobile-header-panel"
      >
        <div style={{ height: '60px', padding: '0 16px', borderBottom: '1px solid var(--border-outline)', background: 'var(--bg-surface)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '28px', height: '28px', borderRadius: '6px', background: 'linear-gradient(135deg, var(--primary-emerald), var(--secondary-cyan))', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', fontSize: '0.9rem' }}>K</div>
            <h3 style={{ fontSize: '0.9rem', fontWeight: 'bold' }}>KRUSHI MITRA PRO</h3>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <select
              value={profile.language}
              onChange={(e) => {
                const newLang = e.target.value;
                const updatedProfile = { ...profile, ...{ language: newLang } };
                setProfile(updatedProfile);
                localStorage.setItem('krushi_profile', JSON.stringify(updatedProfile));
                triggerToast(`Language: ${e.target.options[e.target.selectedIndex].text}! 🌾`);
              }}
              className="form-input"
              style={{
                padding: '4px 6px',
                fontSize: '0.72rem',
                background: 'rgba(2, 6, 23, 0.4)',
                borderColor: 'var(--border-outline)',
                color: 'var(--text-primary)',
                borderRadius: '6px',
                cursor: 'pointer',
                width: '80px',
                height: '32px'
              }}
            >
              <option value="en">🇺🇸 EN</option>
              <option value="hi">🇮🇳 HI</option>
              <option value="mr">🇮🇳 MR</option>
              <option value="gu">🇮🇳 GU</option>
              <option value="te">🇮🇳 TE</option>
              <option value="ta">🇮🇳 TA</option>
              <option value="kn">🇮🇳 KN</option>
              <option value="bn">🇮🇳 BN</option>
            </select>
            
            <button 
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="btn-secondary" 
              style={{ padding: '6px', height: '32px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
            >
              {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation Drawer */}
        {mobileMenuOpen && (
          <div style={{ position: 'absolute', top: '60px', left: 0, width: '100vw', height: 'calc(100vh - 60px)', background: 'var(--bg-obsidian)', zIndex: 99, padding: '16px', display: 'flex', flexDirection: 'column', gap: '8px', overflowY: 'auto' }}>
            {sidebarItems.map((item) => {
              const active = tab === item.key;
              return (
                <button
                  key={item.key}
                  onClick={() => {
                    setTab(item.key);
                    setMobileMenuOpen(false);
                  }}
                  className="btn-secondary"
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    width: '100%',
                    padding: '12px',
                    background: active ? 'rgba(16, 185, 129, 0.05)' : 'transparent',
                    borderColor: active ? 'var(--primary-emerald)' : 'var(--border-outline)'
                  }}
                >
                  <span style={{ color: active ? 'var(--primary-emerald)' : 'inherit' }}>{item.icon}</span>
                  <span style={{ fontSize: '0.85rem' }}>{item.label}</span>
                </button>
              );
            })}
            
            {/* Download App CTA (Mobile Drawer) */}
            <div style={{ marginTop: '16px', padding: '0 4px' }}>
              <a 
                href="/Krushi_Mitra_Pro.apk" 
                download="Krushi_Mitra_Pro.apk"
                onClick={() => {
                  triggerToast(
                    profile.language === 'hi' ? "कृषि मित्र प्रो एपीके डाउनलोड हो रहा है..." :
                    profile.language === 'mr' ? "कृषी मित्र प्रो एपीके डाउनलोड होत आहे..." :
                    "Downloading Krushi Mitra Pro APK... 📲"
                  );
                  setMobileMenuOpen(false);
                }}
                className="btn-primary" 
                style={{ 
                  width: '100%', 
                  justifyContent: 'center', 
                  fontSize: '0.85rem', 
                  padding: '12px',
                  background: 'linear-gradient(135deg, var(--primary-emerald), var(--secondary-cyan))',
                  boxShadow: '0 4px 12px rgba(16, 185, 129, 0.2)'
                }}
              >
                📲 {
                  profile.language === 'hi' ? "ऐप डाउनलोड करें" : 
                  profile.language === 'mr' ? "अॅप डाउनलोड करा" : 
                  "Download App"
                }
              </a>
            </div>
          </div>
        )}
      </div>

      {/* --- Main Contents Panel --- */}
      <div 
        style={{ 
          flex: 1, 
          height: '100vh', 
          overflowY: 'auto', 
          padding: '24px 24px 40px',
          boxSizing: 'border-box'
        }}
        className="main-view-panel"
      >
        {tab === 'dashboard' && (
          <Dashboard 
            profile={profile} 
            weather={weather} 
            diaryEntries={diaryEntries} 
            setTab={setTab} 
            t={t} 
          />
        )}
        
        {tab === 'ai_doctor' && (
          <AIDoctor 
            profile={profile} 
            apiKey={profile.apiKey} 
          />
        )}
        
        {tab === 'chatbot' && (
          <AIChatbot 
            profile={profile} 
            weather={weather} 
            diaryEntries={diaryEntries} 
            t={t} 
          />
        )}
        
        {tab === 'mandi_prices' && (
          <MarketPrices 
            profile={profile} 
            apiKey={profile.apiKey} 
          />
        )}
        
        {tab === 'weather' && (
          <WeatherForecast 
            weather={weather} 
            profile={profile} 
          />
        )}
        
        {tab === 'schemes' && (
          <GovtSchemes 
            profile={profile} 
            apiKey={profile.apiKey} 
          />
        )}
        
        {tab === 'calculator' && (
          <InputCalculator 
            profile={profile} 
          />
        )}
        
        {tab === 'diary' && (
          <FarmDiary 
            diaryEntries={diaryEntries} 
            setDiaryEntries={setDiaryEntries} 
            profile={profile} 
            apiKey={profile.apiKey} 
          />
        )}
        
        {tab === 'soil' && (
          <SoilAdvisor 
            profile={profile} 
            apiKey={profile.apiKey} 
          />
        )}
        
        {tab === 'calendar' && (
          <CropCalendar 
            profile={profile} 
          />
        )}
        
        {tab === 'community' && (
          <Community 
            profile={profile} 
            communityPosts={communityPosts} 
            setCommunityPosts={setCommunityPosts} 
          />
        )}
        
        {tab === 'marketplace' && (
          <Marketplace 
            profile={profile} 
            listings={listings} 
            setListings={setListings} 
            apiKey={profile.apiKey} 
          />
        )}
        
        {tab === 'profile' && (
          <Profile 
            profile={profile} 
            setProfile={setProfile} 
            onSave={() => triggerToast("Profile Settings Saved Successfully! 🌾")} 
            langT={t} 
          />
        )}
      </div>

      {/* CSS adjustments for mobile layouts */}
      <style>{`
        @media (max-width: 1024px) {
          .mobile-header-panel {
            display: flex !important;
          }
          .glass-panel:first-of-type {
            display: none !important;
          }
          .main-view-panel {
            height: calc(100vh - 60px) !important;
            padding: 16px !important;
          }
        }
      `}</style>

    </div>
  );
}
