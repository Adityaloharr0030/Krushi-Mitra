import React from 'react';
import { Leaf, BarChart2, CloudSun, BookOpen, Menu } from 'lucide-react';

const Navbar = ({ activeTab, setActiveTab }) => {
  const navItems = [
    { id: 'dashboard', label: 'Dashboard', icon: <Leaf size={20} /> },
    { id: 'market', label: 'Market Prices', icon: <BarChart2 size={20} /> },
    { id: 'weather', label: 'Weather', icon: <CloudSun size={20} /> },
    { id: 'resources', label: 'Resources', icon: <BookOpen size={20} /> },
  ];

  return (
    <nav className="glass-card" style={{ 
      margin: '20px auto', 
      width: '95%', 
      display: 'flex', 
      justifyContent: 'space-between', 
      alignItems: 'center',
      padding: '12px 32px',
      position: 'sticky',
      top: '10px',
      zIndex: 1000
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <div style={{ 
          backgroundColor: 'var(--primary)', 
          padding: '8px', 
          borderRadius: '12px',
          color: 'white',
          display: 'flex'
        }}>
          <Leaf size={24} />
        </div>
        <h2 style={{ fontSize: '1.4rem', margin: 0, color: 'var(--primary-dark)' }}>
          Krushi Mitra
        </h2>
      </div>

      <div className="nav-links" style={{ display: 'flex', gap: '8px' }}>
        {navItems.map((item) => (
          <button
            key={item.id}
            onClick={() => setActiveTab(item.id)}
            style={{
              padding: '10px 18px',
              borderRadius: 'var(--radius-sm)',
              border: 'none',
              backgroundColor: activeTab === item.id ? 'var(--primary-light)' : 'transparent',
              color: activeTab === item.id ? 'var(--primary-dark)' : 'var(--text-muted)',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              cursor: 'pointer',
              fontWeight: '600',
              transition: 'var(--transition)'
            }}
          >
            {item.icon}
            <span className="nav-label">{item.label}</span>
          </button>
        ))}
      </div>

      <button className="btn btn-primary">
        Get Advice
      </button>

      <style>
        {`
          @media (max-width: 768px) {
            .nav-label { display: none; }
            .nav-links { gap: 4px; }
            .btn-primary { display: none; }
          }
        `}
      </style>
    </nav>
  );
};

export default Navbar;
