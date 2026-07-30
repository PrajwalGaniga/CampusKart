import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { seedApi } from '../api';
import { Zap, UserCheck, Key, AlertCircle, Sparkles } from 'lucide-react';

export function Login({ setActiveTab }) {
  const { login } = useAuth();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [seedLoading, setSeedLoading] = useState(false);
  const [seedSuccess, setSeedSuccess] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!username || !password) return;
    setLoading(true);
    setError(null);
    try {
      await login(username.trim(), password);
      setActiveTab('feed');
    } catch (err) {
      setError(err.message || 'Login failed. Please check credentials.');
    } finally {
      setLoading(false);
    }
  };

  const handleSeed = async () => {
    setSeedLoading(true);
    setError(null);
    try {
      const res = await seedApi.runSeed();
      setSeedSuccess('Seeded test users (alice, bob, charlie). Auto-filling "alice"!');
      setUsername('alice');
      setPassword('password123');
    } catch (err) {
      setError('Seed failed: ' + err.message);
    } finally {
      setSeedLoading(false);
    }
  };

  const fillUser = (u, p) => {
    setUsername(u);
    setPassword(p);
  };

  return (
    <div style={{ maxWidth: '440px', margin: '3rem auto' }}>
      <div className="glass-panel" style={{ padding: '2rem' }}>
        <div style={{ textAlign: 'center', marginBottom: '1.8rem' }}>
          <div className="brand-icon" style={{ width: '48px', height: '48px', margin: '0 auto 0.8rem auto' }}>
            <Zap size={28} />
          </div>
          <h2 style={{ fontSize: '1.6rem', fontWeight: 700 }}>Welcome Back</h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.3rem' }}>
            Log in to broadcast & reply to campus asks
          </p>
        </div>

        {error && (
          <div style={{ background: 'rgba(239, 68, 68, 0.15)', color: '#fca5a5', border: '1px solid rgba(239, 68, 68, 0.3)', padding: '0.75rem', borderRadius: '8px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <AlertCircle size={16} />
            <span>{error}</span>
          </div>
        )}

        {seedSuccess && (
          <div style={{ background: 'rgba(16, 185, 129, 0.15)', color: '#6ee7b7', border: '1px solid rgba(16, 185, 129, 0.3)', padding: '0.75rem', borderRadius: '8px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <UserCheck size={16} />
            <span>{seedSuccess}</span>
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Username</label>
            <input
              type="text"
              className="form-control"
              placeholder="e.g. alice"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label">Password</label>
            <input
              type="password"
              className="form-control"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          <button type="submit" className="btn-primary" style={{ width: '100%', padding: '0.8rem', marginTop: '0.5rem' }} disabled={loading}>
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>

        <div style={{ marginTop: '1.5rem', textAlign: 'center', fontSize: '0.88rem', color: 'var(--text-muted)' }}>
          Don't have an account?{' '}
          <button style={{ background: 'none', color: '#a5b4fc', fontWeight: 600 }} onClick={() => setActiveTab('signup')}>
            Sign Up
          </button>
        </div>

        <hr style={{ borderColor: 'var(--border-color)', margin: '1.5rem 0' }} />

        {/* Quick Demo Seed Section */}
        <div style={{ background: 'rgba(99, 102, 241, 0.08)', border: '1px solid rgba(99, 102, 241, 0.2)', padding: '1rem', borderRadius: '12px', textAlign: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.4rem', fontSize: '0.85rem', fontWeight: 600, color: '#a5b4fc', marginBottom: '0.6rem' }}>
            <Sparkles size={16} />
            <span>Multi-User Demo Seed</span>
          </div>

          <button
            onClick={handleSeed}
            className="btn-secondary"
            disabled={seedLoading}
            style={{ width: '100%', padding: '0.5rem', fontSize: '0.82rem', marginBottom: '0.6rem' }}
          >
            {seedLoading ? 'Seeding Database...' : '⚡ Seed 2 Friended Demo Users (alice & bob)'}
          </button>

          <div style={{ display: 'flex', gap: '0.4rem', justifyContent: 'center' }}>
            <button
              type="button"
              className="btn-secondary"
              style={{ padding: '0.3rem 0.6rem', fontSize: '0.78rem' }}
              onClick={() => fillUser('alice', 'password123')}
            >
              Fill Alice
            </button>
            <button
              type="button"
              className="btn-secondary"
              style={{ padding: '0.3rem 0.6rem', fontSize: '0.78rem' }}
              onClick={() => fillUser('bob', 'password123')}
            >
              Fill Bob
            </button>
            <button
              type="button"
              className="btn-secondary"
              style={{ padding: '0.3rem 0.6rem', fontSize: '0.78rem' }}
              onClick={() => fillUser('charlie', 'password123')}
            >
              Fill Charlie
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
