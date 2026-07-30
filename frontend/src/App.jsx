import React, { useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Navbar } from './components/Navbar';
import { Login } from './pages/Login';
import { Signup } from './pages/Signup';
import { Feed } from './pages/Feed';
import { Friends } from './pages/Friends';
import { History } from './pages/History';
import { PublicBoard } from './pages/PublicBoard';

function MainApp() {
  const { user, loading } = useAuth();
  const [activeTab, setActiveTab] = useState('board');

  React.useEffect(() => {
    if (!loading) {
      if (user && (activeTab === 'login' || activeTab === 'signup' || activeTab === 'board')) {
        setActiveTab('feed');
      } else if (!user && activeTab !== 'login' && activeTab !== 'signup') {
        setActiveTab('board');
      }
    }
  }, [user, loading]);

  if (loading) {
    return (
      <div style={{ display: 'flex', height: '100vh', alignItems: 'center', justifyContent: 'center', color: 'var(--text-muted)' }}>
        <div style={{ textAlign: 'center' }}>
          <div className="brand-icon" style={{ width: '48px', height: '48px', margin: '0 auto 1rem auto', animation: 'spin 2s infinite linear' }}>
            ⚡
          </div>
          <div>Loading Campus Ask-Board...</div>
        </div>
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <Navbar activeTab={activeTab} setActiveTab={setActiveTab} />

      <main style={{ flex: 1 }}>
        {activeTab === 'feed' && user && <Feed />}
        {activeTab === 'friends' && user && <Friends />}
        {activeTab === 'history' && user && <History />}
        {activeTab === 'board' && <PublicBoard />}
        {activeTab === 'login' && <Login setActiveTab={setActiveTab} />}
        {activeTab === 'signup' && <Signup setActiveTab={setActiveTab} />}
      </main>
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <MainApp />
    </AuthProvider>
  );
}
