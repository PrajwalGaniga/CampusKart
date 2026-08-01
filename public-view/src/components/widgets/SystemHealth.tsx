import React from 'react';
import { SystemHealth as SystemHealthType } from '../../types';
import { Server, Database, Activity, Cpu } from 'lucide-react';
import styles from '../../pages/Dashboard.module.css';

interface SystemHealthProps {
  health: SystemHealthType;
}

export default function SystemHealth({ health }: SystemHealthProps) {
  const getStatusColor = (status: string) => {
    switch(status) {
      case 'connected': return '#16A34A';
      case 'connecting': return '#F59E0B';
      case 'error': return '#DC2626';
      default: return '#9CA3AF';
    }
  };

  const getStatusText = (status: string) => {
    switch(status) {
      case 'connected': return 'Operational';
      case 'connecting': return 'Connecting...';
      case 'error': return 'Degraded';
      default: return 'Unknown';
    }
  };

  return (
    <div className={styles.card} style={{ flex: 1, minWidth: '300px' }}>
      <h2 className={styles.cardTitle}>System Health</h2>
      
      <div className={styles.healthGrid}>
        <div className={styles.healthItem}>
          <div className={styles.healthIcon}>
            <Server size={20} />
          </div>
          <div className={styles.healthInfo}>
            <div className={styles.healthLabel}>API Server</div>
            <div className={styles.healthStatus}>
              <div className={styles.healthDot} style={{ backgroundColor: getStatusColor(health.backend) }} />
              {getStatusText(health.backend)}
            </div>
          </div>
        </div>

        <div className={styles.healthItem}>
          <div className={styles.healthIcon}>
            <Database size={20} />
          </div>
          <div className={styles.healthInfo}>
            <div className={styles.healthLabel}>MongoDB</div>
            <div className={styles.healthStatus}>
              <div className={styles.healthDot} style={{ backgroundColor: getStatusColor(health.mongo) }} />
              {getStatusText(health.mongo)}
            </div>
          </div>
        </div>

        <div className={styles.healthItem}>
          <div className={styles.healthIcon}>
            <Activity size={20} />
          </div>
          <div className={styles.healthInfo}>
            <div className={styles.healthLabel}>WebSocket Relay</div>
            <div className={styles.healthStatus}>
              <div className={styles.healthDot} style={{ backgroundColor: getStatusColor(health.websocket) }} />
              {getStatusText(health.websocket)}
            </div>
          </div>
        </div>

        <div className={styles.healthItem}>
          <div className={styles.healthIcon}>
            <Cpu size={20} />
          </div>
          <div className={styles.healthInfo}>
            <div className={styles.healthLabel}>Network Latency</div>
            <div className={styles.healthStatus}>
              <div className={styles.healthDot} style={{ backgroundColor: health.latency < 100 ? '#16A34A' : '#F59E0B' }} />
              {health.latency}ms
            </div>
          </div>
        </div>
      </div>
      
      {health.errorMsg && (
        <div style={{ marginTop: '1rem', padding: '0.75rem', backgroundColor: '#FEF2F2', color: '#991B1B', borderRadius: '6px', fontSize: '0.875rem', border: '1px solid #F87171' }}>
          <strong>Connection Error:</strong> {health.errorMsg}
          <br/>
          <small>Check if the backend is running and reachable.</small>
        </div>
      )}
    </div>
  );
}
