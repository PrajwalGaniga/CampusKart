import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { asksApi } from '../api';
import { Radio, Plus, MessageSquare, Send, CheckCircle, Clock, MapPin, Lock, AlertCircle, X, Users, Globe, ShieldCheck, Phone, Key, Navigation, Zap } from 'lucide-react';

export function Feed() {
  const { user } = useAuth();
  const [asks, setAsks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [wsConnected, setWsConnected] = useState(false);

  // New Ask Modal State
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [askText, setAskText] = useState('');
  const [locationTag, setLocationTag] = useState('Main Campus');
  const [visibility, setVisibility] = useState('friends');
  const [expiryMins, setExpiryMins] = useState(20);
  const [createLoading, setCreateLoading] = useState(false);
  const [createError, setCreateError] = useState(null);

  // Reply / Details Modal State
  const [selectedAsk, setSelectedAsk] = useState(null);
  const [replyText, setReplyText] = useState('');
  const [helperLocation, setHelperLocation] = useState('Library 1st Floor');
  const [etaMinutes, setEtaMinutes] = useState(2);
  const [replyLoading, setReplyLoading] = useState(false);
  const [replyError, setReplyError] = useState(null);
  const [actionSuccessMsg, setActionSuccessMsg] = useState(null);

  // PIN Verification Input & Handoff Action
  const [inputPin, setInputPin] = useState('');
  const [verifyLoading, setVerifyLoading] = useState(false);
  const [statusLoading, setStatusLoading] = useState(false);

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
        visibility: visibility,
        expiry_minutes: parseInt(expiryMins, 10) || 20,
      });

      setAsks((prev) => [newAsk, ...prev]);
      setShowCreateModal(false);
      setAskText('');
      setLocationTag('Main Campus');
      setVisibility('friends');
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
      await asksApi.replyToAsk(
        selectedAsk.id,
        replyText.trim(),
        helperLocation.trim() || 'Nearby',
        parseInt(etaMinutes, 10) || 2
      );
      setReplyText('');
      await loadFeed();
      setSelectedAsk(null);
    } catch (err) {
      setReplyError(err.message || 'Failed to send reply');
    } finally {
      setReplyLoading(false);
    }
  };

  const handleAcceptOffer = async (askId, replyId) => {
    setReplyError(null);
    setActionSuccessMsg(null);
    try {
      const res = await asksApi.acceptOffer(askId, replyId);
      setActionSuccessMsg(res.message);
      await loadFeed();
      const updatedList = await asksApi.getFeed();
      const match = updatedList.find((a) => a.id === askId);
      if (match) setSelectedAsk(match);
    } catch (err) {
      setReplyError(err.message || 'Failed to accept offer');
    }
  };

  const handleUpdateHandoffStatus = async (askId, newStatus) => {
    setStatusLoading(true);
    setReplyError(null);
    try {
      await asksApi.updateHandoffStatus(askId, newStatus);
      setActionSuccessMsg(`Handoff status updated to: ${newStatus.replace('_', ' ')}`);
      await loadFeed();
      const updatedList = await asksApi.getFeed();
      const match = updatedList.find((a) => a.id === askId);
      if (match) setSelectedAsk(match);
    } catch (err) {
      setReplyError(err.message || 'Failed to update handoff status');
    } finally {
      setStatusLoading(false);
    }
  };

  const handleVerifyPin = async (e) => {
    e.preventDefault();
    if (!inputPin.trim() || !selectedAsk) return;
    setVerifyLoading(true);
    setReplyError(null);
    try {
      await asksApi.verifyPin(selectedAsk.id, inputPin.trim());
      setActionSuccessMsg('Item handover verified & completed!');
      setInputPin('');
      await loadFeed();
      setSelectedAsk(null);
    } catch (err) {
      setReplyError(err.message || 'Invalid PIN');
    } finally {
      setVerifyLoading(false);
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
            <Radio color="#6366f1" size={28} /> Campus Help Feed
          </h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.2rem' }}>
            Broadcast requests with proximity location & live arrival tracking.
          </p>
        </div>

        <button className="btn-primary" onClick={() => setShowCreateModal(true)}>
          <Plus size={18} />
          <span>Post an Ask</span>
        </button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
          Loading campus requests...
        </div>
      ) : asks.length === 0 ? (
        <div className="glass-panel" style={{ padding: '3rem', textAlign: 'center' }}>
          <Radio size={44} color="#6366f1" style={{ margin: '0 auto 1rem auto', opacity: 0.5 }} />
          <h3 style={{ fontSize: '1.2rem', color: 'var(--text-muted)' }}>Your Campus Feed is Empty</h3>
          <p style={{ color: 'var(--text-dim)', fontSize: '0.88rem', marginTop: '0.3rem', maxWidth: '400px', margin: '0.3rem auto 1.2rem auto' }}>
            Post a campus help request or add mutual friends to start broadcasting!
          </p>
          <button className="btn-primary" onClick={() => setShowCreateModal(true)}>
            <Plus size={16} /> Post an Ask Now
          </button>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.2rem' }}>
          {asks.map((ask) => {
            const isClaimed = ask.status === 'claimed';
            const isCompleted = ask.status === 'completed';
            const isLocked = ask.status === 'locked' || ask.reply_count >= 5 || isClaimed || isCompleted;
            const isResolved = ask.status === 'resolved';
            const isExpired = ask.status === 'expired';

            return (
              <div key={ask.id} className="glass-panel" style={{ padding: '1.5rem', transition: 'transform 0.2s ease', borderColor: isClaimed ? 'rgba(16, 185, 129, 0.4)' : undefined }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '0.8rem', marginBottom: '0.8rem' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '0.3rem', flexWrap: 'wrap' }}>
                      <span style={{ fontWeight: 700, fontSize: '1.05rem' }}>
                        {ask.is_requester ? 'You' : ask.requester_display_name}
                      </span>
                      {!ask.is_requester && (
                        <span style={{ color: 'var(--text-dim)', fontSize: '0.85rem' }}>
                          @{ask.requester_username}
                        </span>
                      )}

                      {/* Scope Badge */}
                      <span className="badge" style={{ background: ask.visibility === 'public' ? 'rgba(236,72,153,0.15)' : 'rgba(99,102,241,0.15)', color: ask.visibility === 'public' ? '#f472b6' : '#a5b4fc', border: '1px solid rgba(255,255,255,0.1)' }}>
                        {ask.visibility === 'public' ? <Globe size={12} /> : <Users size={12} />}
                        {ask.visibility === 'public' ? 'Public Campus' : 'Friends Only'}
                      </span>

                      {/* Status Badge */}
                      <span className={`badge badge-${isClaimed ? 'open' : isCompleted ? 'resolved' : ask.status}`}>
                        {isCompleted ? (
                          <>
                            <ShieldCheck size={12} /> Completed
                          </>
                        ) : isClaimed ? (
                          <>
                            <CheckCircle size={12} /> {ask.handoff_status === 'arrived' ? 'Helper Arrived' : ask.handoff_status === 'en_route' ? 'Helper En-Route' : 'Offer Accepted'}
                          </>
                        ) : isResolved ? (
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
                  {ask.is_requester && !isResolved && !isCompleted && (
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

                {/* Card Footer / Actions */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '1rem', flexWrap: 'wrap', gap: '0.5rem' }}>
                  <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                    {isClaimed ? `Accepted Helper: ${ask.accepted_responder_name} (⚡ ${ask.accepted_responder_eta || 2}m away)` : ask.reply_count === 0 ? 'No offers yet' : `${ask.reply_count} / 5 offers recorded`}
                  </div>

                  <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button
                      className="btn-secondary"
                      style={{ padding: '0.45rem 0.9rem', fontSize: '0.85rem' }}
                      onClick={() => setSelectedAsk(ask)}
                    >
                      <MessageSquare size={14} />
                      <span>{ask.replies?.length ? `View Offers (${ask.replies.length})` : 'Offers'}</span>
                    </button>

                    {!ask.is_requester && !isLocked && !isResolved && !isExpired && (
                      <button
                        className="btn-primary"
                        style={{ padding: '0.45rem 0.9rem', fontSize: '0.85rem' }}
                        onClick={() => setSelectedAsk(ask)}
                      >
                        <Send size={14} /> Offer Help
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

              {/* Scope Selector */}
              <div className="form-group">
                <label className="form-label">Broadcast Audience</label>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.6rem' }}>
                  <div
                    onClick={() => setVisibility('friends')}
                    style={{
                      padding: '0.75rem',
                      borderRadius: '10px',
                      border: `1px solid ${visibility === 'friends' ? 'var(--primary)' : 'var(--border-color)'}`,
                      background: visibility === 'friends' ? 'rgba(99,102,241,0.15)' : 'rgba(15,23,42,0.4)',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.5rem',
                      fontSize: '0.85rem'
                    }}
                  >
                    <Users size={16} color={visibility === 'friends' ? '#a5b4fc' : 'var(--text-muted)'} />
                    <div>
                      <div style={{ fontWeight: 600, color: visibility === 'friends' ? '#fff' : 'var(--text-muted)' }}>Mutual Friends</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>Only your friends</div>
                    </div>
                  </div>

                  <div
                    onClick={() => setVisibility('public')}
                    style={{
                      padding: '0.75rem',
                      borderRadius: '10px',
                      border: `1px solid ${visibility === 'public' ? '#ec4899' : 'var(--border-color)'}`,
                      background: visibility === 'public' ? 'rgba(236,72,153,0.15)' : 'rgba(15,23,42,0.4)',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.5rem',
                      fontSize: '0.85rem'
                    }}
                  >
                    <Globe size={16} color={visibility === 'public' ? '#f472b6' : 'var(--text-muted)'} />
                    <div>
                      <div style={{ fontWeight: 600, color: visibility === 'public' ? '#fff' : 'var(--text-muted)' }}>All Campus Users</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>Broadcast to everyone</div>
                    </div>
                  </div>
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.8rem' }}>
                <div className="form-group">
                  <label className="form-label">Pickup Location Tag</label>
                  <input
                    type="text"
                    className="form-control"
                    placeholder="e.g. Block C Library Desk 12"
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
                  {createLoading ? 'Broadcasting...' : 'Broadcast Request'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* REPLY & OFFER DETAILS MODAL */}
      {selectedAsk && (
        <div className="modal-overlay" onClick={() => setSelectedAsk(null)}>
          <div className="modal-card" style={{ maxWidth: '580px' }} onClick={(e) => e.stopPropagation()}>
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

            {/* SAFE CAMPUS HANDOFF & LIVE TRACKER CARD */}
            {(selectedAsk.status === 'claimed' || selectedAsk.status === 'completed') && (
              <div style={{ background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.15), rgba(6, 95, 70, 0.3))', border: '1px solid rgba(16, 185, 129, 0.4)', padding: '1.2rem', borderRadius: '14px', marginBottom: '1.2rem' }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.8rem' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#6ee7b7', fontWeight: 700, fontSize: '1rem' }}>
                    <ShieldCheck size={20} />
                    <span>Live Handoff Tracker</span>
                  </div>

                  <span className="badge badge-open" style={{ fontSize: '0.75rem', textTransform: 'capitalize' }}>
                    {selectedAsk.handoff_status?.replace('_', ' ') || 'Accepted'}
                  </span>
                </div>

                {/* 4-Stage Tracker Progress */}
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.3rem', textAlign: 'center', marginBottom: '1rem' }}>
                  {['accepted', 'en_route', 'arrived', 'completed'].map((stg, idx) => {
                    const stages = ['accepted', 'en_route', 'arrived', 'completed'];
                    const currentIdx = stages.indexOf(selectedAsk.handoff_status || 'accepted');
                    const isActive = idx <= currentIdx;

                    return (
                      <div key={stg} style={{ padding: '0.4rem 0.2rem', background: isActive ? 'rgba(16, 185, 129, 0.3)' : 'rgba(255,255,255,0.05)', borderRadius: '6px', border: `1px solid ${isActive ? '#10b981' : 'transparent'}`, fontSize: '0.7rem', color: isActive ? '#fff' : 'var(--text-dim)', fontWeight: isActive ? 600 : 400 }}>
                        {idx + 1}. {stg === 'accepted' ? 'Accepted' : stg === 'en_route' ? 'En-Route' : stg === 'arrived' ? 'Arrived' : 'Complete'}
                      </div>
                    );
                  })}
                </div>

                <div style={{ fontSize: '0.88rem', color: '#d1fae5', display: 'flex', flexDirection: 'column', gap: '0.4rem' }}>
                  <div>📍 <strong>Pickup Landmark:</strong> {selectedAsk.location_tag}</div>
                  <div>👤 <strong>Accepted Helper:</strong> {selectedAsk.accepted_responder_name || 'Friend'} {selectedAsk.accepted_responder_phone && `(${selectedAsk.accepted_responder_phone})`}</div>
                  <div>⚡ <strong>Helper Distance / Location:</strong> {selectedAsk.accepted_responder_location || 'Nearby'} ({selectedAsk.accepted_responder_eta || 2} mins away)</div>

                  {/* Handover PIN Display */}
                  {selectedAsk.handover_pin && (
                    <div style={{ background: 'rgba(0,0,0,0.3)', padding: '0.8rem', borderRadius: '10px', marginTop: '0.6rem', textAlign: 'center' }}>
                      <div style={{ fontSize: '0.78rem', color: '#a7f3d0', textTransform: 'uppercase', letterSpacing: '0.05em' }}>4-Digit Handover Verification PIN</div>
                      <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#fff', letterSpacing: '0.2em', fontFamily: 'monospace' }}>
                        {selectedAsk.handover_pin}
                      </div>
                    </div>
                  )}
                </div>

                {/* Helper Controls (I'm On My Way / Arrived) */}
                {!selectedAsk.is_requester && selectedAsk.status === 'claimed' && (
                  <div style={{ display: 'flex', gap: '0.5rem', marginTop: '1rem' }}>
                    <button
                      className="btn-secondary"
                      style={{ flex: 1, padding: '0.5rem', fontSize: '0.8rem', background: selectedAsk.handoff_status === 'en_route' ? 'rgba(99,102,241,0.3)' : undefined }}
                      onClick={() => handleUpdateHandoffStatus(selectedAsk.id, 'en_route')}
                      disabled={statusLoading}
                    >
                      <Navigation size={14} /> 🏃 I'm On My Way
                    </button>
                    <button
                      className="btn-primary"
                      style={{ flex: 1, padding: '0.5rem', fontSize: '0.8rem' }}
                      onClick={() => handleUpdateHandoffStatus(selectedAsk.id, 'arrived')}
                      disabled={statusLoading}
                    >
                      <MapPin size={14} /> 📍 I Have Arrived
                    </button>
                  </div>
                )}

                {/* Requester PIN Verification */}
                {selectedAsk.is_requester && selectedAsk.status === 'claimed' && (
                  <form onSubmit={handleVerifyPin} style={{ marginTop: '1rem', display: 'flex', gap: '0.5rem' }}>
                    <input
                      type="text"
                      className="form-control"
                      placeholder="Enter 4-digit PIN when meeting..."
                      maxLength={4}
                      value={inputPin}
                      onChange={(e) => setInputPin(e.target.value)}
                    />
                    <button type="submit" className="btn-primary" disabled={verifyLoading} style={{ whiteSpace: 'nowrap' }}>
                      {verifyLoading ? 'Verifying...' : 'Confirm Pickup'}
                    </button>
                  </form>
                )}
              </div>
            )}

            {/* Lock Warning */}
            {(selectedAsk.status === 'locked' || selectedAsk.reply_count >= 5) && selectedAsk.status !== 'claimed' && selectedAsk.status !== 'completed' && (
              <div style={{ background: 'rgba(245, 158, 11, 0.15)', color: '#fcd34d', border: '1px solid rgba(245, 158, 11, 0.3)', padding: '0.75rem', borderRadius: '10px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Lock size={18} />
                <span>This ask has reached the 5-reply limit and is locked against further offers.</span>
              </div>
            )}

            {actionSuccessMsg && (
              <div style={{ background: 'rgba(16, 185, 129, 0.15)', color: '#6ee7b7', border: '1px solid rgba(16, 185, 129, 0.3)', padding: '0.75rem', borderRadius: '10px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <CheckCircle size={18} />
                <span>{actionSuccessMsg}</span>
              </div>
            )}

            {replyError && (
              <div style={{ background: 'rgba(239, 68, 68, 0.15)', color: '#fca5a5', border: '1px solid rgba(239, 68, 68, 0.3)', padding: '0.75rem', borderRadius: '10px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <AlertCircle size={18} />
                <span>{replyError}</span>
              </div>
            )}

            {/* OFFERS LIST WITH PROXIMITY & ETA BADGES */}
            <div style={{ marginBottom: '1.5rem' }}>
              <h4 style={{ fontSize: '0.9rem', color: 'var(--text-muted)', marginBottom: '0.6rem' }}>
                Incoming Offers ({selectedAsk.replies?.length || 0}/5)
              </h4>

              {selectedAsk.replies?.length === 0 ? (
                <div style={{ fontSize: '0.85rem', color: 'var(--text-dim)', fontStyle: 'italic' }}>
                  No offers recorded yet.
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.6rem', maxHeight: '240px', overflowY: 'auto' }}>
                  {selectedAsk.replies?.map((rep) => (
                    <div key={rep.id} style={{ background: rep.is_accepted ? 'rgba(16, 185, 129, 0.12)' : 'rgba(15,23,42,0.6)', border: `1px solid ${rep.is_accepted ? 'rgba(16, 185, 129, 0.4)' : 'var(--border-color)'}`, padding: '0.8rem', borderRadius: '10px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.3rem', flexWrap: 'wrap', gap: '0.4rem' }}>
                        <div>
                          <span style={{ fontSize: '0.85rem', color: '#a5b4fc', fontWeight: 600, marginRight: '0.5rem' }}>
                            @{rep.responder_username} ({rep.responder_display_name})
                          </span>

                          {/* Helper Proximity & ETA Badge */}
                          <span className="badge" style={{ background: 'rgba(99,102,241,0.2)', color: '#c084fc', border: '1px solid rgba(99,102,241,0.3)', fontSize: '0.72rem' }}>
                            <Zap size={10} /> {rep.eta_minutes || 2}m away • {rep.helper_location || 'Nearby'}
                          </span>
                        </div>

                        {/* Accept Offer Button */}
                        {selectedAsk.is_requester && selectedAsk.status !== 'claimed' && selectedAsk.status !== 'completed' && selectedAsk.status !== 'resolved' && (
                          <button
                            className="btn-primary"
                            style={{ padding: '0.25rem 0.6rem', fontSize: '0.78rem', background: 'linear-gradient(135deg, #10b981, #059669)' }}
                            onClick={() => handleAcceptOffer(selectedAsk.id, rep.id)}
                          >
                            <CheckCircle size={12} /> Accept Offer
                          </button>
                        )}

                        {rep.is_accepted && (
                          <span className="badge badge-open" style={{ fontSize: '0.7rem' }}>
                            Accepted Offer
                          </span>
                        )}
                      </div>
                      <div style={{ fontSize: '0.92rem', color: 'var(--text-main)' }}>{rep.text}</div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* REPLY FORM WITH PROXIMITY INPUT & ETA SELECTOR */}
            {!selectedAsk.is_requester && selectedAsk.status === 'open' && selectedAsk.reply_count < 5 && (
              <form onSubmit={handleSendReply}>
                <div className="form-group" style={{ marginBottom: '0.8rem' }}>
                  <label className="form-label">Your Help Offer Details</label>
                  <input
                    type="text"
                    className="form-control"
                    placeholder="e.g. I have an extra charger! I can meet you right now."
                    value={replyText}
                    onChange={(e) => setReplyText(e.target.value)}
                    required
                  />
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.6rem', marginBottom: '0.8rem' }}>
                  <div className="form-group" style={{ marginBottom: 0 }}>
                    <label className="form-label">Your Current Location</label>
                    <input
                      type="text"
                      className="form-control"
                      placeholder="e.g. Library 1st Floor"
                      value={helperLocation}
                      onChange={(e) => setHelperLocation(e.target.value)}
                    />
                  </div>

                  <div className="form-group" style={{ marginBottom: 0 }}>
                    <label className="form-label">Estimated Arrival Time (ETA)</label>
                    <select
                      className="form-control"
                      value={etaMinutes}
                      onChange={(e) => setEtaMinutes(e.target.value)}
                    >
                      <option value={1}>⚡ Instant (&lt; 1 min)</option>
                      <option value={2}>🏃 2 mins away</option>
                      <option value={5}>🚶 5 mins away</option>
                      <option value={10}>🚲 10 mins away</option>
                    </select>
                  </div>
                </div>

                {/* Quick Location Preset Chips */}
                <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap', marginBottom: '1rem' }}>
                  <button type="button" className="btn-secondary" style={{ padding: '0.2rem 0.5rem', fontSize: '0.75rem' }} onClick={() => setHelperLocation('Right Next to You')}>
                    ⚡ Right Next to You
                  </button>
                  <button type="button" className="btn-secondary" style={{ padding: '0.2rem 0.5rem', fontSize: '0.75rem' }} onClick={() => setHelperLocation('Library 1st Floor')}>
                    📚 Library
                  </button>
                  <button type="button" className="btn-secondary" style={{ padding: '0.2rem 0.5rem', fontSize: '0.75rem' }} onClick={() => setHelperLocation('Block A Canteen')}>
                    ☕ Canteen
                  </button>
                  <button type="button" className="btn-secondary" style={{ padding: '0.2rem 0.5rem', fontSize: '0.75rem' }} onClick={() => setHelperLocation('Hostel Gate')}>
                    🏢 Hostel Gate
                  </button>
                </div>

                <button type="submit" className="btn-primary" style={{ width: '100%' }} disabled={replyLoading}>
                  {replyLoading ? 'Submitting Offer...' : 'Send Help Offer (With Location & ETA)'}
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
