import React from 'react';
import { DashboardMetrics } from '../../types';
import { Users, MessageSquare, CheckCircle, Activity } from 'lucide-react';
import styles from '../../pages/Dashboard.module.css';

interface LiveMetricsProps {
  metrics: DashboardMetrics;
}

export default function LiveMetrics({ metrics }: LiveMetricsProps) {
  const cards = [
    { title: 'Registered Users', value: metrics.registeredUsers, icon: Users, color: '#3B82F6' },
    { title: 'Online Now', value: metrics.onlineUsers, icon: Activity, color: '#10B981' },
    { title: 'Open Asks', value: metrics.openAsks, icon: MessageSquare, color: '#F59E0B' },
    { title: 'Resolved Asks', value: metrics.resolvedAsks, icon: CheckCircle, color: '#8B5CF6' }
  ];

  return (
    <div className={styles.metricsGrid}>
      {cards.map((card, idx) => (
        <div key={idx} className={styles.metricCard}>
          <div className={styles.metricHeader}>
            <card.icon size={18} color={card.color} />
            {card.title}
          </div>
          <div className={styles.metricValue}>
            {card.value}
          </div>
        </div>
      ))}
    </div>
  );
}
