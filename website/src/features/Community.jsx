// 👥 Krushi Mitra Pro — Community Forum Feed
import React, { useState } from 'react';
import { MessageSquare, ThumbsUp, Plus, Search, Tag, User, Send } from 'lucide-react';

export default function Community({ profile, communityPosts, setCommunityPosts }) {
  const [activeTab, setActiveTab] = useState('All');
  const [showAddPost, setShowAddPost] = useState(false);
  const [newPostText, setNewPostText] = useState('');
  const [newPostTag, setNewPostTag] = useState('General');
  const [newPostImage, setNewPostImage] = useState('');
  const [activeCommentId, setActiveCommentId] = useState(null);
  const [newCommentText, setNewCommentText] = useState('');

  const lang = profile.language || 'hi';

  const formatText = (textHi, textEn) => {
    return lang === 'hi' ? textHi : textEn;
  };

  const handleAddPost = (e) => {
    e.preventDefault();
    if (!newPostText.trim()) return;

    const newPost = {
      id: `post_${Date.now()}`,
      author: profile.name || 'Aditya Lohar',
      location: `${profile.district || 'Nashik'}, ${profile.state || 'Maharashtra'}`,
      content: newPostText.trim(),
      tag: newPostTag,
      imageUrl: newPostImage || null,
      likes: 0,
      comments: [],
      date: new Date().toLocaleDateString(lang === 'hi' ? 'hi-IN' : 'en-IN', {
        day: 'numeric',
        month: 'short'
      })
    };

    const updated = [newPost, ...communityPosts];
    setCommunityPosts(updated);
    localStorage.setItem('krushi_community_posts', JSON.stringify(updated));

    // Reset fields
    setNewPostText('');
    setNewPostImage('');
    setNewPostTag('General');
    setShowAddPost(false);
  };

  const handleLike = (id) => {
    const updated = communityPosts.map(post => {
      if (post.id === id) {
        return { ...post, likes: post.likes + 1 };
      }
      return post;
    });
    setCommunityPosts(updated);
    localStorage.setItem('krushi_community_posts', JSON.stringify(updated));
  };

  const handleAddComment = (postId) => {
    if (!newCommentText.trim()) return;

    const updated = communityPosts.map(post => {
      if (post.id === postId) {
        const comments = post.comments || [];
        const newComment = {
          id: Date.now().toString(),
          author: profile.name || 'Farmer Mitra',
          content: newCommentText.trim(),
          date: 'Just now'
        };
        return { ...post, comments: [...comments, newComment] };
      }
      return post;
    });

    setCommunityPosts(updated);
    localStorage.setItem('krushi_community_posts', JSON.stringify(updated));
    setNewCommentText('');
  };

  const tabs = ['All', 'Pests', 'Weather', 'Market', 'General'];

  const filteredPosts = activeTab === 'All' 
    ? communityPosts 
    : communityPosts.filter(post => post.tag.toLowerCase() === activeTab.toLowerCase());

  const getTagColor = (tag) => {
    const t = tag.toLowerCase();
    if (t === 'pests') return 'badge-danger';
    if (t === 'weather') return 'badge-cyan';
    if (t === 'market') return 'badge-amber';
    return 'badge-emerald';
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Header Info */}
      <div className="glass-panel" style={{ padding: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.4rem', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <MessageSquare style={{ color: 'var(--primary-emerald)' }} />
            {formatText("किसान मंच — चर्चा चौपाल", "Farmer Community Feed")}
          </h2>
          <p style={{ color: 'var(--text-secondary)' }}>
            {formatText(
              "अन्य किसानों के साथ जुड़ें, फसल सलाह साझा करें, सवाल पूछें और कृषि अनुभवों पर चर्चा करें।",
              "Connect with other growers in your district, share crop protection advice, and ask pest concerns."
            )}
          </p>
        </div>
        <button onClick={() => setShowAddPost(true)} className="btn-primary">
          <Plus size={18} /> {formatText("नया पोस्ट लिखें", "Create Post")}
        </button>
      </div>

      {/* Tabs Row */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '4px' }}>
        {tabs.map((tab, idx) => (
          <button 
            key={idx}
            onClick={() => setActiveTab(tab)}
            className={activeTab === tab ? "btn-primary" : "btn-secondary"}
            style={{ 
              fontSize: '0.8rem', 
              padding: '8px 16px', 
              borderRadius: '20px',
              background: activeTab === tab ? undefined : 'var(--glass-bg)',
              borderColor: activeTab === tab ? undefined : 'var(--glass-border)'
            }}
          >
            {tab === 'All' ? formatText("सभी पोस्ट", "All Posts") : tab}
          </button>
        ))}
      </div>

      {/* Main split */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
        
        {/* New Post Creator Modal */}
        {showAddPost && (
          <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.7)', zIndex: 100, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '20px' }}>
            <div className="glass-panel animate-fade-in" style={{ background: 'var(--bg-surface)', width: '100%', maxWidth: '500px', padding: '24px', position: 'relative' }}>
              <button onClick={() => setShowAddPost(false)} className="btn-secondary" style={{ position: 'absolute', right: '16px', top: '16px', padding: '2px 8px', fontSize: '0.8rem' }}>✕</button>
              <h3 style={{ marginBottom: '16px', fontSize: '1.1rem' }}>✍️ {formatText("चर्चा पोस्ट साझा करें", "Share Post to Community")}</h3>
              
              <form onSubmit={handleAddPost} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Tag/Category</label>
                  <select value={newPostTag} onChange={(e) => setNewPostTag(e.target.value)} className="form-input" style={{ padding: '8px 10px' }}>
                    <option value="General">General</option>
                    <option value="Pests">Pests / Disease</option>
                    <option value="Weather">Weather</option>
                    <option value="Market">Market Prices</option>
                  </select>
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>{formatText("संदेश विवरण", "Message Content")}</label>
                  <textarea 
                    rows="4"
                    value={newPostText}
                    onChange={(e) => setNewPostText(e.target.value)}
                    placeholder={formatText("अपनी समस्या या विचार लिखें...", "What farming concern or success story do you want to share?")}
                    className="form-input"
                    required
                  />
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Optional Image Link</label>
                  <input 
                    type="text"
                    placeholder="https://images.unsplash.com/..."
                    value={newPostImage}
                    onChange={(e) => setNewPostImage(e.target.value)}
                    className="form-input"
                  />
                </div>
                <button type="submit" className="btn-primary" style={{ width: '100%', justifyContent: 'center', marginTop: '6px' }}>
                  {formatText("पोस्ट प्रकाशित करें", "Publish Post")}
                </button>
              </form>
            </div>
          </div>
        )}

        {/* Posts viewport */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          {filteredPosts.map((post) => (
            <div key={post.id} className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
              
              {/* Post header info */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                  <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: 'var(--bg-surface-variant)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary-emerald)' }}>
                    <User size={16} />
                  </div>
                  <div>
                    <h4 style={{ fontSize: '0.9rem', fontWeight: '600' }}>{post.author}</h4>
                    <span style={{ fontSize: '0.72rem', color: 'var(--text-secondary)' }}>📍 {post.location} • {post.date}</span>
                  </div>
                </div>
                <span className={`badge ${getTagColor(post.tag)}`}>
                  <Tag size={12} /> {post.tag}
                </span>
              </div>

              {/* Content */}
              <div>
                <p style={{ fontSize: '0.9rem', lineHeight: '1.6', color: 'var(--text-primary)', whiteSpace: 'pre-wrap' }}>
                  {post.content}
                </p>
                {post.imageUrl && (
                  <img 
                    src={post.imageUrl} 
                    alt="Post Attach" 
                    style={{ width: '100%', maxHeight: '300px', objectFit: 'cover', borderRadius: '8px', marginTop: '12px' }} 
                  />
                )}
              </div>

              {/* Action indicators bar */}
              <div style={{ display: 'flex', gap: '20px', borderTop: '1px solid var(--border-outline)', paddingTop: '12px' }}>
                <button 
                  onClick={() => handleLike(post.id)}
                  style={{ background: 'transparent', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', display: 'flex', gap: '6px', alignItems: 'center', fontSize: '0.82rem' }}
                  onMouseOver={(e) => e.currentTarget.style.color = 'var(--primary-emerald)'}
                  onMouseOut={(e) => e.currentTarget.style.color = 'var(--text-secondary)'}
                >
                  <ThumbsUp size={16} /> {post.likes} {formatText("पसंद", "Likes")}
                </button>
                <button 
                  onClick={() => setActiveCommentId(activeCommentId === post.id ? null : post.id)}
                  style={{ background: 'transparent', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', display: 'flex', gap: '6px', alignItems: 'center', fontSize: '0.82rem' }}
                  onMouseOver={(e) => e.currentTarget.style.color = 'var(--secondary-cyan)'}
                  onMouseOut={(e) => e.currentTarget.style.color = 'var(--text-secondary)'}
                >
                  <MessageSquare size={16} /> {post.comments?.length || 0} {formatText("टिप्पणी", "Comments")}
                </button>
              </div>

              {/* Comments box toggle section */}
              {activeCommentId === post.id && (
                <div style={{ background: 'rgba(2, 6, 23, 0.2)', border: '1px solid var(--glass-border)', padding: '16px', borderRadius: '8px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  
                  {/* List comments */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', maxH: '180px', overflowY: 'auto' }}>
                    {(post.comments || []).map((comm) => (
                      <div key={comm.id} style={{ fontSize: '0.82rem', background: 'rgba(255,255,255,0.01)', border: '1px solid var(--glass-border)', padding: '8px 12px', borderRadius: '6px' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '2px' }}>
                          <span style={{ fontWeight: '600' }}>{comm.author}</span>
                          <span style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>{comm.date}</span>
                        </div>
                        <p>{comm.content}</p>
                      </div>
                    ))}
                    {(post.comments || []).length === 0 && (
                      <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', textAlign: 'center' }}>
                        No comments yet. Write the first response!
                      </p>
                    )}
                  </div>

                  {/* Add comment form */}
                  <div style={{ display: 'flex', gap: '10px' }}>
                    <input 
                      type="text" 
                      placeholder={formatText("टिप्पणी लिखें...", "Write a helpful reply...")}
                      value={newCommentText}
                      onChange={(e) => setNewCommentText(e.target.value)}
                      className="form-input"
                      style={{ padding: '8px 12px', fontSize: '0.82rem' }}
                      onKeyDown={(e) => e.key === 'Enter' && handleAddComment(post.id)}
                    />
                    <button 
                      onClick={() => handleAddComment(post.id)} 
                      className="btn-primary" 
                      style={{ padding: '8px' }}
                    >
                      <Send size={14} />
                    </button>
                  </div>

                </div>
              )}

            </div>
          ))}
          {filteredPosts.length === 0 && (
            <p style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '40px' }}>
              No discussions under this category yet.
            </p>
          )}
        </div>

      </div>

    </div>
  );
}
