// 🏛️ Krushi Mitra Pro — Government Schemes
import React, { useState, useEffect } from 'react';
import { checkSchemeEligibility } from '../services/ai';
import { Search, Landmark, Calendar, Award, CheckCircle, FileText, Globe, ExternalLink, Sparkles, RefreshCw } from 'lucide-react';

export default function GovtSchemes({ profile, apiKey }) {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedScheme, setSelectedScheme] = useState(null);
  
  // AI Eligibility states
  const [eligibilityReport, setEligibilityReport] = useState('');
  const [checkingEligibility, setCheckingEligibility] = useState(false);

  const lang = profile.language || 'hi';

  const defaultSchemes = [
    {
      id: "1",
      name: lang === 'hi' ? "प्रधानमंत्री किसान सम्मान निधि (PM-KISAN)" : "PM-Kisan Samman Nidhi",
      description: lang === 'hi' 
        ? "सभी जोतधारक किसान परिवारों को प्रति वर्ष ₹6,000 की तीन समान किस्तों में आय सहायता।" 
        : "Income support of ₹6,000/- per year in three equal installments to all landholding farmer families across India.",
      ministryLogo: "🏛️",
      deadline: "31 Aug 2026",
      benefitAmount: lang === 'hi' ? "₹6,000 / वर्ष" : "₹6,000 / year",
      eligibilityCriteria: [
        lang === 'hi' ? "छोटे और सीमांत किसान" : "Small & marginal farmers",
        lang === 'hi' ? "स्वयं की खेती योग्य भूमि होनी चाहिए" : "Must own cultivable landholding",
        lang === 'hi' ? "आयकर दाता नहीं होना चाहिए" : "Must not be an income taxpayer"
      ],
      requiredDocuments: [
        lang === 'hi' ? "आधार कार्ड" : "Aadhaar Card",
        lang === 'hi' ? "बैंक पासबुक (आधार से जुड़ा हुआ)" : "Bank Passbook seeded with Aadhaar",
        lang === 'hi' ? "खतौनी या भूमि रिकॉर्ड" : "Land ownership document (Khatauni)"
      ],
      howToApply: lang === 'hi'
        ? "1. pmkisan.gov.in पोर्टल पर जाएं।\n2. 'New Farmer Registration' पर क्लिक करें।\n3. आधार नंबर दर्ज करें, ओटीपी सत्यापित करें और जमीन की जानकारी भरें।"
        : "1. Go to pmkisan.gov.in.\n2. Click on 'New Farmer Registration'.\n3. Input Aadhaar number, verify OTP, upload land documents, and submit.",
      websiteLink: "https://pmkisan.gov.in",
      applyLink: "https://pmkisan.gov.in/RegistrationFormNew.aspx",
      helplineNumber: "155261"
    },
    {
      id: "2",
      name: lang === 'hi' ? "प्रधानमंत्री फसल बीमा योजना (PMFBY)" : "PM Fasal Bima Yojana",
      description: lang === 'hi'
        ? "प्राकृतिक आपदाओं, कीटों और रोगों के कारण फसलों के नुकसान की स्थिति में वित्तीय सुरक्षा प्रदान करने के लिए बीमा।"
        : "Crop insurance providing financial support to farmers suffering crop loss/damage arising out of natural calamities, pests & diseases.",
      ministryLogo: "🛡️",
      deadline: "31 Jul 2026",
      benefitAmount: lang === 'hi' ? "फसल नुकसान पर बीमा दावा भुगतान" : "Insurance payout based on crop loss damage",
      eligibilityCriteria: [
        lang === 'hi' ? "सभी किसान (बटाईदार/काश्तकार भी)" : "All farmers (including sharecroppers & tenant farmers)",
        lang === 'hi' ? "अधिसूचित क्षेत्रों में अधिसूचित फसल उगाने वाले" : "Sowing notified crops in notified areas"
      ],
      requiredDocuments: [
        lang === 'hi' ? "आधार कार्ड" : "Aadhaar Card",
        lang === 'hi' ? "बैंक पासबुक" : "Bank Passbook",
        lang === 'hi' ? "बुवाई का प्रमाण पत्र (पटवारी द्वारा)" : "Sowing Certificate / Land ownership documents",
        lang === 'hi' ? "बटाईदार समझौता (यदि लागू हो)" : "Tenant agreement (if applicable)"
      ],
      howToApply: lang === 'hi'
        ? "1. pmfby.gov.in पर जाएं।\n2. 'Farmer Corner' पर क्लिक करें और लॉगिन करें।\n3. फसल, क्षेत्र की जानकारी डालें, प्रीमियम का भुगतान करें (रबी: 1.5%, खरीफ: 2%)।"
        : "1. Visit pmfby.gov.in.\n2. Click on 'Farmer Corner' and register/login.\n3. Input crop details, land area, upload sowing certificate, and pay nominal premium.",
      websiteLink: "https://pmfby.gov.in",
      applyLink: "https://pmfby.gov.in/farmerRegistrationForm",
      helplineNumber: "18001801551"
    },
    {
      id: "3",
      name: lang === 'hi' ? "किसान क्रेडिट कार्ड योजना (KCC)" : "Kisan Credit Card (KCC)",
      description: lang === 'hi'
        ? "खेती की लागत, बीज, खाद और आकस्मिक खर्चों के लिए बहुत कम ब्याज दरों (4%) पर संस्थागत ऋण उपलब्ध कराना।"
        : "Provides farmers with timely credit for cultivation, seeds, fertilizers, and pesticide expenses at heavily subsidized interest rates.",
      ministryLogo: "💳",
      deadline: "N/A",
      benefitAmount: lang === 'hi' ? "₹3,00000 तक का सस्ता लोन" : "Credit up to ₹3 Lakhs at 4% interest rate",
      eligibilityCriteria: [
        lang === 'hi' ? "सभी किसान, मालिक/काश्तकार" : "All farmers, owners, sharecroppers, tenant farmers",
        lang === 'hi' ? "पशुपालन और मत्स्य पालन करने वाले भी पात्र" : "Self-help groups, joint liability groups, animal husbandry farmers"
      ],
      requiredDocuments: [
        lang === 'hi' ? "आधार कार्ड / वोटर आईडी" : "Aadhaar / Voter ID",
        lang === 'hi' ? "भूमि राजस्व रिकॉर्ड (खसरा-खतौनी)" : "Landholding revenue record",
        lang === 'hi' ? "बैंक से अनापत्ति प्रमाण पत्र (NOC)" : "No-dues certificate from nearby bank"
      ],
      howToApply: lang === 'hi'
        ? "1. अपने नजदीकी सरकारी या व्यावसायिक बैंक शाखा में जाएं।\n2. केसीसी आवेदन पत्र भरें।\n3. भूमि रिकॉर्ड जमा करें। बैंक 14 दिनों के भीतर केसीसी जारी करेगा।"
        : "1. Visit your local public/commercial bank.\n2. Fill out the KCC application form.\n3. Submit land ownership certificates and identity proofs. Bank issues card in 14 days.",
      websiteLink: "https://www.sbi.co.in",
      applyLink: "https://pmkisan.gov.in",
      helplineNumber: "1800115526"
    },
    {
      id: "4",
      name: lang === 'hi' ? "मृदा स्वास्थ्य कार्ड योजना" : "Soil Health Card Scheme",
      description: lang === 'hi'
        ? "किसानों को उनकी मिट्टी की पोषण स्थिति की रिपोर्ट प्रदान करना, जिससे वे खाद का सही मात्रा में उपयोग कर सकें।"
        : "Provides soil health cards reports containing chemical/NPK composition to farmers to balance fertilizer doses and soil structure.",
      ministryLogo: "🧪",
      deadline: "N/A",
      benefitAmount: lang === 'hi' ? "निःशुल्क मिट्टी परीक्षण और कार्ड" : "Free soil testing and customized NPK advisories",
      eligibilityCriteria: [
        lang === 'hi' ? "भारत के सभी भू-धारक किसान" : "All landholding farmers in India"
      ],
      requiredDocuments: [
        lang === 'hi' ? "आधार कार्ड" : "Aadhaar Card",
        lang === 'hi' ? "भूमि खसरा विवरण" : "Land khata/survey details"
      ],
      howToApply: lang === 'hi'
        ? "1. अपने खेत से मृदा का नमूना लें।\n2. स्थानीय कृषि सहायक को नमूना सौंपें या कृषि केंद्र पर जाएं।\n3. मृदा स्वास्थ्य पोर्टल पर रिपोर्ट डाउनलोड करें।"
        : "1. Take a soil sample from your farm fields.\n2. Submit it to the local agriculture officer or nearby testing lab.\n3. Report is generated free on the soil health portal.",
      websiteLink: "https://soilhealth.dac.gov.in",
      applyLink: "https://soilhealth.dac.gov.in/farmer-registration",
      helplineNumber: "011-23381092"
    }
  ];

  const filteredSchemes = defaultSchemes.filter(scheme =>
    scheme.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    scheme.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleCheckEligibility = async (scheme) => {
    setCheckingEligibility(true);
    setEligibilityReport('');
    try {
      const report = await checkSchemeEligibility({ profile }, scheme, apiKey);
      setEligibilityReport(report);
    } catch (e) {
      setEligibilityReport("⚠️ AI checking error. Please ensure your API key is configured.");
    } finally {
      setCheckingEligibility(false);
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
        return <h4 key={idx} style={{ color: 'var(--primary-emerald)', margin: '14px 0 6px', fontSize: '1rem' }} dangerouslySetInnerHTML={{ __html: content.substring(4) }} />;
      }
      if (isBullet) {
        return <li key={idx} style={{ marginLeft: '20px', listStyleType: 'disc', fontSize: '0.85rem', marginBottom: '4px' }} dangerouslySetInnerHTML={{ __html: content.trim().substring(2) }} />;
      }
      return <p key={idx} style={{ fontSize: '0.85rem', marginBottom: '6px', lineHeight: '1.5' }} dangerouslySetInnerHTML={{ __html: content }} />;
    });
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Header & Search */}
      <div className="glass-panel" style={{ padding: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.4rem', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Landmark style={{ color: 'var(--primary-emerald)' }} />
            {lang === 'hi' ? 'सरकारी योजनाएं' : lang === 'mr' ? 'शासकीय योजना' : 'Government Schemes'}
          </h2>
          <p style={{ color: 'var(--text-secondary)' }}>
            {lang === 'hi' ? 'किसानों के लिए सब्सिडी, लोन और कृषि विकास योजनाओं की जानकारी' : lang === 'mr' ? 'शेतकऱ्यांसाठीच्या विविध शासकीय योजना आणि अनुदानांची माहिती' : 'Browse central and state government programs, documents required, and check eligibility.'}
          </p>
        </div>
        
        {/* Search Bar */}
        <div style={{ position: 'relative', width: '100%', maxWidth: '300px' }}>
          <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-secondary)' }} />
          <input 
            type="text" 
            placeholder={lang === 'hi' ? "योजना खोजें..." : "Search schemes..."}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="form-input"
            style={{ paddingLeft: '40px', paddingRight: '16px', paddingTop: '10px', paddingBottom: '10px' }}
          />
        </div>
      </div>

      {/* Grid of Schemes */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(290px, 1fr))', gap: '20px' }}>
        {filteredSchemes.map((scheme) => (
          <div key={scheme.id} className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between', gap: '16px' }}>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                <span style={{ fontSize: '1.8rem', background: 'rgba(255,255,255,0.03)', padding: '6px 12px', borderRadius: '8px' }}>
                  {scheme.ministryLogo}
                </span>
                <span className="badge badge-emerald">
                  {scheme.benefitAmount}
                </span>
              </div>
              <h3 style={{ fontSize: '1.05rem', marginBottom: '8px' }}>{scheme.name}</h3>
              <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', display: '-webkit-box', WebkitLineClamp: '3', WebkitBoxOrient: 'vertical', overflow: 'hidden', lineHeight: '1.5' }}>
                {scheme.description}
              </p>
            </div>
            
            <div style={{ display: 'flex', gap: '10px', marginTop: '10px' }}>
              <button 
                onClick={() => {
                  setSelectedScheme(scheme);
                  setEligibilityReport('');
                }} 
                className="btn-primary" 
                style={{ flex: 1, padding: '8px 12px', fontSize: '0.8rem', justifyContent: 'center' }}
              >
                {lang === 'hi' ? 'विवरण देखें' : 'View Details'}
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Details & AI Eligibility Modal */}
      {selectedScheme && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.7)', zIndex: 100, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '20px' }}>
          <div className="glass-panel animate-fade-in" style={{ background: 'var(--bg-surface)', width: '100%', maxWidth: '800px', maxHeight: '90vh', overflowY: 'auto', padding: '30px', position: 'relative' }}>
            
            {/* Close */}
            <button 
              onClick={() => setSelectedScheme(null)} 
              className="btn-secondary" 
              style={{ position: 'absolute', right: '20px', top: '20px', padding: '4px 10px', borderRadius: '4px', fontSize: '0.8rem' }}
            >
              ✕
            </button>

            {/* Scheme Header */}
            <div style={{ borderBottom: '1px solid var(--border-outline)', paddingBottom: '16px', marginBottom: '20px' }}>
              <span style={{ fontSize: '2.5rem', display: 'block', marginBottom: '8px' }}>{selectedScheme.ministryLogo}</span>
              <h2 style={{ fontSize: '1.4rem', color: 'var(--text-primary)' }}>{selectedScheme.name}</h2>
              <p style={{ fontSize: '0.88rem', color: 'var(--text-secondary)', marginTop: '8px', lineHeight: '1.6' }}>
                {selectedScheme.description}
              </p>
            </div>

            {/* Content split */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px' }}>
              
              {/* Rules, Documents & Apply */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div>
                  <h4 style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.9rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                    <Award size={16} /> {lang === 'hi' ? 'पात्रता मानदंड' : 'Eligibility Criteria'}
                  </h4>
                  <ul style={{ paddingLeft: '20px', fontSize: '0.85rem' }}>
                    {selectedScheme.eligibilityCriteria.map((c, i) => <li key={i} style={{ marginBottom: '4px' }}>{c}</li>)}
                  </ul>
                </div>

                <div>
                  <h4 style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.9rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                    <FileText size={16} /> {lang === 'hi' ? 'आवश्यक दस्तावेज' : 'Required Documents'}
                  </h4>
                  <ul style={{ paddingLeft: '20px', fontSize: '0.85rem' }}>
                    {selectedScheme.requiredDocuments.map((d, i) => <li key={i} style={{ marginBottom: '4px' }}>{d}</li>)}
                  </ul>
                </div>

                <div>
                  <h4 style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.9rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                    <Calendar size={16} /> {lang === 'hi' ? 'आवेदन कैसे करें' : 'How to Apply'}
                  </h4>
                  <p style={{ fontSize: '0.82rem', whiteSpace: 'pre-wrap', lineHeight: '1.5' }}>{selectedScheme.howToApply}</p>
                </div>

                {/* External links */}
                <div style={{ display: 'flex', gap: '10px', marginTop: '10px' }}>
                  <a href={selectedScheme.websiteLink} target="_blank" rel="noopener noreferrer" className="btn-secondary" style={{ fontSize: '0.8rem', padding: '8px 12px', flex: 1, justifyContent: 'center' }}>
                    <Globe size={14} /> Official Site
                  </a>
                  <a href={selectedScheme.applyLink} target="_blank" rel="noopener noreferrer" className="btn-primary" style={{ fontSize: '0.8rem', padding: '8px 12px', flex: 1, justifyContent: 'center' }}>
                    Apply Direct <ExternalLink size={14} />
                  </a>
                </div>
              </div>

              {/* AI Checker Panel */}
              <div className="glass-panel" style={{ padding: '20px', background: 'rgba(2, 6, 23, 0.3)', border: '1px solid var(--border-outline)' }}>
                <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--primary-emerald)', marginBottom: '12px', fontSize: '0.95rem' }}>
                  <Sparkles size={16} />
                  {lang === 'hi' ? 'त्वरित एआई पात्रता जांच' : 'AI Eligibility Evaluator'}
                </h4>
                
                {eligibilityReport ? (
                  <div style={{ maxHeight: '300px', overflowY: 'auto', paddingRight: '4px' }}>
                    {renderMarkdown(eligibilityReport)}
                  </div>
                ) : checkingEligibility ? (
                  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px', padding: '40px 0' }}>
                    <div style={{ width: '24px', height: '24px', border: '2px solid var(--border-outline)', borderTopColor: 'var(--primary-emerald)', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Comparing profile metrics...</span>
                  </div>
                ) : (
                  <div>
                    <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '14px', lineHeight: '1.6' }}>
                      {lang === 'hi' 
                        ? 'कृषि मित्र एआई आपके पंजीकृत विवरणों (भूमि आकार, फसलें, राज्य) को पढ़ेगा और आपकी पात्रता का एक विस्तृत विवरण देगा।'
                        : 'Evaluates your configured profile (land acreage, locations, crop tags) against scheme parameters.'}
                    </p>
                    <button onClick={() => handleCheckEligibility(selectedScheme)} className="btn-primary" style={{ padding: '8px 16px', fontSize: '0.8rem', width: '100%', justifyContent: 'center' }}>
                      {lang === 'hi' ? 'पात्रता की जांच करें' : 'Verify Eligibility'}
                    </button>
                  </div>
                )}
              </div>

            </div>

          </div>
        </div>
      )}

    </div>
  );
}
