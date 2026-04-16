import React from 'react';
import { motion } from 'framer-motion';
import { Cloud, TrendingUp, AlertCircle, ArrowUpRight, Sun, Droplets } from 'lucide-react';

const Dashboard = () => {
  const stats = [
    { title: 'Local Weather', value: '28°C', sub: 'Sunny', icon: <Sun color="#ffa000" />, color: '#fff9c4' },
    { title: 'Soil Moisture', value: '42%', sub: 'Healthy', icon: <Droplets color="#1e88e5" />, color: '#e3f2fd' },
    { title: 'Market Trend', value: '+12%', sub: 'Wheat (UP)', icon: <TrendingUp color="#2e7d32" />, color: '#e8f5e9' },
  ];

  const news = [
    { id: 1, text: 'New subsidy announced for organic fertilizers.', type: 'alert' },
    { id: 2, text: 'Monsoon expected to arrive 2 days early in your region.', type: 'info' },
  ];

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      style={{ padding: '20px' }}
      className="container"
    >
      <header style={{ marginBottom: '40px' }}>
        <h1 style={{ marginBottom: '8px' }}>Namaste, Farmer Friend! 👋</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '1.2rem' }}>
          Here is your farm overview for today, April 16th.
        </p>
      </header>

      {/* Stats Grid */}
      <div className="grid grid-3" style={{ marginBottom: '40px' }}>
        {stats.map((stat, index) => (
          <motion.div 
            key={stat.title}
            whileHover={{ scale: 1.02 }}
            className="glass-card"
            style={{ display: 'flex', alignItems: 'center', gap: '20px' }}
          >
            <div style={{ 
              backgroundColor: stat.color, 
              padding: '16px', 
              borderRadius: 'var(--radius-md)',
              display: 'flex'
            }}>
              {stat.icon}
            </div>
            <div>
              <p style={{ color: 'var(--text-muted)', fontWeight: '600' }}>{stat.title}</p>
              <h2 style={{ margin: '4px 0' }}>{stat.value}</h2>
              <span style={{ fontSize: '0.9rem', color: 'var(--primary-dark)' }}>{stat.sub}</span>
            </div>
          </motion.div>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
        {/* Market Highlights */}
        <section className="glass-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
            <h3>Market Overview</h3>
            <button className="btn" style={{ color: 'var(--primary)', fontSize: '0.9rem' }}>
              View All <ArrowUpRight size={16} />
            </button>
          </div>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {['Wheat', 'Rice', 'Onion'].map((crop) => (
              <div key={crop} style={{ 
                display: 'flex', 
                justifyContent: 'space-between', 
                padding: '16px', 
                backgroundColor: 'rgba(0,0,0,0.02)',
                borderRadius: 'var(--radius-sm)'
              }}>
                <span style={{ fontWeight: '600' }}>{crop}</span>
                <div style={{ display: 'flex', gap: '24px' }}>
                  <span>₹2,450 / Quintal</span>
                  <span style={{ color: '#2e7d32' }}>+₹40 ▲</span>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Alerts & News */}
        <section className="glass-card" style={{ backgroundColor: 'var(--primary-dark)', color: 'white' }}>
          <h3 style={{ color: 'white', marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <AlertCircle size={20} /> Agri-Alerts
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {news.map(item => (
              <div key={item.id} style={{ 
                padding: '12px', 
                borderLeft: '4px solid var(--accent)', 
                backgroundColor: 'rgba(255,255,255,0.1)',
                fontSize: '0.95rem'
              }}>
                {item.text}
              </div>
            ))}
          </div>
        </section>
      </div>

      <style>
        {`
          @media (max-width: 900px) {
            div[style*="gridTemplateColumns: 2fr 1fr"] {
              grid-template-columns: 1fr !important;
            }
          }
        `}
      </style>
    </motion.div>
  );
};

export default Dashboard;
