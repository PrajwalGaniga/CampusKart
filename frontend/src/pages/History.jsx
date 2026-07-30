import React, { useState, useEffect } from 'react';
import { asksApi } from '../api';
import { History as HistoryIcon, Trash2, MapPin, Clock, Lock, CheckCircle, MessageSquare } from 'lucide-react';

export function History() {
  const [historyAsks, setHistoryAsks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [clearing, setClearing] = useState(false);

  const loadHistory = async () => {
    try {
      const data = await asksApi.getHistory();
      setHistoryAsks(data);
    } catch (err) {
      console.error('Failed to load history:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadHistory();
  }, []);

  const handleClearHistory = async () => {
    if (!window.confirm('Are you sure you want to clear your personal history view?')) return;
    setClearing(true);
    try {
      await asksApi.clearHistory();
      setHistoryAsks([]);
    } catch (err) {
      alert('Failed to clear history: ' + err.message);
    } finally {
      setClearing(false);
    }
  };

  const formatDate = (isoStr) => {
    try {
      return new Date(isoStr).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' });
    } catch {
      return isoStr;
    }
  };

  return (
    <div className="container">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <HistoryIcon color="#6366f1" size={28} /> Personal History
          </h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.2rem' }}>
            Archive of asks you requested or replied to.
          </p>
        </div>

        {historyAsks.length > 0 && (
          <button className="btn-danger" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }} onClick={handleClearHistory} disabled={clearing}>
            <Trash2 size={16} />
            <span>{clearing ? 'Clearing...' : 'Clear History'}</span>
          </button>
        )}
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>Loading history...</div>
      ) : historyAsks.length === 0 ? (
        <div className="glass-panel" style={{ padding: '3rem', textAlign: 'center' }}>
          <HistoryIcon size={40} color="#6366f1" style={{ margin: '0 auto 1rem auto', opacity: 0.5 }} />
          <h3 style={{ fontSize: '1.2rem', color: 'var(--text-muted)' }}>No History Records</h3>
          <p style={{ color: 'var(--text-dim)', fontSize: '0.88rem', marginTop: '0.3rem' }}>
            Asks you create or reply to will be saved here for your reference.
          </p>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.2rem' }}>
          {historyAsks.map((ask) => {
            const isLocked = ask.status === 'locked' || ask.reply_count >= 5;
            const isResolved = ask.status === 'resolved';

            return (
              <div key={ask.id} className="glass-panel" style={{ padding: '1.5rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '0.8rem', marginBottom: '0.8rem' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '0.3rem' }}>
                      <span style={{ fontWeight: 700, fontSize: '1rem', color: ask.is_requester ? '#a5b4fc' : 'var(--text-main)' }}>
                        {ask.is_requester ? 'You asked:' : `@${ask.requester_username} asked:`}
                      </span>

                      <span className={`badge badge-${ask.status}`}>
                        {isResolved ? (
                          <>
                            <CheckCircle size={12} /> Resolved
                          </>
                        ) : isLocked ? (
                          <>
                            <Lock size={12} /> Closed (5/5)
                          </>
                        ) : ask.status === 'expired' ? (
                          <>Expired</>
                        ) : (
                          <>Open ({ask.reply_count}/5)</>
                        )}
                      </span>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.8rem', color: 'var(--text-dim)', fontSize: '0.8rem' }}>
                      <span style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
                        <MapPin size={12} /> {ask.location_tag}
                      </span>
                      <span style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
                        <Clock size={12} /> Created {formatDate(ask.created_at)}
                      </span>
                    </div>
                  </div>

                  {ask.has_replied && !ask.is_requester && (
                    <span className="badge badge-resolved" style={{ background: 'rgba(139,92,246,0.15)', color: '#c084fc' }}>
                      You Replied
                    </span>
                  )}
                </div>

                <p style={{ fontSize: '1.05rem', color: 'var(--text-main)', margin: '0.8rem 0 1.2rem 0' }}>
                  "{ask.text}"
                </p>

                {/* Replies list inside history card */}
                {ask.replies && ask.replies.length > 0 && (
                  <div style={{ background: 'rgba(15,23,42,0.5)', border: '1px solid var(--border-color)', borderRadius: '12px', padding: '1rem', marginTop: '1rem' }}>
                    <div style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-muted)', marginBottom: '0.6rem', display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
                      <MessageSquare size={14} /> Recorded Replies ({ask.replies.length}/5 max)
                    </div>

                    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.6rem' }}>
                      {ask.replies.map((rep) => (
                        <div key={rep.id} style={{ background: 'rgba(255,255,255,0.03)', padding: '0.6rem 0.8rem', borderRadius: '8px', fontSize: '0.88rem' }}>
                          <div style={{ display: 'flex', justifyContent: 'space-between', color: '#a5b4fc', fontSize: '0.8rem', fontWeight: 600, marginBottom: '0.2rem' }}>
                            <span>@{rep.responder_username} ({rep.responder_display_name})</span>
                            <span style={{ color: 'var(--text-dim)', fontWeight: 400 }}>{formatDate(rep.created_at)}</span>
                          </div>
                          <div style={{ color: 'var(--text-main)' }}>{rep.text}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
