import React, { useState, useEffect } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { friendsApi } from '../api';
import { X, QrCode, Check, AlertCircle } from 'lucide-react';

export function QRCodeModal({ onClose, onSuccess }) {
  const [qrData, setQrData] = useState(null);
  const [scanCode, setScanCode] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [error, setError] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);

  useEffect(() => {
    async function loadQr() {
      try {
        const data = await friendsApi.getQr();
        setQrData(data);
      } catch (err) {
        setError('Failed to generate QR Code');
      } finally {
        setLoading(false);
      }
    }
    loadQr();
  }, []);

  const handleScanSubmit = async (e) => {
    e.preventDefault();
    if (!scanCode.trim()) return;
    setSubmitLoading(true);
    setError(null);
    setSuccessMsg(null);

    try {
      const res = await friendsApi.addByQr(scanCode.trim());
      setSuccessMsg(res.message || 'Friend added successfully!');
      setScanCode('');
      if (onSuccess) onSuccess();
    } catch (err) {
      setError(err.message || 'Failed to add friend via QR');
    } finally {
      setSubmitLoading(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.2rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <QrCode className="text-primary" size={24} color="#6366f1" />
            <h3 style={{ fontSize: '1.2rem', fontWeight: 700 }}>In-App QR Code</h3>
          </div>
          <button onClick={onClose} style={{ background: 'none', color: 'var(--text-muted)' }}>
            <X size={20} />
          </button>
        </div>

        {error && (
          <div style={{ background: 'rgba(239, 68, 68, 0.15)', color: '#fca5a5', border: '1px solid rgba(239, 68, 68, 0.3)', padding: '0.6rem 0.8rem', borderRadius: '8px', marginBottom: '1rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
            <AlertCircle size={16} />
            <span>{error}</span>
          </div>
        )}

        {successMsg && (
          <div style={{ background: 'rgba(16, 185, 129, 0.15)', color: '#6ee7b7', border: '1px solid rgba(16, 185, 129, 0.3)', padding: '0.6rem 0.8rem', borderRadius: '8px', marginBottom: '1rem', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
            <Check size={16} />
            <span>{successMsg}</span>
          </div>
        )}

        {loading ? (
          <div style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-muted)' }}>Generating QR Code...</div>
        ) : (
          <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
            <div style={{ background: '#ffffff', padding: '1rem', borderRadius: '16px', display: 'inline-block', boxShadow: '0 8px 24px rgba(0,0,0,0.4)' }}>
              {qrData?.qr_payload && <QRCodeSVG value={qrData.qr_payload} size={180} />}
            </div>
            <p style={{ marginTop: '0.8rem', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
              Have your friend scan this QR or share payload:
            </p>
            <code style={{ background: 'rgba(0,0,0,0.3)', padding: '0.2rem 0.6rem', borderRadius: '4px', fontSize: '0.8rem', color: '#a5b4fc', wordBreak: 'break-all' }}>
              {qrData?.qr_payload}
            </code>
          </div>
        )}

        <hr style={{ borderColor: 'var(--border-color)', margin: '1.2rem 0' }} />

        <form onSubmit={handleScanSubmit}>
          <label className="form-label">Scan or Paste Friend's QR Code Payload</label>
          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <input
              type="text"
              className="form-control"
              placeholder="e.g. campusask:user:bob"
              value={scanCode}
              onChange={(e) => setScanCode(e.target.value)}
            />
            <button type="submit" className="btn-primary" disabled={submitLoading} style={{ whiteSpace: 'nowrap' }}>
              {submitLoading ? 'Adding...' : 'Connect'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
