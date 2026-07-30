import React, { useState, useEffect } from 'react';
import { boardApi } from '../api';
import { LayoutDashboard, MapPin, Clock, Lock, CheckCircle, ShieldAlert, Sparkles } from 'lucide-react';

export function PublicBoard() {
  const [asks, setAsks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [wsConnected, setWsConnected] = useState(false);

  // Fetch initial board state
  useEffect(() => {
    async function loadBoard() {
      try {
        const data = await boardApi.getBoard();
        setAsks(data);
      } catch (err) {
        console.error('Failed to load public board:', err);
      } finally {
        setLoading(false);
      }
    }
    loadBoard();
  }, []);

  // Subscribe to public board WebSocket
  useEffect(() => {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}/ws/board`;
    const ws = new WebSocket(wsUrl);

    ws.onopen = () => {
      console.log('Connected to Public Board WebSocket');
      setWsConnected(true);
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        console.log('Board WS Event:', data);

        if (data.event === 'BOARD_NEW_ASK') {
          setAsks((prev) => [data.ask, ...prev]);
        } else if (data.event === 'BOARD_ASK_UPDATED') {
          setAsks((prev) =>
            prev.map((ask) => (ask.id === data.ask.id ? { ...ask, ...data.ask } : ask))
          );
        } else if (data.event === 'BOARD_ASK_EXPIRED') {
          setAsks((prev) => prev.filter((ask) => ask.id !== data.ask_id));
        }
      } catch (err) {
        console.error('Board WS message parse error:', err);
      }
    };

    ws.onclose = () => {
      console.log('Public Board WebSocket disconnected');
      setWsConnected(false);
    };

    return () => {
      ws.close();
    };
  }, []);

  const formatTimeLeft = (expiresAt) => {
    const diff = new Date(expiresAt) - new Date();
    if (diff <= 0) return 'Expired';
    const mins = Math.floor(diff / 60000);
    const secs = Math.floor((diff % 60000) / 1000);
    return `${mins}m ${secs}s`;
  };

  return (
    <div className="container">
      {/* Header Banner */}
      <div className="glass-panel" style={{ padding: '1.8rem', marginBottom: '2rem', background: 'linear-gradient(135deg, rgba(21,28,44,0.9), rgba(30,41,61,0.7))', borderColor: 'rgba(99,102,241,0.25)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '1rem' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '0.4rem' }}>
              <LayoutDashboard size={26} color="#a5b4fc" />
              <h1 style={{ fontSize: '1.8rem', fontWeight: 700 }}>Live Campus Board</h1>
              <div className="badge badge-open" style={{ marginLeft: '0.5rem', background: wsConnected ? 'rgba(16, 185, 129, 0.2)' : 'rgba(239, 68, 68, 0.2)', color: wsConnected ? '#6ee7b7' : '#fca5a5' }}>
                <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: wsConnected ? '#10b981' : '#ef4444', display: 'inline-block' }}></span>
                <span>{wsConnected ? 'LIVE FEED' : 'CONNECTING'}</span>
              </div>
            </div>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.95rem' }}>
              Public, real-time anonymized view of campus requests as they happen. No identity revealed until resolved.
            </p>
          </div>

          <div style={{ background: 'rgba(99,102,241,0.1)', border: '1px solid rgba(99,102,241,0.2)', padding: '0.6rem 1rem', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.85rem', color: '#a5b4fc' }}>
            <ShieldAlert size={16} />
            <span>Identity Stripped Mode</span>
          </div>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
          Loading public board...
        </div>
      ) : asks.length === 0 ? (
        <div className="glass-panel" style={{ padding: '3rem', textAlign: 'center' }}>
          <Sparkles size={40} color="#6366f1" style={{ margin: '0 auto 1rem auto', opacity: 0.7 }} />
          <h3 style={{ fontSize: '1.2rem', color: 'var(--text-muted)' }}>No Active Campus Asks</h3>
          <p style={{ color: 'var(--text-dim)', fontSize: '0.88rem', marginTop: '0.3rem' }}>
            When students post requests in their network, anonymized broadcasts appear here in real time.
          </p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(310px, 1fr))', gap: '1.2rem' }}>
          {asks.map((ask) => {
            const isLocked = ask.status === 'locked' || ask.reply_count >= 5;
            const isResolved = ask.status === 'resolved';

            return (
              <div key={ask.id} className="glass-panel" style={{ padding: '1.4rem', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.8rem' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', color: '#a5b4fc', fontSize: '0.85rem', fontWeight: 600 }}>
                      <MapPin size={14} />
                      <span>{ask.location_tag || 'Main Campus'}</span>
                    </div>

                    <span className={`badge badge-${ask.status}`}>
                      {isResolved ? (
                        <>
                          <CheckCircle size={12} /> Resolved
                        </>
                      ) : isLocked ? (
                        <>
                          <Lock size={12} /> Closed (5/5)
                        </>
                      ) : (
                        <>Open ({ask.reply_count}/5)</>
                      )}
                    </span>
                  </div>

                  <p style={{ fontSize: '1.05rem', fontWeight: 500, color: 'var(--text-main)', marginBottom: '1.2rem' }}>
                    "{ask.text}"
                  </p>
                </div>

                <div>
                  {/* Progress bar */}
                  <div className="progress-bar-container">
                    <div
                      className={`progress-bar-fill ${isLocked ? 'locked' : ''}`}
                      style={{ width: `${Math.min(100, (ask.reply_count / 5) * 100)}%` }}
                    ></div>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '0.8rem', fontSize: '0.8rem', color: 'var(--text-dim)' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
                      <Clock size={12} />
                      <span>Expires in {formatTimeLeft(ask.expires_at)}</span>
                    </div>
                    <span>Anonymized Request</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
