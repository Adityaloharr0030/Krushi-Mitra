// 🌾 Krushi Mitra Pro — Direct-Sale Marketplace
import React, { useState } from 'react';
import { generateListingDescription } from '../services/ai';
import { Search, Plus, Phone, MessageSquare, ShoppingBag, PlusCircle, Sparkles, Star, CheckCircle, RefreshCw } from 'lucide-react';

export default function Marketplace({ profile, listings, setListings, apiKey }) {
  const [searchTerm, setSearchTerm] = useState('');
  const [showAddListing, setShowAddListing] = useState(false);
  
  // New listing form states
  const [commodity, setCommodity] = useState('Tomato');
  const [variety, setVariety] = useState('');
  const [quantity, setQuantity] = useState('');
  const [unit, setUnit] = useState('Quintal');
  const [pricePerUnit, setPricePerUnit] = useState('');
  const [quality, setQuality] = useState('A');
  const [location, setLocation] = useState(`${profile.district || 'Nashik'}, ${profile.state || 'Maharashtra'}`);
  const [description, setDescription] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('9876543210');
  const [isOrganic, setIsOrganic] = useState(true);
  const [isNegotiable, setIsNegotiable] = useState(true);
  const [deliveryAvailable, setDeliveryAvailable] = useState(true);
  
  const [writingAI, setWritingAI] = useState(false);

  const lang = profile.language || 'hi';

  const formatText = (textHi, textEn) => {
    return lang === 'hi' ? textHi : textEn;
  };

  const handleAddListing = (e) => {
    e.preventDefault();
    if (!quantity || !pricePerUnit) return;

    // Map crop to custom stock pictures
    const stockImages = {
      Wheat: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=500&auto=format&fit=crop",
      Onion: "https://images.unsplash.com/photo-1508747703725-719ae2c226e1?q=80&w=500&auto=format&fit=crop",
      Tomato: "https://images.unsplash.com/photo-1595855759920-86582396756a?q=80&w=500&auto=format&fit=crop",
      Rice: "https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=500&auto=format&fit=crop",
      Potato: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=500&auto=format&fit=crop",
      Soyabean: "https://images.unsplash.com/photo-1599599810769-bcde5a160d32?q=80&w=500&auto=format&fit=crop",
      Cotton: "https://images.unsplash.com/photo-1594761053050-b112507d189f?q=80&w=500&auto=format&fit=crop",
    };

    const newListing = {
      id: `listing_${Date.now()}`,
      farmerName: profile.name || 'Aditya Lohar',
      commodity,
      variety: variety || 'Local',
      quantity: parseFloat(quantity),
      unit,
      pricePerUnit: parseFloat(pricePerUnit),
      quality,
      location,
      description: description || `Fresh Grade-${quality} ${commodity} harvested in ${location}.`,
      imageUrl: stockImages[commodity] || "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=500&auto=format&fit=crop",
      phoneNumber,
      isOrganic,
      isNegotiable,
      deliveryAvailable,
      isVerified: true,
      dateListed: new Date().toLocaleDateString()
    };

    const updated = [newListing, ...listings];
    setListings(updated);
    localStorage.setItem('krushi_marketplace_listings', JSON.stringify(updated));

    // Reset Form
    setVariety('');
    setQuantity('');
    setPricePerUnit('');
    setDescription('');
    setShowAddListing(false);
  };

  const handleAIWrite = async () => {
    if (!quantity || !pricePerUnit) return;
    setWritingAI(true);
    try {
      const details = {
        commodity,
        variety: variety || 'Local',
        quality,
        quantity,
        unit,
        pricePerUnit,
        location,
        isOrganic,
        isNegotiable
      };
      const desc = await generateListingDescription(details, lang, apiKey);
      setDescription(desc);
    } catch (e) {
      console.error(e);
      setDescription("Error writing description. Please enter details manually.");
    } finally {
      setWritingAI(false);
    }
  };

  const getSmsLink = (listing) => {
    const text = `Hi ${listing.farmerName}, I saw your listing for ${listing.quantity} ${listing.unit} of ${listing.commodity} on Krushi Mitra Pro. I am interested.`;
    return `sms:${listing.phoneNumber}?body=${encodeURIComponent(text)}`;
  };

  const getWhatsAppLink = (listing) => {
    const text = `Hi ${listing.farmerName}, I saw your listing for ${listing.quantity} ${listing.unit} of ${listing.commodity} on Krushi Mitra Pro. I am interested.`;
    return `https://wa.me/91${listing.phoneNumber}?text=${encodeURIComponent(text)}`;
  };

  const filteredListings = listings.filter(item =>
    item.commodity.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.location.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Header Info */}
      <div className="glass-panel" style={{ padding: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.4rem', marginBottom: '4px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ShoppingBag style={{ color: 'var(--primary-emerald)' }} />
            {formatText("फसल मंडी बाज़ार", "Marketplace")}
          </h2>
          {/* Marketplace Version Banner (Requirement from DAILY_REPORT.md) */}
          <span style={{ fontSize: '0.72rem', background: 'rgba(6, 182, 212, 0.12)', color: 'var(--secondary-cyan)', padding: '2px 8px', borderRadius: '4px', fontWeight: '600', letterSpacing: '0.04em', textTransform: 'uppercase' }}>
            Version 2.0 - UPDATED TODAY
          </span>
          <p style={{ color: 'var(--text-secondary)', marginTop: '8px' }}>
            {formatText("बिचौलियों के बिना सीधे खरीदारों से संपर्क करें और अपनी फसल बेचें।", "Sell crops directly to wholesalers and retail buyers without intermediate brokers.")}
          </p>
        </div>
        <button onClick={() => setShowAddListing(true)} className="btn-primary">
          <PlusCircle size={18} /> {formatText("नया उत्पाद बेचें", "Post Crop Listing")}
        </button>
      </div>

      {/* Search Input bar */}
      <div className="glass-panel" style={{ padding: '16px', position: 'relative' }}>
        <Search size={18} style={{ position: 'absolute', left: '28px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-secondary)' }} />
        <input 
          type="text" 
          placeholder={formatText("फसल खोजें (जैसे: Tomato, Wheat)...", "Search listing by crop name or district location...")}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="form-input"
          style={{ paddingLeft: '44px', paddingRight: '16px' }}
        />
      </div>

      {/* Grid of Listings */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(290px, 1fr))', gap: '24px' }}>
        {filteredListings.map((item) => (
          <div key={item.id} className="glass-panel" style={{ overflow: 'hidden', display: 'flex', flexDirection: 'column', height: '100%' }}>
            
            {/* Image banner */}
            <div style={{ position: 'relative', height: '150px' }}>
              <img src={item.imageUrl} alt={item.commodity} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              <span className="badge badge-emerald" style={{ position: 'absolute', top: '12px', left: '12px', boxShadow: '0 4px 8px rgba(0,0,0,0.3)' }}>
                ⭐ Grade {item.quality}
              </span>
              {item.isOrganic && (
                <span className="badge badge-cyan" style={{ position: 'absolute', top: '12px', right: '12px', boxShadow: '0 4px 8px rgba(0,0,0,0.3)' }}>
                  Organic
                </span>
              )}
            </div>

            {/* Content Details */}
            <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px', flex: 1, justifyContent: 'space-between' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
                  <h3 style={{ fontSize: '1.15rem' }}>{item.commodity}</h3>
                  <span style={{ fontSize: '1.1rem', fontWeight: '700', color: 'var(--primary-emerald)' }}>
                    ₹{item.pricePerUnit}/{item.unit}
                  </span>
                </div>
                <p style={{ fontSize: '0.78rem', color: 'var(--text-secondary)' }}>
                  📍 {item.location} • {formatText("मात्रा:", "Qty:")} {item.quantity} {item.unit}
                </p>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-primary)', marginTop: '8px', lineHeight: '1.4', display: '-webkit-box', WebkitLineClamp: '3', WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                  {item.description}
                </p>
              </div>

              {/* Tags and Direct Buttons */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '8px' }}>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px', fontSize: '0.7rem' }}>
                  {item.isNegotiable && <span style={{ background: 'rgba(255,255,255,0.03)', padding: '2px 6px', borderRadius: '4px', border: '1px solid var(--glass-border)' }}>Negotiable</span>}
                  {item.deliveryAvailable && <span style={{ background: 'rgba(255,255,255,0.03)', padding: '2px 6px', borderRadius: '4px', border: '1px solid var(--glass-border)' }}>Delivery Available</span>}
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '8px' }}>
                  <a href={`tel:${item.phoneNumber}`} className="btn-secondary" style={{ padding: '8px', fontSize: '0.8rem', justifyContent: 'center' }}>
                    <Phone size={14} /> Call
                  </a>
                  <div style={{ display: 'flex', gap: '4px' }}>
                    <a href={getSmsLink(item)} className="btn-secondary" style={{ padding: '8px', fontSize: '0.8rem', flex: 1, justifyContent: 'center' }}>
                      SMS
                    </a>
                    <a href={getWhatsAppLink(item)} target="_blank" rel="noopener noreferrer" className="btn-primary" style={{ padding: '8px', fontSize: '0.8rem', flex: 1, justifyContent: 'center', background: 'linear-gradient(135deg, #22C55E, #15803D)' }}>
                      WhatsApp
                    </a>
                  </div>
                </div>
              </div>

            </div>

          </div>
        ))}
        {filteredListings.length === 0 && (
          <p style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px', gridColumn: '1 / -1' }}>
            No crop listings found matching your search.
          </p>
        )}
      </div>

      {/* Add Listing Modal */}
      {showAddListing && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.7)', zIndex: 100, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '20px' }}>
          <div className="glass-panel animate-fade-in" style={{ background: 'var(--bg-surface)', width: '100%', maxWidth: '650px', maxHeight: '90vh', overflowY: 'auto', padding: '24px', position: 'relative' }}>
            <button onClick={() => setShowAddListing(false)} className="btn-secondary" style={{ position: 'absolute', right: '16px', top: '16px', padding: '2px 8px', fontSize: '0.8rem' }}>✕</button>
            <h3 style={{ marginBottom: '16px', fontSize: '1.1rem' }}>🌾 {formatText("फसल बिक्री लिस्टिंग बनाएं", "Post Crop Sale Listing")}</h3>
            
            <form onSubmit={handleAddListing} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Crop Name</label>
                  <select value={commodity} onChange={(e) => setCommodity(e.target.value)} className="form-input" style={{ padding: '8px 10px' }}>
                    <option value="Tomato">Tomato</option>
                    <option value="Wheat">Wheat</option>
                    <option value="Cotton">Cotton</option>
                    <option value="Onion">Onion</option>
                    <option value="Rice">Rice</option>
                    <option value="Potato">Potato</option>
                    <option value="Soyabean">Soyabean</option>
                  </select>
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Variety</label>
                  <input type="text" placeholder="E.g., Lokwan, Sharbati" value={variety} onChange={(e) => setVariety(e.target.value)} className="form-input" style={{ padding: '8px 12px' }} />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 2fr', gap: '12px', alignItems: 'end' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Quantity</label>
                  <input type="number" placeholder="100" value={quantity} onChange={(e) => setQuantity(e.target.value)} className="form-input" style={{ padding: '8px 12px' }} required />
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Unit</label>
                  <select value={unit} onChange={(e) => setUnit(e.target.value)} className="form-input" style={{ padding: '8px 10px' }}>
                    <option value="Quintal">Quintal</option>
                    <option value="Kg">Kg</option>
                    <option value="Ton">Ton</option>
                  </select>
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Price per Unit (₹)</label>
                  <input type="number" placeholder="2400" value={pricePerUnit} onChange={(e) => setPricePerUnit(e.target.value)} className="form-input" style={{ padding: '8px 12px' }} required />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Quality Grade</label>
                  <select value={quality} onChange={(e) => setQuality(e.target.value)} className="form-input" style={{ padding: '8px 10px' }}>
                    <option value="A+">A+ (Premium)</option>
                    <option value="A">A (Good)</option>
                    <option value="B">B (Medium)</option>
                  </select>
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Phone Number</label>
                  <input type="text" placeholder="10 digit number" value={phoneNumber} onChange={(e) => setPhoneNumber(e.target.value)} className="form-input" style={{ padding: '8px 12px' }} required />
                </div>
              </div>

              <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.8rem', cursor: 'pointer' }}>
                  <input type="checkbox" checked={isOrganic} onChange={(e) => setIsOrganic(e.target.checked)} />
                  {formatText("जैविक खेती (Organic)", "Organic Sown")}
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.8rem', cursor: 'pointer' }}>
                  <input type="checkbox" checked={isNegotiable} onChange={(e) => setIsNegotiable(e.target.checked)} />
                  {formatText("भाव तोल संभव (Negotiable)", "Negotiable")}
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.8rem', cursor: 'pointer' }}>
                  <input type="checkbox" checked={deliveryAvailable} onChange={(e) => setDeliveryAvailable(e.target.checked)} />
                  {formatText("डिलिवरी उपलब्ध", "Delivery Available")}
                </label>
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                  <label style={{ fontSize: '0.78rem', color: 'var(--text-secondary)' }}>Description</label>
                  <button 
                    type="button" 
                    onClick={handleAIWrite} 
                    disabled={writingAI || !quantity || !pricePerUnit}
                    className="btn-secondary" 
                    style={{ fontSize: '0.72rem', padding: '4px 8px', display: 'flex', gap: '4px', alignItems: 'center' }}
                  >
                    <Sparkles size={12} style={{ color: 'var(--primary-emerald)' }} />
                    {writingAI ? 'Writing...' : 'AI Auto Write'}
                  </button>
                </div>
                <textarea 
                  rows="3" 
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Provide details about moisture content, harvest date, bag packing, etc..." 
                  className="form-input"
                />
              </div>

              <button type="submit" className="btn-primary" style={{ width: '100%', justifyContent: 'center', marginTop: '6px' }}>
                {formatText("मार्केट में सूचीबद्ध करें", "Publish Listing")}
              </button>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
