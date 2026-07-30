import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { asksApi } from '../api';
import { Radio, Plus, MessageSquare, Send, CheckCircle, Clock, MapPin, Lock, AlertCircle, X } from 'lucide-react';

export function Feed() {
  const { user } = useAuth();
  const [asks, setAsks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [wsConnected, setWsConnected] = useState(false);

  // New Ask Modal State
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [askText, setAskText] = useState('');
  const [locationTag, setLocationTag] = useState('Main Campus');
  const [expiryMins, setExpiryMins] = useState(20);
  const [createLoading, setCreateLoading] = useState(false);
  const [createError, setCreateError] = useState(null);

  // Reply Modal State
  const [selectedAsk, setSelectedAsk] = useState(null);
  const [replyText, setReplyText] = useState('');
  const [replyLoading, setReplyLoading] = useState(false);
  const [replyError, setReplyError] = useState(null);

  const loadFeed = async () => {
    try {
      const data = await asksApi.getFeed();
      setAsks(data);
    } catch (err) {
      console.error('Failed to load feed:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadFeed();
  }, []);

  // WebSocket Subscription for user feed updates
  useEffect(() => {
    if (!user?.id) return;

    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}/ws/feed/${user.id}`;
    const ws = new WebSocket(wsUrl);

    ws.onopen = () => {
      console.log('Connected to User Feed WebSocket');
      setWsConnected(true);
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        console.log('User WS Event:', data);

        if (data.event === 'NEW_ASK') {
          setAsks((prev) => [data.ask, ...prev]);
        } else if (data.event === 'ASK_UPDATED') {
          setAsks((prev) =>
            prev.map((ask) => (ask.id === data.ask.id ? { ...ask, ...data.ask } : ask))
          );
          if (selectedAsk && selectedAsk.id === data.ask.id) {
            setSelectedAsk(data.ask);
          }
        }
      } catch (err) {
        console.error('User WS parse error:', err);
      }
    };

    ws.onclose = () => {
      console.log('User Feed WebSocket disconnected');
      setWsConnected(false);
    };

    return () => {
      ws.close();
    };
  }, [user?.id, selectedAsk]);

  const handleCreateAsk = async (e) => {
    e.preventDefault();
    if (!askText.trim()) return;
    setCreateLoading(true);
    setCreateError(null);

    try {
      const newAsk = await asksApi.createAsk({
        text: askText.trim(),
        location_tag: locationTag.trim() || 'Main Campus',
        expiry_minutes: parseInt(expiryMins, 10) || 20,
      });

      setAsks((prev) => [newAsk, ...prev]);
      setShowCreateModal(false);
      setAskText('');
      setLocationTag('Main Campus');
    } catch (err) {
      setCreateError(err.message || 'Failed to post ask');
    } finally {
      setCreateLoading(false);
    }
  };

  const handleSendReply = async (e) => {
    e.preventDefault();
    if (!replyText.trim() || !selectedAsk) return;
    setReplyLoading(true);
    setReplyError(null);

    try {
      await asksApi.replyToAsk(selectedAsk.id, replyText.trim());
      setReplyText('');
      // Reload feed to ensure fresh state
      await loadFeed();
      // Close modal
      setSelectedAsk(null);
    } catch (err) {
      // Handles HTTP 409 "This ask is already closed"
      setReplyError(err.message || 'Failed to send reply');
    } finally {
      setReplyLoading(false);
    }
  };

  const handleResolve = async (askId) => {
    try {
      await asksApi.resolveAsk(askId);
      loadFeed();
      if (selectedAsk?.id === askId) setSelectedAsk(null);
    } catch (err) {
      alert(err.message || 'Failed to resolve ask');
    }
  };

  const formatTimeLeft = (expiresAt) => {
    const diff = new Date(expiresAt) - new Date();
    if (diff <= 0) return 'Expired';
    const mins = Math.floor(diff / 60000);
    const secs = Math.floor((diff % 60000) / 1000);
    return `${mins}m ${secs}s`;
  };

  return (
    <div className="container">
      {/* Top Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.8rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <Radio color="#6366f1" size={28} /> Mutual Friends Ask Feed
          </h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.2rem' }}>
            Broadcast requests to your mutual friends. Automatically locks at 5 replies.
          </p>
        </div>

        <button className="btn-primary" onClick={() => setShowCreateModal(true)}>
          <Plus size={18} />
          <span>Post an Ask</span>
        </button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
          Loading friend requests & asks...
        </div>
      ) : asks.length === 0 ? (
        <div className="glass-panel" style={{ padding: '3rem', textAlign: 'center' }}>
          <Radio size={44} color="#6366f1" style={{ margin: '0 auto 1rem auto', opacity: 0.5 }} />
          <h3 style={{ fontSize: '1.2rem', color: 'var(--text-muted)' }}>Your Friends Feed is Empty</h3>
          <p style={{ color: 'var(--text-dim)', fontSize: '0.88rem', marginTop: '0.3rem', maxWidth: '400px', margin: '0.3rem auto 1.2rem auto' }}>
            Add friends using the Friends tab or tap below to post your first campus help request!
          </p>
          <button className="btn-primary" onClick={() => setShowCreateModal(true)}>
            <Plus size={16} /> Post an Ask Now
          </button>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.2rem' }}>
          {asks.map((ask) => {
            const isLocked = ask.status === 'locked' || ask.reply_count >= 5;
            const isResolved = ask.status === 'resolved';
            const isExpired = ask.status === 'expired';

            return (
              <div key={ask.id} className="glass-panel" style={{ padding: '1.5rem', transition: 'transform 0.2s ease' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '0.8rem', marginBottom: '0.8rem' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '0.3rem' }}>
                      <span style={{ fontWeight: 700, fontSize: '1.05rem' }}>
                        {ask.is_requester ? 'You' : ask.requester_display_name}
                      </span>
                      {!ask.is_requester && (
                        <span style={{ color: 'var(--text-dim)', fontSize: '0.85rem' }}>
                          @{ask.requester_username}
                        </span>
                      )}

                      <span className={`badge badge-${ask.status}`}>
                        {isResolved ? (
                          <>
                            <CheckCircle size={12} /> Resolved
                          </>
                        ) : isLocked ? (
                          <>
                            <Lock size={12} /> Locked (5/5)
                          </>
                        ) : isExpired ? (
                          <>Expired</>
                        ) : (
                          <>Open ({ask.reply_count}/5)</>
                        )}
                      </span>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.8rem', color: 'var(--text-dim)', fontSize: '0.8rem' }}>
                      <span style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
                        <MapPin size={12} /> {ask.location_tag || 'Main Campus'}
                      </span>
                      <span style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
                        <Clock size={12} /> {formatTimeLeft(ask.expires_at)}
                      </span>
                    </div>
                  </div>

                  {/* Actions */}
                  {ask.is_requester && ask.status !== 'resolved' && (
                    <button
                      className="btn-secondary"
                      style={{ padding: '0.35rem 0.75rem', fontSize: '0.8rem', color: '#6ee7b7', borderColor: 'rgba(16,185,129,0.3)' }}
                      onClick={() => handleResolve(ask.id)}
                    >
                      <CheckCircle size={14} /> Mark Resolved
                    </button>
                  )}
                </div>

                {/* Ask Body */}
                <p style={{ fontSize: '1.1rem', fontWeight: 500, color: 'var(--text-main)', margin: '0.8rem 0 1.2rem 0' }}>
                  "{ask.text}"
                </p>

                {/* Lock Progress Bar */}
                <div className="progress-bar-container">
                  <div
                    className={`progress-bar-fill ${isLocked ? 'locked' : ''}`}
                    style={{ width: `${Math.min(100, (ask.reply_count / 5) * 100)}%` }}
                  ></div>
                </div>

                {/* Card Footer / Reply trigger */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '1rem', flexWrap: 'wrap', gap: '0.5rem' }}>
                  <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                    {ask.reply_count === 0 ? 'No replies yet' : `${ask.reply_count} / 5 replies recorded`}
                  </div>

                  <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button
                      className="btn-secondary"
                      style={{ padding: '0.45rem 0.9rem', fontSize: '0.85rem' }}
                      onClick={() => setSelectedAsk(ask)}
                    >
                      <MessageSquare size={14} />
                      <span>{ask.replies?.length ? `View Replies (${ask.replies.length})` : 'Replies'}</span>
                    </button>

                    {!ask.is_requester && !isLocked && !isResolved && !isExpired && (
                      <button
                        className="btn-primary"
                        style={{ padding: '0.45rem 0.9rem', fontSize: '0.85rem' }}
                        onClick={() => setSelectedAsk(ask)}
                      >
                        <Send size={14} /> Reply
                      </button>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* CREATE ASK MODAL */}
      {showCreateModal && (
        <div className="modal-overlay" onClick={() => setShowCreateModal(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.2rem' }}>
              <h3 style={{ fontSize: '1.2rem', fontWeight: 700 }}>Post Campus Ask</h3>
              <button onClick={() => setShowCreateModal(false)} style={{ background: 'none', color: 'var(--text-muted)' }}>
                <X size={20} />
              </button>
            </div>

            {createError && (
              <div style={{ background: 'rgba(239,68,68,0.15)', color: '#fca5a5', border: '1px solid rgba(239,68,68,0.3)', padding: '0.6rem 0.8rem', borderRadius: '8px', marginBottom: '1rem', fontSize: '0.85rem' }}>
                {createError}
              </div>
            )}

            <form onSubmit={handleCreateAsk}>
              <div className="form-group">
                <label className="form-label">What do you need help with?</label>
                <textarea
                  className="form-control"
                  rows={3}
                  placeholder="e.g. Need an iPhone charger near Block C, table 4!"
                  value={askText}
                  onChange={(e) => setAskText(e.target.value)}
                  maxLength={280}
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.8rem' }}>
                <div className="form-group">
                  <label className="form-label">Location / Building Tag</label>
                  <input
                    type="text"
                    className="form-control"
                    placeholder="e.g. Block C Library"
                    value={locationTag}
                    onChange={(e) => setLocationTag(e.target.value)}
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Auto-Expiry Time</label>
                  <select
                    className="form-control"
                    value={expiryMins}
                    onChange={(e) => setExpiryMins(e.target.value)}
                  >
                    <option value={10}>10 minutes</option>
                    <option value={20}>20 minutes (default)</option>
                    <option value={30}>30 minutes</option>
                    <option value={60}>1 hour</option>
                  </select>
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.6rem', marginTop: '1rem' }}>
                <button type="button" className="btn-secondary" onClick={() => setShowCreateModal(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary" disabled={createLoading}>
                  {createLoading ? 'Broadcasting...' : 'Broadcast to Friends'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* REPLY & DETAILS MODAL */}
      {selectedAsk && (
        <div className="modal-overlay" onClick={() => setSelectedAsk(null)}>
          <div className="modal-card" style={{ maxWidth: '540px' }} onClick={(e) => e.stopPropagation()}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <span className={`badge badge-${selectedAsk.status}`}>
                  {selectedAsk.status.toUpperCase()} ({selectedAsk.reply_count}/5)
                </span>
                <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  By @{selectedAsk.requester_username}
                </span>
              </div>
              <button onClick={() => setSelectedAsk(null)} style={{ background: 'none', color: 'var(--text-muted)' }}>
                <X size={20} />
              </button>
            </div>

            <p style={{ fontSize: '1.1rem', fontWeight: 500, color: 'var(--text-main)', marginBottom: '1.2rem' }}>
              "{selectedAsk.text}"
            </p>

            {/* Atomic Lock Warning Banner */}
            {(selectedAsk.status === 'locked' || selectedAsk.reply_count >= 5) && (
              <div style={{ background: 'rgba(245, 158, 11, 0.15)', color: '#fcd34d', border: '1px solid rgba(245, 158, 11, 0.3)', padding: '0.75rem', borderRadius: '10px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Lock size={18} />
                <span>This ask has reached the maximum 5 replies and is locked. No further replies accepted.</span>
              </div>
            )}

            {replyError && (
              <div style={{ background: 'rgba(239, 68, 68, 0.15)', color: '#fca5a5', border: '1px solid rgba(239, 68, 68, 0.3)', padding: '0.75rem', borderRadius: '10px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <AlertCircle size={18} />
                <span>{replyError}</span>
              </div>
            )}

            {/* List of Replies */}
            <div style={{ marginBottom: '1.5rem' }}>
              <h4 style={{ fontSize: '0.9rem', color: 'var(--text-muted)', marginBottom: '0.6rem' }}>
                Recorded Replies ({selectedAsk.replies?.length || 0}/5)
              </h4>

              {selectedAsk.replies?.length === 0 ? (
                <div style={{ fontSize: '0.85rem', color: 'var(--text-dim)', italic: 'true' }}>
                  No replies recorded yet.
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.6rem', maxHeight: '220px', overflowY: 'auto' }}>
                  {selectedAsk.replies?.map((rep) => (
                    <div key={rep.id} style={{ background: 'rgba(15,23,42,0.6)', border: '1px solid var(--border-color)', padding: '0.75rem', borderRadius: '10px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#a5b4fc', fontWeight: 600, marginBottom: '0.2rem' }}>
                        <span>@{rep.responder_username} ({rep.responder_display_name})</span>
                        <span style={{ color: 'var(--text-dim)', fontWeight: 400 }}>
                          {new Date(rep.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </span>
                      </div>
                      <div style={{ fontSize: '0.9rem', color: 'var(--text-main)' }}>{rep.text}</div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Reply Form */}
            {!selectedAsk.is_requester && selectedAsk.status === 'open' && selectedAsk.reply_count < 5 && (
              <form onSubmit={handleSendReply}>
                <div className="form-group" style={{ marginBottom: '0.8rem' }}>
                  <label className="form-label">Your Reply</label>
                  <input
                    type="text"
                    className="form-control"
                    placeholder="e.g. I can bring it right now to your table!"
                    value={replyText}
                    onChange={(e) => setReplyText(e.target.value)}
                    required
                  />
                </div>
                <button type="submit" className="btn-primary" style={{ width: '100%' }} disabled={replyLoading}>
                  {replyLoading ? 'Submitting Reply...' : 'Send Reply (Atomic 5-Lock)'}
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
