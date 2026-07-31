import React, { useEffect, useState } from 'react';
import ControlCenterLayout from '../components/layout/ControlCenterLayout';
import { Activity, Server, Database, Users, MessageSquare } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import styles from './Dashboard.module.css';
import { format } from 'date-fns';
import EventFlowVisualizer from '../components/EventFlowVisualizer';

interface Stats {
  open_asks: number;
  resolved_asks: number;
  locked_asks: number;
  expired_asks: number;
  online_users: number;
  total_events: number;
  average_response_time: string;
}

interface FeedEvent {
  id: string;
  type: string;
  message: string;
  time: Date;
}

export default function Dashboard() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [health, setHealth] = useState<any>(null);
  const [feed, setFeed] = useState<FeedEvent[]>([]);

  const fetchStats = async () => {
    try {
      const res = await fetch('http://127.0.0.1:8000/api/v1/public/stats');
      const data = await res.json();
      setStats(data);
    } catch (e) {
      console.error(e);
    }
  };

  const fetchHealth = async () => {
    try {
      const res = await fetch('http://127.0.0.1:8000/api/v1/public/health');
      const data = await res.json();
      setHealth(data);
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    fetchStats();
    fetchHealth();
    
    // Simulate real-time updates for now, ideally connect to WS
    const interval = setInterval(() => {
      fetchStats();
      fetchHealth();
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    // Connect to WebSocket for live feed
    const ws = new WebSocket('ws://127.0.0.1:8000/ws/public');
    
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.event === 'connected') {
        setFeed(prev => [{ id: Math.random().toString(), type: 'system', message: 'WebSocket Connected', time: new Date() }, ...prev].slice(0, 50));
      } else if (data.event === 'ask_created') {
        setFeed(prev => [{ id: data.data.ask_id, type: 'ask', message: 'New ask broadcasted to network', time: new Date() }, ...prev].slice(0, 50));
      } else if (data.event === 'ask_resolved') {
        setFeed(prev => [{ id: data.data.ask_id, type: 'resolve', message: 'An ask was resolved', time: new Date() }, ...prev].slice(0, 50));
      }
    };

    return () => ws.close();
  }, []);

  return (
    <ControlCenterLayout>
      <div className={styles.dashboardGrid}>
        
        {/* KPI Row */}
        <div className={styles.kpiRow}>
          <div className={styles.kpiCard}>
            <div className={styles.kpiLabel}>Online Users</div>
            <div className={styles.kpiValue}>{stats?.online_users || 0}</div>
          </div>
          <div className={styles.kpiCard}>
            <div className={styles.kpiLabel}>Active Asks</div>
            <div className={styles.kpiValue}>{stats?.open_asks || 0}</div>
          </div>
          <div className={styles.kpiCard}>
            <div className={styles.kpiLabel}>Resolved Today</div>
            <div className={styles.kpiValue}>{stats?.resolved_asks || 0}</div>
          </div>
          <div className={styles.kpiCard}>
            <div className={styles.kpiLabel}>Avg Response Time</div>
            <div className={styles.kpiValue}>{stats?.average_response_time || '0m'}</div>
          </div>
        </div>

        {/* Live Activity Feed */}
        <div className={`${styles.card} ${styles.activityFeed}`}>
          <div className={styles.cardHeader}>
            <Activity size={16} /> Live Activity Feed
          </div>
          <div className={styles.feedList}>
            <AnimatePresence initial={false}>
              {feed.map((item) => (
                <motion.div 
                  key={item.id}
                  className={styles.feedItem}
                  initial={{ opacity: 0, height: 0, y: -20 }}
                  animate={{ opacity: 1, height: 'auto', y: 0 }}
                  exit={{ opacity: 0, height: 0 }}
                >
                  <div className={styles.feedTime}>{format(item.time, 'HH:mm:ss')}</div>
                  <div className={styles.feedContent}>
                    <span style={{ color: item.type === 'system' ? 'var(--accent-warning)' : 'var(--text-primary)' }}>
                      {item.message}
                    </span>
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>
            {feed.length === 0 && (
              <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Waiting for events...</div>
            )}
          </div>
        </div>

        {/* System Monitor */}
        <div className={`${styles.card} ${styles.systemMonitor}`}>
          <div className={styles.cardHeader}>
            <Server size={16} /> System Health
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', marginTop: '1rem' }}>
            <StatusRow label="API Gateway (FastAPI)" status={health?.api_status} latency={health?.api_latency} />
            <StatusRow label="MongoDB Cluster" status={health?.db_status} />
            <StatusRow label="WebSocket Relay" status={health?.websocket_status} />
            <StatusRow label="Kubernetes Pods" status={health?.kubernetes_status} />
            <StatusRow label="Docker Engine" status={health?.docker_status} />
          </div>
        </div>

        {/* Event Flow Visualizer */}
        <EventFlowVisualizer />
        
      </div>
    </ControlCenterLayout>
  );
}

function StatusRow({ label, status, latency }: { label: string, status?: string, latency?: string }) {
  const isOperational = status === 'operational';
  
  return (
    <div className={styles.statusRow}>
      <div className={styles.statusLabel}>{label}</div>
      <div className={styles.statusValue}>
        {latency && <span style={{ color: 'var(--text-secondary)', fontSize: '0.75rem', marginRight: '0.5rem' }}>{latency}</span>}
        <div className={`${styles.dot} ${isOperational ? styles.dotOperational : styles.dotWarning}`} />
        <span style={{ color: isOperational ? 'var(--accent-success)' : 'var(--accent-warning)' }}>
          {isOperational ? 'Operational' : 'Connecting...'}
        </span>
      </div>
    </div>
  );
}
