import React, { useState } from 'react';
import Navbar from './components/Navbar';
import Dashboard from './pages/Dashboard';
import { motion, AnimatePresence } from 'framer-motion';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard />;
      case 'market':
        return (
          <div className="container" style={{ padding: '20px' }}>
            <h1>Market (Mandi) Prices</h1>
            <p style={{ color: 'var(--text-muted)' }}>Real-time commodity rates from local and national markets.</p>
            <div className="glass-card" style={{ marginTop: '20px', minHeight: '300px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <p>Fetching latest market data...</p>
            </div>
          </div>
        );
      case 'weather':
        return (
          <div className="container" style={{ padding: '20px' }}>
            <h1>Detailed Weather Forecast</h1>
            <p style={{ color: 'var(--text-muted)' }}>7-day outlook for optimal planting and harvesting.</p>
            <div className="glass-card" style={{ marginTop: '20px', minHeight: '300px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <p>Loading weather insights...</p>
            </div>
          </div>
        );
      case 'resources':
        return (
          <div className="container" style={{ padding: '20px' }}>
            <h1>Agri-Resource Center</h1>
            <p style={{ color: 'var(--text-muted)' }}>Expert guides, government schemes, and crop disease management.</p>
            <div className="glass-card" style={{ marginTop: '20px', minHeight: '300px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <p>Accessing knowledge base...</p>
            </div>
          </div>
        );
      default:
        return <Dashboard />;
    }
  };

  return (
    <div style={{ position: 'relative', minHeight: '100vh', paddingBottom: '60px' }}>
      {/* Background Blobs */}
      <div style={{
        position: 'fixed',
        top: '-10%',
        right: '-10%',
        width: '500px',
        height: '500px',
        background: 'radial-gradient(circle, rgba(46,125,50,0.05) 0%, rgba(255,255,255,0) 70%)',
        zIndex: -1
      }} />
      <div style={{
        position: 'fixed',
        bottom: '5%',
        left: '-5%',
        width: '400px',
        height: '400px',
        background: 'radial-gradient(circle, rgba(255,160,0,0.03) 0%, rgba(255,255,255,0) 70%)',
        zIndex: -1
      }} />

      <Navbar activeTab={activeTab} setActiveTab={setActiveTab} />
      
      <main>
        <AnimatePresence mode="wait">
          <motion.div
            key={activeTab}
            initial={{ opacity: 0, x: 10 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -10 }}
            transition={{ duration: 0.3 }}
          >
            {renderContent()}
          </motion.div>
        </AnimatePresence>
      </main>

      <footer style={{ 
        textAlign: 'center', 
        padding: '40px 0', 
        color: 'var(--text-muted)',
        fontSize: '0.9rem',
        borderTop: '1px solid rgba(0,0,0,0.05)',
        marginTop: '60px'
      }}>
        <p>© 2026 Krushi Mitra - Your Digital Agricultural Companion</p>
        <p style={{ fontSize: '0.8rem', marginTop: '8px' }}>Empowering Farmers through Information</p>
      </footer>
    </div>
  );
}

export default App;
