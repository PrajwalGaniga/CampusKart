import React from 'react';
import { useAuth } from '../context/AuthContext';
import { Zap, Radio, Users, History, LogOut, User, LayoutDashboard } from 'lucide-react';

export function Navbar({ activeTab, setActiveTab }) {
  const { user, logout } = useAuth();

  return (
    <header className="navbar">
      <div className="navbar-inner">
        <div className="brand" style={{ cursor: 'pointer' }} onClick={() => setActiveTab('feed')}>
          <div className="brand-icon">
            <Zap size={20} />
          </div>
          <span>Campus Ask-Board</span>
        </div>

        <nav className="nav-links">
          {user ? (
            <>
              <button
                className={`nav-item ${activeTab === 'feed' ? 'active' : ''}`}
                onClick={() => setActiveTab('feed')}
              >
                <Radio size={16} />
                <span>Feed</span>
              </button>

              <button
                className={`nav-item ${activeTab === 'friends' ? 'active' : ''}`}
                onClick={() => setActiveTab('friends')}
              >
                <Users size={16} />
                <span>Friends</span>
              </button>

              <button
                className={`nav-item ${activeTab === 'history' ? 'active' : ''}`}
                onClick={() => setActiveTab('history')}
              >
                <History size={16} />
                <span>History</span>
              </button>
            </>
          ) : null}

          <button
            className={`nav-item ${activeTab === 'board' ? 'active' : ''}`}
            onClick={() => setActiveTab('board')}
          >
            <LayoutDashboard size={16} />
            <span>Public Board</span>
          </button>

          {user ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.8rem', marginLeft: '1rem', paddingLeft: '1rem', borderLeft: '1px solid var(--border-color)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                <User size={14} />
                <span style={{ color: 'var(--text-main)', fontWeight: 600 }}>@{user.username}</span>
              </div>

              <button
                className="nav-item"
                title="Logout"
                style={{ color: '#ef4444' }}
                onClick={() => {
                  logout();
                  setActiveTab('login');
                }}
              >
                <LogOut size={16} />
              </button>
            </div>
          ) : (
            <div style={{ display: 'flex', gap: '0.5rem', marginLeft: '0.5rem' }}>
              <button
                className={`nav-item ${activeTab === 'login' ? 'active' : ''}`}
                onClick={() => setActiveTab('login')}
              >
                Login
              </button>
              <button
                className="btn-primary"
                style={{ padding: '0.4rem 0.9rem', fontSize: '0.85rem' }}
                onClick={() => setActiveTab('signup')}
              >
                Sign Up
              </button>
            </div>
          )}
        </nav>
      </div>
    </header>
  );
}
