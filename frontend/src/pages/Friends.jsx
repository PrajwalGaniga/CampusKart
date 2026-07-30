import React, { useState, useEffect } from 'react';
import { friendsApi } from '../api';
import { QRCodeModal } from '../components/QRCodeModal';
import { Users, UserPlus, QrCode, Search, Check, X, Clock, ShieldCheck, AlertCircle } from 'lucide-react';

export function Friends() {
  const [friends, setFriends] = useState([]);
  const [requests, setRequests] = useState({ received: [], sent: [] });
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchLoading, setSearchLoading] = useState(false);
  const [showQrModal, setShowQrModal] = useState(false);
  const [actionMsg, setActionMsg] = useState(null);
  const [error, setError] = useState(null);

  const loadData = async () => {
    try {
      const [fData, rData] = await Promise.all([
        friendsApi.getFriends(),
        friendsApi.getRequests(),
      ]);
      setFriends(fData);
      setRequests(rData);
    } catch (err) {
      console.error('Failed to load friends data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleSearch = async (e) => {
    e.preventDefault();
    if (!searchQuery.trim()) return;
    setSearchLoading(true);
    setError(null);
    try {
      const results = await friendsApi.search(searchQuery.trim());
      setSearchResults(results);
    } catch (err) {
      setError(err.message || 'Search failed');
    } finally {
      setSearchLoading(false);
    }
  };

  const handleSendRequest = async (userId) => {
    setActionMsg(null);
    setError(null);
    try {
      const res = await friendsApi.request(userId);
      setActionMsg(res.message);
      loadData();
      if (searchQuery) {
        const results = await friendsApi.search(searchQuery.trim());
        setSearchResults(results);
      }
    } catch (err) {
      setError(err.message);
    }
  };

  const handleAccept = async (requestId) => {
    setActionMsg(null);
    try {
      await friendsApi.accept(requestId);
      setActionMsg('Friend request accepted!');
      loadData();
    } catch (err) {
      setError(err.message);
    }
  };

  const handleReject = async (requestId) => {
    setActionMsg(null);
    try {
      await friendsApi.reject(requestId);
      setActionMsg('Friend request rejected');
      loadData();
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="container">
      {/* Top Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <Users color="#6366f1" size={28} /> Mutual Friends Network
          </h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.2rem' }}>
            Connect with campus friends. Asks are only visible to your mutual accepted friends.
          </p>
        </div>

        <button className="btn-primary" onClick={() => setShowQrModal(true)}>
          <QrCode size={18} />
          <span>In-App QR Code</span>
        </button>
      </div>

      {actionMsg && (
        <div style={{ background: 'rgba(16, 185, 129, 0.15)', color: '#6ee7b7', border: '1px solid rgba(16, 185, 129, 0.3)', padding: '0.75rem', borderRadius: '8px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Check size={16} />
          <span>{actionMsg}</span>
        </div>
      )}

      {error && (
        <div style={{ background: 'rgba(239, 68, 68, 0.15)', color: '#fca5a5', border: '1px solid rgba(239, 68, 68, 0.3)', padding: '0.75rem', borderRadius: '8px', marginBottom: '1.2rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <AlertCircle size={16} />
          <span>{error}</span>
        </div>
      )}

      {/* Search Friends Section */}
      <div className="glass-panel" style={{ padding: '1.5rem', marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '1.1rem', fontWeight: 600, marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Search size={18} color="#a5b4fc" /> Search Campus Users
        </h3>

        <form onSubmit={handleSearch} style={{ display: 'flex', gap: '0.6rem', marginBottom: '1rem' }}>
          <input
            type="text"
            className="form-control"
            placeholder="Search by username (e.g. bob, charlie)..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
          <button type="submit" className="btn-primary" disabled={searchLoading}>
            {searchLoading ? 'Searching...' : 'Search'}
          </button>
        </form>

        {searchResults.length > 0 && (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '0.8rem', marginTop: '1rem' }}>
            {searchResults.map((u) => (
              <div key={u.id} style={{ background: 'rgba(15,23,42,0.5)', border: '1px solid var(--border-color)', padding: '0.8rem 1rem', borderRadius: '12px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ fontWeight: 600, fontSize: '0.95rem' }}>{u.display_name}</div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>@{u.username}</div>
                </div>

                {u.status === 'friends' ? (
                  <span className="badge badge-open">Friends</span>
                ) : u.status === 'pending_sent' ? (
                  <span className="badge badge-locked">Sent</span>
                ) : u.status === 'pending_received' ? (
                  <span className="badge badge-resolved">Pending</span>
                ) : (
                  <button className="btn-secondary" style={{ padding: '0.35rem 0.7rem', fontSize: '0.8rem' }} onClick={() => handleSendRequest(u.id)}>
                    <UserPlus size={14} /> Add
                  </button>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Pending Requests Section */}
      {requests.received.length > 0 && (
        <div className="glass-panel" style={{ padding: '1.5rem', marginBottom: '2rem', borderColor: 'rgba(245, 158, 11, 0.3)' }}>
          <h3 style={{ fontSize: '1.1rem', fontWeight: 600, marginBottom: '1rem', color: '#fcd34d', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Clock size={18} /> Pending Friend Requests ({requests.received.length})
          </h3>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '1rem' }}>
            {requests.received.map((req) => (
              <div key={req.request_id} style={{ background: 'rgba(15,23,42,0.6)', border: '1px solid rgba(245, 158, 11, 0.2)', padding: '1rem', borderRadius: '12px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ fontWeight: 600 }}>{req.sender_display_name}</div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>@{req.sender_username}</div>
                </div>

                <div style={{ display: 'flex', gap: '0.4rem' }}>
                  <button className="btn-primary" style={{ padding: '0.35rem 0.7rem', fontSize: '0.8rem' }} onClick={() => handleAccept(req.request_id)}>
                    <Check size={14} /> Accept
                  </button>
                  <button className="btn-danger" style={{ padding: '0.35rem 0.7rem', fontSize: '0.8rem' }} onClick={() => handleReject(req.request_id)}>
                    <X size={14} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Mutual Friends List */}
      <div className="glass-panel" style={{ padding: '1.5rem' }}>
        <h3 style={{ fontSize: '1.1rem', fontWeight: 600, marginBottom: '1.2rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <ShieldCheck size={18} color="#10b981" /> Active Mutual Friends ({friends.length})
        </h3>

        {loading ? (
          <div style={{ padding: '1rem', color: 'var(--text-muted)' }}>Loading friends...</div>
        ) : friends.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-muted)' }}>
            No mutual friends added yet. Use the search bar above or scan a QR code to connect!
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: '1rem' }}>
            {friends.map((f) => (
              <div key={f.id} style={{ background: 'rgba(15,23,42,0.4)', border: '1px solid var(--border-color)', padding: '1rem', borderRadius: '14px', display: 'flex', alignItems: 'center', gap: '0.8rem' }}>
                <div style={{ width: '42px', height: '42px', borderRadius: '50%', background: 'linear-gradient(135deg, var(--primary), var(--secondary))', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, fontSize: '1.1rem', color: '#fff' }}>
                  {f.display_name.charAt(0).toUpperCase()}
                </div>
                <div>
                  <div style={{ fontWeight: 600, fontSize: '0.95rem' }}>{f.display_name}</div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>@{f.username}</div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {showQrModal && (
        <QRCodeModal onClose={() => setShowQrModal(false)} onSuccess={loadData} />
      )}
    </div>
  );
}
