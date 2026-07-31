import React from 'react';
import { Activity, LayoutDashboard, Network, Database } from 'lucide-react';
import styles from './ControlCenterLayout.module.css';

interface Props {
  children: React.ReactNode;
}

export default function ControlCenterLayout({ children }: Props) {
  return (
    <div className={styles.layout}>
      <aside className={styles.sidebar}>
        <div className={styles.logo}>C</div>
        <LayoutDashboard className={styles.navItem} size={20} />
        <Activity className={styles.navItem} size={20} />
        <Network className={styles.navItem} size={20} />
        <Database className={styles.navItem} size={20} />
      </aside>
      
      <main className={styles.main}>
        <header className={styles.header}>
          <div className={styles.headerTitle}>
            CampusPulse <span className={styles.badge}>Live</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
            <div style={{ width: 6, height: 6, borderRadius: '50%', backgroundColor: 'var(--accent-success)' }} />
            Connected to wss://campuspulse.internal
          </div>
        </header>
        
        <div className={styles.content}>
          {children}
        </div>
      </main>
    </div>
  );
}
